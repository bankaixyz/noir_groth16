# Groth16 Verify in Noir

This package provides a Groth16 verifier over BN254, with a fast SP1-specific
path for two public inputs.

## Main API

Generic verifier:

- `verify(vk, proof, public_inputs) -> bool`

SP1 verifier (two inputs):

- `verify_sp1(vkey, public_values, proof) -> bool`
- `verify_sp1_fast(vk, proof, public_inputs, msm2_w3_table) -> bool`

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

`verify_sp1` computes these inputs and calls the fast verifier path.

## Optimization notes

The SP1 path uses a 3-bit joint-window MSM (w = 3) for two scalars:

- **Precomputed table**: `sp1_msm2_w3_table` stores all `a*ic1 + b*ic2`
  combinations for 3-bit digits.
- **Joint windowing**: `msm2_window3_g1_jac` processes both scalars together,
  reducing additions vs. a per-scalar double-and-add.
- **Mixed add**: `add_g1_jac_mixed` is used because the table entries are affine
  constants, lowering per-add constraints.

## Performance notes

- Current implementation: **3,938,711 constraints**.
- Tests are slow and can take ages.
