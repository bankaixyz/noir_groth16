# `noir_groth16_verify` (Groth16 Verify on BN254) — Contributor Guide

This package provides a Groth16 verifier over BN254 built on `noir_bn254_pairing`, plus an SP1-specific fast path for the “two public inputs” format used by SP1.

## Key entrypoints

- `src/verify.nr`
  - `verify::<N, L>(vk, proof, public_inputs) -> bool`
  - `verify_sp1_fast(proof, public_inputs) -> bool`
  - `verify_sp1_fast_with_table(vk, proof, public_inputs, msm2_w3_table) -> bool`
- `src/sp1.nr`
  - `verify_sp1::<N>(vkey, public_values, proof) -> bool`
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

- `src/sp1.nr` hashes/masks and then calls `verify_sp1_fast`.
- `src/config/sp1.nr` contains the embedded SP1 verifying key and the precomputed 2-scalar MSM table.
- `scripts/` contains helpers to regenerate SP1 constants/tables used in `src/config/sp1.nr`.
- `SP1_NOIR_SPEC.md` documents the constant formats and hashing rules.

## Tests

```bash
cd groth16_verify
nargo test
```

