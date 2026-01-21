# `noir_groth16_verify` (Groth16 Verify on BN254) — Contributor Guide

This package provides a Groth16 verifier over BN254 built on `noir_bn254_pairing`, plus an SP1 wrapper and optimized path for the “two public inputs” format used by SP1.

## Key entrypoints

- `src/verify.nr`
  - `verify::<N, L>(vk, proof, public_inputs) -> bool`
- `verify_optimized(vk, proof, public_inputs, msm2_w3_table, t_preimage, delta_lines, gamma_lines, lines, b_lines_raw, b_line_witness, mul_034_witnesses, rho, c, w) -> bool`
- `src/sp1.nr`
  - `verify::<N>(vkey, public_values, proof) -> bool`
- `verify_optimized::<N>(vkey, public_values, rho_seed, a_x, a_y, b_x_c0, b_x_c1, b_y_c0, b_y_c1, c_x, c_y, c, w, lines, b_lines_raw, b_line_witness, mul_034_witnesses) -> bool`
  - `sp1_public_inputs(vkey, public_values) -> [Field; 2]`
- `src/types.nr`
  - `Proof { a, b, c }`
  - `VerifyingKey<L> { ic, gamma_neg, delta_neg, alpha_beta }`

## Verifier flow (generic)

1. Compute the linear combination:
   - \(L = ic[0] + \sum_i public\_inputs[i] * ic[i+1]\)
2. Run a 3-pairing check:
   - `pairing_multi([A, C, L], [B, delta_neg, gamma_neg]) == alpha_beta`
3. Return a boolean equality in `Fp12`.
4. Enforce proof points are on-curve, non-infinity, and in the G2 subgroup.

## SP1-specific flow

SP1 exposes two public inputs:

- `input0 = vkey` (already a field element)
- `input1 = sha256(public_values)` interpreted big-endian and **masked to 253 bits**

Implementation details:

- `src/sp1.nr` hashes/masks and then calls the generic/optimized verifier.
- `src/config/sp1.nr` contains the embedded SP1 verifying key and the precomputed 2-scalar MSM table.
- `scripts/` contains helpers to regenerate SP1 constants/tables used in `src/config/sp1.nr`.
- `SP1_NOIR_SPEC.md` documents the constant formats and hashing rules.

## Tests

```bash
cd groth16_verify
nargo test
```

