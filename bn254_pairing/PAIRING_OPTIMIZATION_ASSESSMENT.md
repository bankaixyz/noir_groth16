## BN254 Pairing Optimization Assessment (Noir vs gnark)

### Context and goal

This repo implements BN254 pairing in Noir (`noir_bn254_pairing`) and uses it in Groth16 verification (`groth16_verify`). You reported that pairing-heavy circuits are costing significantly more constraints than expected, while gnark achieves ~600k constraints for a single pairing in its benchmark note.

This document assesses the optimizations listed in `bn254_pairing/PAIRING_PERF.md` against the current Noir implementation, focusing on the highest-impact path for your main use-case:

- **You only need a boolean check** (“pairing equation holds”), not the GT/Fp12 output for downstream arithmetic.
- **Most G2 points are fixed constants** (verification key points), not prover-controlled.

### Code locations (current implementation)

- **Pairing + Miller loop + final exponentiation**: `bn254_pairing/src/pairing.nr`
- **Fp12 operations (sparse muls, cyclotomic sq, Frobenius, expt chain)**: `bn254_pairing/src/fp12.nr`
- **G2 arithmetic + line generation used by Miller loop**: `bn254_pairing/src/g2.nr`
- **Groth16 usage pattern (3 pairings; 2 fixed G2 VK points)**: `groth16_verify/src/verify.nr`

### What is already implemented in this repo (important baseline)

Before discussing “should we implement X?”, it’s crucial to note that several gnark-style optimizations are **already present** in this Noir codebase:

- **Signed NAF loop counter**: `loop_counter()` in `bn254_pairing/src/pairing.nr` is used in the Miller loop and already reduces the number of mixed-add steps.
- **Sparse line-element multiplication in Fp12**:
  - `Fp12.mul_by_034`, `Fp12.mul_by_01234` and helper `mul_034_by_034` exist in `bn254_pairing/src/fp12.nr`.
  - These are used throughout `miller_loop` in `bn254_pairing/src/pairing.nr`.
- **Optimized final exponentiation (easy + hard)**:
  - `final_exp_easy_part`, `final_exp_hard_part`, and `final_exponentiation` are in `bn254_pairing/src/pairing.nr`.
  - Hard part uses cyclotomic operations and a fixed chain: `Fp12.cyclotomic_square` and `Fp12.expt` in `bn254_pairing/src/fp12.nr`.
- **Multi-pairing Miller loop**: `miller_loop<let N: u32>` evaluates all pairs together and amortizes squarings (this is already the right shape for Groth16’s 3-pairing check).

Given that, the biggest deltas vs the gnark optimization list are not “do we have sparse mul / NAF / optimized final exp” (you do), but:

- **Precomputed G2 lines for fixed Q** (currently missing)
- **A PairingCheck-style shortcut for boolean checks** (currently missing)

---

## Optimization 1) Precomputed G2 line evaluations (big impact)

### What it is

In the Miller loop, each iteration needs line function coefficients for doubling/addition on the **G2** point \(Q\). Computing those coefficients in-circuit is expensive because it is dominated by non-native field arithmetic in \( \mathbb{F}_{p^2} \) and projective-coordinate formulas.

The optimization: when \(Q\) is **fixed/constant**, compute *all required line coefficients* off-circuit once, and embed them as constants (or trusted witness data) so the circuit only:

- evaluates those lines at \(P\) (cheap scalar multiplies / additions),
- and performs sparse multiplications in \( \mathbb{F}_{p^{12}} \).

In gnark terms (from your perf note): `NewG2AffineFixed` + `NewG2AffineFixedPlaceholder` moves the G2 “line computation” outside the circuit.

### Where it would land in this repo

Current behavior (in-circuit line computation):

- Lines are generated inside `G2Proj.double_step`, `G2Proj.add_mixed_step`, and `G2Proj.line_compute` in `bn254_pairing/src/g2.nr`.
- `bn254_pairing/src/pairing.nr` calls those in `miller_loop`, for every pair and for every iteration.

To precompute G2 lines, you would introduce a “fixed-Q” representation (conceptually):

- `G2AffineFixed` that carries:
  - the original affine point \(Q\), and
  - a fixed schedule of `LineEvaluation` coefficients for:
    - initial setup,
    - each NAF iteration: doubling line and (when digit ≠ 0) addition line,
    - final Frobenius-related steps.

Then add a `miller_loop_fixed_q` (or a hybrid that accepts a mix of fixed and variable Q’s) that consumes these precomputed line evaluations and **skips** `double_step` / `add_mixed_step` arithmetic for those indices.

