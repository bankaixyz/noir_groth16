# BN254 Pairing + Groth16 Verification (Noir)

This repo contains two Noir libraries:

- `noir_bn254_pairing`: BN254 pairing, final exponentiation, and curve ops.
- `noir_groth16_verify`: Groth16 verification on BN254, plus an SP1-optimized path.

## Cryptography summary

- **Curve and groups**: BN254 (aka alt_bn128) with G1 over Fp and G2 over the
  sextic twist in Fp2; pairing target is Fp12.
- **Pairing**: optimal Ate pairing e: G1 x G2 -> Fp12, computed with a signed-NAF
  Miller loop on the BN parameter x and finalized by a full exponentiation into
  the r-torsion subgroup.
- **Final exponentiation**: easy part uses Frobenius maps; hard part uses
  cyclotomic squaring (Karabina 2010) and a fixed addition chain tailored to
  BN254 (Fuentes-Castaneda, Knapp, Rodriguez-Henriquez 2011).
- **Groth16 verification**: compute L = IC_0 + sum_i IC_{i+1} * input_i and check
  e(A, B) * e(C, -delta) * e(L, -gamma) = e(alpha, beta).
- **Proof validation**: verifier enforces on-curve checks, rejects infinity points,
  and checks G2 subgroup membership for proof points.
- **SP1 fast path**: 2-scalar MSM with a 3-bit joint window (Straus/Shamir),
  using embedded constants; use `verify_sp1_fast_with_table` only with trusted tables.

Tests are slow; the fastest sanity check is in the Groth16 verifier.

## Environment setup

This repo targets **Noir `>= 0.33.0`** (see `compiler_version` in each package’s `Nargo.toml`).

### Install Noir (nargo)

Recommended install method is `noirup`:

```bash
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
noirup
nargo --version
```

If your `nargo` is older than `0.33.0`, use `noirup` to switch to a newer Noir version (see `noirup --help`), then re-check `nargo --version`.

### Compile / execute / prove (example circuits)

First runs will fetch git dependencies (e.g. `noir-bignum`, `sha256`) automatically.

`pairing_multi_example`:

```bash
cd pairing_multi_example
nargo compile
nargo execute   # uses inputs from Prover.toml
```

`sp1_verify_example`:

```bash
cd sp1_verify_example
nargo compile
nargo execute   # uses inputs from Prover.toml
```

### Quick sanity test

```bash
cd groth16_verify
nargo test
```

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

For custom SP1 verifying keys and MSM tables, use `verify_sp1_fast_with_table` and
ensure the table/VK are constants in the circuit.

Example circuits live in `pairing_multi_example` and `sp1_verify_example`.
