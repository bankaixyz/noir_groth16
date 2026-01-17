# BN254 Pairing + Groth16 Verification (Noir)

This repo contains two Noir libraries:

- `noir_bn254_pairing`: BN254 pairing, final exponentiation, and curve ops.
- `noir_groth16_verify`: Groth16 verification on BN254, plus an SP1-optimized path.

Tests are slow; the fastest sanity check is in the Groth16 verifier.

## Pairing usage

Single pairing:

```noir
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::pairing::pairing;

fn verify_pairing(p: G1Affine, q: G2Affine) -> Field {
    let f = pairing(p, q);
    // Use the Fp12 result in your circuit.
    1
}
```

Multi pairing (checks multiple pairs in one Miller loop):

```noir
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::pairing::pairing_multi;

fn multi_pairing(p: [G1Affine; 2], q: [G2Affine; 2]) -> Field {
    let f = pairing_multi(p, q);
    1
}
```

## Groth16 verification usage

Generic verifier:

```noir
use noir_groth16_verify::types::{Proof, VerifyingKey};
use noir_groth16_verify::verify::verify;

fn check<const N: u32, const L: u32>(
    vk: VerifyingKey<L>,
    proof: Proof,
    public_inputs: [Field; N],
) -> bool {
    verify::<N, L>(vk, proof, public_inputs)
}
```

SP1 verifier (two public inputs: vkey and hash(public values)):

```noir
use noir_groth16_verify::sp1::verify_sp1;
use noir_groth16_verify::types::Proof;

fn check_sp1<const N: u32>(
    vkey: Field,
    public_values: [u8; N],
    proof: Proof,
) -> bool {
    verify_sp1::<N>(vkey, public_values, proof)
}
```

Example circuits live in `pairing_multi_example` and `sp1_verify_example`.
