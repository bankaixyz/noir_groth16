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
- `pairing_multi(p: [G1Affine; N], q: [G2Affine; N]) -> Fp12`
- `pairing_check_optimized(p_list: [G1Affine; 3], q_list: [G2Affine; 3], t_preimage, delta_lines, gamma_lines, lines, b_lines_raw, b_line_witness, rho, c, w) -> bool`

Only these entrypoints are intended for external use.

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
- **Pre-evaluated line schedule**: `pairing_check_optimized` consumes witnessed line
  coefficients and validates them, skipping in-circuit G2 arithmetic for the Miller loop.
- **Preimage pairing check**: uses a preimage `t_preimage` and witnesses `(c, w)` to
  reduce the final exponentiation to a single `is_one` check.
- **Frobenius shortcuts**: final exponentiation uses `frobenius`, `frobenius_square`,
  and `cyclotomic_square` once the element is in the cyclotomic subgroup.


