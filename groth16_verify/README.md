# Groth16 Verify in Noir

This package provides a Groth16 verifier over BN254, with an optimized path
and an SP1 wrapper for two public inputs.

## Cryptography summary

- **Groth16 equation**: compute L = IC_0 + sum_i IC_{i+1} * input_i and check
  e(A, B) * e(C, -delta) * e(L, -gamma) = e(alpha, beta) in Fp12.
- **Proof validation**: verifier enforces on-curve checks, rejects infinity points,
  and checks G2 subgroup membership for proof points.
- **Public inputs**: inputs are BN254 scalars; the SP1 path hashes public values
  with SHA256 and masks to 253 bits to stay in the scalar field.
- **MSM optimization**: the optimized path uses a joint-window MSM (Straus/Shamir)
  with precomputed table entries a*IC1 + b*IC2 for 3-bit digits.

## Main API

Generic verifier:

- `verify(vk, proof, public_inputs) -> bool`
- `verify_optimized(vk, proof, public_inputs, msm2_w3_table, t_preimage, delta_lines, gamma_lines, lines, b_lines_raw, b_line_witness, mul_034_witnesses, rho, c, w) -> bool`

SP1 verifier (two inputs):

- `sp1::verify(vkey, public_values, proof) -> bool`
- `sp1::verify_optimized(vkey, public_values, rho_seed, a_x, a_y, b_x_c0, b_x_c1, b_y_c0, b_y_c1, c_x, c_y, c, w, lines, b_lines_raw, b_line_witness, mul_034_witnesses) -> bool`

Core types:

- `Proof { a, b, c }`
- `VerifyingKey { ic, gamma_neg, delta_neg, alpha_beta }`

## Verifier flow

1. Compute the linear combination `L = ic[0] + sum(public_inputs[i] * ic[i+1])`.
2. Run a 3-pairing check with `pairing_multi`:
   - `e(A, B) * e(C, delta_neg) * e(L, gamma_neg) == alpha_beta`
3. Return a boolean equality in Fp12.

## SP1-specific flow

SP1 exposes two public inputs:

- `input0 = vkey`
- `input1 = sha256(public_values)` masked to 253 bits

`sp1::verify` computes these inputs and calls the generic verifier.
`sp1::verify_optimized` additionally derives `rho` (Poseidon2 with a public seed),
validates the line schedule, and uses the preimage pairing check.

## Optimization notes

The optimized path uses a 3-bit joint-window MSM (w = 3) for two scalars:

- **Precomputed table**: `sp1_msm2_w3_table` stores all `a*ic1 + b*ic2`
  combinations for 3-bit digits.
- **Joint windowing**: `msm2_window3_g1_jac` processes both scalars together,
  reducing additions vs. a per-scalar double-and-add.
- **Mixed add**: `add_g1_jac_mixed` is used because the table entries are affine
  constants, lowering per-add constraints.
- **Line schedules**: fixed G2 pairings use precomputed lines; the variable B
  pairing uses witnessed line steps validated in-circuit.
- **Preimage pairing check**: the pairing product is verified via `(t_preimage, c, w)`
  to avoid a full final exponentiation.

## Performance notes

- Current implementation: **3,938,711 constraints**.
- Tests are slow and can take ages.
