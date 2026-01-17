## Pairing library guide

### Module map
- `fp.nr`: BN254 base field element (`Fp`) helpers and constants.
- `fp2.nr`: Quadratic extension `Fp2 = Fp[u] / (u^2 + 1)` with Frobenius and twist constants.
- `fp6.nr`: Sextic extension `Fp6 = Fp2[v] / (v^3 - (9 + u))`.
- `fp12.nr`: Dodecic extension `Fp12 = Fp6[w] / (w^2 - v)` plus cyclotomic/Frobenius helpers.
- `g1.nr`, `g2.nr`: Curve groups and operations.
- `pairing.nr`: Miller loop and final exponentiation for BN254.
- `tests/`: Fixture-driven tests for `Fp2`, `Fp6`, `Fp12`, and pairing/group logic.

### Data layout
`Fp` values are stored as 3 limbs in little-endian order. Each limb is a 120-bit chunk:
`value = limb0 + limb1 * 2^120 + limb2 * 2^240`.

### Field tower summary
- `Fp2` uses the non-residue `u^2 = -1`.
- `Fp6` uses the non-residue `v^3 = 9 + u`.
- `Fp12` uses the non-residue `w^2 = v`.

### Constants worth reusing
The following helpers are used heavily across the tower:
- Base field small constants: `fp_zero`, `fp_one`, `fp_two`, `fp_three`, `fp_four`, `fp_eight`, `fp_nine`.
- Twist/Frobenius constants: `non_residue`, `non_residue_inv`, `b_twist`, `endo_u`, `endo_v`, and the
  `frobenius_*_power_*` tables in `fp2.nr`.

### Implementation notes
- `Fp2`, `Fp6`, and `Fp12` operations are expressed in terms of base field ops (add/sub/mul/neg/inv).
- `Fp6` and `Fp12` include sparse multiplication helpers (`mul_by_01`, `mul_by_34`, `mul_by_034`, etc.)
  used in the Miller loop and final exponentiation.
- `Fp12::expt` is the hard exponentiation chain for BN254’s final exponentiation.
