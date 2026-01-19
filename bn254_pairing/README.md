# BN254 Pairing in Noir

This package implements the BN254 pairing in Noir. It includes finite field arithmetic,
G1/G2 operations, the Miller loop, and the final exponentiation.

## Cryptography summary

- **Curve**: E: y^2 = x^3 + 3 over Fp, with G1 = E(Fp)[r].
- **Twist**: G2 is defined on the sextic twist E'(Fp2)[r].
- **Pairing target**: Fp12 with embedding degree 12; result lies in GT.
- **Final exponentiation split**:
  (p^12 - 1) / r = (p^6 - 1) * (p^2 + 1) * (p^4 - p^2 + 1) / r.

## Main API

Core pairing entrypoints:

- `pairing(p: G1Affine, q: G2Affine) -> Fp12`
- `pairing_with_miller_inverse(p: G1Affine, q: G2Affine, f_inv: Fp12) -> Fp12`
- `pairing_multi(p: [G1Affine; N], q: [G2Affine; N]) -> Fp12`
- `pairing_multi_with_miller_inverse(p: [G1Affine; N], q: [G2Affine; N], f_inv: Fp12) -> Fp12`
- `miller_loop(p: [G1Affine; N], q: [G2Affine; N]) -> Fp12`
- `final_exponentiation(z: Fp12) -> Fp12`
- `final_exponentiation_with_inverse(z: Fp12, z_inv: Fp12) -> Fp12`

Curve helpers you can `assert` against in your circuit:

- `is_on_curve_g1_affine`, `is_on_curve_g2_affine`
- `g1_affine_infinity`, `g2_affine_infinity`, `neg_g1_affine`, `neg_g2_affine`
- `add_g1_affine`, `add_g1_jac`, `add_g1_jac_mixed`, `double_g1_jac`
- `add_g2_jac`, `double_g2_jac`, `projective_from_affine_g2`

## Algorithm overview

- **Miller loop**: evaluates f_{x,Q}(P) for the optimal Ate pairing using signed
  NAF digits of the BN parameter x and sparse line evaluations in Fp12.
- **Final exponentiation**: easy part uses inverse + Frobenius maps; hard part uses
  cyclotomic squaring (Karabina 2010) and a fixed chain for BN254
  (Fuentes-Castaneda, Knapp, Rodriguez-Henriquez 2011).

## Optimization notes

The implementation uses several circuit-friendly optimizations:

- **Pair filtering**: `filter_pairs` removes infinity inputs to skip work.
- **Signed NAF loop**: reduces additions in the Miller loop without changing f_{x,Q}(P).
- **Sparse line arithmetic**: line evaluations are handled via `mul_by_034`,
  `mul_034_by_034`, and `mul_by_01234` to avoid full Fp12 multiplies.
- **Mixed additions on G2**: `double_step` and `add_mixed_step` avoid affine inversion
  costs and keep line evaluations cheap.
- **Miller inverse witness**: if you can supply `f_inv = miller_loop(...)^{-1}` as a
  witness, the circuit asserts `f * f_inv == 1` and skips the Fp12 inversion in the
  easy part of final exponentiation. Use `pairing_with_miller_inverse` or
  `pairing_multi_with_miller_inverse` for this path.
- **Frobenius shortcuts**: final exponentiation uses `frobenius`, `frobenius_square`,
  and `cyclotomic_square` once the element is in the cyclotomic subgroup.

## Utilities

To compute `miller_loop(...)^{-1}` offline for the inverse-assisted APIs, use:

```bash
python scripts/compute_miller_inverse.py --case single_generators
```

The script reads `src/tests/bn254_miller_loop_vectors.json` by default and outputs
both a hex JSON object and a Noir `Fp12` literal. You can point it at your own
JSON by passing `--input` (it accepts either the vector file format or a flat
object with the same `c0_b0_a0`...`c1_b2_a1` keys).

## Performance notes

These figures are measured in a Noir circuit and are intended as rough guidance.
Some tests are slow.

| Pairings | Constraints | ACIR opcodes | Proving time |
| --- | --- | --- | --- |
| 2 | 1,812,974 | 8,196 | 15.38s |
| 3 | 2,035,715 | 8,196 | 16.0s |
| 4 | 2,227,841 | 8,912 | 16.7s |

