use crate::types::VerifyingKey;
use noir_bn254_pairing::fp::Fp;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp6::Fp6;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::{G1Affine, g1_affine_infinity};
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

/// Poseidon input hash for SP1 verifying key (alpha_beta limbs).
pub fn sp1_vk_hash() -> Field {
    6446815737053153707797248679798859719027829623554482675155244433404538974249
}

/// SP1 pairing-check preimage: FE(t_preimage) = alpha_beta^{-1}.
pub fn sp1_t_preimage() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0xcd880fc71b32452a5324c62edc92c2, 0xb9080b7c2a6afd02d2ab1df32a0de2, 0x1485],
        [0x600d6ce94a2ec7c946936df26d54d, 0xaab8efdce7292991f6a07f5836e8c, 0x18b3],
    );
    let c0_b1 = fp2_from_limbs(
        [0x51f8ec2c3269fdfe8140dd0b4557eb, 0x8fd6a7e00d1ec7b378d5d9066ae94d, 0x1c88],
        [0x65149e762a0f194bea7177c23b43ce, 0xa195e2d362721d9d07d990d259d149, 0x2435],
    );
    let c0_b2 = fp2_from_limbs(
        [0xa3c586b9480262bf5cc25d3299c9fa, 0xc6aeef879e18c66be0c7a3617b7ff8, 0x1795],
        [0xc3ac98de3d588388fa46f6a10abbee, 0xca6a7134280bba0548ed98abbae202, 0x303f],
    );
    let c1_b0 = fp2_from_limbs(
        [0x3a5a6e14c8481ef1054c919532fdc, 0xc684f8f7d17b4ce6cf6f761c22881b, 0x25de],
        [0xa020ffacd4a2b772b45b39cfc94696, 0x212173dd5108b102c149e1e165da20, 0x208f],
    );
    let c1_b1 = fp2_from_limbs(
        [0x981bb6b4aba9212db8419418d974fe, 0x312f573162985df20296c1926a5fbe, 0x1a9f],
        [0xa99a11fb1bd88669a1d30679573243, 0x7e317a16c26c0fa9b4ba83a63a0399, 0xc8e],
    );
    let c1_b2 = fp2_from_limbs(
        [0xd0e1a0ca46f03d2d1b0a8326547e86, 0xd0337602f5b5cf330e166986842f64, 0x1b53],
        [0xfb2e33c3461cebde7071790717a2bb, 0x9348750ebf1bbd5c4c554a738f1cb, 0x1de0],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}

/// SP1 Groth16 verifying key constants.
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

/// Precomputed ic1 + ic2 for SP1 circuits that combine inputs.
pub fn sp1_ic1_plus_ic2() -> G1Affine {
    // Precomputed as ic1 + ic2 in G1 over BN254 Fq (same limb format as this file).
    // Generated by `groth16_verify/scripts/compute_sp1_ic1_plus_ic2.py`.
    G1Affine {
        x: fp_from_limbs(0x16177598b9d0369697230b2e296916, 0x5af24b707167681d410040d2ad4df8, 0x426),
        y: fp_from_limbs(0xa285de7196175d462ec4ce4d17a366, 0xf806536b89c0deb69e20e68f353643, 0x29f5),
    }
}

