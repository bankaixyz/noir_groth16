# SP1 Groth16 Verification Notes (Noir)

This document mirrors `privacy-pools-aggregator/sp1.go` and provides:
1) the exact hashing logic for SP1 public values and program vkey, and
2) a copyable list of verifier constants encoded as 120-bit little-endian limbs.

## 1) Public input hashing + vkey processing

The SP1 verifier expects exactly two public inputs:

1. **Program vkey (bytes → field element)**
   - Read `vkey` as hex string (optionally `0x`-prefixed).
   - Decode into bytes.
   - Interpret as **big-endian** integer.
   - Convert into a BN254 scalar field element.

2. **Hashed public values (SHA-256 + mask)**
   - Read `publicValues` as hex string (optionally `0x`-prefixed).
   - Decode into bytes.
   - Compute `sha256(publicValuesBytes)`, producing a 32-byte digest.
   - Interpret digest as a **big-endian** integer `d`.
   - Apply mask: `d = d & ((1 << 253) - 1)`.
   - Convert masked `d` into a BN254 scalar field element.

In Noir-style pseudocode (not exact syntax):
```rust
fn hash_public_values(public_values_hex: str) -> Field {
    let bytes = hex_to_bytes(public_values_hex);
    let digest = sha256(bytes); // 32 bytes
    let d = bytes_to_u256_be(digest);
    let masked = d & ((1u256 << 253) - 1);
    field_from_u256_be(masked)
}

fn vkey_to_field(vkey_hex: str) -> Field {
    let bytes = hex_to_bytes(vkey_hex);
    let v = bytes_to_u256_be(bytes);
    field_from_u256_be(v)
}
```

## 2) Verifier constants in 120-bit LE limbs

**Encoding rule** (little-endian limbs, 120-bit each):
```
Fp::from_limbs([l0, l1, l2])
```
where `l0` is the least-significant 120 bits.

### G1 alpha
```
ALPHA_X = Fp::from_limbs([0xea33fbb16c643b22f599a2be6df2e2, 0x9aa7e302d9df41749d5507949d05db, 0x2d4d])
ALPHA_Y = Fp::from_limbs([0x89830a19230301f076caff004d1926, 0xdd503c37ceb061d8ec60209fe345ce, 0x14be])
```

### G1.K (IC) points
These are the constant term and two public inputs.
```
IC0_X = Fp::from_limbs([0x24779233db734c451d28b58aa9758e, 0x1e1cafb0ad8a4ea0a694cd3743ebf5, 0x2609])
IC0_Y = Fp::from_limbs([0x25489fefa65a3e782e7ba70b66690e, 0xf50a6b8b11c3ca6fdb2690a124f8ce, 0x9f])

IC1_X = Fp::from_limbs([0xed36c6ec878755e537c1c48951fb4c, 0x3fd0fd3da25d2607c227d090cca750, 0x61c])
IC1_Y = Fp::from_limbs([0x5e9a273e6119a212dd09eb51707219, 0x7ae9c2033379df7b5c65eff0e10705, 0xfa1])

IC2_X = Fp::from_limbs([0xfdec51a16028dee020634fd129e71c, 0xb241388a79817fe0e0e2ead0b2ec4f, 0x4ea])
IC2_Y = Fp::from_limbs([0xa9e16fca56b18d5544b0889a65c1f5, 0x6256d21c60d02f0bdbf95cff83e03e, 0x723])
```

### G2 points (Solidity stores -beta, -gamma, -delta)

The on-chain verifier stores **negated** G2 points. In gnark, these are negated again to recover β, γ, δ:
```
beta = -betaNeg
gamma = -gammaNeg
delta = -deltaNeg
```

Use the following limb values for the *negated* points, then negate once in-circuit (or precompute the negation off-circuit and hardcode those instead).

