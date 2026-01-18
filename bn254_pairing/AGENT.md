# `noir_bn254_pairing` (BN254 Pairing) — Contributor Guide

This package implements BN254 pairing operations in Noir: field towers, curve ops, the Miller loop, and final exponentiation.

## Where to start

- `src/pairing.nr`: high-level pairing entrypoints and Miller loop / final exp wiring
- `src/g1.nr`: G1 arithmetic (affine/jacobian helpers)
- `src/g2.nr`: G2 arithmetic + line evaluations used during the Miller loop

## Module map

- `src/fp.nr`: base field (`Fp`) utilities/constants
- `src/fp2.nr`: quadratic extension (`Fp2`)
- `src/fp6.nr`: cubic-over-quadratic (`Fp6`)
- `src/fp12.nr`: quadratic-over-`Fp6` (`Fp12`)
- `src/g1.nr`: BN254 G1
- `src/g2.nr`: BN254 G2 (twist)
- `src/pairing.nr`: pairing / miller loop / final exponentiation

The crate re-exports `bignum::BigNum` as `noir_bn254_pairing::BigNum`.

## Main APIs

Core entrypoints (see `src/pairing.nr`):

- `pairing(p: G1Affine, q: G2Affine) -> Fp12`
- `pairing_multi(p: [G1Affine; N], q: [G2Affine; N]) -> Fp12`
- `miller_loop(p: [G1Affine; N], q: [G2Affine; N]) -> Fp12`
- `final_exponentiation(z: Fp12) -> Fp12`

Useful curve checks/helpers:

- `is_on_curve_g1_affine`, `is_on_curve_g2_affine`
- `g1_affine_infinity`, `g2_affine_infinity`, `neg_g1_affine`, `neg_g2_affine`

## Tests

Tests live under `src/tests/` and can be slow.

```bash
cd bn254_pairing
nargo test
```