### Why it is sound

- **When Q is a true constant** (VK points embedded in circuit): this is purely a refactoring. You are not changing the algebra; you are changing *where* line coefficients are computed (off-circuit once vs in-circuit every proof).
- **Soundness requirement**: the prover must not be able to choose these line coefficients freely. So:
  - Safe: line coefficients are hardcoded constants (or derived deterministically from hardcoded constants).
  - Unsafe: line coefficients are supplied as witness inputs without constraints tying them to \(Q\) (that would let a prover “fake” the Miller loop).
- For Groth16 verification, this is a great fit because VK points are trusted constants and should not be prover-controlled.

### Expected constraint savings (what to expect here)

From `PAIRING_PERF.md` (gnark):

- No precomputed G2 lines: **607,721** constraints
- With precomputed G2 lines: **544,547** constraints
- Delta: **63,174** constraints (~**10.4%**)

For this Noir repo, exact numbers will differ (Noir’s `bignum` gadget cost differs from gnark’s emulated-field cost), but the direction and scaling are the same: this optimization removes “G2-side line coefficient arithmetic”.

Conservative expectations:

- **Per pairing with fixed Q**: likely **~5–15%** reduction of the full pairing cost (bigger if your G2 formulas are a larger share of your total).
- **Groth16 verify pattern (3 pairings; 2 fixed Q’s)**:
  - Roughly scales with how many Q’s are fixed: expect **~3–10%** reduction of the pairing portion if you still compute a full final exponentiation at the end.
  - If you also implement the PairingCheck shortcut (Optimization 6), absolute savings from fixed lines remain, but the *percentage* may shift depending on how much final exponentiation you removed.

---

## Optimization 2) Sparse Fp12 multiplications in the Miller loop

### What it is

Line evaluations in BN pairings correspond to **sparse** elements of \( \mathbb{F}_{p^{12}} \). Instead of multiplying by a dense Fp12 element each time, you multiply by a special form where only a few coefficients are non-zero.

This reduces the number of base-field multiplications per Miller iteration, which is one of the biggest levers in pairing circuits.

### Current state in this repo

This optimization is **already implemented** and used:

- In `bn254_pairing/src/fp12.nr`:
  - `Fp12.mul_by_034` (line element with non-zero slots 0,3,4)
  - `mul_034_by_034` (multiply two sparse line elements into 5-slot form)
  - `Fp12.mul_by_01234` (multiply by an element with non-zero slots 0..4)
- In `bn254_pairing/src/pairing.nr`:
  - `miller_loop` uses these functions throughout (including fusing two lines into one `mul_by_01234` call).

### Why it is sound

It is a pure arithmetic identity: you are computing the same product in \( \mathbb{F}_{p^{12}} \) with fewer multiplications by exploiting known zeros in the representation.

### Expected constraint savings

Because it is already applied, **there is no “new” savings** to capture by “implementing it” again. The remaining opportunity is only:

- making sure you never fall back to a dense multiply when a sparse multiply is valid, and
- possibly adding additional specialized sparse cases if your line representation admits them.

If you discovered any dense `Fp12.mul` in the Miller loop path, migrating it to a sparse multiply could yield a noticeable win. As written today, the Miller loop path is already using sparse multipliers.

---

## Optimization 3) Cached inversions and reuse of line scalars

### What it is (gnark’s version)

gnark precomputes, per G1 point \(P=(x,y)\):

- \(y^{-1}\)
- \(-x/y\)

and reuses them across all line evaluations. This reduces repeated inversions and multiplications if the chosen line representation involves dividing by \(y\) (or otherwise benefits from normalizing by \(y\)).

### Current state in this repo

Your Miller loop currently evaluates a line at an affine G1 point with:

- `line_eval_at_point(line, p)` in `bn254_pairing/src/pairing.nr`
  - multiplies `line.r0` by `p.y` and `line.r1` by `p.x`
  - does **not** compute any inversions of `p.y`

So the direct “cache yInv once” optimization does **not** map 1:1. There is no repeated inversion to eliminate in the current formulation.

### Does it make sense to implement here?

It depends on whether you change the line representation.

- **If you keep today’s line evaluation form** (multiply by \(x\) and \(y\) each time): caching inversions won’t help; there are none.
- **If you refactor to a normalized-by-\(y\)** representation (or another representation where \(1/y\) is needed repeatedly), then caching could matter. But in a non-native field circuit, inversions are expensive; introducing an inversion just to then cache it is often a net loss unless it enables other bigger simplifications (e.g., omitting denominators/vertical lines safely).

