# Randomized Fp12 Checks Spec (Medium Approach)

Status: Draft

## Summary
This spec proposes a medium-scope optimization: replace expensive `Fp12`/`Fp6`/`Fp2` multiplication and squaring in the pairing path with **witnessed outputs + randomized constraint checks**. The goal is to cut constraint count substantially while avoiding a full `bignum` refactor across the codebase.

The key idea is to verify non-native multiplications using **randomized polynomial identity checks** (Schwartz–Zippel) with an **in-circuit Poseidon-derived challenge**. This shifts costs from heavy non-native multiplication constraints to cheap native-field linear combinations.

References (validation):
- https://eprint.iacr.org/2024/640 (On Proving Pairings)
- https://eprint.iacr.org/2022/1162 (Pairings in R1CS)
- https://eprint.iacr.org/2024/265 (Beyond the circuit: minimizing foreign arithmetic)
- https://hackmd.io/@ivokub/SyJRV7ye2 (Optimizing emulated pairing, part 1)
- https://hackmd.io/@yelhousni/emulated-pairing (Optimizing emulated pairing, part 2)

---

## Goals
- Reduce constraints of the Groth16/SP1 verifier by replacing `Fp12` multiplication-heavy paths with randomized checks.
- Keep the pairing logic and PairingCheck semantics identical (no cryptographic changes).
- Limit scope to **Fp12/Fp6/Fp2 operations in the pairing path**, leaving G1/G2 arithmetic and existing bignum usage elsewhere untouched.
- Deliver a spec that is complete enough to implement without re-discovery.

## Non-goals
- Full randomized arithmetic for all `Fp` operations across the codebase.
- Removing bignum entirely.
- Changing public input format or verification equations beyond what’s required for the randomized checks.

---

## Current Architecture (Relevant)

### Pairing and verifier call paths
- `bn254_pairing/src/pairing.nr`
  - `pairing_check_with_preimage()` is used by `verify_sp1_pairing_check`.
  - `miller_loop_div_c()` uses `Fp12.mul_by_034`, `mul_by_01234`, and `Fp12.square` extensively.
- `groth16_verify/src/verify.nr`
  - `verify_sp1_pairing_check()` calls `pairing_check_with_preimage`.
- `groth16_verify/src/sp1.nr`
  - Public inputs are derived via `sha256`.

### Field towers
- `Fp2` in `bn254_pairing/src/fp2.nr`
- `Fp6` in `bn254_pairing/src/fp6.nr`
- `Fp12` in `bn254_pairing/src/fp12.nr`

These operations currently use `bignum::BN254_Fq` (non-native) for all arithmetic.

---

## Optimization Overview

### High-level idea
For each expensive non-native multiplication:
1. **Prover supplies the product as witness** (no in-circuit multiply).
2. **Circuit validates correctness using a randomized check**:
   - Represent limb values as polynomials.
   - Check equality at a random evaluation point `rho`.
   - Use a batched accumulator with `alpha` to avoid many independent constraints.

This is the standard randomized check approach for non-native arithmetic, validated in the references above.

### Why this is “medium scope”
We do *not* replace all bignum usage in the codebase. We only:
- Add randomized verification for **Fp12/Fp6/Fp2 multiplications and squarings inside the pairing path**.
- Keep existing bignum operations in:
  - G1/G2 arithmetic
  - input parsing
  - linear combinations (MSM) and checks outside the pairing path

---

## Soundness Requirements

Randomized checks are only sound if the challenge is **not controllable by the prover**.

### Required: Poseidon in-circuit over a public seed
This spec **requires** an in-circuit Poseidon hash to derive `rho` and `alpha`:
- The circuit accepts a **public seed** (random nonce) supplied by the verifier/host.
- The circuit derives challenges as:
  - `rho = Poseidon(domain_sep, seed, public_inputs, vk_hash)`
  - `alpha = Poseidon(domain_sep_2, seed, public_inputs, vk_hash, rho)`

This keeps hashing in-circuit while preserving soundness because the seed is external and unpredictable to the prover.

### Not acceptable
- Deriving `rho` only from witness values inside the same circuit.  
  This is not sound in a single proof system without an external commitment.