#### -beta
```
BETA_NEG_X0 = Fp::from_limbs([0xd68bc0e071241e0213bc7fc13db7ab, 0x7847ad4c798374d0d6732bf501847d, 0xe18])
BETA_NEG_X1 = Fp::from_limbs([0x8480a653f2decaa9794cbc3bf3060c, 0x32fcbf776d1afc985f88877f182d3, 0x967])
BETA_NEG_Y0 = Fp::from_limbs([0xeab2cb2987c4e366a185c25dac2e7f, 0x8cc13cd9f762871f21e43451c6ca9e, 0x192a])
BETA_NEG_Y1 = Fp::from_limbs([0x838bccfcf7bd559e79f1c9c759b6a0, 0x52a100a72fdf1e5a5d6ea841cc20ec, 0x17])
```

#### -gamma
```
GAMMA_NEG_X0 = Fp::from_limbs([0x4322d4f75edadd46debd5cd992f6ed, 0xdeef121f1e76426a00665e5c447967, 0x1800])
GAMMA_NEG_X1 = Fp::from_limbs([0xaa493335a9e71297e485b7aef312c2, 0x9393920d483a7260bfb731fb5d25f1, 0x198e])
GAMMA_NEG_Y0 = Fp::from_limbs([0xaf83285c2df711ef39c01571827f9d, 0xefcd05a5323e6da4d435f3b617cdb3, 0x1d9b])
GAMMA_NEG_Y1 = Fp::from_limbs([0x36395df7be3b99e673b13a075a65ec, 0xc4a288d1afb3cbb1ac09187524c7db, 0x275d])
```

#### -delta
```
DELTA_NEG_X0 = Fp::from_limbs([0x3d3b76777a63b327d736bffb0122ed, 0x41f4ba0c37fe2caf27354d28e4b8f8, 0x3ff])
DELTA_NEG_X1 = Fp::from_limbs([0x865e0cc020024521998269845f74e6, 0xcb8de715675f21f01ecc9b46d236e0, 0x1cc7])
DELTA_NEG_Y0 = Fp::from_limbs([0x266e474227c6439ca25ca8e1ec1fc2, 0xd3274441670227b4f69a44005b8711, 0x192b])
DELTA_NEG_Y1 = Fp::from_limbs([0xd7f8b2725cd5902a6b20da7a2938fb, 0x9cd7827e0278e6b60843a4abc7b111, 0x190])
```

### alpha_beta = e(alpha, beta) (GT element)
```
ALPHA_BETA_C0_B0_A0 = Fp::from_limbs([0xa1ade8b03e8b987d3578b630dc140d, 0x9b812acb2275e21f0ccfd2b5b2c71b, 0x47c])
ALPHA_BETA_C0_B0_A1 = Fp::from_limbs([0xaabe2ef7a97706a8942a30d91b604a, 0xb9be47b538f0c82106a3fb9b1e13da, 0x2e96])
ALPHA_BETA_C0_B1_A0 = Fp::from_limbs([0x99afc69013773684381d2c74892018, 0x1f1d74c43656ee464741e6399c7237, 0xd22])
ALPHA_BETA_C0_B1_A1 = Fp::from_limbs([0x941c208b4fbc53d65aedcda7805cf4, 0x69ecd427a0ce90dce160e1de184905, 0x1ae0])
ALPHA_BETA_C0_B2_A0 = Fp::from_limbs([0xcf123696b3ba61a91d739d7f8f06d, 0x3910f5f590d5910ffe4610de63e7dc, 0x1176])
ALPHA_BETA_C0_B2_A1 = Fp::from_limbs([0x997fe53031ccd822922facdac67ac5, 0xdda5649d0d0c861bd1e1b3ecedd2dc, 0xfa3])
ALPHA_BETA_C1_B0_A0 = Fp::from_limbs([0x12cd3e2c33863498d5c913e5a8b842, 0xb627bc5985831858c16686982b1936, 0xfa5])
ALPHA_BETA_C1_B0_A1 = Fp::from_limbs([0x51d4bf1954e7c38dc83ad48fe8fe49, 0xb58bd40a46bdfc4b5b84c4b8254e37, 0x1650])
ALPHA_BETA_C1_B1_A0 = Fp::from_limbs([0x6cfeef5f8a6cb7436a6993f2ede1e4, 0xf2efd31e0684176c24c07bcd59dbfd, 0xa28])
ALPHA_BETA_C1_B1_A1 = Fp::from_limbs([0x80d70a0ae1724dd8935bbcca6fe574, 0x2257e8e26c9335e43a8ccc062db079, 0x2bd8])
ALPHA_BETA_C1_B2_A0 = Fp::from_limbs([0x61029c66caf40ca88899036fa48094, 0x7a5d05d208ec0d189852bc3fcef800, 0x1a62])
ALPHA_BETA_C1_B2_A1 = Fp::from_limbs([0x38b4d32805c8d7862a2499dd4fccd3, 0x11fa3287536b8ab776bc5889266c4, 0x11c5])
```