### Soundness considerations

If you ever introduce \(1/y\) in-circuit:

- You must ensure you never invert 0. In BN254 G1, points with \(y=0\) are not in the prime-order subgroup (they would be 2-torsion), but you still need either a subgroup guarantee or a circuit assertion to exclude the edge case.

### Expected constraint savings

Conservative expectation **in this repo as-written**:

- **Low / possibly negative** (0–3% at best) unless paired with a more substantial line-representation change.

---

## Optimization 4) Signed NAF loop counter for the optimal Ate loop

### What it is

Use a signed non-adjacent form of the BN parameter to reduce non-zero digits, which reduces the number of G2 additions (and line evaluations) versus a binary loop.

### Current state in this repo

Already implemented:

- `loop_counter() -> [i8; 66]` in `bn254_pairing/src/pairing.nr`
- `miller_loop` uses those digits and chooses:
  - `add_mixed_step(q)` for digit `+1`
  - `add_mixed_step(q_neg)` for digit `-1`
  - no add step for digit `0`

### Why it is sound

NAF is just another addition chain for the same scalar; it computes the same Miller loop exponent with fewer non-zero steps.

### Expected constraint savings

Already realized in the current design. Any additional savings would require more aggressive windowing (e.g., wNAF), but that typically introduces precomputed multiples and extra logic that may not pay off in-circuit.

---

## Optimization 5) Optimized final exponentiation (for full `Pair`)

### What it is

Compute \( f^{(p^{12}-1)/r} \) via:

- **Easy part**: conjugations, inversion, and Frobenius maps
- **Hard part**: cyclotomic squaring + a fixed addition chain tailored to BN254

This avoids generic exponentiation in \( \mathbb{F}_{p^{12}} \), which would be far more expensive.

### Current state in this repo

Already implemented:

- Easy part: `final_exp_easy_part` in `bn254_pairing/src/pairing.nr`
- Hard part: `final_exp_hard_part` in `bn254_pairing/src/pairing.nr` using:
  - `Fp12.cyclotomic_square()` and `Fp12.expt()` from `bn254_pairing/src/fp12.nr`
  - Frobenius variants: `Fp12.frobenius`, `.frobenius_square`, `.frobenius_cube`

### Why it is sound

These are standard BN final-exponentiation decompositions. Assuming your field arithmetic is correct (including inverses), this is fully sound and produces a correct GT element.

### Expected constraint savings (remaining opportunity)

Because this is already in place, the remaining improvements here are “next-level”:

- **Torus / compressed cyclotomic representation** (working in \( \mathbb{F}_{p^6} \) for part of the hard exponentiation) can reduce constraints further, but it is a more complex refactor.
- Additional micro-optimizations can come from more specialized multipliers if some factors in the chain are sparse or have special structure.

Conservative expectation if you invest in torus-style final exponentiation optimizations:

- **~5–20%** reduction of the final exponentiation portion, which could translate to **~2–10%** on a full pairing, depending on your Miller/FE split.

---

## Optimization 6) PairingCheck shortcut (boolean checks; avoid full `Pair`)

### What it is (and why it matters most for you)

If the application needs to assert an equation of the form:

\[
\prod_i e(P_i, Q_i) = 1
\]

you do **not** need to output a GT element. In gnark, `PairingCheck` avoids computing the full final exponentiation and instead performs a cheaper “final exponentiation is one” verification aided by a hint (`pairingCheckHint`) plus constrained consistency checks (`AssertFinalExponentiationIsOne`).

Given your stated goal (“boolean check only”) this is the single most promising optimization if it can be implemented soundly in Noir.

### How it maps to this repo

Today, Groth16 verify does:

- compute `result = pairing_multi([...])` (which includes `final_exponentiation`)
- compare `result` to a constant `vk.alpha_beta`

See `groth16_verify/src/verify.nr` (uses `pairing_multi` from `bn254_pairing/src/pairing.nr`).

A PairingCheck-style flow would instead:

- compute only the **multi Miller loop accumulator** `f = miller_loop([...])`
- then run a specialized check that the final exponentiation of `f` is the identity (or reduces the check to a cheaper condition), without computing the full GT output.

### Turning Groth16 “equals constant” into a “equals 1” check

There are two practical ways to use a PairingCheck-style API for Groth16:

- **Option A (pairing-based)**: store \( \alpha \in G1 \) and \( \beta \in G2 \) in the VK (instead of only `alpha_beta`), and check:
  - \( e(A,B)\cdot e(C,-\delta)\cdot e(L,-\gamma)\cdot e(-\alpha,\beta) = 1 \)
  - This is 4 pairings, but the extra pairing is fully constant and is a good target for “fixed-Q lines” (Optimization 1) or even more aggressive constant folding.
