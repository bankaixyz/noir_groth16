# BN254 Pairing + Groth16 Verification (Noir) — Contributor Guide

This repo contains Noir implementations of BN254 pairings and Groth16 verification, plus small example circuits you can compile/execute/prove locally.

## What’s in this repo

- **`bn254_pairing/`**: `noir_bn254_pairing` library (fields, curves, Miller loop, final exponentiation).
- **`groth16_verify/`**: `noir_groth16_verify` library (Groth16 verify over BN254 + SP1-optimized path).
- **`pairing_multi_example/`**: example circuit exercising multi-pairing.
- **`sp1_verify_example/`**: example circuit that verifies an SP1 Groth16 wrapper proof.

Each folder is its own Nargo project; run `nargo` commands from within that directory.

## Setup

- Install Noir via `noirup` and ensure **Noir `>= 0.33.0`**.
- See the root [`README.md`](README.md) for the exact commands.

## Common commands (copy/paste)

Fastest sanity check:

```bash
cd groth16_verify
nargo test
```

Run the multi-pairing example:

```bash
cd pairing_multi_example
nargo compile
nargo execute
```

Run the SP1 verifier example:

```bash
cd sp1_verify_example
nargo compile
nargo execute
```

## Where to look (key files)

Pairing library:

- `bn254_pairing/src/pairing.nr`: `pairing`, `pairing_multi`, `pairing_check_optimized`
- `bn254_pairing/src/g1.nr`: G1 ops
- `bn254_pairing/src/g2.nr`: G2 ops + line evaluations used by Miller loop
- `bn254_pairing/src/fp*.nr`: field towers (`Fp`, `Fp2`, `Fp6`, `Fp12`)

Groth16 verifier:

- `groth16_verify/src/verify.nr`: generic `verify` and `verify_optimized`
- `groth16_verify/src/sp1.nr`: SP1 `verify` + `verify_optimized`, plus public input hashing
- `groth16_verify/src/config/sp1.nr`: embedded SP1 verifying key + precomputed MSM table
- `groth16_verify/SP1_NOIR_SPEC.md`: reference notes + constants format

