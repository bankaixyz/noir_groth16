# Pairing Constraint Reduction Plan (Noir BN254)

This note summarizes why the current randomized Fp12 checks did not reduce
constraints in Noir, and outlines concrete optimizations that can shave ~1M+
constraints from the pairing verifier.

## Why randomized Fp12 checks did not help in Noir

Noir's `bignum` multiplication is already constrained by a **single quadratic
expression**:

```
lhs * rhs - result = 0
```

So replacing those multiplications with randomized limb checks removes only a
small number of constraints, while adding many native-field multiplications and
Poseidon hashing. The net effect is neutral or worse. The remaining cost is
dominated by **G2 arithmetic and line processing** inside the Miller loop.

## Where the constraints actually live

1. **G2 arithmetic in the Miller loop**
   - `double_step`, `add_mixed_step`, `line_compute`
   - Heavy non-native ops in Fp2

2. **Line evaluation and line multiplication**
   - `line_eval_at_point` (Fp2 * Fp)
   - `mul_034_by_034` (~6 Fp2 muls each)

These run many times per pairing, so they dominate the total constraint count.

## Optimization options that can remove ~1M constraints

### Option A: Witness all line evaluations (largest savings)

**Idea:** Move all G2 arithmetic off-circuit. Witness the line evaluations
and only verify the Miller accumulator transitions in-circuit.

**Steps:**
- Off-circuit: compute every line `l = (r0, r1, r2)` for each step.
- On-circuit: use witnessed lines directly in `mul_by_034` / `mul_by_01234`.
- Verify accumulator transitions with randomized checks.

**Expected savings:** ~0.8M–1.4M depending on number of pairings.

**Notes:** This is the biggest win but adds witness size and trace management.

---

### Option B: Precompute fixed-G2 lines (medium scope)

**Idea:** Delta/gamma are fixed in the SP1 verifier, so their line coefficients
can be precomputed and hardcoded. Only proof's `B` (variable G2) still uses
in-circuit line computation.

**Steps:**
- Precompute line coefficients for fixed G2 points offline.
- Hardcode them and skip G2 arithmetic for those points.
- Keep existing in-circuit path for proof's `B`.

**Expected savings:** ~0.6M–0.9M.

**Notes:** Smaller refactor, much lower witness overhead.

---

### Option C: Randomize `mul_034_by_034` (medium scope)

**Idea:** Replace the Fp2 multiplications inside `mul_034_by_034` with
randomized checks + witnessed outputs.

**Steps:**
- Witness `mul_034_by_034` outputs (`x0`, `x3`, `x4`, `x04`, `x03`, `x34`).
- Verify each Fp2 multiplication using randomized Fp checks.
- Use the witnessed outputs to form the line product.

**Expected savings:** ~0.3M–0.5M.

**Notes:** This stacks well with Option B.

## Recommended path to sub-2M

1. **Implement Option B** (fixed-G2 line precomputation).
2. **Add Option C** (randomize `mul_034_by_034`).
3. If needed, **upgrade to Option A** (full line witnessing).

This progression keeps complexity manageable while delivering large savings.

## Soundness considerations

- If lines are witnessed, they must be validated (randomized checks + consistency).
- Public seed + Poseidon-derived `rho`/`alpha` are required for soundness.
- Ensure `w` remains constrained to the Fp6 subfield.