- **Option B (Fp12 preimage)**: precompute a constant \(t \in \mathbb{F}_{p^{12}}\) such that:
  - `final_exponentiation(t) == vk.alpha_beta^{-1}`
  - Then check that `final_exponentiation(miller_product * t) == 1` using the PairingCheck routine.
  - This keeps the pairing count at 3, but requires an offline one-time precomputation per VK.

### Soundness considerations (critical)

Because PairingCheck typically uses “hint-like” witness values to avoid a full exponentiation, **soundness hinges on the constrained checks**:

- Any hint/unconstrained value must be tied back to the constrained computation by algebraic relations.
- You must keep all necessary curve validity checks for variable points:
  - G1 on-curve and non-infinity (already enforced in `groth16_verify/src/verify.nr`)
  - G2 on-curve + subgroup check for prover-controlled G2 points (already enforced for `proof.b`)
- For fixed VK points, you can treat them as trusted constants and skip subgroup checks (they are part of the trusted setup/VK).

### Expected constraint savings

This is the **highest expected ROI** optimization in your specific setting.

Rule-of-thumb (across many pairing circuit implementations):

- Full pairing cost is typically “Miller loop + final exponentiation”.
- Final exponentiation is often a very large fraction of the total (commonly **~40–60%**).

So, if PairingCheck can avoid most of the full final exponentiation work, conservative expectations are:

- **Single pairing**: **~25–55%** reduction versus `pairing(...)` (depends on how much of FE you avoid and how expensive the replacement checks are).
- **Groth16 (3 pairings)**:
  - If you can keep 3 pairings (Option B), you should expect roughly the same proportional reduction on the pairing portion.
  - If you add a 4th fully-constant pairing (Option A), Miller-loop work increases, but FE avoidance can still dominate; fixed-line precompute mitigates the extra pairing cost.

In other words: this is the most plausible path to “close the gap” to gnark-style constraint counts for verification circuits, because it targets the dominant cost center you currently pay in `pairing_multi`: the full final exponentiation.

---

## Practical recommendations (prioritized for your use-case)

### 1) Implement fixed-Q line precomputations for VK points

- Target the Groth16 pattern in `groth16_verify/src/verify.nr`:
  - `vk.delta_neg` and `vk.gamma_neg` are constant \(Q\)’s.
- Implement a hybrid multi-miller-loop that accepts a mix of:
  - variable `G2Affine` (current path)
  - fixed/precomputed-line `G2AffineFixed` (new path)

This is a clean win with minimal cryptographic risk when applied only to constants.

### 2) Add a PairingCheck-style API for boolean checks

Because you only need boolean checks, this is likely your biggest single lever.

Suggested library-level API (conceptual):

- `pairing_check<let N: u32>(p_list: [G1Affine; N], q_list: [G2Affine; N]) -> bool`

and/or:

- `pairing_check_with_constant_preimage(f: Fp12, t: Fp12) -> bool` (Option B wiring)

Then adapt Groth16 verification to use it.

### 3) Only after those: consider deeper final-exponentiation refactors

You already have an optimized FE chain. Further FE improvements (torus compression) can help, but are higher-effort and lower-certainty than the two items above.

---

## How to validate and quantify savings (recommended measurement approach)

To make constraint savings concrete in Noir, measure at three layers:

- **Layer A (baseline)**: current `pairing_multi` cost in your target circuit.
- **Layer B (Miller-only)**: replace `pairing_multi` with `miller_loop` only and measure the delta; this approximates “how much FE costs you today”.
- **Layer C (optimized variants)**:
  - fixed-Q lines enabled for VK points
  - PairingCheck-enabled path (with the same input validity checks)

This gives you an empirical cost breakdown and quickly tells you whether the cost is dominated by:

- G2 line computation,
- sparse Fp12 muls (unlikely, since already optimized),
- or final exponentiation.

---

## Bottom line (high-signal takeaways)

- **Already implemented**: signed NAF Miller loop, sparse Fp12 line multipliers, and an optimized final exponentiation chain.
- **Most promising new optimizations for you**:
  - **Precompute G2 lines for fixed VK points** (expect ~3–10% savings in Groth16’s 3-pairing pattern).
  - **PairingCheck-style boolean verification** that avoids full final exponentiation (expect ~25–55% savings on the pairing portion, depending on how much FE you can remove and what the replacement checks cost).