### Practical note
Currently, `groth16_verify` only uses `sha256`. This spec requires adding a Poseidon dependency to compute `rho` and `alpha` in-circuit.

---

## Data Model and Representation

### Existing limb encoding
Base field `Fp` elements are represented as 3 limbs of 120 bits:
```
value = limb0 + limb1 * 2^120 + limb2 * 2^240
```
This is already used in:
- `sp1_verify_example/Prover.toml`
- `groth16_verify/scripts/compute_sp1_pairing_check_witness.py`

### Flattened Fp12 coefficient order
Use the existing order documented in `PAIRING_CHECK_OPTIMIZATION_SPEC.md`:
1. `c0.b0.c0`
2. `c0.b0.c1`
3. `c0.b1.c0`
4. `c0.b1.c1`
5. `c0.b2.c0`
6. `c0.b2.c1`
7. `c1.b0.c0`
8. `c1.b0.c1`
9. `c1.b1.c0`
10. `c1.b1.c1`
11. `c1.b2.c0`
12. `c1.b2.c1`

---

## Randomized Check Design

### 1) Limb polynomial evaluation
For a limb triple `[l0, l1, l2]` and challenge `rho`:
```
eval_limbs(l0,l1,l2,rho) = l0 + l1*rho + l2*rho^2
```
All operations here are native-field `Field` arithmetic (cheap).

### 2) Base-field multiplication check
For `a * b ≡ c (mod p)`:
Let `A(X), B(X), C(X), P(X)` be limb polynomials for `a, b, c, p`.
Let `Q(X)` be quotient witness limbs (range-checked).

Check:
```
A(rho)*B(rho) - C(rho) - Q(rho)*P(rho) == 0
```

This replaces all non-native multiplication constraints with a small number of native-field ops + range checks on limbs.

### 3) Batched checks
Use a second challenge `alpha` to batch multiple multiplication checks:
```
acc = Σ alpha^i * check_i
assert(acc == 0)
```

This avoids one equality constraint per multiplication.

### 4) Scope-limited batching
Batch only for:
- Fp multiplications that appear **inside Fp2/Fp6/Fp12 ops used by the pairing path**.

Do not alter bignum operations globally.

---

## API and Module Changes (Detailed)

### New module: randomized checks
Add:
```
bn254_pairing/src/randomized_check.nr
```
Responsibilities:
- Define `RandomCheckContext` with:
  - `rho: Field`
  - `alpha: Field`
  - `alpha_pow: Field`
  - `acc: Field`
- Provide helpers:
  - `eval_limbs(limbs, rho) -> Field`
  - `check_fp_mul(limbs_a, limbs_b, limbs_c, limbs_q, ctx)`
  - `finalize(ctx) -> bool`

### Fp limb access helpers
We need a reliable way to get limbs from `Fp` values:
Option A (preferred): If `bignum::BigNum` exposes `to_limbs()`, add:
```
fn fp_to_limbs(x: Fp) -> [u128; 3]
```
Option B: If not available, require **limbs to be carried alongside Fp values** in the randomized path.

### Fp2/Fp6/Fp12 witnessed variants
Add “checked” variants that do not compute products directly:
```
Fp2::mul_checked(self, other, out, q_witness, ctx) -> Fp2
Fp6::mul_checked(self, other, out, q_witness, ctx) -> Fp6
Fp12::mul_checked(self, other, out, q_witness, ctx) -> Fp12
Fp12::square_checked(self, out, q_witness, ctx) -> Fp12

Fp12::mul_by_034_checked(...)
Fp12::mul_by_01234_checked(...)
```

Each `*_checked`:
- Accepts the **witnessed output** (`out`) plus quotient limbs for every base-field mul.
- Updates the `RandomCheckContext` with the batched checks.
- Returns `out` (no heavy multiply).

### Pairing path integration
Add a new entrypoint in `bn254_pairing/src/pairing.nr`:
```
pub fn pairing_check_with_preimage_randomized<let N: u32>(
    p_list: [G1Affine; N],
    q_list: [G2Affine; N],
    t_preimage: Fp12,
    c: Fp12,
    w: Fp12,
    rho: Field,
    alpha: Field,
    witness_trace: PairingMulTrace,
) -> bool
```