/// Precomputed 2-scalar MSM table for window size 3 (Straus/Shamir).
pub fn sp1_msm2_w3_table() -> [G1Affine; 64] {
    // Table index is `a + 8*b` where `a` is the 3-bit digit for input0 and `b` is the 3-bit digit for input1.
    // Each entry is `a*ic1 + b*ic2`. Generated by `groth16_verify/scripts/compute_sp1_msm2_table_w3.py`.
    [
        g1_affine_infinity(),
        G1Affine {
            x: fp_from_limbs(0xed36c6ec878755e537c1c48951fb4c, 0x3fd0fd3da25d2607c227d090cca750, 0x61c),
            y: fp_from_limbs(0x5e9a273e6119a212dd09eb51707219, 0x7ae9c2033379df7b5c65eff0e10705, 0xfa1),
        },
        G1Affine {
            x: fp_from_limbs(0x777c16d463e89f8b702ab5c5b33401, 0xa790215d6c0d058de7a94134ea11ad, 0x302d),
            y: fp_from_limbs(0x853af1b69d5b8e89c815fd14cbbb35, 0x3543859c3e36b58674cfed607aa461, 0xa8b),
        },
        G1Affine {
            x: fp_from_limbs(0x7356a5f10aabd77001d586640e5c77, 0x6224a0f44095a6229ee26c2727f4a2, 0x2b8a),
            y: fp_from_limbs(0x30b94a485e0242ed61fc6ce2e2116f, 0x546f0665e0ad3c59605cc0225519c0, 0x25a5),
        },
        G1Affine {
            x: fp_from_limbs(0xd0d518a5c3c09b62f8dd0789337734, 0xfec58bbe6bc845c6a97967c9dc3476, 0x1c52),
            y: fp_from_limbs(0xb75a540749642afad99acd7f88fa51, 0x90ac3e284a191a6c8b6da11900ed09, 0xc10),
        },
        G1Affine {
            x: fp_from_limbs(0x9d94687107158c58562fe0a26f9960, 0xfeda309d85708afd6575ab6b4b9566, 0x24a0),
            y: fp_from_limbs(0x28d8465c93ecbc644e12b7b433c4eb, 0xa971bd6d3a922e8c5027c55736d142, 0xef1),
        },
        G1Affine {
            x: fp_from_limbs(0xab533e92c9d81d606103dce4967cf2, 0x8feb442717bd547b001a60e9ed59c6, 0x1024),
            y: fp_from_limbs(0x890ddf95de0e4dd8af9cb7e8bb188c, 0xaec1c79285e121ab48c81d72c1215f, 0x2acd),
        },
        G1Affine {
            x: fp_from_limbs(0x2f7e70f91f1958764a88da4aef036b, 0xb69e6f154ced5c266fa33d87c735cb, 0x1c0b),
            y: fp_from_limbs(0xd799ea618f90b21286cc2d45dad074, 0xa8b803c7a7525e677688c6c222a2af, 0x175f),
        },
        G1Affine {
            x: fp_from_limbs(0xfdec51a16028dee020634fd129e71c, 0xb241388a79817fe0e0e2ead0b2ec4f, 0x4ea),
            y: fp_from_limbs(0xa9e16fca56b18d5544b0889a65c1f5, 0x6256d21c60d02f0bdbf95cff83e03e, 0x723),
        },
        G1Affine {
            x: fp_from_limbs(0x16177598b9d0369697230b2e296916, 0x5af24b707167681d410040d2ad4df8, 0x426),
            y: fp_from_limbs(0xa285de7196175d462ec4ce4d17a366, 0xf806536b89c0deb69e20e68f353643, 0x29f5),
        },
        G1Affine {
            x: fp_from_limbs(0xada5542323859fb92f550330b19d52, 0xe9f4635b3cf1c71a7577b183595b60, 0x469),
            y: fp_from_limbs(0x6a5825a8e6bc1af96218fb17659b3, 0xf5880878602acf94575923a6f1b69b, 0x24ed),
        },
        G1Affine {
            x: fp_from_limbs(0x6048e5a5f1cd6ed2574b3d397c6dac, 0xb6ce590c02ccc1d1f5d73bea8e2e9e, 0x2f62),
            y: fp_from_limbs(0x9cb7bab1ddc3dae7e95ac53e7c2d9, 0xc31c9ff11266b588e4f3bf1f246cba, 0x2a0f),
        },
        G1Affine {
            x: fp_from_limbs(0xa37695428e7dd0348f55cc76383d8c, 0xd2b1dcd83074ad40f32ecdfc36b30d, 0x14dd),
            y: fp_from_limbs(0x86b2d1365cfd30077ed6e9f564d57d, 0xdf35d2a36282f7281ae0971c7d9dfb, 0x8dd),
        },
        G1Affine {
            x: fp_from_limbs(0x4bc280fd425df356b575f4f24d14b9, 0xfa18924e80832c8b416ad0b98e413, 0xaee),
            y: fp_from_limbs(0x1c5837ee1f4eb7c2e08ab1c3423a35, 0x528483dc3e4ffe10d11ab2633df896, 0x1d9e),
        },
        G1Affine {
            x: fp_from_limbs(0xf580e8e2b9c6cfcfc8f457c9a0e1da, 0x3222f8fd334d9ec204fcdb0d78dee6, 0xf10),
            y: fp_from_limbs(0x47dd2b3c42c1284a2054d1a6e5a684, 0xcf360b739560c7657f947088e7b06b, 0xa34),
        },
        G1Affine {
            x: fp_from_limbs(0x8e703d81fbf4428820de18d8e13899, 0xfcf782ab1755eb469970815ce494b5, 0x1d87),
            y: fp_from_limbs(0xa857709f64899a62786db451f185ba, 0x2e0790941e7c2bc9251601c8ecdce9, 0x47),
        },
        G1Affine {
            x: fp_from_limbs(0xfac504b53801c57df724917dc4c401, 0x7bf2fb905f69364bc1390ff829a424, 0xb41),
            y: fp_from_limbs(0x849d465bc8246ea8db98bdd168e78a, 0x4c12ab664aa4bb8e3bfd1cec1fef68, 0x960),
        },
        G1Affine {
            x: fp_from_limbs(0x706be7f3787ec5c16d63398f3fb7ea, 0x5623cf9d86bc30fb9971deb094cae8, 0x2da2),
            y: fp_from_limbs(0xcc41c254a59385883d64cd73b52f9a, 0xe53790d0a8f90dadd42f8b47ddb5c3, 0x1501),
        },
        G1Affine {
            x: fp_from_limbs(0x4de4b1f72f4118e94a607bcfeab619, 0x608525200302f4dfa93a979ce6ebd1, 0x2d44),
            y: fp_from_limbs(0x74412a2e216026669ce6cf5348a99e, 0x10ef0f7d4aa61402d6468142f9b7aa, 0x2471),
        },
        G1Affine {
            x: fp_from_limbs(0x7857066851cebf544d80bdbb27efbc, 0x4a83eaa5c0d7c32e872308033c7871, 0x19e2),
            y: fp_from_limbs(0xff7bce44528ccc3c74b0c92f84008b, 0xc50be7ce9e28d9eb9f962bb8452cb1, 0x1672),
        },
        G1Affine {
            x: fp_from_limbs(0xcd880dfe391227851c3aebe695acb1, 0xf175d8843e642c3604584a43508872, 0x18a5),
            y: fp_from_limbs(0x661ba67a836a4e7b543c69661cd36c, 0xc588b8bc0d6e53ed2b797bd1fbf23, 0x1346),
        },
        G1Affine {
            x: fp_from_limbs(0xccbe1339321ea5a77393757c3e3498, 0xff2de297e1df8920633b468e72583e, 0x1937),
            y: fp_from_limbs(0x1d52f6797acb1786f8bc3c2e4d2cb2, 0xec8ab58537b4899cc25fb2690e0701, 0x191c),
        },
        G1Affine {
            x: fp_from_limbs(0x677cfe5e853cd17894ecb6fb61b4cc, 0x4d638950f0a5dac6b1e60140624558, 0x1f18),
            y: fp_from_limbs(0xfd8d0673cf662bd24d03b648db62f2, 0x4878d1013cd4e7edc6ebeb8c5886c2, 0x1ba7),
        },
        G1Affine {
            x: fp_from_limbs(0x58e0de5057acca85db82be81d44948, 0x562de24e3557848015fbbf3f9f7a26, 0x1a58),
            y: fp_from_limbs(0xb248588bd5fc49710d4b1918a84cb9, 0x915dfbf2af3035a0c582abdb9e5076, 0x23a1),
        },
        G1Affine {
            x: fp_from_limbs(0x39cc158f9955635d640812ed912840, 0xf08c0d6f241d4f4430a0b9bc1f8ae0, 0x212e),
            y: fp_from_limbs(0x741b512552750b5bbc900dc313d7e8, 0x826de61da342b95c20f8af8a6e281b, 0x9e4),
        },
        G1Affine {
            x: fp_from_limbs(0xfa36f340a20ba9ee20ad625df53250, 0xb92c9abd5934750e5b97f4759d4235, 0x2549),
            y: fp_from_limbs(0x1ebf186eea26c8e9a98a4b3757e545, 0x50a466f151a70f1910bdd196eb2edd, 0x201f),
        },
        G1Affine {
            x: fp_from_limbs(0x1b55790b5a9e47fc8a021b31475a09, 0xcb3e2d0ca1b7a828869260bdd33d00, 0x60c),
            y: fp_from_limbs(0x8010b0f7605243749eabff7702d21a, 0x2888d57a6ec27722e914029797a240, 0x2891),
        },
        G1Affine {
            x: fp_from_limbs(0xe8aefd8c3584b0addef227effccfab, 0xaa5e54cda0fe9572c7c9f58d0b63f5, 0x1188),
            y: fp_from_limbs(0xee874b42741084228ab40b377e2a6b, 0xa606232a256ff7371a57abca496cf2, 0xf9e),
        },
        G1Affine {
            x: fp_from_limbs(0x9cbd36b1b45327cc1a2933fc7f5c82, 0xe28533731fe7a890379da6f304daad, 0x1d7a),
            y: fp_from_limbs(0xebe6e1a9b8696a72a0a09e1ae2d15, 0x8beb3e857c91a48c1325f7df1c3551, 0x2c19),
        },
        G1Affine {
            x: fp_from_limbs(0x68a100d8a8ec277aa0b7781f847a78, 0xc4adfdf2caea76e1020a1e669499ef, 0x385),
            y: fp_from_limbs(0xeef8fe6d717beab39307da02b467cc, 0x61130bde456898023d0919f6f3f31d, 0x1f28),
        },
        G1Affine {
            x: fp_from_limbs(0xc1ac1d5e6cd0d8a985b4a2c4b1a5c4, 0xdd76cb6bcbdb203e4d974c73e55f67, 0x1fe8),
            y: fp_from_limbs(0xcf37fc89bc4aafdec695a61b8ca4ea, 0xe46d83e29f41480b5e9392ca5d467b, 0x3d3),
        },
        G1Affine {
            x: fp_from_limbs(0x6b5dd56a5bc2f6432e9c466987e9e6, 0xdc54d8e562f71f17a013b054ed7a46, 0x14b),
            y: fp_from_limbs(0xca7df2ebdc90991d731fa167d8a291, 0x17e5a4a07a646c5158c0affce52d5c, 0x18f0),
        },
        G1Affine {
            x: fp_from_limbs(0x558bf84121167c77f1cc52b2117bfe, 0x690ebbe36950957921ea2cd75241d3, 0x2844),
            y: fp_from_limbs(0x1f77990c75edbf2ce3c179b1abb19a, 0xf6d9b601594d51d48b8f2f7b3ae1cf, 0x260b),
        },
        G1Affine {
            x: fp_from_limbs(0xf958079cdf9b3785c74155240ef771, 0x44486361434ca6df115367692f0e8e, 0x263c),
            y: fp_from_limbs(0x19491b40bc14304cd690858405e3bf, 0xb91fdb04a77fd8e5f90574f6ff329, 0x2ac0),
        },
        G1Affine {
            x: fp_from_limbs(0xb2af1d6628df67be4c4d6c2f14943e, 0x500764ef055fa1502e104d0f26691a, 0x212f),
            y: fp_from_limbs(0x4774b7677982334159b3e223ecde35, 0xcd4b257f3bb853e1ffeb3651841ff8, 0x6a4),
        },
        G1Affine {
            x: fp_from_limbs(0x63b1044b00adeebdcfe44ba8a8b908, 0x15c4042ce9d61526f0863d240fc755, 0x1eaa),
            y: fp_from_limbs(0x9e7103445de6fd40ea12ea2cb7050f, 0xc47f3e7cf7fc02fb0599830541ae43, 0x22ec),
        },
        G1Affine {
            x: fp_from_limbs(0xf5f6496df2f0d186c719c10b12ccc2, 0xfbff17409e592ab0311a629210a312, 0x330),
            y: fp_from_limbs(0x40b6e44624e337aa05d7cd45476242, 0x43fc0455a0de4c108611e8caca41b9, 0x13b1),
        },
        G1Affine {
            x: fp_from_limbs(0x2b7b87dcb3c5f3df719d570f8f07fa, 0xe9989e1f3feb697f4280ed276ec47c, 0x13ee),
            y: fp_from_limbs(0x4434bb6bd962ac38936320574059ac, 0x78b0c4c39c954d1a8b9d70391873d1, 0x188b),
        },
        G1Affine {
            x: fp_from_limbs(0x55917a074db8a078e906684da5d13e, 0x3fdf18a15370eba7ea0346e19aa1dd, 0xccc),
            y: fp_from_limbs(0x29e157307cf8cf4c8bba4f64833a37, 0xbd38631fa873deb852f8d780e108e0, 0x1ddc),
        },
        G1Affine {
            x: fp_from_limbs(0xb73bec9c0ea8e99dc9c15bafbafe55, 0xa352b4f31f0641f965f489d046454e, 0x2e7b),
            y: fp_from_limbs(0xd9f6ff5d2ae1f8c0556a46ec510fd1, 0x8eda1d4287467047e59fb1135f0dd0, 0x2bd8),
        },
        G1Affine {
            x: fp_from_limbs(0x61fe9a51abbd4f32c8bcf8fb49d8f8, 0xbd438b5bef0670aaff4f21c18e84f1, 0x1651),
            y: fp_from_limbs(0x31f4ce8d9c4562620c42fa0a82040e, 0x7933b6c2eff1abb401389c689d64ab, 0xdc2),
        },
        G1Affine {
            x: fp_from_limbs(0x7458696d0b00c01be5ccfc21cdeaf1, 0x7a842f312c144069737670b095ab3a, 0x61b),
            y: fp_from_limbs(0xbb8c2bac0413bd9fd211fc356066d1, 0xb7713e0b50a33d5a0ff0ef85a826e6, 0x122a),
        },
        G1Affine {
            x: fp_from_limbs(0xcea47a16aadde5c85d5752d4986c04, 0xad0db4f105d27b8db5cbe2e93b33cc, 0x1df9),
            y: fp_from_limbs(0x6095e766020f8b5e915fda7f54d1b5, 0xbe98e3466353658b533c7130935f50, 0x575),
        },
        G1Affine {
            x: fp_from_limbs(0x461f46a7f7815485fbbd4ca84089e, 0x2f39d8ed8648517c253ef3c984cc83, 0x3c0),
            y: fp_from_limbs(0x52877e2235cdd853dc423185075f09, 0x579ee935821a83ce976ccbcae77d72, 0x1e74),
        },
        G1Affine {
            x: fp_from_limbs(0x181363a12a7d4fb7495bbab5eeac8b, 0x1ac78c915aeaf5f73ceb350fa7b88b, 0x27d6),
            y: fp_from_limbs(0xcffaae2e47ad1b1b6ffdb93d6d559c, 0xf02a1c7b1e94a6cb7793b03c1aceab, 0xedd),
        },
        G1Affine {
            x: fp_from_limbs(0xf1377b257a087cbc0880c3a7f99ccc, 0xa5cd38a1d7eaf7c03e32afdde61557, 0x22b9),
            y: fp_from_limbs(0x1c7b84b3f78ef431239ace42bb97ff, 0x73f104f955afd976bd648c41218a31, 0x2cce),
        },
        G1Affine {
            x: fp_from_limbs(0x2388a4dadc36e2740f0f7079680ec7, 0x49e3d2b88cb726820df1eb544e274a, 0x26b),
            y: fp_from_limbs(0x95e10403e9723b6f78b2ec98f7a95, 0xa8131f8675c000023cbc1fb9df4819, 0x2e5e),
        },
        G1Affine {
            x: fp_from_limbs(0xf6a9b229bb8ec1dbc025a2a3dcc58f, 0xb611b7c162b70072015c7d1deba332, 0xc41),
            y: fp_from_limbs(0xce6ab0e9d763667681e9f32efd60d4, 0x7b29b6a40ab5edccadc665d4ee06c6, 0x27a4),
        },
        G1Affine {
            x: fp_from_limbs(0x3d500761c501f1296bf88509c6eae2, 0x44abd442ae293bca3eb82b06813f7b, 0x237a),
            y: fp_from_limbs(0x13b1d81e2f678da46e206e93a32377, 0xd5099fa6e2f5e6f8b1990aaaa593bb, 0x2a3f),
        },
        G1Affine {
            x: fp_from_limbs(0xc3311e6eb298f656c687510ed3f1d8, 0xcd2fdffe76c3eb5abe1ab70d86510b, 0x1558),
            y: fp_from_limbs(0x7781e006c12eb3a4936a6034ad3bb2, 0xbccdedd16288b80d864829cf3c0a6f, 0x1c4e),
        },
        G1Affine {
            x: fp_from_limbs(0xc770caaf3528fa4370856316105285, 0x77db42179bf8237e457a1bde874acb, 0x1f6b),
            y: fp_from_limbs(0xac0030601b934529fa8302d4f58102, 0xe38955a849eb0b1ead78ea83fa1d1b, 0x1617),
        },
        G1Affine {
            x: fp_from_limbs(0x9aee49cb2a724b22f08774c5f49b9a, 0xaae34c95bf9d8d4f1897baf106da0f, 0x1234),
            y: fp_from_limbs(0xbb0b94b87f7271aa5bff56e387234d, 0x359ec82cfd52fea6804a00fa615b33, 0x119d),
        },
        G1Affine {
            x: fp_from_limbs(0xb7f637dfd513e0762c2759761fa5, 0x1d5ae6a17ed2503b59ad8e646e539f, 0x1fa4),
            y: fp_from_limbs(0x4b4c9d9ee05c971f9edddcc628cca7, 0x80a60f87a3b374a9de15b273d1403c, 0x2e65),
        },
        G1Affine {
            x: fp_from_limbs(0xec1f05bd6e807fa4d91a14a80a81bc, 0x37c40493ab865771ce845e60ef9195, 0x21c),
            y: fp_from_limbs(0x70772f4e183c3e3884b835ca0c9187, 0x58454f4d509c836819400eaf410710, 0x16b8),
        },
        G1Affine {
            x: fp_from_limbs(0x69cf043ce3b520a2793842ca1a2e6c, 0x9088a2a73fd422d890bd39587e6468, 0x1909),
            y: fp_from_limbs(0xcba3c7d698b2e5ef9bfcbe743f8fad, 0xd6c09518fa0f574a670676e08933, 0x298d),
        },
        G1Affine {
            x: fp_from_limbs(0x55709a65c9044d5b1cd7b4f284314f, 0xc9a83e3e1ee0fc27fa63bab3a60a44, 0x87e),
            y: fp_from_limbs(0xa320e48248372f106de937e83cbb50, 0x3206e58a8c68d979dddf200f23b066, 0x2a7c),
        },
        G1Affine {
            x: fp_from_limbs(0x52dec1af68dd9c3c6e93be383bf14d, 0x97471c6377513f50464a3077f69e04, 0x434),
            y: fp_from_limbs(0x14b035616e6b3f91b16646d9a30ecd, 0x8357b0f71d209301841a5203a6172e, 0x298),
        },
        G1Affine {
            x: fp_from_limbs(0x8ac51bd07a2e738f6c9115558f40a3, 0x49186a440c5ef0d7ae8f29bd2ff94e, 0x1a54),
            y: fp_from_limbs(0x62a60753a4deaf4a36a66152384eb6, 0x2c4d8f80e4510b0591e49d8afa9180, 0x902),
        },
        G1Affine {
            x: fp_from_limbs(0xcd77c0f0e3d94acf1042e32b442f48, 0xaccdc9cb20b52dc1c65699303233c3, 0xd6f),
            y: fp_from_limbs(0x14266987b186d5f391e69d5f413f4d, 0x93af089fd9e044f1bea5854cd79aba, 0x16ea),
        },
        G1Affine {
            x: fp_from_limbs(0x38a3f440893cb70d67487f21945871, 0x27f581b9fc67cfe2b58b6bda5e48dd, 0x2a),
            y: fp_from_limbs(0xd7f0677cbca5a53e0f21d0f1346f06, 0x1c3e6d944449fe8d91190e8ca1a16d, 0x2e4f),
        },
        G1Affine {
            x: fp_from_limbs(0x5089eac6045e85d96dd658f322671e, 0xbb52303803c086f3628196b2588471, 0x1855),
            y: fp_from_limbs(0xb89d6f25f4249e7f5bdaa3f05013a4, 0xee915466f2d88943fdac757000aa77, 0x1c2c),
        },
        G1Affine {
            x: fp_from_limbs(0xe82a9394d1f85b03dc21adead142dc, 0x9adb7f7ccf913f2b08ee69763139bf, 0x1c25),
            y: fp_from_limbs(0xaa4e90fa313c03d4c17b7d8026c23e, 0x51d304cc0af9a602878548ede8914f, 0x185c),
        },
        G1Affine {
            x: fp_from_limbs(0xde75b45dc68d365d19209950b43109, 0x4296bf5b42b4cb00adf086386d657b, 0x2af5),
            y: fp_from_limbs(0xb89c5e0bad3f7f9927bfb07f237959, 0x330e55b987856259ef449f679a2fe0, 0x816),
        },
        G1Affine {
            x: fp_from_limbs(0xd9eb15450ca3025055358dadc2ba1a, 0xe81ef29bcf01de50a5cb065559c1a5, 0xbea),
            y: fp_from_limbs(0xbdb1dcb5359fbb07aff42bdec84424, 0xd5b5b2bcc0a2073c23350fb24c99dd, 0x86e),
        },
    ]
}