## 3) Proof verification steps (pairing equation)

Your pseudocode logic is **valid** for a Groth16 verifier that stores `gamma_neg` and `delta_neg` in the VK. The pairing equation you wrote matches the gnark flow:

```
e(pi_A, pi_B) * e(pi_C, delta_neg) * e(L, gamma_neg) == alpha_beta
```

Where:
```
L = IC[0] + sum_{i=0}^{N-1} public_inputs[i] * IC[i+1]
alpha_beta = e(alpha, beta)
```

Implementation steps (Noir-side):
1. Enforce `L == N + 1`.
2. Compute the accumulator `L` using the IC points and public inputs.
3. Run `multi_pairing([pi_A, pi_C, L], [pi_B, delta_neg, gamma_neg])`.
4. Compare the result with the precomputed `alpha_beta`.

Important details:
- **Public inputs must be field-reduced** (they already are if you use `Field` in Noir).
- **Alpha_beta** must be computed with **beta** (not `beta_neg`).
- The proof points must be valid curve points. If your pairing library assumes subgroup checks, make sure your input encoding enforces that (or add checks if you can afford them).
- If your GT type exposes components (like `c0`, `c1`), comparing those is equivalent to full equality; otherwise compare the full GT element directly.

## Precomputation Notes

- In gnark, `vk.Precompute()` builds pairing-precomputation tables for the verifying key.
- For Noir, prefer to:
  - Hardcode the points above as constants, and
  - Precompute any pairing line coefficients for `alpha`, `beta`, `gamma`, `delta`, and the fixed `IC` points (if your pairing library supports fixed-base precomputation).
- If you can precompute Miller loop line coefficients for the fixed G2 points, do so outside the circuit and hardcode them.

## 4) Randomized PairingCheck path (Poseidon challenges)

The randomized Fp12 checks use a public seed and in-circuit Poseidon to derive challenges:

```
rho   = Poseidon(domain=1, seed, public_inputs[0], public_inputs[1], vk_hash)
alpha = Poseidon(domain=2, seed, public_inputs[0], public_inputs[1], vk_hash, rho)
```

For SP1, `vk_hash` is hardcoded as:

```
sp1_vk_hash = 6446815737053153707797248679798859719027829623554482675155244433404538974249
```

This value is computed as SHA256 over the 12 Fp limbs of `alpha_beta` in the standard
Fp12 coefficient order (c0.b0.c0, c0.b0.c1, ..., c1.b2.c1), concatenating each 120-bit
limb as 16 big-endian bytes, then masking to 253 bits.

### Additional inputs (randomized path)

The randomized entrypoint adds:

- `seed: Field` (public input)
- `trace: PairingMulTrace<3>` (witness), containing:
  - `mul_by_034: [Fp12; 132]`
  - `mul_by_01234: [Fp12; 66]`
  - `squares: [Fp12; 65]`
  - `muls: [Fp12; 27]`
  - `fp_mul_witnesses: [FpMulWitness; 12702]`

`FpMulWitness` stores limbs for the base-field product `c` and quotient `q`, each as
three 120-bit limbs. The witness generator pads unused entries with zero values.