Where `PairingMulTrace` provides the witnessed outputs + quotients for the Fp12 ops invoked during:
- `miller_loop_div_c`
- the final `f_t * w * frobenius(...)` chain

### Groth16 verifier integration
Add a new opt-in entrypoint in `groth16_verify/src/verify.nr`:
```
verify_sp1_pairing_check_randomized(..., rho, alpha, trace) -> bool
```
This keeps the existing fast path intact.

---

## Witness / Prover-side Generation

### Witness additions
For each `Fp12` multiplication or square:
- Witness the resulting `Fp12` value.
- Provide `Q` limbs for each `Fp` multiply involved in the formula.

This increases witness size but keeps constraints low.

### Script changes
Extend:
```
groth16_verify/scripts/compute_sp1_pairing_check_witness.py
```
to output:
- the **public seed** (provided by host/verifier)
- `PairingMulTrace` with:
  - each intermediate `Fp12` product
  - quotient limbs for all base-field multiplications

Add a dedicated output format (JSON or TOML) to keep witness manageable.

---

## Files to Change (Concrete)

### bn254_pairing/
- `src/randomized_check.nr` (new)
- `src/fp.nr`
  - add `fp_to_limbs` helper if possible
- `src/fp2.nr`, `src/fp6.nr`, `src/fp12.nr`
  - add `*_checked` variants and limb helpers
- `src/pairing.nr`
  - add `pairing_check_with_preimage_randomized`
  - implement a randomized Miller loop variant that uses checked ops
- `src/tests/`
  - new tests for randomized checks:
    - `fp12_checked_mul` vs standard `mul`
    - `pairing_check_with_preimage_randomized` vs standard

### groth16_verify/
- `src/verify.nr`
  - new entrypoint wiring randomized path
- `src/sp1.nr`
  - extend public inputs to include the Poseidon seed or add a separate entrypoint that accepts it
- `src/poseidon_challenge.nr` (new)
  - Poseidon-based `derive_rho_alpha(seed, public_inputs, vk_hash)`
- `scripts/compute_sp1_pairing_check_witness.py`
  - generate full trace for randomized checks
- `Nargo.toml`
  - add Poseidon dependency
- `SP1_NOIR_SPEC.md`
  - document new witness format and challenge source

---

## Challenge Derivation (Detailed)

### Required: Poseidon in-circuit with public seed
Add Poseidon and derive challenges in-circuit:
- Input: `seed` (public), `public_inputs`, `vk_hash`, and fixed domain separators.
- Output: `rho`, `alpha` used by `RandomCheckContext`.

### Optional: recursive randomness
If the verifier is embedded in another proof system, derive the seed from the outer transcript instead of passing it directly.

---

## Testing Strategy

1. Unit tests:
   - `Fp12.mul_checked` equals `Fp12.mul` for random fixtures.
   - Fail tests for incorrect `out` / `q`.
2. Pairing path:
   - `pairing_check_with_preimage_randomized` accepts known vectors.
3. Integration:
   - `verify_sp1_pairing_check_randomized` accepts the SP1 test vector.
   - Keep the old path for comparison.

---

## Performance Expectations

Based on current measurements (~3.63M constraints for SP1 verify):
- Expected reduction: **~0.6M to ~1.3M constraints**.
- Larger if Fp12 multiplications dominate the remaining cost.

---

## Risks and Mitigations

### Soundness risk if randomness is prover-controlled
Mitigation: require a public seed from the verifier/host and derive `rho`/`alpha` with in-circuit Poseidon.

### Large witness size
Mitigation: batch checks, compress trace format, or use deterministic trace ordering.

### BigNum limb access unavailable
Mitigation: pass limbs explicitly in witness trace; range check them.

---

## References
- https://eprint.iacr.org/2024/640
- https://eprint.iacr.org/2022/1162
- https://eprint.iacr.org/2024/265
- https://hackmd.io/@ivokub/SyJRV7ye2
- https://hackmd.io/@yelhousni/emulated-pairing

