use crate::types::VerifyingKey;
use noir_bn254_pairing::fp::Fp;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp6::Fp6;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::BigNum;

fn fp_from_limbs(l0: u128, l1: u128, l2: u128) -> Fp {
    Fp::from_limbs([l0, l1, l2])
}

fn fp2_from_limbs(a0: [u128; 3], a1: [u128; 3]) -> Fp2 {
    Fp2 { c0: fp_from_limbs(a0[0], a0[1], a0[2]), c1: fp_from_limbs(a1[0], a1[1], a1[2]) }
}

fn fp6_from(b0: Fp2, b1: Fp2, b2: Fp2) -> Fp6 {
    Fp6 { b0, b1, b2 }
}

fn fp12_from(c0: Fp6, c1: Fp6) -> Fp12 {
    Fp12 { c0, c1 }
}

fn gamma_neg() -> G2Affine {
    G2Affine {
        x: fp2_from_limbs(
            [0x4322d4f75edadd46debd5cd992f6ed, 0xdeef121f1e76426a00665e5c447967, 0x1800],
            [0xaa493335a9e71297e485b7aef312c2, 0x9393920d483a7260bfb731fb5d25f1, 0x198e],
        ),
        y: fp2_from_limbs(
            [0xaf83285c2df711ef39c01571827f9d, 0xefcd05a5323e6da4d435f3b617cdb3, 0x1d9b],
            [0x36395df7be3b99e673b13a075a65ec, 0xc4a288d1afb3cbb1ac09187524c7db, 0x275d],
        ),
    }
}

fn delta_neg() -> G2Affine {
    G2Affine {
        x: fp2_from_limbs(
            [0x3d3b76777a63b327d736bffb0122ed, 0x41f4ba0c37fe2caf27354d28e4b8f8, 0x3ff],
            [0x865e0cc020024521998269845f74e6, 0xcb8de715675f21f01ecc9b46d236e0, 0x1cc7],
        ),
        y: fp2_from_limbs(
            [0x266e474227c6439ca25ca8e1ec1fc2, 0xd3274441670227b4f69a44005b8711, 0x192b],
            [0xd7f8b2725cd5902a6b20da7a2938fb, 0x9cd7827e0278e6b60843a4abc7b111, 0x190],
        ),
    }
}

fn alpha_beta() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0xa1ade8b03e8b987d3578b630dc140d, 0x9b812acb2275e21f0ccfd2b5b2c71b, 0x47c],
        [0xaabe2ef7a97706a8942a30d91b604a, 0xb9be47b538f0c82106a3fb9b1e13da, 0x2e96],
    );
    let c0_b1 = fp2_from_limbs(
        [0x99afc69013773684381d2c74892018, 0x1f1d74c43656ee464741e6399c7237, 0xd22],
        [0x941c208b4fbc53d65aedcda7805cf4, 0x69ecd427a0ce90dce160e1de184905, 0x1ae0],
    );
    let c0_b2 = fp2_from_limbs(
        [0xcf123696b3ba61a91d739d7f8f06d, 0x3910f5f590d5910ffe4610de63e7dc, 0x1176],
        [0x997fe53031ccd822922facdac67ac5, 0xdda5649d0d0c861bd1e1b3ecedd2dc, 0xfa3],
    );
    let c1_b0 = fp2_from_limbs(
        [0x12cd3e2c33863498d5c913e5a8b842, 0xb627bc5985831858c16686982b1936, 0xfa5],
        [0x51d4bf1954e7c38dc83ad48fe8fe49, 0xb58bd40a46bdfc4b5b84c4b8254e37, 0x1650],
    );
    let c1_b1 = fp2_from_limbs(
        [0x6cfeef5f8a6cb7436a6993f2ede1e4, 0xf2efd31e0684176c24c07bcd59dbfd, 0xa28],
        [0x80d70a0ae1724dd8935bbcca6fe574, 0x2257e8e26c9335e43a8ccc062db079, 0x2bd8],
    );
    let c1_b2 = fp2_from_limbs(
        [0x61029c66caf40ca88899036fa48094, 0x7a5d05d208ec0d189852bc3fcef800, 0x1a62],
        [0x38b4d32805c8d7862a2499dd4fccd3, 0x11fa3287536b8ab776bc5889266c4, 0x11c5],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}

pub fn sp1_vk() -> VerifyingKey<3> {
    let ic0 = G1Affine {
        x: fp_from_limbs(0x24779233db734c451d28b58aa9758e, 0x1e1cafb0ad8a4ea0a694cd3743ebf5, 0x2609),
        y: fp_from_limbs(0x25489fefa65a3e782e7ba70b66690e, 0xf50a6b8b11c3ca6fdb2690a124f8ce, 0x9f),
    };
    let ic1 = G1Affine {
        x: fp_from_limbs(0xed36c6ec878755e537c1c48951fb4c, 0x3fd0fd3da25d2607c227d090cca750, 0x61c),
        y: fp_from_limbs(0x5e9a273e6119a212dd09eb51707219, 0x7ae9c2033379df7b5c65eff0e10705, 0xfa1),
    };
    let ic2 = G1Affine {
        x: fp_from_limbs(0xfdec51a16028dee020634fd129e71c, 0xb241388a79817fe0e0e2ead0b2ec4f, 0x4ea),
        y: fp_from_limbs(0xa9e16fca56b18d5544b0889a65c1f5, 0x6256d21c60d02f0bdbf95cff83e03e, 0x723),
    };

    VerifyingKey {
        ic: [ic0, ic1, ic2],
        gamma_neg: gamma_neg(),
        delta_neg: delta_neg(),
        alpha_beta: alpha_beta(),
    }
}
