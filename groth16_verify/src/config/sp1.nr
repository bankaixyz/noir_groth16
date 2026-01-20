use crate::types::VerifyingKey;
use noir_bn254_pairing::fp::Fp;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp6::Fp6;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::{G1Affine, g1_affine_infinity};
use noir_bn254_pairing::g2::{G2Affine, LineEvaluation};
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

pub fn sp1_gamma_lines() -> [LineEvaluation; 88] {
    [
        LineEvaluation {
            r0: fp2_from_limbs([0xa3ced21887a6f699cd9802cdf4fb54, 0xbd4bb718dbd69556e3011b96811fc7, 0x2590], [0x966266e1671de6ab59b5b9a2452eb6, 0x13a0b0bfe0ebd93d335ad218672b78, 0x120d]),
            r1: fp2_from_limbs([0x2acf7ddb7ad74c028c1a0bd146a17d, 0x437ba87bf892de86475ec2155dd6bf, 0x2f6a], [0xf3267310f51196b7463fd620b3b35a, 0xc4dd8bf1d0a89f2a486ff97fe6ba7e, 0xc2f]),
            r2: fp2_from_limbs([0xb438bbdf5a33b01c62291ec21ef35e, 0x6ffff444379dc2e1719e9c2dfa84dd, 0x2fdb], [0x3254d06c8c5a375c2d23c3e377fa32, 0xa04b05921f5d350f523c3ccf10bed7, 0x828]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xa82229858fce6a4911165728dda396, 0xa068a30500c2551e64270b3d39d784, 0x1e5a], [0xab3461975d253f51747802fa055ccb, 0xa1605c1135d2ac90863b5252c1959c, 0x1a91]),
            r1: fp2_from_limbs([0x17a7f673c4bae392e34187bad5904e, 0xc2dcf0a82ceda849c7f90d6ed83ef5, 0xbaf], [0x9d8de9c7a2281a6214c1c06702bd49, 0x11f337d9540a423cbb84dd38dce539, 0xbdb]),
            r2: fp2_from_limbs([0x512714012eb84e4c0dbb20656b4bce, 0xef5accc8cd53e4836f0937190108ce, 0x2f1e], [0x2ba073a0e774835890e8d7ad4f3691, 0x5bd3095403ef2770263c4659d095b2, 0x2b25]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xa82229858fce6a4911165728dda396, 0xa068a30500c2551e64270b3d39d784, 0x1e5a], [0xab3461975d253f51747802fa055ccb, 0xa1605c1135d2ac90863b5252c1959c, 0x1a91]),
            r1: fp2_from_limbs([0xd1ca50961a4e71285cc3bc3972cf15, 0x91ce3bee74799a7d12a62913078297, 0x106b], [0x7182f924a73e75ec5251772ac96a4e, 0xe8e019e243c2e8be77a81eee53f094, 0x9ba]),
            r2: fp2_from_limbs([0x2f09e06f48e42bc86407f101a0b219, 0x4cab4ca5cbd2d8e5c45025250e283c, 0x2453], [0x544032f72b2bae5a306169cec59c2c, 0xafdb82e82a1581a7f051fd72bc0381, 0x198]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf696df75c66c6183780b84679dfcfc, 0x50e5b10978f7ff303fe75f8166d386, 0x9c2], [0xd1b6dddb7a269f5d2f1140ed4a3f63, 0x90ba657c5492af8db26ffe65f2eaa4, 0x14b3]),
            r1: fp2_from_limbs([0x284559dce3ef45f9877ed036afafbd, 0x37722703751d290a9af3d2fac7e06c, 0x23cf], [0xba7d644d6d1485133957b760f93cf7, 0x69560bbb78670a24d1b344d839e266, 0x304c]),
            r2: fp2_from_limbs([0x998e607902f89f764f8c17e8a5791e, 0x1631de1444ff04c6634b8a8f16d8f6, 0xd0f], [0x9f525eb7e65f202ca52337a2fedf00, 0xede27e30332cf41e40f9739f314589, 0x2167]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x8d4ca48df28f4a0ad4167750e3ba76, 0xbc1060640d7f46f6116f2c7a1a131a, 0x112b], [0xf7f6e2aa0cd24c895245a213ecd163, 0x88020f2481f29079930ae34a947df7, 0x21db]),
            r1: fp2_from_limbs([0x8ad3ddd0f8a0531e6e2a84a9456766, 0x3f301fc798ee1df94c1ee49917db49, 0x2963], [0x77a4621b89b56d4121a11823681be6, 0x52a5c83adba194d40a417699e837b9, 0x19f4]),
            r2: fp2_from_limbs([0x230c3730d2117c826100c8a18228c9, 0x90620dd5271464e65d566c9f321f1a, 0x15a4], [0xe2d5b53aa3728f73f3ccc7e696f1d8, 0xdf3fe8522bf28a134def5317e622d2, 0x1be9]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xfb067c10d74e05cd6832f65421e84f, 0xd26d7daa26555628dce1e3bdd00b8, 0x17fd], [0x77f455410176748c6fa7e106fce3d5, 0xfc588e83cb30505b24dd083519dedc, 0xcbe]),
            r1: fp2_from_limbs([0x444adb45ea14b25a657cba051922ad, 0x32d2968eceb8389be40e4132754c8c, 0x1fb], [0x56c98ae11b47217bde50948ffa53aa, 0xf0cb949c619ef363e006ddd697e54c, 0x9a6]),
            r2: fp2_from_limbs([0x5c344fa8b64d1746ae002a5fd45fd6, 0x935c9c424e0b3834bae755e17c7cca, 0x2649], [0xf9ff97c552c64d25b1eab05934bfbf, 0xf1f0024334e940ff1adbb9c865e4d4, 0x16db]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x3b0fc20f2bc0ace724dfe0d0ddf4c2, 0xb35e6b57c1e63f65d4d80096a5a8d8, 0xf69], [0x3e5ec8c226f36bdce1f4c6478ff00a, 0x41c3ef486793f486e6ba13b125f3e1, 0x4c8]),
            r1: fp2_from_limbs([0x3fdca19b8e07727652c2ea9f60983d, 0xd99a3654d7c91e281c341d57857ebf, 0x2e90], [0x9a5f9d013435c69a88017a0c7d873e, 0xcb17a77a75fa93361ab83b97e0bbc5, 0x264e]),
            r2: fp2_from_limbs([0x73c78e90cedd9abccff8d134530fcc, 0x6d01a507c090e7a391fc21f1516e4d, 0x14b], [0x2e02698ac9a4e16e3a8c53a725bbea, 0x58f7d68849c6c4b91e6886f994019d, 0x1fa9]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xfb57e7cf3657efc10a0bec4f2bdc99, 0x27808c04a10a7fda39aaabebe0a846, 0x205a], [0xe216b0aa86144d3d38c9c08554f150, 0x45b8c99eb45945d4d4ec4fc562ccc3, 0x2630]),
            r1: fp2_from_limbs([0xd59cf531e594a850ad60d856059667, 0x34579f070658b508f910c28c8e2113, 0x13c], [0x6a0aea85c96a771b5837f5e35c62b6, 0xe597c7cff164470aa094b42e6d0872, 0x26cf]),
            r2: fp2_from_limbs([0xaa9b249d6d73d86b8bb0ace5c7fab8, 0xa97a147683bcfd6e287742e9bf5494, 0x155], [0x5a001d94246f5420b381c7b8f26fa7, 0x18862b4aa3884b6d8eee5a92d76808, 0x22d9]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x5dbd5088bf0ce786df8feb9d64da68, 0xa22b3e097fa1fdae9ea43b32f98e92, 0x795], [0x975a17d19dfbd0c530c9b5e0710709, 0x642585dc02e7d78f75ecf9e77acb3a, 0x7f3]),
            r1: fp2_from_limbs([0x3c16afeda5fa0f3221f073dcd094e9, 0x9b9bb9b33553f49accf7259b1ac050, 0x1d4d], [0x66aa6a332a4256564ea99598b37ee1, 0x83c56739bced57d305840b87f26ebb, 0xd10]),
            r2: fp2_from_limbs([0x9ff3c269a752e1be51531a7f6d0346, 0x93e8c611f675ad93fa226589197b37, 0xcb9], [0x5e5fde1cbe110e486b059d59ee6c58, 0xe7b980149c1534bf20c8b0c512ba4e, 0x24e3]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe0c28427bd6653b3b2c97a650a4847, 0xab22565e89498b9d7a853f23bf6e3, 0x26ab], [0xb338840fe443e0a07c302dc3b2c14f, 0x400cd5b4d836529841eb26174cbfff, 0x2db5]),
            r1: fp2_from_limbs([0x3489f175103586a1a2b000593b49da, 0x11215b2405f485db987cb9b41d8948, 0x6c6], [0x669aaf5cbcf9ab117f2d1c81cc313c, 0x59c244d0a8c10fc20c9952dafa3c23, 0x1813]),
            r2: fp2_from_limbs([0xba85f2295078328bce36675838b6d2, 0x8cf9098f245fda348affef854b51bc, 0xb7b], [0xad175edf50cd71a39494b2ef46d74a, 0xf22c541aa86870029386141a214187, 0x2364]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd5a08a543267bc4db14c7dfc11982d, 0x9b93476c9f1669f96b01fa6ddfdbc7, 0x2ca9], [0xfb590cf60eb25cba67ba008c3ae184, 0xd6b4a6be6340af0dc119ac1623cf8, 0xcea]),
            r1: fp2_from_limbs([0xfcd85c9969c6482342e3dc18d3bdcc, 0x880fdc510e728dee8d0334dac38c10, 0x108d], [0xb5a0b7476892984d96f59d506e5074, 0xe4e8fef9d868ddae4e79f4ef5bc175, 0x1e46]),
            r2: fp2_from_limbs([0x22beaab4199a27709ee4060a6cd7dd, 0xebb1cb735dc93d34942d2481972efb, 0x1d48], [0xf0cd67862ee901cca772ba949dfb76, 0x5bd0b398d7c81536ca1f52362cfabe, 0x2f81]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1ba9f5b6d17131cbeea02f534531bd, 0xd9d32b75611d9abfb7df5f1c8b7fad, 0x18f9], [0x2b914f5f0d2e2426087395b1c66151, 0x8374aa9b74de0d058c872f3ec385fa, 0x220f]),
            r1: fp2_from_limbs([0xd851186340f29a85145be415eca39, 0xa7d76564855086fd067dd3f1749a76, 0x1c68], [0xd7864ee5492aa9ef873ac25a7d2269, 0x1354bf251cb19edec6adb81a6cc68f, 0x1b45]),
            r2: fp2_from_limbs([0x4e1f268fefa5badf8972c8e0797478, 0x3ce2bcb16a5f9a28bcb2cb6bd91ea6, 0x16d4], [0x929a98e7577b45e08cd44bbb76daf6, 0x76875e5fbdfb05f99f91b8f86edfc5, 0x299e]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x32a57e6766b5713cdbd543bc20674f, 0xea94d98811b4a898c77af27e50e3e5, 0x127a], [0xf194852d5b58a06639d81d527b9ffe, 0x71d68d22e34809aecb96a360f3c158, 0x1ccb]),
            r1: fp2_from_limbs([0x78a2aa553427b7d16a2c376dc274b6, 0x37c1bef366bbaad43314db0ebc8cd0, 0x19a4], [0x8ecf8f8e5412c102ba88003bb86f50, 0xee15037005631396158003fed690bb, 0x17df]),
            r2: fp2_from_limbs([0x340841f8eed89a7130ca9d3ebf3782, 0xe57d0e3fc68096d43fe276d46df511, 0x17b2], [0xe469755922f110fecc883b1842ef04, 0x865ca7fb02fe77367f6b437a4dc95e, 0x2b34]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x653c7404f7a60874163c7f383d82fc, 0x7203585067aba7ab4f6194c6cf2a23, 0x2e12], [0xe9d4957146454638d256ee13b5b433, 0x6e4458134c4d76df190eeefa6fa150, 0x1424]),
            r1: fp2_from_limbs([0xe8c745c232dc0310e13e9603b41f2, 0xc4230ef711b17259029c932bc47b04, 0x2b7], [0x73874d62c3fd7c3da0707c82afe937, 0x98124f55dcc1467e4dfec8bd4d85e0, 0x195f]),
            r2: fp2_from_limbs([0x7db3679f5326bb98652242965bacc7, 0x77dbb4ea3d9b5f6c0cf9cbfb56d749, 0x6b], [0x84e7a587e2810d82a7dfaf588298a6, 0xb585f5b39149b4f5cb90f1c0b64fda, 0x18e7]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd1a4469a29ac0436a4f78daf27c57e, 0x5dac3712796061a1e94b38a5830b9, 0x1c70], [0xf5cf9c950489e714b3014d1d9bf80d, 0xa43a3f321131785f3ff67eb1027dc3, 0x801]),
            r1: fp2_from_limbs([0xac8be7f35c6950a75d354632a8ccfd, 0xd64c332327297a59a6f8814af92afc, 0x53d], [0x6c11b14ea17b796090ab1c7e719f, 0x4ff4b4f6e036048a91826a3ad1057b, 0x3000]),
            r2: fp2_from_limbs([0x4c5e594cba67215475bc31611920c6, 0xc3183bd2218ee4040efa8322470ff2, 0xd96], [0x8231304d5755de7a74a22f87754a98, 0x5f7cc2084511b353771cbf62d647e, 0x2dcf]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x865bdee09c9d0518da594e324e180e, 0x6ace5358426a9e98a827327b582854, 0x1dcf], [0x1a76a3fda36527c3e4e8dd108ee5e2, 0xd0fa19f45ad247ae51fca854dfec7a, 0xba6]),
            r1: fp2_from_limbs([0x7d342031130091795b504f7b95ca19, 0x4e7c3202dee473c214dcb8b156fdea, 0x2621], [0xf8b879640844ce20142e0ef42c8f64, 0x70197dee3d78fffadfc8265fc1a086, 0x4e3]),
            r2: fp2_from_limbs([0x286edc86cc583f0af0f2a028ca2ed1, 0x3288e59a7bd9e6e747a5107a9d9f63, 0x2ca6], [0x7e28ff21d4e8492b3b4f337145c72c, 0xc612053950e759c13e9467af385205, 0x28e1]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x72380be98b387869866985c3c2dbdc, 0x94f6c581f8ddbb235705adc42191bf, 0x1fc2], [0xa7e843dd215aa4a7aedca2e7888a23, 0xe75e731508f52b8fa46a31b234cc6c, 0x1386]),
            r1: fp2_from_limbs([0x2fa6d4a213ea24eb48b18111cc4d9c, 0xc36f6367bbfa4d30779e27fac6b308, 0x10a1], [0xca674b077af460f95c558f5fc5bc61, 0xe730b8518499d59e0db0c4e3357267, 0xe3d]),
            r2: fp2_from_limbs([0x35381ef83f696f15459a1c3a4c5584, 0x8782e044c827d574b422c7cc042f8e, 0x90e], [0xf27a550566fa444e87e959dd4e1b2c, 0x7dcc2c3ddb57439aa860df87d1740b, 0x85c]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1586d75717e273bc5da099d26f685c, 0x446bf98a77db74849409333fd0d72f, 0x26fe], [0x8ee578608dac6c7cee25b7873025f2, 0xe30b726146bb64a91dc70c72b113d3, 0xcbc]),
            r1: fp2_from_limbs([0xe8035ef2563ace5b620667e5d79dd7, 0xcd4e09e3ff05f240fb5931bd0b1daf, 0x51f], [0x9cec193c9a02e5a984ae48d9577228, 0xed239a82a2e7aec26d98fde9b47ffc, 0x45]),
            r2: fp2_from_limbs([0x3bdd09748ecdb0770a629ed606763f, 0xe1706e9cd8412f5b4ca71f3570c8ec, 0x119b], [0x7810ac57b92056fe4f7c379422052e, 0x9ef1244680d21be8bed0ac815d4878, 0xc7b]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd6cd07d3753fd2e8ecc86e01c2ceac, 0x8f0737ce9450737bb90ac85609e258, 0x1a00], [0x6b11bf63941f4c87e49367489ea391, 0x91ca838491b679b4905b2f74bb8761, 0x2d94]),
            r1: fp2_from_limbs([0x1310fe5313f7cea1df60c85e93017d, 0x5365d2ad5ecf01db8a4d129b1cf900, 0x10c7], [0xb6e9a62ffac0050b51054300afe4c9, 0x69811aac0a59f8a687c0ea58cb7d05, 0x19ae]),
            r2: fp2_from_limbs([0xed882b52c91985e36e452573bb3fad, 0xa0f8355899148bee00cedfc7a09341, 0x2090], [0x4fdaffa44bebbbb4ae48984d2beadd, 0xe34ef173822a04339767401170e4d0, 0x29b2]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd9299e2361051ef7b0a44a54ac1a4, 0x86927e6b0d37128a05ffdf0ced9f5a, 0x2c19], [0xe0b6c6ca542facc5122a6619119f39, 0x436f4c6633c7fcac72f86a484646f9, 0x1b57]),
            r1: fp2_from_limbs([0x267b40580dfacf34f4cb6434572b72, 0x2283519b89851fe15042f21d482e7, 0x14a2], [0x49897c9659a393580aa6a2dfc4ebf5, 0x89f2815561139ffa4fe993fd504eee, 0x143d]),
            r2: fp2_from_limbs([0xefb83b86296c4ba26cbd90053dd108, 0x9b8ff6488012dcefa97be6ab8e032c, 0x1deb], [0x6bda9b9a0afd1dc479bdda22900b57, 0x927a4ef4cbed25b726eb3594e1c16e, 0x2174]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xb41d958340bac544764535f06a16ac, 0xa181a1ae7cae305fd122d46fb264c3, 0x58b], [0x1c5e48e77ae7599ee2f243405c54a1, 0x245e43998418fb631802f8d63d715d, 0xfc7]),
            r1: fp2_from_limbs([0x51f8957d3dd1f36b680f5d796a932f, 0x2762ba80bf9ebf2702649d61acfd79, 0x25b8], [0x4e06d013931efc68ae866ca2592b88, 0x919f456e1845d1aeb210693d795eac, 0x19e9]),
            r2: fp2_from_limbs([0x79a471fe4b70fe4d68b15e4d5b2236, 0xfb19e4d757fa265477b0fbfdff67dd, 0x26fa], [0x729f11abc9393738f2ce11438a2853, 0x9bb63117cdeb91a78408f1fb98f1f4, 0x2666]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x857e46b833c69d2986667cccb76604, 0xac02c1abba9cecdce3ff7fc56aa25, 0x220b], [0x8f122cf4d2d01b34d5551f1f39bd57, 0x8388ff723112f26cd899cf855592df, 0xd7a]),
            r1: fp2_from_limbs([0x4e95411a4b6c029aea568d299236de, 0x474e71378fe74f8df63abbef7f34fc, 0x274c], [0xff89903aab354dc547b605e80d5608, 0xb96731dd110e3a3192840bee461d9, 0x400]),
            r2: fp2_from_limbs([0x45a38e13cad4e9ea722c84bd112e88, 0x8a87ee15105597021e36fec449689f, 0xb40], [0xd63728cdf8552927e4b15921fd64e5, 0xd1fcda86093fa2a0e766f8261938e3, 0x299d]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x61cf1fb00a1d2793ee18263c818a2e, 0x3f6749ba538e36c48d2b19b3042223, 0x1dae], [0xd077b77b4ab0d5710129bfbcf75ac8, 0xff59ef0970d6f099b7de719cc4c422, 0x2eaf]),
            r1: fp2_from_limbs([0xdea26ec273d815ae979edf286d1f83, 0xf4c16bd89db80e6dcb8e980cc704b0, 0x121c], [0xcc556b0fd1c890fbf0c4b73804a07c, 0x543a9dd6e2ad894aeeb5b00a366b9d, 0x1e88]),
            r2: fp2_from_limbs([0xc5c2c46ed6041d6882d3171da163b4, 0xe3b5aed83e931c17498ed69bef26e2, 0xa1b], [0xcd4d05e76f740e48abc664e3c01dc5, 0x2624a4b1b0e1ad3e4746b73bd744a9, 0x1a40]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xffd0f942baabd849c79624ede152ac, 0xe0c3d10fd34e4eb150a72024ec0782, 0x1f8e], [0xf2b6015b344f69e3ebe0f70daa9fed, 0x6478714f9107e291c11df412ec14f, 0x47a]),
            r1: fp2_from_limbs([0xb5d136ac88da09318782fad63a7721, 0x4d77be6ca73371ff24f6be5e93704e, 0x2703], [0xc5c77e650e7ad5e7f2c3ba165d5dda, 0xe83fb41446748856214f8ad92a4ced, 0x22cb]),
            r2: fp2_from_limbs([0x66ff52c5945318dbe330f2b1368dbb, 0x152bb567953bd09c1aececd4cb7678, 0x34a], [0x4fa9bc6577fb99e58f893760f9a8b3, 0xc50d3452218a1ed52ad0d5115dfc07, 0x16fb]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xb1627b0fd2bd7300624c9a1ef1c939, 0x2b01c88be750d47c20dfd398dfdc16, 0xba9], [0x15546eb7211ab0eb64fa1f0ffb7c44, 0x9aeda1661e1b36a285e897cfdea4a0, 0x1b49]),
            r1: fp2_from_limbs([0x4a7d2987d7c2ccbd477292297151d2, 0xfc236927cd9a5bf070647e3cc92b73, 0xe47], [0xf6f81d049d7e9fd94597a466b633bc, 0x6595e74ea7f4e3a259745f6a4c015e, 0x27d0]),
            r2: fp2_from_limbs([0x213f96684a28081cc79c5f65364c09, 0xace87f20b4463bdb01fdf0ac4956f8, 0x1d5], [0xaea59e5ab38412fa9f32b14494321a, 0x5ad1570aea5d765891da53ba2ba78b, 0x209c]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x883c3bf905b72e48135ee1616498d0, 0x8f7cf732b03fb11d26fc0cf433001, 0x1243], [0xac71b95481446f6a1177a5e59e3a52, 0xb419040516e84bfad2d6dd5f87e2d3, 0x64f]),
            r1: fp2_from_limbs([0xa07789b0c70400b3938f9182c52316, 0xc3da2ca2ac472da515be65f0213d06, 0x1dba], [0x68f38864c2f87f826a3e204c7e7b7e, 0x96534480e1b4908378a292e716419d, 0x27a6]),
            r2: fp2_from_limbs([0xc40605720d93b401ba2264179e9944, 0xe83800b813ccd44de14d508d999308, 0x779], [0x3bbb3a38ebb46c45666f2b9dcb9a76, 0xb211e5b5b65ca733d46baa1ed20845, 0x28a4]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd58f3c8a679b9ff4f5c66e82571619, 0x1d7823953a67775bf6fd250cb3867a, 0x1ac8], [0x2fefbda1e7622da32d2ef35f1d1c0d, 0x1a65b21d4481bc69758c3fec5a4110, 0x2d60]),
            r1: fp2_from_limbs([0xd5066c8314104d781ed5e2ace8544f, 0xed5ebb708c0d0a9d298c195d8d852b, 0x358], [0x46487b39c05d4ad4253f598d271859, 0x4891b8abe699b799767d500744555f, 0x134d]),
            r2: fp2_from_limbs([0xd5cd3568410eb3a291d50a79d4c5ee, 0x471f4c0f12fc0f5db48b4a3bd1e49e, 0x2631], [0xd06527b0545e52dd8f26531f77a2a7, 0xccde5b301821a1d69943dd205d052e, 0x24d8]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x64d5ebe2234bd3291371c0bf7318a6, 0x5605eacec712df0792c71a612a3d14, 0x1eba], [0x77ec9b7ff14f6ff136897133ba0f71, 0xcfc3c97e22f240f834cd181a4cb5ae, 0xcd1]),
            r1: fp2_from_limbs([0xf1a599f9937962d5aa30fe567a5bbd, 0xcdccd4733bae17a07c6b22e526f827, 0x16a7], [0x685dad5d3953d12ab18a2d5e364ef3, 0xfcd4ac019539c5cfed83a6d7c10889, 0x6e2]),
            r2: fp2_from_limbs([0x7401b8550daddf9b6970abc57daa2f, 0x942eb97869ca97fe4e49db504a038d, 0x2759], [0x3c43acb5c6bccfbce184ea5582cbf9, 0x43c100b8369ea82d04b7e80086b079, 0x1e96]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x53bd3d7abe9a20495ce874df2fca8e, 0x3f79dcfe601b525e23d7002dd4a646, 0x10c0], [0x972ebb31d173100d84590b5a556c25, 0x9234e8ac19446635648c7d4f7b5c87, 0x130]),
            r1: fp2_from_limbs([0x1ca3194dd696a434e72a41bafc1998, 0xc2e35203f10321a08a72103f6f95c2, 0x2d], [0x3b4581bc771958a0a2ec45647f9442, 0xe6eb101af37ca3c738101ae289ac12, 0xe32]),
            r2: fp2_from_limbs([0xee17087e7e80035cd66488ff48c53a, 0x3165229006dc727b9e08e656052beb, 0x1f95], [0xf07c6d1655f6ee4d3ba639cfdc0526, 0x7186c0adcc9897b8dcd259235e2a8b, 0xa10]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x85188fbfcb8cafa3ff231a3cfa4ac8, 0x20af7802ccc91232ac94ef45ea6fe4, 0x1f6c], [0x853bf74db744de59093405abc6397d, 0x9816df7b4bf3f85f53cc1d99ef3192, 0x270d]),
            r1: fp2_from_limbs([0x71189672be5228814b80b3ea34f74, 0x170d64934d651ace73cb78e185b745, 0x29af], [0xbab1cef69765dfe53acddc90b25b94, 0x8df266c69a06f7969afd14de5f9441, 0x2141]),
            r2: fp2_from_limbs([0x88cb6537edca925698a601d7d8e5b0, 0x42c9957a1e8339623f9d7a59e1cfce, 0x1da1], [0x3e0fc142c63a50edf9424260ed045a, 0x5a878c3c613ea958a5b14b3e6bb233, 0x176b]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xad89daed941349119f7911bc837c0f, 0xcc0919a595ede17168963cfd93acc4, 0x14ae], [0x2d6223d2d86ee6bae567ab2d2ab694, 0xae28dc8b7612ed954268bcea6b1e05, 0x13c5]),
            r1: fp2_from_limbs([0xbcbdd76f33df61196f0b619d75ec9b, 0x47bda9941829c1e3cfb20a39fa961, 0x2be], [0xb8993a439aa3df75e6199dfea0e95, 0xbf19aebe675877994c34af1d0bb1f5, 0x1df2]),
            r2: fp2_from_limbs([0x1af39e3f54a87b9b7ad656c57da3be, 0x4e1839303eae4cd6254249eca98d37, 0xef1], [0xdc87c70010ba977389670926d8cef5, 0xdffd0e692f81a3bdd0fc45e2d40efe, 0x4f4]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xcc71deae1a14336565721b4b8f4a51, 0x6781ac7e16f3a602f41fdc6e1d8fc7, 0xd80], [0xbea96841391665f810bd7f706cbc61, 0x53126c11c5a0d0c956a24d804d8281, 0x1865]),
            r1: fp2_from_limbs([0x8c9afa89d7c268c9887bb73a592d4f, 0x10136f7b6d1640da2910fa19245d7d, 0x1e36], [0x854ee7db518c8ded25b8d91c8e4d80, 0xcd700991782bcd849fe3b46a339b9d, 0x249f]),
            r2: fp2_from_limbs([0xa957d5bd310feddf15591eb9bfea7d, 0x44dbaa57392d8c8d88ec941a05fc3f, 0xfd3], [0x843bda4a3bb91f40486a47ce12c21a, 0xf97678159e23e3cdbda1e787fdf367, 0xb15]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xda4f2c305557c4fcd9c1950600876, 0x656538d159cd2632a247d42672cfeb, 0x15ce], [0x3fb83223b521f104952288be29645d, 0x3921951b268a81878016033343504f, 0x124c]),
            r1: fp2_from_limbs([0xf720523e601db30ac07f5ae282fa2b, 0xf8d25aa8326755cbb86cb1826fd0f4, 0x1952], [0xdec59a8f2714de3218f1cddbbc546a, 0x2b473b645cc05825e38451c596ee62, 0x68e]),
            r2: fp2_from_limbs([0x562ab3560b8302cdd497eecb20b366, 0x12a2027f3d3496da90210f3a90aa02, 0x2026], [0x79455d6630b7f9696098549bde9ac, 0x705be9b9c0b7dd039fae9b0dbb5898, 0x832]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xccaa98821e6a18943f68c109561d4d, 0xec4710c2a1b43cc14b002d33517fb0, 0x2e5f], [0xd16c61682a93e3ea169a9c3cc94589, 0x2217ec69889e24a2e6cc6b23900342, 0x1dc1]),
            r1: fp2_from_limbs([0x2a2b4d13a258573314930f44c43698, 0x26a84cbccb2e029c43d60b8393b8bd, 0x10b7], [0x7d76c60e50d70384492a0ecf67ead8, 0x9133856d9dc949ee0f64dcce81ce7f, 0x2935]),
            r2: fp2_from_limbs([0x20926cb3e700458f57bf5f12615eae, 0x1ed16dfccebcacef5d2f1032ae5e52, 0x1344], [0x2445ebd2eefc042a89fd5ebe0ddc58, 0xc1f6ccd8052c198d2b86be22659d91, 0x18d4]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xa71b9c56f8e00d22e8156bd88cc4d1, 0xf34cdf236641c2707077ca3a4b3321, 0x1c1b], [0x2bc376214acff98598773e6cc5cc9c, 0x2687fe23974251e79263ec2098e8df, 0xcf8]),
            r1: fp2_from_limbs([0xe132b8f89a89b66addd711bfa8dded, 0x33fc1c42fdfedee75cfe59bb9add88, 0x2af0], [0xcd7d67d670c604e747fbde383ef3e3, 0x3e923b5efd185f9c5324effabd8211, 0x1174]),
            r2: fp2_from_limbs([0x77792b85e48f5fc094e5d305304ee5, 0xbd9d09c2a6fe0566bdda8447a64df, 0x651], [0x5ea8b9191299137277333d826ca0ee, 0x349166adee3b7de790c34cda9337ac, 0x2dd9]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd9dd40c296eadec26a4334afcd857d, 0x1d980a788ac39792c4fcda6d7f2a, 0x21e], [0x268599e9fd4e16c7315d1f7e5bee2b, 0x201fbca80475bde0dec390d7ec81ab, 0x1f33]),
            r1: fp2_from_limbs([0x4e4d4ee79daba5e8ca44d85a50f4a1, 0x16d652317f6c7bf9b009bf113c233d, 0x18b4], [0xd52bd564d04deeef1ac610610790a2, 0xb15e5070f9a3628cd747e5d5722e66, 0x15ab]),
            r2: fp2_from_limbs([0xa23f537420a0f59e30bd1ca2bb3401, 0x812ba8c81b7cc81527e90e8fdba8f, 0x780], [0x8ec84f953fdec2aac81ab15c05acee, 0x1cd84e028228a20c00abd1627da7bc, 0x2468]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe352e0973217c619d3158118d4df8, 0xa9e0786fcff3a2c17ce597745ef8e3, 0x163f], [0xb125737fb649594b87dbbe9881d21a, 0x9f3529bb63c1da267661bf4e64a3ff, 0x2ea3]),
            r1: fp2_from_limbs([0xe24c06a98a043fccffb160cd9d3ac6, 0xf4774407fac83c24533fee1f69b30a, 0x13dd], [0x13ef897531dc96fc1e66b28696a631, 0xbd8346b618dd54a054451039d2050d, 0x2660]),
            r2: fp2_from_limbs([0x910c66f90ab7146403be2f6cc320d1, 0xfebe078d78c1564ee3ad7cef3c4e0d, 0x760], [0x1575df3d796cc1446405d47c0548ef, 0x67be34979583c214647c6a309f2d42, 0x14b]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x4e88f305257f330b0d56583199afab, 0xcde17e5045d6ef1d94b1169339188d, 0x25e7], [0xaaa44006ebdb5e25211a515581f195, 0x4a27f679b07116f2d047c37184cf29, 0x19c7]),
            r1: fp2_from_limbs([0x5723d408e3cd08d80265d2d707a03e, 0x33d8ed94fbe5481d965da723673bf4, 0x1e77], [0x29c46142e676dbc1f67df6929a3f47, 0x9caa79cd6f624eb64432868ddb780d, 0x110f]),
            r2: fp2_from_limbs([0xac2867bc1a6e7f71229524218375d2, 0x599e2aa70c7cdc8e4be99f3c04dfeb, 0x291c], [0x6d56de3069879e28ac104c02970efd, 0x3658c81ad6d2012a7f2363013c45ee, 0x2d8a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x4ce3e1486940c997f7902e205b14bb, 0x29b217b5371f43fffc95e148c183d9, 0x161a], [0xced4dfa24c199ec6749269111ffb38, 0x3ca16117ec6b4341d1f66b42dbc3dc, 0x15b8]),
            r1: fp2_from_limbs([0xb4eeeaad67b688a4eae8934f2ef513, 0x41e366b6ebb8bf4f41a3868481bc2f, 0x1e88], [0xf9b32739a6b37ea63fbbcc08e64393, 0x26011ce436132d926a8c7dacf350a9, 0x2034]),
            r2: fp2_from_limbs([0xb11c230f6f3ae4fe2912ab8372eeaa, 0x2fc399abc587e6fd091812a25b8553, 0x21dd], [0x6db061aaaa0b04bab6e37c93409027, 0xd311884ee52c0db23e75e1ce5dc2ff, 0xe48]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xb07ba587ab5b7785050120ab3dfdb2, 0x84c468c3f17961d48b9da781d9c382, 0x2ccc], [0xe6bd7ff5ffa455c70228f2b9db2d3e, 0x73499657644a2c9dad3d210306820b, 0x9bb]),
            r1: fp2_from_limbs([0x255f5f718726ff78d10ed2f763755a, 0xd32e57aeb173fdb71daf9d5a99f541, 0x2488], [0x2fe7bdc2f8077cab980203f825c492, 0x88173c20d2d0cbb04549fd47f3810b, 0x1b8d]),
            r2: fp2_from_limbs([0x317dab22d0b1195ef12e9502d158eb, 0x307b49ae43ea435eb43e3c0fc8149, 0x2b29], [0x124fd66e4416456c187039adbae225, 0x3b84be4cfbe7afcf2733892e88ee8d, 0x204c]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x240fa75f8fcae781fedb40234671e, 0xc9be1cc5ce007d589bfe53e7181bc5, 0x1bdb], [0xfa6019fc243a3637f8e7bd6c10ed1c, 0xec08edafe8db48c0869408ab904e17, 0x1aa]),
            r1: fp2_from_limbs([0x5e9468d8c97506a37c031ed5434665, 0x6db18ec32b676fad4bbb2d9ded2e94, 0x259a], [0xcef8fb0fd5a4809a9c31b88628175f, 0xe68487d50edf7909a595e63b4fd0f7, 0x143f]),
            r2: fp2_from_limbs([0x9410d81efb32cc5c998fbfe8476295, 0xe130e745156abff5d8e3314c18cdd5, 0x175d], [0xc29751f6187afa5d726c5dcc77d8f2, 0x8bce86389c4e5dc991d81b9b0fc5cb, 0x2f81]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf4cc190139bad52725cfb51f2dbc1d, 0x75e7c591f2f87df03bf179d309b5cd, 0x8a], [0xcffe8b5501776efc67ce6e1cf40949, 0x6c111b23ee3b4794fced5879557e52, 0x2e56]),
            r1: fp2_from_limbs([0xd80a79f9fd22779fb24e3d6dd06cc9, 0x22e66cfffc10007cd8963b30371973, 0x19c9], [0x318fd29f71608252d27109c9eca8d3, 0x5e6364f5c61637657bf28cc16201a1, 0x2436]),
            r2: fp2_from_limbs([0xb4bfcfcf56f60b4f9e1f6a477141f2, 0xcc485b959e5ef317f6490ff8742cb8, 0x238c], [0x1bcf1f22c73dda53bd497a68250268, 0x69a4d51520ab9f842d7becbab14524, 0xcbc]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xff18f5a5d598dd8b38e63a9cc722eb, 0x65806a114e2501039937db037ab1e, 0x2a91], [0xaab92ad57393e9cde4ebbe5381cfb0, 0x4ddfc8c2e66b45f0fb8aad51f2af24, 0x106a]),
            r1: fp2_from_limbs([0xca122fccb239aabfd6efdcc9076650, 0xf3906ad2e0f2d5a43a68f0f81744da, 0x14bd], [0x505cae5d1748b98938a3cf769c91a, 0x3248cd8492d57f7e25135bc4bcbfc5, 0x1c1e]),
            r2: fp2_from_limbs([0xbb0923532a50373ec3ed5966579801, 0xd1913bd562eca37d02140fdd8e7326, 0x2b0d], [0xae0e60c6899019ca42a855ee5252ce, 0x5a167d1a9267e08e4a4c79cebc0200, 0x613]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x6d08639eccf0d5f9aa264e2bde0eb0, 0x33ecfc5e2a0bfe8df05267b1c796c2, 0x850], [0x34fcb82d1f6db54fe5b74c65e458a3, 0xc201a84f26a2dd78de9479f875f134, 0x1a6b]),
            r1: fp2_from_limbs([0xd3a46baf533a1cfacb585ccfdb4d79, 0xd6077258ff4e9eed86c71bf2e7856d, 0x18e0], [0xc299c10e9228d30cb32a30db7f2a2d, 0x9fe2d5a09996ab8b34e2d51727ea68, 0x180f]),
            r2: fp2_from_limbs([0xbdbf89a8da1b539b98eb5fe936e93e, 0xec04e7aacec6cd2998e2176f2bb318, 0x14fa], [0xb2de02fe9271652d3f4cb5da3e1a5a, 0xebd6b212ea717a8283569b5b7ff48b, 0x25c4]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x850c5c5973d456a97aec254d670dc7, 0x315320b5e453582faf8b4fb277562a, 0x1224], [0x1bb338c98cec6e1e5984914b2b7499, 0x1fef5a336301dc2cc4857daab0a0ab, 0xe9a]),
            r1: fp2_from_limbs([0x3737401993e8b0fa46530d1270c420, 0xdb0909dec140857b4deaa9edf97b33, 0x2960], [0x758a235fc6ee54449dfaa48fbb2426, 0x9352c79c0ebded13363663ed505db0, 0x117]),
            r2: fp2_from_limbs([0xa034e89149c2abb66ee06cd0b1096f, 0x88bee8427e7a3bfb5f28eb29511405, 0x2465], [0x24822bf141d81ae2e9103f91f279e9, 0x6872a23492a746cd8c3f2235c36da1, 0x1068]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe5189b8c66e57b1814a102e0165420, 0x4f8fc9007230845c42bea40939b42d, 0x2585], [0x8ed8ea901d23188b7c4bcbd8b5e70d, 0x45a3c1ad92f38d36e5e838df23e0, 0x2953]),
            r1: fp2_from_limbs([0x4fce82da7627c30156e0184fc9c68b, 0x12cdf15e8ef6e6cd02dc613c370a55, 0x7f4], [0xe0bf73ac572274cb1238d49de2fd34, 0x5020044a4dcd438efdec2ca80595cc, 0xb64]),
            r2: fp2_from_limbs([0x62dca60de0050eec58f333f558c5ff, 0xb8fc3c27d784129fa7a63fff8aacc5, 0xe01], [0x87c7a76eab96f46be019142af45714, 0x948ce6042ed22c010ff84971b0baba, 0x2438]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x6ebc9bd421a186e83292c5fb08a154, 0xb8045876d98b82bffc8fa2e6c5a2d3, 0x259e], [0xf431b58b31bb3a1f8ab515131d3922, 0x2f27dcfc76b43f66e3bbfe3bc24285, 0x12a8]),
            r1: fp2_from_limbs([0xaaf7dbd8dab24aebfd9457c19193cb, 0xc7ffd5fd3fc8f660883af926187fe9, 0x2912], [0xc163094fe71171472dd5674af2fe0f, 0x6947b1e0174433f8a7435456b69413, 0x2747]),
            r2: fp2_from_limbs([0x9b95cbbf7a8da776aa29e2b9752b5d, 0x5cead1d3261c6b819f91aaea5b6bcb, 0x1463], [0x9e6390bbbfaeb3b0d01091f30ef94e, 0x17e449ea85315004fa419a05e0cdc3, 0x1c6]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x98cb718e8d36d2a1eb188b9b41d760, 0xc6f96cf27b765fe33ee1c0556e29cb, 0x2359], [0x4ed24bb7dacf1514486ae7f517ec19, 0x602b5648b8a04d9caf2e717ba9dc2d, 0x216b]),
            r1: fp2_from_limbs([0xfc9b54d29b617bd09c39e19f17ab61, 0x52891085a210195e60b4efbe0e19c3, 0x13e9], [0x435c14bb11193447bec7194e6fe23f, 0x2ba1a7096be5aaa378bf6ccf44e43c, 0x2d3c]),
            r2: fp2_from_limbs([0xc1459cc280d59d51ab1cfbd467c4d1, 0x4335c778a22311924119bd99d2cf6c, 0x16f4], [0x42b42b977f3a95f293d19166470f26, 0x1ff083c217f5fd9888ab8a5e25aed, 0x1e1c]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x12c7993f46dc79632bcd71e86064d0, 0x9ca0b5b000d1095ddbad70c5699355, 0x1733], [0xea4d241fe8124615473f75e766a6a3, 0xd6c1b320124136fabf42d0f58b283e, 0x7c5]),
            r1: fp2_from_limbs([0xcc2193a54e134eca4653a44ff9a9a1, 0x9245ef15f7c8bea93bf197e77e5a5a, 0x1c7e], [0xeeb4ec5feba02eea299a09767b9b3, 0xdcb53eac6b3534770b54a42111a351, 0x9a9]),
            r2: fp2_from_limbs([0xc335110aa4fa4abb44c1bffd4cc740, 0x6b4a696eee1ef38bb6968c9b5cec44, 0x52], [0x6a51a416dcfe6245079d731c26c07e, 0xb69b9e49ef3ad69bf07857cd8ae000, 0x228a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xfec18bffeb43e0cbcb63f1fa722571, 0xcecb97178f631ae1c5958d181fdb88, 0x1810], [0x63a6aa949eed249f541bfadbe6abff, 0xeaf27a60d2dcf71316bb17d08e5296, 0x204]),
            r1: fp2_from_limbs([0xe8209fe6684a62ec24e01bb32986fc, 0xc634b40223e540d5ac10f57e2c3019, 0x160f], [0xf281e6c4efd965802a90e30236b39b, 0xbc3365db1db3a06949cd06ed736b81, 0x1cbb]),
            r2: fp2_from_limbs([0xe13fd790823c6a7d11389a698d8486, 0x455c7347b328cff79232c368591278, 0x918], [0xc97fc6b9863d3b57a14b8d7d78022f, 0x2dad46e126c199e69877b6c9c91d29, 0xfbd]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x392cdc991bb644b0adf94845e2a8b2, 0x11d4d7284b79a466f9034929ed93ce, 0x84d], [0x46c323e7c5bbf85e931c7befb2977f, 0x81e9e4a988fed3f8cf4758f020003f, 0x675]),
            r1: fp2_from_limbs([0xa8c62bc5669a3e938807fefca87a12, 0x8a015ec657fda05821bcbae157b144, 0x1539], [0xe8a229937937e8c1e7055a7444101, 0x2fddacb17fc4cde6154b5884591273, 0x1b5a]),
            r2: fp2_from_limbs([0x6d1b50d0e3c2563e067e967cf5e7a, 0x735a85b338bf5a08a0b1ec11ab46f2, 0x2f26], [0x9b9dfa7075f58a78a3d0419f393a05, 0x838793bf48317be517f790259b4693, 0x1c03]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x966cb8a11b642cafac8089e6e93bb0, 0xaf1c6df2eeed455cb22f1de9e8832b, 0xb9b], [0xbf2e4e6e0b5895aabf98bcb0c7ed6e, 0x445503ba7062f2ea7b4bb75c6cbc96, 0x1553]),
            r1: fp2_from_limbs([0xc8d2ed961f63d39727a76c0f67dec1, 0x5efc8c809b89fad3b6973dcf5657e2, 0x1f35], [0x828ee3598f6e2109a449e6bcf7dd12, 0x701c38c962b1d53b050c5b04bcf678, 0x1aef]),
            r2: fp2_from_limbs([0x5803900f4af5f64c3af0235902247c, 0x426ef3085198e7fa531d98195f9dbf, 0xd8c], [0x1262bae5bc4cd3c58015a7383ee08, 0x2bfdb7df36ffe862819125e634fb42, 0x110f]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xc90da0db0eb1da321bff19d455893f, 0x968c530b897716c6723b75b1bbef67, 0x2fae], [0xd8fc907a2ae69ebbc24f19f4313ce8, 0x8ffc5f907218536ab9aa82ff5608c0, 0x183a]),
            r1: fp2_from_limbs([0xfa46984b18ea4136a37ca9017faf38, 0xdc1ceb92dada6d8d223a7b2c740a85, 0xff4], [0x43579d38f22c6611cb9f25c2d1cc02, 0x4fda6e918756a9f17ec1b912269a72, 0x6d]),
            r2: fp2_from_limbs([0xbf3964953414e1a565cb863fe0802d, 0xcba1bb68c5295f3eeea021abe76824, 0xab9], [0x264a68fe71e902f57534cdc89831ae, 0x401797f06c9bab4618b9b065ea72c5, 0x1d09]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x8d9273301b3644dd61c39dd96f6ad2, 0x69b297efb522c04a1cb1df5319ebaa, 0x27ac], [0x5dc40503deb8a6f622a50cfe5e3ce6, 0x8cec148d41de8f69e595e187720bf4, 0x2330]),
            r1: fp2_from_limbs([0xb22e0c5df63648ddf2ac003be37870, 0xad4ac471f5f4f26f4c6a12e66949cb, 0x25bc], [0x734a3cd86ef1bdcfaa338ec35a352a, 0xe926cb9f8643a8bf732efe21cd20c1, 0x2afa]),
            r2: fp2_from_limbs([0xc324e0f41c8aaa98747af93b641168, 0x6dd90c63fdda02d4f9f58191151d8d, 0x46f], [0xb36c4372b75e01fe0f07529f10a519, 0xaf67eeb220ca3e61f81d72431f1f22, 0x2198]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x5d8325c1e35e71d8fab5bb585f44cd, 0xbca91ca89c579d9a9b800d0f993ce6, 0x18df], [0xb754c05c8d20d702498c02cce4cbe2, 0x48ad214c7035dd23185bb74c94f71f, 0x1169]),
            r1: fp2_from_limbs([0x7fee029c10f916bc05983ad9f25ccf, 0x58aea72d07f96a5517a5ebf6e55c71, 0x190b], [0x3b38d436fd69cb537dd3159826ec4c, 0xa830d7e0073e7c0e50d0863ce6777d, 0x2559]),
            r2: fp2_from_limbs([0x74731a189ef5ba38eb7473aa2c68ec, 0x2898ebad44e9813a5625f7aa20224b, 0x224d], [0x1416bae9413b9395667bde1a565cb4, 0x51f479349273bb65fd3fb5b797cf72, 0x1669]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1797deb1311eac30b29c790f57890c, 0x45332ceb609a42d9732e58ffc27fa1, 0xa45], [0x99d76aa2ef6e27d15e63c54acdef0c, 0xdb54b0933caa4344288632145c0d3c, 0x5d2]),
            r1: fp2_from_limbs([0xe070bf894e792f0a597ca99be8ed9, 0x915435f06744a01c29dbb7a0025dc1, 0x28b3], [0xb89926a1cefe4c178261c53b8a9914, 0x65d3e914162780e032d02aaa7a3084, 0x1135]),
            r2: fp2_from_limbs([0x8d2dfa5a277208a182bd8e171515b4, 0x5c58e554e3de0d3d99da740fa9eca6, 0x1e43], [0x6f49c59f86451ccc4fea3282b897c2, 0x666dcf0a78b3fe70bb087af2790ae7, 0x1e27]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x4bc7d291d31a2c9f01577e7390ebcb, 0x13149c4ccbc25fe413f9f1ccdd0a08, 0x412], [0x2f967270c4ed52e7b44d205b6c13f9, 0xb67dc797bc4c2f0c858e024f1b12f2, 0xcf5]),
            r1: fp2_from_limbs([0xbb096f4b6865468d8befaa0ea98c91, 0x21fee1c65c7ccede9f46d73775b845, 0x1e3a], [0xb7f57b287e51ea7dedc2627dcfbcb, 0x79f26a5379af1959e97e8e67853ae6, 0xb4c]),
            r2: fp2_from_limbs([0x103371aa6ae303d9ce3093968c80bb, 0x39cae6f7fa9dbfa7f6dd1e501d0f46, 0x9d5], [0x7bcff66257e48485948a1d78116941, 0x636276f570085ef26ab00c5dc1aaf, 0x13fa]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x65dd6d7d4575038813ca53299cea3b, 0x75370b054f5fb78d36a4c098268f7c, 0x704], [0x529e6827e5fa8b32e3e257070a9ea0, 0x66720eec5e354800bd98b7ee953793, 0x1731]),
            r1: fp2_from_limbs([0x67465a53a6cbb632533aebd1043ccb, 0x9dcc79ea79a201a3b7468ea2d51f97, 0x2099], [0xf7efe2bb446826e3e0a06ecf55d6e2, 0x45ec023bacba4e0c6bd8ca9ea8bd74, 0x5ea]),
            r2: fp2_from_limbs([0x7cad8ce4f56040f3c2d01b07482817, 0xee1bc7db618bf54675b435ad987798, 0xde4], [0xef1ff871603c3684ebfb2be96aaebf, 0x1bef1bff12cdbe4731458cbf715b4c, 0x1f70]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x8943cb95ebb88b91351d7e94ae4222, 0x2173223ac04235729a3dfd4dbe8dd5, 0x9a6], [0x6b8972e121145eb04198dd07de953b, 0xe1da5fb2f48c64f6b534b0fbd716b9, 0x1bf8]),
            r1: fp2_from_limbs([0x5f2394896990639f04fdae34353f81, 0xc1544e1501f0125a1e4be02d9e22de, 0x1152], [0x3d74f9332a2d9991d271a5057f9935, 0xabdd706036c74309d2b6b400661dc4, 0x1a01]),
            r2: fp2_from_limbs([0xc6e38a6a2dc89d9f39363f8d0b4498, 0xade8fd11f8ab1e7f688becd8072b83, 0x17ec], [0x742163be03bd935ef579cf007958f4, 0x6846ef57a976fb69c138b73d1e8ba8, 0x226]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xca171d91ce0a2b76f5a1a5017ebdd9, 0x62c277fc6d7392f18c71b5e4c3440a, 0x2c97], [0x639dd36cd905e6ed0a842d563d6339, 0xfbaf16c346634f8a528d17973eaaf8, 0x1825]),
            r1: fp2_from_limbs([0x33d8828f05a11dc5b397e4f45d253b, 0x48cfc1f2598372937bbf9e58c16b75, 0x288], [0xdccc6a60c451ef5d72221588c69fc8, 0xd651ca8638696e79e675dcc3f1cf65, 0x1629]),
            r2: fp2_from_limbs([0xe5736534cfa2b01ade0fe95f933132, 0xe1608f65c801a46efe6f05692761dd, 0x688], [0xcb976a55ce6d30b3ce77977a8d30a5, 0xd8be0ccc877d5e00cad6bbe09335b, 0x41]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xcc5fd25f3b530d7216caf23cbac799, 0x4d47aca52658fb9e2956e33a42276, 0x2f86], [0x9baea63102f93f494782f2d9ee244c, 0x8b6ad022967c9676a315a77367e5c2, 0xb74]),
            r1: fp2_from_limbs([0x336f40edbcf408f22a25f18a54e8fb, 0x32bdbb9fd802bc98fa3ae20e5d2aff, 0x6ee], [0x4bba7cf061b790935ce56e87450a1, 0x845d95d4e3b9e4b4d6d55d40013782, 0x23e6]),
            r2: fp2_from_limbs([0xe4d764df6b1beefe7c1b08dbf989cb, 0x3a8fc4301d905fee904c785788100b, 0xe2b], [0x65b71d14b2cdf0b8a8373972255ca1, 0x940d9345d225a9c53a05da1adb4a8c, 0xe27]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x239733e8516039756bbb87d176fe46, 0xcbae65da157583bee198269feff599, 0x26b5], [0xd511a59ddb712e3037dff7f147c174, 0x69fec4f7e20fabc83cdf1f53df4cfa, 0x2934]),
            r1: fp2_from_limbs([0x75bee3815cbb5b8fc9559fe4546a7, 0x70b8cf27c9529bca274ed62eaea401, 0x4e6], [0x1cd0722bc06d3f182fd1c2c73aa016, 0x1d82d1f96695a995cf3bea43b27602, 0x26aa]),
            r2: fp2_from_limbs([0x7a99420bb31c716037a9796e8128fb, 0xa27aa843bec55165f6d3c2e501348f, 0x1702], [0xcd8098b3c24d2171c1e421b165cf37, 0x8539b2e17f773fd7ca9913e34de652, 0x234]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x84b23c80f683a57098c9a3bccd3558, 0xf7eb40cc64184baec8d87c80b05b2d, 0x2b8a], [0x1227db6247b1208c6a9fe0a6c7fd25, 0x2d464eea0f850bd6f3d965907baee2, 0x2997]),
            r1: fp2_from_limbs([0x74673a7000b44d7950295dbc425d1e, 0xb4d1a8411fee7767a268a1ebb2585a, 0xfec], [0x2fa901bb3dfdbc03872a834fd92cec, 0x2aae83fbe499a3fb656fa5d34e8d20, 0x2049]),
            r2: fp2_from_limbs([0x95a907d75ce1022cfbc8df0ce3f6bf, 0x9cd8531b5df84e765fb89453a9248f, 0x20a3], [0xea15b3fdb1d2ecf8e07ba06f0a2400, 0x9462243e22100d295329b8e9bd50e3, 0x110e]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x229f8d3f68b4551bc735305f6fb33b, 0x199634998c59e48a2fe70e6a896cf3, 0x3031], [0xbec11ec46d4fc21f76beed5b0ccec8, 0x7f2341a5517c002de2feda489d5869, 0x27c5]),
            r1: fp2_from_limbs([0x71ae9316253b8c8f66042b2fb1dd9c, 0xc90046e2ecf4ac923e6873fe32f777, 0x278a], [0x8c251affc6e3d81fffa36cd46974e3, 0x675129700374d50cb5655b6185424a, 0x1b8e]),
            r2: fp2_from_limbs([0xdf1a3229a1b57d4e4305c3ad4ae71d, 0x3617f116aa78fd25095baa2aefb838, 0x2aef], [0x105e3335530175a7c23abb19b20553, 0xf64be793d6c326ec80e3fea13750fb, 0x152a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x6d4f639cb6e507c219c4a6b8c2645e, 0x38be2e233d5e43ae30e20786551a0f, 0x1c0b], [0xcd274eb51c37e397082616b186f54a, 0x8c354282032fedee9fc623b1cdeaf8, 0x2c3a]),
            r1: fp2_from_limbs([0x29811c7891b5c3f1ac66ac18dd48f5, 0x8108f7ea2fe88edc962cb6b4cf8962, 0x289d], [0x23965952ed697f0029d476ae3cefda, 0xc8a1f54fe6d3ad4c6145994fbb1ce3, 0x973]),
            r2: fp2_from_limbs([0x1c6ff819a300e3ee1e6795f07e89bd, 0x2c29ef6eea4436a1bb397597168725, 0x48d], [0x68a6f7c7a6b4855ca04fe97238c3a7, 0xec3bd60a0dfaf667ae4b083d585321, 0x2a28]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x8025e6bf166199ead21b427759b7, 0x7ed92b968e5a6c0f77d8d560a73ea0, 0x160], [0x461d77ca68ce640431e9c5215cce13, 0x44445bf288b7812fd704d1c63e8d8f, 0x847]),
            r1: fp2_from_limbs([0xfbd760ad90571e2e652104857db848, 0x456c740434d10bcba705dd5720ec79, 0x2715], [0x54c917a991253427e533ac6edf34ef, 0x6cdc56ec652518552a0f1dec08e71a, 0x18a0]),
            r2: fp2_from_limbs([0x3673ed9a2b092b4ffcdff4e2c3dada, 0x136dbc73d3da22769ef15946808130, 0x2f97], [0x84c1c526e4a67491268259b766e913, 0x4e8ec407b353ed403d3e7da0958409, 0x108]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x2158f31dc34924d0771c0b450210a6, 0xef211560cf95f9fc9649e9f946855a, 0x2d5b], [0xa0cfeb78ee314bb4fa6229f2fc08af, 0x35388acb2887962f0656b064ba321c, 0x2106]),
            r1: fp2_from_limbs([0x63cbaedae79c5dbccfb204e00d73a0, 0x3ea2a624a84661a3d3ec8bb8fc426, 0x2d0f], [0x7b6f2ba24c4a854f73a52d0784d2e9, 0x89dfcf99123beb47b8eab0310533a0, 0x1587]),
            r2: fp2_from_limbs([0x6beb3578d16beef4b7f5ab9b0970a4, 0x58197dc5db36e3c7c651be0484663f, 0xbfe], [0xea2a9520ecbf763d2cbd1a8fc57ff5, 0x78abc42e7b604f924203d71cc7082b, 0x104f]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x46253ae404dc142b5acdcfd0db7beb, 0xf1aaf99ef4831f28db29e3c4551da0, 0x1c72], [0x12882366bdf25dd557b4906d1713fa, 0x352d8160bfd2700b55372b321fb237, 0x2842]),
            r1: fp2_from_limbs([0xdfbd8f6d0851931de0c154db7546ec, 0xc34bab7626bb94f9319287a80ebfcf, 0x454], [0xe59114073bc4ef73f3678d4e6887c3, 0xf3547b9b4cbf28ffd45933ddc7a131, 0x9b8]),
            r2: fp2_from_limbs([0x2f8083e842c2d6b84495cc9c978ca0, 0x2439a8f7a794633123de0b79bd23c7, 0x1705], [0xd2a3c0719f5d99e83188150fed9664, 0x9c4eafa72d81b5c8887524e0bd37e9, 0x28c5]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xa72b3eedc7d3970ab4908445876f29, 0x9dcdbb14d99d703194b2d879539b5a, 0x207b], [0x4a27474858ca508c041b0c5bcdb0e9, 0xb74485f872240359918fe8d315dcd3, 0x17dc]),
            r1: fp2_from_limbs([0x2e859f7b0d757833802eab3312212a, 0x7cf9c56e703e1967b4131011be7e0e, 0x51e], [0x556a970fcfac5f4422497beb593360, 0x55d6a68e780773e285e868ceb42111, 0x2b34]),
            r2: fp2_from_limbs([0xfbcc591e452d4b379593883bdae796, 0x7b48081e49b3fbea0b72690302fb5d, 0xc0e], [0x3aae5d3b108a787b2c644ca7b29155, 0x48a778ecf7b186c5fb2507230744b7, 0x1c4e]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe95ceef0b69eb75ab62f50dc186d16, 0xba87f760d60dbfdfeaac1c5e95a943, 0x1c94], [0x826a62104ecf189bde6138e1455020, 0x7b8addf67cc1fe24798c83f9403a11, 0x1d7]),
            r1: fp2_from_limbs([0x74a8aedbe6aed13c6e5d806971782, 0x39397b8e1061bf40cab5fa578dd641, 0x65d], [0x6ce8a237dbbf64ae1c8d6478024a3e, 0x30efeb08851a7b296937fb95a20ddf, 0x2474]),
            r2: fp2_from_limbs([0xd55265416bba917a17d587008bd2b6, 0xa09ac153b7c586a81176bf5d54db0f, 0x25a4], [0xd0b7d91ed8559592ebcb491b8e7f52, 0x548da24b3a54f079890d134131e5bf, 0x18c7]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x637418d0a5ef049284a18ce2ae7ef7, 0x280029e51b9365b24139b8d0153c3a, 0x245a], [0x3911057293d673bf5236278fff3841, 0x6fdfb644da43f119f5f53ce229ea2c, 0x5e1]),
            r1: fp2_from_limbs([0xfdd41c9763d1663b42ed63a9706ca8, 0x6293d4b41fd2c42783284754db9a34, 0x16ab], [0x6485bfa752327287e9f33103f8a197, 0x895b554d08a567b49e2e7dca6b43fb, 0x2789]),
            r2: fp2_from_limbs([0x4469c06330a5d0e78d4923e322c943, 0x681a48e5058d0cbc86740a93afb24d, 0x26b9], [0x43540970dafd3dfbaef36ea8e24416, 0x5bd352165e3ef4099ea436ada942cd, 0x12a1]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x2dc9665223d9a82c8d228274de9d0f, 0x4f664165f4a0787b0ad2ab125b566, 0x256f], [0xfce9182c4b63f1a9c7fdf6e9bb2051, 0x206ecbf6c004a31d3e5d02f0ba7166, 0x2a2]),
            r1: fp2_from_limbs([0x16cbeb1408c29bae637e2a0ad494e9, 0xaebf1454b29c29bc42eaec48bc147, 0xd8], [0x625ca0aca167a47f21bc503b92d626, 0xec4f0ad5b2643ae5b8f4550e4be3cc, 0xa34]),
            r2: fp2_from_limbs([0xb94f52c8e31ecb427c9e0c7da65194, 0x194a81e6ba057a37076b1776242187, 0x17e2], [0x880dd567d62136eb2536cef4eeccaa, 0xc8ddf9bd7a9e33e98e550aebb709ca, 0x2019]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1331e5db8c1c0bd5d8851de8c44cd0, 0x734d098c649e7874237bec354eeb7a, 0x20e7], [0xae778e9dc4d41c79967b4308477def, 0x8a2bdb8eb41daa50f8df4dd549dc07, 0x25c0]),
            r1: fp2_from_limbs([0xd1dcc1f0286acc4bbe11eee167c4f1, 0xd77d7d796ef26c3eb4fad26fe16817, 0x2225], [0xfe5d3c1f6225510fe9ac27663ff0be, 0x26ecd6e34252cc567d26d5e6046534, 0x26cc]),
            r2: fp2_from_limbs([0xbf04fb79210db431d7023a8ec661ee, 0xa471995a04963a87993eae0d725fc0, 0x4a4], [0x3815739948a96fb76f7e3bbecb3b78, 0x2660cf556f1a72b7c22b0640b458bf, 0x5d2]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x3b2dba97df8b764f7aafc01cbdeee6, 0x40063f2709dce2d76986ff6b3d699f, 0x1624], [0x370a9f21ce16e0cf2a7e629f73c82f, 0x9c91bce3bf3ed6db40d55c48ea23e4, 0x1271]),
            r1: fp2_from_limbs([0x70c496787b1420c95cf7c915411072, 0x3fe367a387b69b76a869f4112a0ac7, 0x1994], [0xb49007df1186a608e61610dc1fa219, 0x48ba103508c2afb25730639768491f, 0x10e8]),
            r2: fp2_from_limbs([0xcbd489f6655e17ef1d66ba3ee423f1, 0x5cd04ad18f51c6f3df46585e89cd3c, 0x1d05], [0xb44b49ef1cd2f1cf60a13010823059, 0xcdd36960fb0f70133693e439211c43, 0x2201]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xc44021309c64d0748dba1c518dd0fd, 0xf0db92d0f58dc4f0408a404429e8c, 0x19e2], [0x2e6785829057c2356cc7662c754721, 0xe57f8815222cd9be77ad8ae5d4e15b, 0xc91]),
            r1: fp2_from_limbs([0x679df3707cf6d7f7efe520150c15da, 0x3098a528924bfcbee56a637c78d561, 0x14e0], [0x5f77dd87ac88ae5d7307b85e357cfb, 0x585f9db8d002e81476eb4275271645, 0x1102]),
            r2: fp2_from_limbs([0x36dea2065863ce359efcd082dcd855, 0xb1d104f644d9c123bad20db8fb621e, 0x1e26], [0x62aca6cedb97435382448badc5771f, 0x2d6cca6f93a09b60a6ec9a2e9b935, 0x2bce]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x4057d94abff8bf447a41aebaf85422, 0x40196b2731db33466e73dafcfdfd6e, 0x1970], [0x39a7de1aa0ba92143c081d805566f9, 0x69b5412afecff17957ab7d0063b2cc, 0xcf6]),
            r1: fp2_from_limbs([0xeedbbd4c7f7751ecd4640aad291301, 0x1b8d2c010b2d16bc84b06ef81d8944, 0x2e0c], [0xfc991e8ec621e0a8325b94bdd9c025, 0x5082bbca1986b23a57920721307ce7, 0xc63]),
            r2: fp2_from_limbs([0x965014730a3d9942cfa9f075867d97, 0xfa0066ab1e52a76a3055e6b6befc54, 0x2708], [0xc5816002ce2227266936d3a39abff9, 0xbe0153cc835dffc9dc85e2bf8f67cc, 0x1c9e]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x6eb7ac83dfec2c8f87962008a15a18, 0x59322b3094075dc48d67cb90081cdb, 0x924], [0x5ef8b8a2102eb4422bd7d2e0f26247, 0xe9331c459acd98b80cf23b5c08d1f2, 0x195f]),
            r1: fp2_from_limbs([0x8f7339c45729943ba9ffcc2b4a74dd, 0x1f3701d646ac1fffac1e3f17d92792, 0x1cd2], [0x7f23c8040b5b01d6fdf80fcdc3acd3, 0xd62a0007c17107410b8a8d43043c95, 0x2a5]),
            r2: fp2_from_limbs([0x7a62ef05f4e9e52c4326937bc0888e, 0x6b2a400cc87e863520152badaf1501, 0x1269], [0xc49deefff09ed99a193ffa4785724, 0x4b39e24d4556aec328882ad0441308, 0x1de9]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x32be457f51bb6d55fd47a18dab2cd2, 0xb43eb22c4bc98f7ecca55a4989efd5, 0x2f07], [0x4f9cd7d36a1e411ef36fb128f6f384, 0x38bc6889879cce96f03b0583da9069, 0x3e]),
            r1: fp2_from_limbs([0x377033b14f4d79ad2b7af14575692, 0x6eccb8b0441ca93da193cfee90e9a0, 0xa77], [0x75dce4bfac0c52af2eb70779a2ca16, 0x6f9a0fecad881b5a3ebdc509247bf3, 0x1b2c]),
            r2: fp2_from_limbs([0xfae88c9093eb07ed95156578bf5782, 0xc9c662399f3e6f725801ab75a3566c, 0x468], [0x4f67af49bebe7ecfee631fbc39be0d, 0xfcd9bb59630372e52997e1190bdff9, 0x1b27]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xc221f0fa2cce6d9b6d2e0752fa5226, 0xe14a45014392dc353ba4781178c4ab, 0x2c24], [0xe73942929b5f39d1e3fb386b8397a6, 0x3c341dabe1a001af00121ff145571, 0x2ce3]),
            r1: fp2_from_limbs([0x26263a0432cf23ca9eb68a96aecff9, 0x271d308d38920371346f55e8e426ed, 0x2d4e], [0xf96829b3cfae32f9442574fcc17f86, 0xd503f55bbab6b90d61abdda55d6b1a, 0xca4]),
            r2: fp2_from_limbs([0x7a310ebd46995eb2793902d581127a, 0xc351c4f53077c49157b2d4d0e3e5de, 0xaa3], [0x6a41b4ec81cb13428a7d3bc609c364, 0x9a34cec9f203aebc1b0f6bffe47aaa, 0x2c5d]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xdbd79ee0c775437b3e1a5e4bc48886, 0xc16085d866fb61513e71880266fe49, 0xd0b], [0x1f6f8a3488f430228c565f71738710, 0x2654214faad951fe868bed67f90801, 0xe1e]),
            r1: fp2_from_limbs([0x5f27c4d92c5cc9c33fd68f5c951740, 0x5616622f51ff8cd23638489f5509ef, 0x13ef], [0xedec20f0f611272d3e0fc464259d91, 0xfcf6c54d0185df46af21d1c2403206, 0xe4]),
            r2: fp2_from_limbs([0xc74f23d467802cbdb961374a7ef98a, 0xa0755f8a01b102d157f9bfab056bf2, 0x1d51], [0x4a1b9f63f8d94c599bdc1a0b0aa702, 0xc436d02904391831081c4751559ddb, 0xf44]),
        },
    ]
}

pub fn sp1_delta_lines() -> [LineEvaluation; 88] {
    [
        LineEvaluation {
            r0: fp2_from_limbs([0xb5f8944c9408933efc5edbed21bb0a, 0xf69739e0724f21369e387b01f9ad0c, 0x2e70], [0xd1792c83b81f6ce74a4a61e42a8b51, 0x14c3dc359b37eae4352f3829c8fb73, 0x2d43]),
            r1: fp2_from_limbs([0x59698d4d5287d679192478d8155c7a, 0x370733b21f320e572fbda775cbc3b9, 0x2949], [0x35262d675742d093c3938f33137c19, 0x844f93d7c987eb6abee332dc427dfb, 0x1d1]),
            r2: fp2_from_limbs([0x1a706d92ab49ee1388c7cd92df771e, 0xe45864dabc5ed35fa5a963901d52b, 0x5e2], [0x86d227602c6ca756e580e1b7531a1, 0x6df0282da688d6141aa94910b09790, 0x2ca8]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd27478343677766f294edf31af3cc7, 0x1f62dd6cdb6d84af433498bbe3ab2d, 0x1bbd], [0x4d7c544978c3632449b911587786fa, 0x3b85223988ca1c23a247b70eacac5c, 0x188]),
            r1: fp2_from_limbs([0x4bee7899d589216bae791399b1b109, 0x534cb1f0f3c2fd37f5cc9b32cd50d4, 0x29c9], [0x51fcd23446db370b018cb92107b263, 0x6e2728408a39bab7c67f0400bec94f, 0x2f4e]),
            r2: fp2_from_limbs([0x1b77206f04236bce84c950bca8e760, 0xef87743676ed48c9c47ddc40656c83, 0xd6a], [0xabb7992758d19d7629e5593afd331b, 0xbfb457a74050714bb229a1d0db16d0, 0x2cc1]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd27478343677766f294edf31af3cc7, 0x1f62dd6cdb6d84af433498bbe3ab2d, 0x1bbd], [0x4d7c544978c3632449b911587786fa, 0x3b85223988ca1c23a247b70eacac5c, 0x188]),
            r1: fp2_from_limbs([0x6a1ce2029afd7e834970f9b948709c, 0x66d918d13735c8c9a557a23e4cd6b4, 0x562], [0xea9de96ed78fd62d6f892efd5a057f, 0xc36671d4454a9e5ae21b498cf9b220, 0x968]),
            r2: fp2_from_limbs([0xdc0271731544925032bc7603958560, 0xd104bd6c48514ba30e8279745111e0, 0x1d6c], [0xa8fd240e5ebe205ba9eb975510891a, 0xd79fcb743e74ee498fe694421c6bba, 0x2721]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x9d1285610ae2b216ba8b70c785f8fc, 0xcc34d4c1c2e8f038af652701ca8c7f, 0xc3c], [0x343591f2c169a37c2dcd2ed25c85cc, 0x7e55828d913ba2dfe47baf9e874cf8, 0x2c69]),
            r1: fp2_from_limbs([0xc86fa912048e4183cb7817b2ebe80a, 0x3428dfa1e7eebd40b3f5e596683a9d, 0x147a], [0x4f17bc0aa3c585c83b5b0e19aa76f8, 0xbd52701f184eceadce2745b1e43d7e, 0x1776]),
            r2: fp2_from_limbs([0xb493b3ea7db6ce91594b4de74d779b, 0x304872b1b09989516514e93e528b00, 0x1f29], [0x22d842b4ed08ac4fc7c6e24b820216, 0x3e3ed0fa0a9a0a6e26692d6ecce01, 0x88a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1a62516639c6f18724d9fd6ac37f91, 0xf021987d11a6a3fc926f740b1845fd, 0x540], [0x29f258489d814d22de870a5e2eef0e, 0x8d313ab3c56c99a5e6729f200eb21b, 0xf5c]),
            r1: fp2_from_limbs([0x192150b6fbbed81c58d97d692228ac, 0x43e3a873f56140f2055f99acb21643, 0x1755], [0x4c2acc1392ddaa1bd97f2e82bf5817, 0xfe39b68406dafbd65e6860b71aba91, 0xe72]),
            r2: fp2_from_limbs([0xb61103b309429cd7f53cb1663c7796, 0xe64156024e4edb950e27be9e551e6a, 0x1b0d], [0x2d62c348b98e879635f6f3e47d2667, 0xebfaa57bd168dd783e8da100f1e1ea, 0x181d]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x48eeb0bb29f655064f3838d49fbe9c, 0xa946e14b8eec0425239bd4cd81e577, 0x28c4], [0xbd4e29db75702c447ff3b065d84010, 0xf702d521c1392a695dfd7ba51da181, 0x1e69]),
            r1: fp2_from_limbs([0x7ed27bb0ddccd64657e2cf73436c2d, 0xd5a6c110b364a2513031448ea9e0e4, 0x17d5], [0x839da3e732e769ea094664343afec0, 0x2947335490c989900e0d1192c43630, 0x1b71]),
            r2: fp2_from_limbs([0x8aac74776a42d007f7a65c1f2b898, 0xfba690d35eb2f41f23841216351232, 0x304c], [0x6ec525b7a415c13b35f841cdb827eb, 0x502fe644b6f30e80f0b506f70df815, 0x2b0f]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xff01a71f5ede9a49e999ad646eec51, 0x8dce567881d2b771136b2807dc4899, 0x2e72], [0xf3349a9298519ab3afa0b8f4339b32, 0xd265a86242d45945c7a399bc7f2985, 0xe01]),
            r1: fp2_from_limbs([0x4b097374b0da69664e9c7c9ffd176, 0x566107060603a10b34ba1ea80efec6, 0x1402], [0xc543e82470ea36314b38fbcc6a4e7f, 0xe5fe37eaeddf9d5c8839a243cadb0, 0x1d18]),
            r2: fp2_from_limbs([0xcdf4b35616b5b53c2c429b9400d873, 0x44533bf15154138c6f62c3a10dbf61, 0x1332], [0xc9fed616ab1712734906c5c339dc7f, 0x98dcf17cd6acf9f2790a8e4fe7d452, 0x1a15]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x28bd1ac00f2f833d9dbc3ef1cdb5b2, 0xe0dc7c422823caf222308effefd8eb, 0x2040], [0x93969bee729d22e226090b200be22b, 0xc03717fa912a9eb256c3ceba1c1717, 0x1770]),
            r1: fp2_from_limbs([0xbad860f81886400ac216b62645d47, 0xdbb78f6be95079939ed0dfa504d142, 0x2be4], [0x9c959c17a365e23864032b5c4f84e6, 0xc464bf371f074e8b89a25d099fb9fb, 0x131b]),
            r2: fp2_from_limbs([0x87572f14eae1360116e8c32448b66a, 0x3b5ab095cd45c2cb64de131a12036c, 0x2c92], [0x3c497eecf0a410c47492b93ee39cb6, 0x2621fc67e44f7657df854539fd8973, 0xe94]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x382c4b994f5064c31cd78a105f27b0, 0x4cba4ebded5f077ee1d06d3e981528, 0x161f], [0xada0ffa19e899e1979cb132c44a15a, 0xab43365109f28df58cba02fd662432, 0x2a4]),
            r1: fp2_from_limbs([0x321159d9be292006e561068c759408, 0xf2fd51f938717a5e2d2c61a1bff900, 0x537], [0x70067491b43239d2961193545186c8, 0xc7292cb0cffde58bd806d39d35bd9a, 0x1f03]),
            r2: fp2_from_limbs([0x43986af1779f62e09d5340544e0a27, 0xb302357f08c6ad4d90f90da6fb09be, 0x191a], [0xa947e40a4ac62197ca241dafec138c, 0xe8b43932fd9c92a9f022eef98b845a, 0x2ef4]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x8465998cf3c16db5f491eda92816d3, 0xa3fe51f0e94c710ab7451e08ebe64d, 0xe27], [0x9f1fd3c735bcc2518c17efc5bb5f21, 0x290665d10c965fa21626f2aa9ede08, 0x292]),
            r1: fp2_from_limbs([0x3e17567056b5e00289e3bed6ef321, 0xa085fe788fb91625bcbe12003fcdad, 0x8dc], [0x46ca446a4c9961e86e97a835078b62, 0x4e4fb2171b607c98087fb478c16819, 0x65f]),
            r2: fp2_from_limbs([0x12e60eb56ae2d307f2fa899adbc947, 0xbae1fd4aefe83387f8f70e000c2273, 0xab7], [0xe0d019663154cfabddb9b6e7cac934, 0x7e0338d1683174fd43eec96a160dbc, 0x1031]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xc4ea089bf481557a6164dd258584ba, 0xec9d250cfed4dff5d84505abd5c423, 0x22a6], [0x4c55bb640b97b144a1dbe50976d48, 0xe0399e9eaf33ea38dc57c622628338, 0x260a]),
            r1: fp2_from_limbs([0xf43969a4884974219d2c6d43a647e9, 0x1c3c71da75e0eda68be9704f6289d0, 0x2bf6], [0x985bd4a0d426afabd9568c67456b5b, 0x9297be0f39ca1b993709d58e1ef28e, 0xc95]),
            r2: fp2_from_limbs([0x562aa81d8991689f79f5e920b8467f, 0x19d067cc65c1dcbacb33001fe95d10, 0x1655], [0xe8412bb5d7eddfa24876666bf9f975, 0x9de0e631a1724744f3dca9d34b2020, 0xec4]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd26ce53a434702729788f80ec5aeb9, 0x71cc5532037bb66fa57e163dc390f9, 0x1d41], [0x94e1c245fb1ee7c20829b89e5ee137, 0x94f742494f2feecccc55915979a09c, 0x191e]),
            r1: fp2_from_limbs([0xee97ee8554643911117902e009c78f, 0xc0c43e35758a69736f8f4a5e39483b, 0x5ca], [0xed1c3b0f2c5ded80b25fda3cff8e8a, 0xd9db35e0e121274163692882536785, 0x10f2]),
            r2: fp2_from_limbs([0x145e70ab897599c4ea635f5301c972, 0xcbe84aeee28c32a337c35a660517b2, 0x26b3], [0xf8eda59adcda664c023fc8da80bbfc, 0x71cf32ab6fc2c6c26297f1dbc43f4e, 0x2e21]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf43901c667280a728ceeded63d24ea, 0xb13f63b4c30fb250c6ca6f2204c806, 0x2296], [0x61580ce5e5f336ed7666da57431193, 0x153c2036a3aecf45474669e155d5f0, 0x1310]),
            r1: fp2_from_limbs([0x3edae9156418fc3cb2fffce32f17bc, 0x5a7d429b4ec9105d9c030c07a42123, 0x2aee], [0x6f4cb2778c4cbc418d393d1ded5094, 0x9a82efc2c494ae8538b01c851774f2, 0x1e4b]),
            r2: fp2_from_limbs([0x839c1cd99318c57d2c56e8a4086a53, 0x9fadf0aadce4beaa39c714394233ad, 0x789], [0x9df2b4afef21d42ccc97520cd91ec4, 0xcc21dd589dd8d9a5a8f46751922454, 0x126b]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd31a7b94ac0c425f36853bd7201962, 0x6af5c03f4d7c9652b9f7bad768d0a2, 0x2102], [0xd651336f8d25d08e5dfe61db28e293, 0xbdcffad335c7ef79f522a6988c12e, 0x1854]),
            r1: fp2_from_limbs([0x6e9decd4e57e6d847cde4b6d4ff19f, 0x5bccb3784a758e3043c64aa65e8fa2, 0x2804], [0xed72abc2d6cbb3c73c9feebc85edcb, 0x46519b72b63d8d717a68c8be92d0a7, 0xd3]),
            r2: fp2_from_limbs([0x164005a3a15ad2da0139d2f59f3fe7, 0xa154504ed5e8214d0c5df86696479d, 0x2efe], [0xd1ad1f2d1d9538ef26cebf73c0aa18, 0xe57744d4008dffa4b13332d78c0204, 0x1abd]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xea8cd1746d8ce0ff23c208c70d0402, 0x52b9b8f717aaae7696dd9d02dfe53b, 0x2657], [0x921275ac674263025352c62f0cc7b5, 0x264964b7a603f55f11e71cc380ae91, 0x2b90]),
            r1: fp2_from_limbs([0x4cb85c9b3a2e5d1b056e3a6b092e59, 0xef6104d3604ab2b0f0296b914bb0ed, 0x13b9], [0x24e30924c59a8d3957015b160982cf, 0x6fd4d39787a818fd83baa74bc53457, 0x411]),
            r2: fp2_from_limbs([0xaf6f6280ebccf65b2a556a14d8ebbd, 0xa974371836411530e9d791518acf17, 0x4ee], [0x144b98039fc7544c32f774e94bb544, 0x96a96b38a58d2fa8e34666846ad63e, 0x10d6]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xcf1a1be72a0dde916d452d53104141, 0x737ed88a9e9a4fe440682cd927fc36, 0x65b], [0x7198efe014caab80c1e4ec97463a89, 0xae24109878bde1d54c2663b9e7938e, 0x2743]),
            r1: fp2_from_limbs([0x973018e4510ed0f0818d4a085782d, 0x91609aece01d240a10c426028b5f21, 0x1a6c], [0xa63b40c5ff9e9139f3eac405610ee0, 0x6e8cf5f0d791c6393e6bcaf2492928, 0x1f6b]),
            r2: fp2_from_limbs([0x208a5bbd623fddee5e5305ad5c9d3, 0xa786bb477b920ebd04d86a9d27a711, 0x2cfc], [0xb1b74f55f93c6d5fe7d67ca2b6a5a4, 0x6674ce6621aed13adde2caf1f13bba, 0xa67]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x5400b2d9d0806f2698f608b219e3ff, 0x999c43ea01abfd93ff9312a8a99257, 0x2076], [0xa364ccf486e2c087cbce8af7d87765, 0x6b2ca9db8897aa48822089a2fa90cd, 0xcb8]),
            r1: fp2_from_limbs([0x73e25826374d640144695579656216, 0x21ebe2a0f5c0a7bff6f70094afdd42, 0xf15], [0x53e7bf0a4e9e08a3c315621510b622, 0x886c0511f264bda06820ef745653da, 0x6ec]),
            r2: fp2_from_limbs([0xce94a83b6348ffe8d0ad582fee7720, 0x19dcafe10405df54ad9bac611fb591, 0xbbe], [0x1a9cd0366b17b526d7c33b77368324, 0xa1d570d52a22d4ca3ac3758717daee, 0x1f30]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1b286c72d5243c65da092636fa7c2f, 0xccaf7225bf755347689d9495272dc3, 0x1dfb], [0xd78632751ecbd71974587b4cdf6835, 0xb5814f6480e4f6732fefaff8c29163, 0x1443]),
            r1: fp2_from_limbs([0x290464183fcd65dd1febcf5a5b3e2c, 0xa6ee79dc8284a90e7fffaa6b58365e, 0x1fd], [0xefbdc9247f6040e7056c1d420f1c32, 0x532b37e15b0b0d2debac87f6b3c89f, 0x1ca2]),
            r2: fp2_from_limbs([0xf1c34869863e1dd762c4ec07cbb34c, 0x225fb321224bfb0f6a450d2b588143, 0x2c07], [0xdffcaec2290a75b9c8f112fb7b5c05, 0xa6603e06260a80eaa0e12e50719f08, 0x1a20]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x50fc146f3df36dd1597b2a15fdcc7, 0xba2db02fdd8269692cb5fe9f478fc9, 0x2e68], [0x4e183b4026f5d8013ae596ac284b1a, 0x29133f682568fe0541fc301814bf84, 0x2c7e]),
            r1: fp2_from_limbs([0x18e404e8967569b33e734269ca4f8c, 0xfdc96fd90a19f1c29132a8508f4a77, 0x597], [0x10b5a6853117be3125453d79667ec4, 0x56b45d0938c4940f558fb6a55ca7fd, 0x1e00]),
            r2: fp2_from_limbs([0xcb72e87436422481e6c6fb73464ff9, 0x298931510889d34a9a8ef870bb0f83, 0x25e9], [0xa1286feb1c5a5d8f3bdb6fea6b40f7, 0xb70a4c3886cf169e87cb134234c896, 0x1002]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x6fe68ae17df7289d2773a96d913c13, 0x70965feb00c9b52ad0ea7f5d31eb1d, 0x8f6], [0xb446772149075fc33f19430824700f, 0x7b9ee5923bca17b24869abd6d8bf46, 0x1bcb]),
            r1: fp2_from_limbs([0xa04daf11839ef11980a898e53d65fd, 0x4ad586a63a832bc6682f4365785a3c, 0xcc8], [0x75b9683ffc6e42b0f0e350e14b982e, 0xc71e549b93405d22cf44d41eeb7a48, 0x1167]),
            r2: fp2_from_limbs([0xc08883ea926d7cb913599bff5bf933, 0x91a0fc9cc3ef37db398c70841a05e3, 0xaa6], [0x81c52c8e3ebb4ab9e7da587e22e5e3, 0x875c8a2225d833cf2bd01e4697fc50, 0x279]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x9830cc398f0f50bfebc280bcbbe388, 0x2b7b165169088e5cebcb886a09f71, 0x195f], [0x332ccb39fe0ea205da71cc45aad4a, 0xee2dc79a819efc67c1eddb51a3a813, 0x1d06]),
            r1: fp2_from_limbs([0xd1ff6e24374a8faff894455cb59c38, 0xb14aeff6ef499e05354189b2ca4a5c, 0x179], [0xc2d0b0b3b31f5aa4f8b35e0e69d50a, 0x854ed697f9cfe57efe82f46bcb1e39, 0x1f50]),
            r2: fp2_from_limbs([0x141a8cdc218be4142e502817407288, 0xf7903951b5dcd57a7659544b48dd58, 0xc2f], [0x9f84f65d6708db4b07efb45556ac3c, 0x19e4330539ea88a8c75a04c6711351, 0xe70]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xdfef148870295e13fed1278567fe2f, 0x52748592466bb385374aecf8d05725, 0x2462], [0xc1bd99bf9dff307b2ed604175aa0b5, 0x210f0303599349211babb45f48d68c, 0x2bd5]),
            r1: fp2_from_limbs([0x19eb029d7c42432c256fcceb2e397, 0x7dbe61f4502c61fd622d83753a6333, 0x1], [0x27595db07f6399e3a09210697771c0, 0xd1af119d11ffe5a231c691263144c9, 0x2dae]),
            r2: fp2_from_limbs([0x39a4ff36d6d7d94ea6ecb96187fd01, 0x6c7c04d91d95eb0f7f1afc27454cac, 0x6e2], [0x1492add165c30694c4f0f5bea3e27, 0x6d462d472cc5301f86a11297f80db4, 0xba9]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xa6a1505bb4a5280216b9f4255de870, 0x93fbb2dc5b17ac7e4cbc93223972b9, 0xcff], [0x1f734d635bf17d47a41a2595794a3f, 0xe9cf26467f0abd8c989a9b9911a485, 0x1b4b]),
            r1: fp2_from_limbs([0x1404427dae33f95bd7b79b4c187b39, 0x42853c8959e5edae6143ac06aa4a07, 0x2d80], [0x1a6240fac14a98d87c0a92c4f791a2, 0xe058963dfeffae4b6bb12283ae77e5, 0x2b29]),
            r2: fp2_from_limbs([0x419ac567a7f0a5ce3c196883895718, 0x704c5cdd0862ab152771b608ccc8d9, 0xc22], [0xb09d4676610629e3f4d930d12d883b, 0xf2e248f998e33e36f27ceaffe4eb1d, 0x2f8]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1f3287c146dd78258bdb9a8987c23c, 0x226d7d9d237b5bfcd04b8e39e24cbc, 0x1153], [0x9678d2cf9bbb0e9d96329cc3306b8f, 0x62663bfb04b7cd0888cde314d5d7ff, 0x20ca]),
            r1: fp2_from_limbs([0xbd02ee2d9b79371e49f773cf27e1ef, 0x906f70ccfda44bf7f3db252f7b833a, 0x6f7], [0xe83edf70057b2345d6fd533c422909, 0x254558eca63bcf71314e90835e60a5, 0x2aa6]),
            r2: fp2_from_limbs([0xb9fe224f86b2ad6d40f43629c5afad, 0xb1fa6f949c745ccff640e3bc69353f, 0x2245], [0x9c06f7a654a5a19b209663efeebf33, 0x8729467d42d0e9cc3e36740367be25, 0xc30]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x9bdbde1a2a5cc6a618369180aabff3, 0xf4a396c85288d4a2d8ae0ec8507da6, 0x27fc], [0xe6427b7e7e9a13a9b8b88433b25697, 0x3b272b4507d0d7cd3ef7524fb1f801, 0xd6a]),
            r1: fp2_from_limbs([0x905800254f6d1e8aff3276f692a84c, 0x5f04db4f2f21f5058e3ae0e8a1f9bd, 0x2003], [0x2751375fdeb84fe75702e526a8af86, 0x895cab6c6b0d0cf883df5bb64f1688, 0x2916]),
            r2: fp2_from_limbs([0x4db012bb2ef92fdd2aef328df4b41, 0x8babd8bedc76df6ad8d8aacb381e, 0x243a], [0xf9c77d73a48c864004ca370ee9a297, 0x84f4fb78872948219c8a2dc4866dd1, 0x246b]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xce19fa6e9f9ae92cb99cbc3aa899bd, 0xc78376f7a5383387ce5b7609a63168, 0x20c6], [0xe39f8615c584ddb06f4a8672d0e7fb, 0xe753c380c0baa96e53cde4ea66c18c, 0x29ec]),
            r1: fp2_from_limbs([0x4e55e7982712c22990804eb4445da, 0x979bed572a368c613e2872a1e8170, 0x1327], [0x9a704d738d3be994db65b24f31ac58, 0x75f0fe118bf260b97bf664f2296e55, 0x6e5]),
            r2: fp2_from_limbs([0xb16fe8fb86f9be15dc77fa85dd1a46, 0x216d81d803d4f6e099164d45fe8a80, 0xac3], [0xb6a4299b433ac66b600647b2e04a9c, 0xbff7dd815093dc1e457ce8915a4827, 0x26a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf09b677c3201134a57e851feebbb44, 0xa435aed658c69ebf6d99b3ef67a714, 0x25d0], [0x320b21d08e61fad837d306d7599e6f, 0xd527e207fa04a1571347d6c9a2819d, 0x177b]),
            r1: fp2_from_limbs([0x7f23b78050a67e742d6e38752de8f, 0x954c0a4effed8e4600d046933b2e0b, 0x1778], [0x5837fb26bfa1d24792928479259c36, 0xb289833cf347d379395059acbc72f7, 0x2b2b]),
            r2: fp2_from_limbs([0xf1296c2aa0e85470e60c58f0424db1, 0xe23625bf6d00cc43fdc06cb8f77c00, 0x269c], [0x49d059cf4da7b430241daa309a94e3, 0x183d8ba9e841d752d93b3beeebe9f6, 0x2750]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x55dc1f3c715ee9ea7f5486b05e9d3e, 0x7926490cc504680de7420cdd9985b8, 0x2213], [0x53460b5683e4ed89d489a063795666, 0x7d01501905d34b7e0b0b06197c6996, 0x301d]),
            r1: fp2_from_limbs([0x5be1329dbc360dad27edd4068779fc, 0xd1fe3f670034a0a8fbd91f432dd6e2, 0x26e2], [0x480fd90702c611363cbd062479c579, 0xf14883efe5029b3b1c21f14af749e1, 0xe1b]),
            r2: fp2_from_limbs([0xacf0e6ad61300ea281a330e6bdb901, 0x12b64321f577db8901e9f71c2fd360, 0x782], [0x567d609cee69972762b125ea331c6b, 0x100e8bf1e6f4a9f9ca5f47b966a8a3, 0x1eae]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x3a8ace3283fa2e432080cd2c30de93, 0x354180719a7d66d782edaade28adc7, 0x2ab1], [0x65cd9f69989a0e43a913d2ffa345e4, 0x7c8120f30ab93162f6412d37394987, 0x2370]),
            r1: fp2_from_limbs([0x14a70ee5fb55b189e26e2e7d90d039, 0x1eacdf78c7b7a92d0f13a91c242882, 0x84f], [0x46345ab3d88337ac0c0754a1f995de, 0x19e82a3413af6c7865b83f7fabc56c, 0x886]),
            r2: fp2_from_limbs([0xf5c0830abd054a4e721f0242d013cf, 0x95535fd4b85ec4c099dcdec24d9da1, 0x27f6], [0x7b7d761445448df5e6b6f18d90dc92, 0xc3e762b3a6e860bddb07be62c2490, 0x1e62]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd27f0050a694176d5151f3e095ed22, 0xc0b7055dfe2502a5929118ba9190e4, 0x6e6], [0x826952199149cf3663a18a025fabe, 0xe5cf78867a91a455ba4469136aa474, 0x1196]),
            r1: fp2_from_limbs([0xd31a99fb2e76724df9359aac8ab608, 0x877ad485a41bf46287343db33da86d, 0x1490], [0x7259876f2fb95507513e398b12addc, 0xb95f07e3e8ef09bf03ac51effcfdce, 0xc13]),
            r2: fp2_from_limbs([0x965c87dc843b8e078c83429d656da0, 0x427f1fae50d9ee4e3199e660910a22, 0x1105], [0xa7270420f4bf34a5de6db4ba658281, 0x95599753fdb1dc39ba21a788c91f43, 0x1a36]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x7f00bca0e4b8dcb80791cf3b2d7556, 0x76f59b110073883803e3efe7c0ae9f, 0xa50], [0xa808c9bc6146850a27a96d46aa9bd8, 0x8c3d969a6d3a686f37ae0a8bc95c55, 0x20e1]),
            r1: fp2_from_limbs([0x909f6553f502efa668b34b3132f947, 0x2f14a210139ba5f7bea96322bae1d0, 0x4d0], [0x825a432ded174aa928747b2117370b, 0x5dbcd5c9cf485d9e7037b973e91f44, 0x1f98]),
            r2: fp2_from_limbs([0x13a8a8c417f482afbcff29eb970ec8, 0x3b8845f654cf2ef99f33acb0ef922, 0x95b], [0xa9323565db610fbc227b2aa51f796e, 0x1e7b414092fa5771e2b56bed8c3891, 0x1990]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x6b47f00e0b134b69c06fc79b14147b, 0x680284d9ebd50d8f00927d7ac0b235, 0xae7], [0x3638188b29e6c30a692a48a2a43b1a, 0xf7fefb2c94888ba44547914a11473b, 0x1ebd]),
            r1: fp2_from_limbs([0x4731aca492f99dcc4229ac249de58c, 0xd54fb9a5b62437cb6389e2883d3a2e, 0x2e02], [0x3c69eaa93a6f160d24019eb8139920, 0x961a82c5a9bdbde330316fa8a9d9a3, 0x48b]),
            r2: fp2_from_limbs([0x44d1aa89a790191c4ad2b49295c96b, 0x6b7076a33bb81df002d58cb9de480a, 0x1a76], [0x107b15a1b8ef87e5ecffb579ac638a, 0x526b59ea05173f80bc740ab3d64734, 0x9fa]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x548cd39d11eaf36faf75b4f6d16028, 0xcbbf156ff8a7fa5238f6fc49ffa562, 0x1e72], [0x604b4d7a307f937277152732786dbd, 0x85b22b25e1c1e7d4489b1011d90247, 0x1c8b]),
            r1: fp2_from_limbs([0xdc0151ed5edf9fc6e0f0c7e5bb60b8, 0x621221d539e6386787117e77c9e6e5, 0x5a4], [0x8d2c1932dda669fba5950c38e68d7c, 0x95cb9f4b1300ab8cf3067119272eaf, 0x418]),
            r2: fp2_from_limbs([0x83597b7ba8f8e961d244259b24cc97, 0xc833392f4d4b7e74185995236186a7, 0x283b], [0xfeabd57c72a2ed324611cea9f80382, 0x11c03583e18b1bcd456db681743adc, 0xb97]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x5a1e5860b22fe80eb125578acb3c55, 0x70c1f8eb837f5c5915cab29453f23a, 0x1bfe], [0x7ad03c32f07096790fece9902ced21, 0x8c505335e21e9be901742d591996f8, 0x16f6]),
            r1: fp2_from_limbs([0x38d582867ae2a8b42242819e6e37c2, 0x9716cbe64a7ff437195ed1faed912b, 0x208b], [0x750f22da674109413f1226bf9d225a, 0x42841415a480f91f1dc0ca50353856, 0x15c1]),
            r2: fp2_from_limbs([0x36abb17c80333e0ead18e71c4c2c2e, 0x9c84f6661bdd25f70e726d947eefb3, 0x1dc1], [0x5e94a2c6bb3ba8e2ffcc587a9c0b45, 0x88fd9daca816a68bc3a7adecf2803c, 0x813]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x3b7185c88d562aedbce56cf88c38b3, 0x9ec9f50a758f7e3789a99d81c9dcf5, 0x2f96], [0xf5fd286f2dddf49eece2a6b687bc62, 0xbd71209d265b27476bcbaff1823010, 0x48d]),
            r1: fp2_from_limbs([0xf951fd7224a6e5488ca8df9b3e01d7, 0xd7d11c1429a8abbbcbedebd466365b, 0x25bd], [0x8423dffca292e62b2fc0541d1430a9, 0xbb58f4482bad168f78dcb8e5b3442, 0x2c13]),
            r2: fp2_from_limbs([0xa6f756fff289ee6b09d01ca3f76d0e, 0x16f8e35e117109cfc18695f4a931ab, 0x15eb], [0xfbcfb7188bfcbdeda7089f1b83cdc, 0x1361790edaf116137b441ea373ce0a, 0x19ec]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xb8df9cc7dfbb53d14c8d378190e3f6, 0x47ae49820137ccbd6c8fe54eeab79a, 0x17ad], [0x20d705774a264b4760b4fd3c4452eb, 0xc06fc3226ca34bee040f149dc95915, 0x239b]),
            r1: fp2_from_limbs([0xea1085191a86997304fce8c4ad61b6, 0x32fcca50538244350100994e0a7fb0, 0x1ab9], [0xed24e5205743315dbbd8fe8fc8a6ff, 0xc2e946c5e83e0247725623fad3e838, 0x22fe]),
            r2: fp2_from_limbs([0x8157b27f9d4bdeb3d319c0ddebd953, 0xcbfd41858d47c7994b9d10283cac6e, 0x188f], [0x2c93eb095d80d10a389401f25e119b, 0x242e3b32a33933b67cea26a35295a0, 0x25fd]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x32e51bd515382b62594792bf93f041, 0xc3f1f570cc12b1dcaf8bc10da935fe, 0x1223], [0x40bc5aeb584cef9d32fde350626f6e, 0x5bdad511341b364577d4b58981d49a, 0x2c6]),
            r1: fp2_from_limbs([0x6b4bc0261bf4442e373244f49b00b6, 0xfb70323b1c69938140a62f10df7783, 0x1d70], [0xe054c87062540f0d5f9cc11e14a569, 0xaad0bce1830e1050f3105087c9454d, 0x112d]),
            r2: fp2_from_limbs([0x9948d7fc682bf7484b6c35cd769a77, 0xcdffbf078938588a47745a98b34c1c, 0x7c4], [0x251389c60a4e60bb008026227062, 0x64804286df00970d5c57334abeb734, 0x682]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x539d5f324b7b27c49635c0ad1a0769, 0x45beca65ad42c8336055579e4450cb, 0xb34], [0x1eb83204df06de83ed5472f4cbc290, 0x1a1f0c5e486a473fa3a75d08d2de21, 0xcdf]),
            r1: fp2_from_limbs([0x872b19aece1d2637534acdb90e8707, 0xf381d05583a628b10a42925d247da7, 0x12f4], [0xc70b8bf427bc36a6e74f1f09432122, 0xf4bb248dd4e34da1a0b56d849cd9fc, 0x1907]),
            r2: fp2_from_limbs([0xe9cf085ddb0a22e2f00ade99b23bfb, 0x9a672b6aa3b67800751dc7b119263b, 0x3e8], [0x7ce7ade49f63220b3a8127faad61e, 0x9a533eef4b0c0729ee41cea9a94a60, 0x2a39]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1d870963246f0f81af822d5d6ed9dc, 0x69c7091743f5d7348f44d32b96143c, 0x153d], [0xf65dfd0d3b250a41e8fcac3a501878, 0x3940d729beb7d3b8c286899fb8482e, 0x2a4c]),
            r1: fp2_from_limbs([0xf581b88087512fd47cc2b6aa4ce9fb, 0x7ba4f31be861d1b138e4ffc9268b53, 0x163d], [0x2cc1da2936a547904c82f154556681, 0x21d72a11321959470c378aa7bcf72c, 0x448]),
            r2: fp2_from_limbs([0xfcfd01103173fef6eef334b347e3be, 0xc63274ea2b96ee113f80601524f65f, 0x248f], [0x6e440a38960a8c420604a60b24070c, 0xa221c9883c68a83b0dbf331b274a26, 0x2212]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xddd1565ee35629f6f4fad67ec313e, 0xa5514b97d88f23b39390a2acdf5717, 0x1a56], [0xe0cbb39510ad01c10d6f76653ced95, 0xf116c5849824884dba4e142d7f81d9, 0x1efa]),
            r1: fp2_from_limbs([0xa72c0a1a9f97b4d6f3e3de0335d99a, 0x8228fd4efa7138148bc1edd28e20bd, 0x1e07], [0xdc892f656caa06186b75b98f60f08d, 0xab2e1d94f34eee3eb32533fda6e7f7, 0x18a1]),
            r2: fp2_from_limbs([0xc9bd518b026c93db113a101425d74b, 0x9d89c5834d9de2f1070037b99cbe4c, 0x1a4b], [0x5c1a023060751246449752c24c113d, 0xb1e6c3c5804a66094a9fcd689ed9d2, 0x1f12]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe47836c0000d04aaae6784cf1f9c52, 0xfce342d451668a126d0226d5693e8, 0x2cb6], [0xf5754b365aefcbb3a1f3f2c188dbf7, 0x769638503145eeec58cfe365ebcdd, 0x16bd]),
            r1: fp2_from_limbs([0xaec4a958be1e29e4d91b9c1de37481, 0xb62666fb5a8094ba00238895232076, 0x282], [0xd1e9a82571de093d4018aa37fddca5, 0xf78b41f79de03186daa9efdb3926bc, 0x24d3]),
            r2: fp2_from_limbs([0x3178d862e2afd8b202560e35f1765e, 0xefded0872751f3fad04d251c34c551, 0x1b2f], [0xe2069c49cbce27021abe889e8c79a2, 0xeaaf43eae25d1bc3a0739f15c5b7c3, 0x2214]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf79f94befa9e541b76473562a7b0d, 0xcf4e7ff365831e7cee79e2e4bc192e, 0xa0], [0x7ba201621fead3098be29bd2c4974c, 0xa29287da9d9983a3b1b4ad0f6dfeba, 0x22b7]),
            r1: fp2_from_limbs([0x6fc4fdff9cefe779d64334b2dc19ce, 0xe86fbba839b8e788cc946cef732a9, 0x2355], [0xf98eb3670e64a2919e7d5d665fa67b, 0xc47cfe2fc56949a13aa663b9655961, 0x2be2]),
            r2: fp2_from_limbs([0x1918a2075c95339aa2062314b58bf3, 0xe96176f6c28c3ea5514ac6cc94d2dc, 0xef2], [0xe3c35679b51f618280722d85c8ac99, 0x48844c1153fa87b3d1ece0928c2af4, 0x2232]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x402f412f69dabc366cc5bd2a3f6eb1, 0xa72d048796612db3cae1e1f7d19f11, 0x1662], [0xeb384f3a0e0526d997f73777b52a65, 0x46daa456f5261ce363687b498abad5, 0xade]),
            r1: fp2_from_limbs([0xbd59674578b79e488f4e7f2c28892a, 0x68da2f5e5a7b4e08817d00f4d111fe, 0x2626], [0xdbd0064b17930ce6367678a6d49eb, 0xf2d58fd423836e94055395e0a808b3, 0x1a87]),
            r2: fp2_from_limbs([0xe7fb5afca1157fdc1411f2797a175f, 0x4881dcb908a2aaefb0c92e78065212, 0x2821], [0xe6dc65ca3caa0d28c06d7381f6120b, 0x7fc1f77b1ee8da1ce64082b8d68acc, 0xe95]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xda82e226b0948f24ecd4ce21adbc78, 0x3c8916336103f79a0e76c8b1102d28, 0x24e5], [0x5f7df7ecacedcedfebcca4bd315f67, 0x70d0971440f29026d7b985ca8e6790, 0xb8e]),
            r1: fp2_from_limbs([0x50fac4782c0beb6af9c30c38ea611b, 0x78a782264bebd1c16b6cabb8c5a12, 0x1471], [0x259ae463c6f280e45ba5e6a85c8e1e, 0x28409ae768f5f0dba785ed52247bfb, 0x64]),
            r2: fp2_from_limbs([0x6d1e2ba327bf0079a3a6484e714d62, 0xcaa4c08448ead24488e12534695876, 0x1d4e], [0xb6bd4c42bef8864d6addfd161b5311, 0xfc20c8c6ac5bf4963851d3824b31de, 0x573]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x6372dbb8e3090b96d2b2fd70e6942f, 0x2688c08626ca3d011790ca56b1a7e3, 0x25ab], [0x39dfbfe806bd8f7a242c6ea27701, 0x353bd19b83002ee066cc170510fb94, 0x12bd]),
            r1: fp2_from_limbs([0xc07e4c7088b577ef888e0ab137a574, 0xddac6900d3ab669aebf40fb8550c7, 0x2c1e], [0xc31da1b15f4d90f261e7c97816af2e, 0x46a0aa0ece335f443db7a0afa79e7b, 0x6d8]),
            r2: fp2_from_limbs([0x8150b25ccef35c83ac555beaefd2bc, 0x4ffa0076067b3d11c98b569fd9899d, 0x1830], [0x54913e8d1e36ea19ca0d7acd4f116b, 0x96d1678c8578fd930c620a969943b8, 0x1f93]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x3f47fa5ee0de2d11bf938ff51be2e7, 0x1226f667f55a02f00c73172b45bf92, 0x205f], [0xc9e34f33d33152f7b3f55187485fc4, 0xbe0f3a71357f2f2313bc7d0ab0429b, 0x1474]),
            r1: fp2_from_limbs([0x46309e69ea87ca7a6e66f22b5e01db, 0x6c1d8273827cb5c5a0821d11b85754, 0x3db], [0x2b68877d69619a891601927ceed02b, 0x1a75558355c818a7ac2a11f1fa0eb6, 0x1bae]),
            r2: fp2_from_limbs([0x296b7bd0cd40a86febc815d9d88952, 0xff7ffcab6ea5fcefced312494ed93, 0x6c6], [0xda66cf88fef98af56d222b54418dd9, 0x4317c0ff8b83e4aaab7f36d6c85fb, 0x1c00]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x563b3d07b0938f786082d614fd7d69, 0x9eb59c24630f421f5dacb8b4fbc83, 0x1d52], [0xc266de93554c28a998ea081893e0c4, 0x4947d61602ea28f071219a73e18fd8, 0x1e9a]),
            r1: fp2_from_limbs([0xfcc72ce9d0fc0922bb6db00b6f6e1f, 0x51d71fd418ba0396bc731d0c91592a, 0x2e5b], [0x7756778071ea929d6904438f66d212, 0x5472441d75dc5e0249b00f9e7e6df, 0x57]),
            r2: fp2_from_limbs([0x96f84baee6bde5d615efc4d2071752, 0x4a26d98f6fe6814159107cb56c15e2, 0x1440], [0x3df13df948e0e9e913c4a8ad08f877, 0xad237a26a7aac16e3a0b75b6862a24, 0x22d5]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1e71330f31343a707a15082970f17b, 0x22e48be1a2e49f56841d51ee535c87, 0xf3c], [0x131ca36f5ab065089e8ac11f9f76f1, 0x6e93cf4e0baf99b9afed818b884caf, 0xb3a]),
            r1: fp2_from_limbs([0x1dc7dbb6f8a74f65563d689d18e96f, 0xbadfabbd6ee9d3dbcd14c78ba4ce93, 0x1b61], [0xcd29b4722e83a8a5481b1a0f7064cc, 0x99806683bb094c6c106c5f68090c28, 0x658]),
            r2: fp2_from_limbs([0x687168fa2b88ef77f402c332164967, 0xe9b0d80486a84961871beec40b3c33, 0x2fe4], [0x8eaad505f80f703abd20cf2509061d, 0xe8d63e02f5c71dd3da0bffa3474391, 0x1196]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x463c04dfaccce615fc24f1b9776eef, 0xeef2ed8fbc661325d0f6cd313fb18, 0x1871], [0xf117871a3c74c5324ce96495e1f6a1, 0x91569228d5e99bd0882aeb92287c3b, 0x172a]),
            r1: fp2_from_limbs([0x3f2ff55f58918617d348bd3b403b1a, 0x72143cbfc3caefa5870848b5225ce, 0x16d2], [0x90400cde1ef31a1c80d05af0b65f54, 0x39dc01626521ca58fe48ba8e03d65e, 0x8b2]),
            r2: fp2_from_limbs([0x3876b1843ebeb941e99c4bd1ef15f0, 0xb674950d2feebf8fab7f01ff273481, 0x1289], [0x974208074f25a00891750073adb09e, 0xe4c7de035b7d30d7cfcd29d4aee32b, 0xe67]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xaa6fa9ed661190e112a4f347bada42, 0xc735feb1ade6f6db52a84b3d909eb1, 0xb80], [0xc807f87116c6f0640abef1f8b471bf, 0xe288d574511c48e206fd342792457b, 0x124a]),
            r1: fp2_from_limbs([0x63099dc0cddc356558c79c95f54bdf, 0xa5c7b365486880cb40d32186c8f946, 0x2471], [0x2645e1ab255541769adf8146e39c09, 0x6ef9b0683d8a82465556c39657a23a, 0x15ad]),
            r2: fp2_from_limbs([0x3037715643296a98930a576a5773ac, 0x4fa74355a521262944432206afa4fd, 0x2f94], [0xb54f1c5b97588e691eeadf56271c2b, 0x85aa54a52c5a13f0f56315e5ecb55d, 0x2c15]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x1f5015def84cde6d9ef27989bd09a5, 0x201e55af1277f8300d3048cac37f1b, 0x2ad0], [0x5f3084ba2c15635fc320150291c06a, 0xa20ce1504b1716024e2dd0cffedb85, 0x2ecc]),
            r1: fp2_from_limbs([0x93b78847cca9fce4e5364ddba2512f, 0x36b18e7eae4d4e9aaec3473cfc46fd, 0x46e], [0xb69dbe555db251a778cdae95af141b, 0x3ade0a5da9772c03d5c69a205ae427, 0x2e17]),
            r2: fp2_from_limbs([0x6289cfd03e3a4af9ee88373de1b080, 0x3340221ce4977871f5ea9618d3e165, 0x29b5], [0x748cb334a43b26a0c44c8b5a5aeb8, 0xa3178a1af68756408bbba83b6795a1, 0x10d8]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe95976542264e97360afa39b0f2783, 0xa6457d0df05a1cbf43530b370f510f, 0x3d7], [0xbb5a927c7a13b43ed97e857ed2d026, 0xf4f35b1643ce3947655a2ec1e309dd, 0x2d20]),
            r1: fp2_from_limbs([0xd465eb059733d4111eafcfa475fe2b, 0xce109e88e77f45eb3bb7a1a8e6bbc6, 0x293d], [0xf20512d978ca719df4b84bbfd8a255, 0x33f7b11ed8863623987d3ac83a057f, 0x1824]),
            r2: fp2_from_limbs([0x6952e145deab85d5c0a9e8d18e2e9c, 0x9be8bbac5c6fc876d304f74ed56f3c, 0x2805], [0xc367a1a6fc1f0afbd9b8d75f3f103b, 0x30615ac45bacda1247be276752e06f, 0x10ec]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xef47d15af1458d23fb79372e87cd56, 0x81610ff5a7997c850d90bd7e64a3b0, 0x1511], [0xbcc77bde3dd9b7e06f469182533978, 0x9d18ef29356936cde08f8d945229df, 0x193c]),
            r1: fp2_from_limbs([0xae1864f31383eb50f7b5ef63d1dd8b, 0x7913f31d8040f25f4c4ed33f9c9614, 0x1e13], [0x5d0935050db5a3eb2108f47f2a59b2, 0x6b20498a01bc42afd27955a8264151, 0x26c4]),
            r2: fp2_from_limbs([0x9e10c95eb3584a2520f2c815caf6b0, 0xced347a049782dc232808f1dc96341, 0xddb], [0x696a704f2c89fa3863b6fbbfb2a2b9, 0x18cce9926f4abd94478e46c396fdc1, 0x1d6f]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x380e10e4927efe15072d6d031facdd, 0xc4594d12346a9e2eb962b973902d17, 0x1df7], [0xcf36e043af797bd1a23d5717857d3e, 0x6d576d2e3942d2970b79c01aad1d7, 0x1657]),
            r1: fp2_from_limbs([0xfd0871ea9a2c06bd11110f5dcbec13, 0xccf07ddd053d558a605430070fbf92, 0x2519], [0x237eaaf57f6007181b0c7ee5ed2c17, 0x6b65ca89934769b212f1367b57a7e9, 0x28ba]),
            r2: fp2_from_limbs([0xa00d7f96012f6947d21442c64dac10, 0xcf48befeade3102f42b8e583692456, 0x484], [0x7fb6106444450e62c9a63f8644eaf1, 0xd37f77966b6678bf7bea8fe98eee83, 0x2127]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xbc51ede828c48b4b4c12168f8a923c, 0x217bfeb97173f7affbdd7ce68a622, 0x374], [0xa7544b93e023c0a18347bcaa822cc4, 0xd9c44b937dbe7353193c02a6091242, 0x169b]),
            r1: fp2_from_limbs([0xe7cf2b49ef4e9f86f0271ccac165d5, 0x724d772979e09ef4ac32f04538e91, 0x691], [0x58090f2b1ad15e7ed3fbd6459c6f7a, 0xf3d4db252f0a72c0bdee76224a8efa, 0x2c19]),
            r2: fp2_from_limbs([0x884970bab2f7a918d5646c91d21318, 0x59180780622caf878301c0e9263c70, 0x12c0], [0xb64c00e932e7cba2600b8f3e39db3, 0x3adc5762d8525dcb5cce618992da4d, 0x1846]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x9dcaa840382d1408acf5a39b754141, 0xdce4510e372984f02af5ee825b5889, 0xe66], [0x9121669d645e74d4e655aac4e898de, 0xf89ae92a199c56074e95c8d2807b5b, 0x15f5]),
            r1: fp2_from_limbs([0x3688bee0714d5374ff810da0a14552, 0xc309d5833b443d1bbbf59abda86acd, 0x1d19], [0xa9c5c1c961a4cdcc2fe634260af14f, 0x476908feca37f4f93fb7811f1ca70a, 0xca7]),
            r2: fp2_from_limbs([0x518b50f48d7bacfc773bf66e569bf1, 0xcb2592204783881635f991de4c6ca4, 0xe8f], [0x334af278a3cf9486759cd73e5a8863, 0xd8b3c750daf737b9e8c613b66b6fba, 0xe25]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xd17a2fbef0566a73c2a59fd99a1521, 0xd1394dc9b99604853e8a9b22117670, 0x125c], [0x8c1f2f741b575fdae151a7217a87c8, 0xa8944572dbf5dacafaf96ec875e6d7, 0x2ad]),
            r1: fp2_from_limbs([0x6a600ff718faab2dfa5dfd845c7466, 0xe733ba41c29e26dac1291cbf49d6af, 0x2e7b], [0xccd8b02fc55bca55694df10f315c56, 0x863a74cb87b196e44aff45f23f44ca, 0x16f0]),
            r2: fp2_from_limbs([0x464b4bec0658dc458c46867ceccd21, 0x78f86fdf843d289c6c770f13baf3ea, 0x1718], [0xa217f2e5f2965a4a1be53bc82c0708, 0x1150924bd5dbec633e4dd8d30dd3bd, 0x1398]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x9532627266b9af77a19e7d03d105e, 0xfce8a9d7104085a616582bbcfc22f8, 0x1c08], [0x9134beafac0dd6aa205ca8ecf5765f, 0x7300387f401db22cf4cfbd866389de, 0x2c80]),
            r1: fp2_from_limbs([0x5c1f7e1542c4b504777bea4210f356, 0x877df84f86cdf24ad74641a3a9a30b, 0x26d6], [0x7bb2de96280efe56572321388026ee, 0x45fc58c11a2aa5691e3f77d1979e0a, 0xd0e]),
            r2: fp2_from_limbs([0x5368dacc46bd8a20fbb6f3244101b1, 0x77cb205891a3fb41ece0d6c248fac2, 0x1380], [0xeeb23a4d44bae8259de782e95cd9ad, 0x893d12acfb32f5da372c963c78da1e, 0x206b]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x49dc50f48281fd63e15e564fd40bee, 0xe7d4346282913e5a32a0df8e223a42, 0x2808], [0x992ea3556986c06c1a3b9d05600c11, 0x368f840bc3ea8eeb840009dbbf2db9, 0xdec]),
            r1: fp2_from_limbs([0x6b4c92d5fb12011ffef46404e6015d, 0x33a10a25b5625c32446d163cdaac52, 0x655], [0x138d333023e997ec20cd475d310bf4, 0x1eb8fbef857a28b2812fc9df83e6c0, 0xed9]),
            r2: fp2_from_limbs([0xb52b35dc81dfe215cc64ee149e198f, 0x860c356ce996623d0bd416013c8342, 0x1270], [0xaf6d226ae599f846a313fdf3a52bbd, 0xc4540d60b749e39341152ceec199c6, 0x13b8]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x3b931073e9bb3a7d7bd7d46db57364, 0x3c831508c00ae02bef1e589542d8a8, 0xacc], [0xeccd899e56b6be3c4ffb138d9b3df6, 0xaad41a0baa931d5104122fa8d8c06, 0xa56]),
            r1: fp2_from_limbs([0xa75248bcb2ac2d5f94467e96b107b, 0x5432b2dfed73a57d6d1a014a58e1d8, 0x293b], [0xb7acdde6bf984a21c4fd63684aedc7, 0xc13d68e70cb758f211d12102bcbfe, 0x303b]),
            r2: fp2_from_limbs([0xc821c1197c79d22da252b2e4b84d8d, 0x1e69a41a2bec25915bb7e8fdf4c7b3, 0x29ac], [0x1ab9b0064fe61cb2cdb4696f7cc7aa, 0x638184058a203499fd56bae3afcc1d, 0x1c5b]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf064c33f80a83d81a3ec4ff80c67aa, 0xf880e8161fb16f1673681012e2dd87, 0x833], [0xec3a7179e8f9af741526da82478db9, 0x775f2bbed73702086822cb7bcc82fc, 0xdc9]),
            r1: fp2_from_limbs([0x218bf23a661481e71cd707cd8de774, 0xec9a11ac4fd4cb4aead5cd4fa9f871, 0x69c], [0x4b1b7e062a6b1e10f5cad998f178d0, 0x304ed4778af07c706b1d39a87db8c2, 0x29aa]),
            r2: fp2_from_limbs([0xe9b4cf6f242e963f683116065c4a58, 0xa95511e249d39ac2ad91bc941643e2, 0x169d], [0x9b6f61d0fab815262874bd4ed3500c, 0xabe55703973539abcc50d5ccfa849e, 0x1bd1]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x334261eb1677c4f3aad42cb7defd47, 0xa36fe2de45fdaef10d32588ef411c2, 0x2091], [0xd33dbec29b7896cf8fb43885bf10f9, 0x94b4301397335aaefef87921eca2d9, 0x1f21]),
            r1: fp2_from_limbs([0x7eb753f0cf46e22af5633918c92820, 0xcd62dae0a32d240862811e58803c6b, 0x1fd], [0x5541eed7edc1d579584d9ce5b0bcc4, 0xbff8b1f52fe72b61027ef46d18fd65, 0x2720]),
            r2: fp2_from_limbs([0xc0aaa8f42bef05c34f92c727fe4fbd, 0xf9e92a242f56f767dac9c0da33576d, 0x14fd], [0x9784f81e7228e428a34f6638de775c, 0xd95af0a479d8b1b26d9986f6c9f9ec, 0x1d5c]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x8bdcc312007036399119d3469db094, 0xe046f179492372723b3765ed9e89f1, 0x13f3], [0x6684caf36a1c883c77c9a102f9aa19, 0xb1ac49eab220ae47b43937f515c1ad, 0x2091]),
            r1: fp2_from_limbs([0x8d5d36db6a0f54a8164ea0731c5847, 0xc397e300ad94d5fa9230bba7121b23, 0x2727], [0x7215ed6303ae2cd8fa5674ab55decd, 0xabb87a1eae7cc388af749f010401cf, 0x2bf6]),
            r2: fp2_from_limbs([0x5c43381b2875b4b48aa2764fde4281, 0x6846e883ec6eb8e7cb7745d10409ad, 0x2983], [0x24d34cf3f1470e0cf3a0c3c779ca56, 0x3abec76b2aeedeffa74f342171ef25, 0x2309]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x716f5bbf54b310fb8bc201bccdfdc6, 0xdfda7fc25a9c0ee4744da9cee58369, 0x1924], [0x9fede77fb66af60c5d4121f922eecc, 0x116cccc512c90405c806f9e2ea52b9, 0x1204]),
            r1: fp2_from_limbs([0x54d7fb0ce163b5cdfcf3436ffe71eb, 0x1b975740f46bba5756718407e9d1c1, 0x86a], [0x3ed4b2b389ce3007c7f7cd346fb4b3, 0x9f185e26f1193923bc869c54b027fa, 0x25a9]),
            r2: fp2_from_limbs([0xcac1089b6e96a3e239ab8119ced560, 0x604f0385ba6fc1f15e5c0efcd9b256, 0x980], [0x6a43d644d79d96b23d488bfab5c99c, 0xd41f1b175e92ed65f80e43dfa64621, 0x3d3]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xfadc85a57c8d47e378cdc72b2fce9b, 0xd20d8f70f5334f7d3c7296a1aa3cc0, 0x1a19], [0x67aa94464edb43025cb4f1e863bbbc, 0xca31f912f19730d3594953434677b3, 0x29b9]),
            r1: fp2_from_limbs([0x130f296ec8e73312c13b551230e545, 0xc9e0b47ab98bc03cec58f8efd35bb6, 0x401], [0xcae3f91228d69bf6ed46b411a38875, 0x16f2d7b4c94053d67aed834fffea1b, 0x1ee7]),
            r2: fp2_from_limbs([0x6c940be720cd5b659fa3709f415382, 0x3a9e0d24ff448e18adc2e3f3d6a85a, 0x2adb], [0xaf6b42a01cbeefa321aec19a5dd582, 0xd6fc2e4c37a4e0c6585722006a5782, 0x14c0]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x9995b18e953f74e90257d16db351cc, 0x8baa7ff84b27b96b74c06e955aca5, 0x1028], [0xd65ca59e59176d263ad7a9c42e134a, 0x996dda7c8d98ae1ecd3444e8a9f591, 0x1d2a]),
            r1: fp2_from_limbs([0x6faadcc49d6d5b2a980a0026fae07d, 0xa971079e029c20484fb6160ab6066f, 0x254b], [0x1cfa5e749c3abb62531b58a9464f4d, 0x20ce730349ec0c7ba6c4caba4cd89f, 0x1080]),
            r2: fp2_from_limbs([0x1409f2926326e59b6a4356c3a9c917, 0x51b027ed8cc5336cd4fe20decac80d, 0x300d], [0x557a4e58950ea965e5a86c2c6f60ad, 0xbe9ef63c2314ebd757f90f9de2f4f, 0x1b1d]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x5ac48c6788f2a7cb536e44e3bd9d19, 0x5feb061d3ec081d0e33f6830bb0657, 0x28b8], [0x576d5081827f6be98b2d2523b3cd8e, 0xe6cd51cb85e11f612958bec40a4dc9, 0x1887]),
            r1: fp2_from_limbs([0xf1f5dafd3a2f5ff90dce3414c0054f, 0xad62bb90580075503adb14f645f919, 0xabf], [0x4b39475a334f0cd63f8b4c7ccfdb42, 0xe9d7e1aaa30af4385b593c5d2bbc5, 0x1893]),
            r2: fp2_from_limbs([0xabaef56b6c827d21382842cf572d8c, 0x2c499f27b00117fd9f885d184d2fe7, 0x24e3], [0x19f704bfec90afd20e19f4d1f09c69, 0x1ad3f1e660431c5c394505969b4c6, 0x7f8]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x3411420ba47943ed7cb1d629bc1a34, 0xb53f101d6a95bc3891ff54bf0648f5, 0x2c56], [0x8673e52ac94a877838edcb1376891f, 0x85eaa85a2fec1719b616b9e543468b, 0x1d67]),
            r1: fp2_from_limbs([0x59c74cb44ede0aea64a869c17344fe, 0xe51621004e634ae989c6d00722d9ab, 0x124a], [0x3a812e43d8e7930ee0af888fde6661, 0x99f615f2502851a7d4aa010ba75ccf, 0x2ef1]),
            r2: fp2_from_limbs([0xcfce9affd6139ea0abef604c19ed30, 0xb51877711a569a21b4eff1a5c5bf3e, 0x1755], [0x98a4900d34c0c7607ab6b02fd7c172, 0x83afd3b05da2756678457e40e4f263, 0x276c]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x5bbf41dda19bff8b5072b08f2fcbaa, 0xe8188c743ea8d20517928a5cd8cf06, 0x1706], [0xa063e24f7c1fcd4b07e6ce954b81ee, 0x6824861ffdb9719b6d2cc1a1c70bae, 0x24d5]),
            r1: fp2_from_limbs([0x68ec31ba3f750e8be742b931d08dd5, 0x7e7c7a634f507a8e864f5d1e8054de, 0x2d07], [0x3ec0654776965490d682d1c9686215, 0xf88de189be6305ff8128eae5c7eb8e, 0x2861]),
            r2: fp2_from_limbs([0xb0ee44b6d80040674b50fa77b89a8b, 0x8b5571d7b6182fe21df7e65bd4e6b8, 0x24d9], [0x8497f8557c97eff986ec5333bc6b22, 0xaabe2c85de9272edb8ec79692b24c0, 0x5dd]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x5032a582d479c24c8f65a207d2f538, 0xdac6a2d210c3c61ccedc93f75a38e3, 0x1587], [0xb9164b025a6e412d9606f144f5181d, 0x553ec772446d813218674a9dc5fff8, 0x5ac]),
            r1: fp2_from_limbs([0xfc944362551597bc1107de6455ab9b, 0x21e9ae2a82dec7c7bd7d41ad34d154, 0xc4], [0x43cd3a26d0361f68019b47b1271627, 0x3c855861da5bc11437af3f1705ab04, 0xe9d]),
            r2: fp2_from_limbs([0x1a173c0f8603cd04b222a292da5819, 0xe0d4dc94dbd6db83e539215ca3342a, 0x1c2e], [0x1f278b2aef1ec61b05bb42c215c9df, 0xe750966ada3d37485f5858eb2c5a38, 0x14a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x67c521fe0b2c09974ed49f89342997, 0xd524123b9a707b825d40de2c373f4a, 0x460], [0x3dd8f1dd02a8746daf159f08dc9771, 0xbd92b64f27d43794bc75ce2d171ed1, 0x1fc7]),
            r1: fp2_from_limbs([0xb94c4283381f728b967c8f960cfbec, 0xf8298e4b59aed01cbbbaf3d1b116cd, 0x231d], [0xc14c79708b96ef45ab08dd04454ee1, 0x9c32e35e925fe5eda80d7ce44f0d5c, 0x17c6]),
            r2: fp2_from_limbs([0xfa3dc686e62f24cb3eaabdbffe8450, 0xd5c427f38aa980bfe9bebb0a23d92b, 0x2d7d], [0x2c6c81942046470df9303bc3fbd4e4, 0xdc036faadf327a847a6c2d6b654479, 0x159f]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x688fa935954f5bc16de9af4452b4b2, 0x4444f3debc7080f31115f479d38a0, 0x1217], [0xbd4869fff6a9f7a2a804c5279ee5da, 0x20fc570fcf9f43a956da4c5c474bf4, 0x14a0]),
            r1: fp2_from_limbs([0x9f4670c3bd36771d0e3e69b51525b1, 0x7cae509353e36466292856743cf1dc, 0x28e8], [0x2dc81e329ec59c0e1cae6505c21b2d, 0x67fe38915606e1c7631e0950bcc570, 0x2c93]),
            r2: fp2_from_limbs([0xbf420b8b0ad1870988e14edd93f746, 0xd23ad34004e99c5374440e4697e2f3, 0x70], [0xd095a56b09bdac8a18c7a3c8db68e, 0xd21beacade47c8fcfd71e19e5c7754, 0x17d8]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf60d964e2acbcbf2f45470be7157f, 0x5066f910da8652d6ec0c1b97ca5f9, 0xf9d], [0x500431c4020f9f77407ceae88b7502, 0xe3211fc375cc8461f5f080e62c1b08, 0x29ac]),
            r1: fp2_from_limbs([0x3da80a2d8e42314a26edbc411a30f, 0xb1a04059c63a27309ba6073ca3ad06, 0x2d83], [0x8f160be22479aff040b94472dd9d9, 0xd1b551e3cd673d29e1bc5d8364d082, 0x120e]),
            r2: fp2_from_limbs([0x5cab30946af69d53d3458113d1f7fb, 0x914b00bc09fc94e0cf56c4152d64be, 0x2b87], [0xf15a4f019e373763306b17f160e556, 0xdeb8db529633df7461d682f9d259d1, 0x57a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xc691ad8b726e99cd73729d3b14eab3, 0x9dcaa45ee64c22aba1de7d07757eb0, 0x2af5], [0x26881836045dfae708268cd685c530, 0x640e3f816a8c894a1ef0f5fdd917f4, 0x1fd5]),
            r1: fp2_from_limbs([0x5592a1e6367724c4daf956343df3d8, 0x5b1941d3ce688a7c14b675c5e86519, 0x2ce9], [0x34c282db893ee39cf69ee03a54b039, 0xb16908f7fce790af50996ca37d8d14, 0x1d33]),
            r2: fp2_from_limbs([0x70aff9ece0943e3f7439c0e70ea37f, 0xb8a88215f9337ae16ec7ace7eccfcd, 0x15d0], [0xbf6105841359692f849a16373c79d, 0xf4b6845fe5de4ba397efdaffc4a4a3, 0x1e9a]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xeaedc6173248b50e1a211c224f71f, 0x49f1e5b7f8d7e86729fec50f13ff2, 0x1825], [0x2d9fb85bde874d9a135822cb4a0e0f, 0xb23f5acf814497c8ef84a7f0a31156, 0x195f]),
            r1: fp2_from_limbs([0xc41b988c650c02bbc78ae956caefb6, 0xd0e9c5fc0cef229dfebe03a58ba8e7, 0x523], [0x26610db09a9779df08c3d2bde171d0, 0xe757df895154b3ad7433fbe13a76a2, 0x1c73]),
            r2: fp2_from_limbs([0x405f577e7e3eadec71cb5dfdfabe5, 0x9917fd55a00c393ac5da427eacd2bc, 0xa10], [0xc51de9b0716e982a6b5da3daccbed8, 0x1575ab1b0c1022ab8f836eec1537c7, 0x1c20]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe4cd844401d3c7ea5330c9ea0f521b, 0x84cbe8f151988d77b0099e54fcbbe1, 0xdea], [0x4c87d1488a16c70da63449f249ad2a, 0x84a6dc43a695ff65ecdf31ed0389a4, 0x1ced]),
            r1: fp2_from_limbs([0x4377b6a9eb66e5880a1d475cb686c8, 0xabe3f42aed8f96d4f943da60bbba20, 0x12d], [0xead2918273a2be2d18becc7133113f, 0x7a298af073a23740182a1ffa835c30, 0x2ae8]),
            r2: fp2_from_limbs([0x36d0f0541068f7116eaa724b3debdf, 0xbdb89a45c93d5b160102c6265c4a7f, 0x2ac9], [0x39ef55e1a1f86ef48af1a4be51d8bb, 0x16f7a5fff18e9edd02577f923fc132, 0x220d]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x184fafb06857177181d600a55043c3, 0xcdd03571540c29da6d886292db8f9e, 0x25a0], [0x231e7a555a7abb2cde5f7cd977c70, 0x4d7ddf867e5fbffa2bbc3b23d5a800, 0x2f64]),
            r1: fp2_from_limbs([0x5b723b7c4ce04915be6f0b93144505, 0x43a3c969ef0c20881cf9153a4837d4, 0xb7c], [0x62bc47478ac954055354e5f18dde82, 0x102f60722d40ae7d614cbb35b65413, 0x290f]),
            r2: fp2_from_limbs([0x1d071feae52d2f1744d92da9a6bbc4, 0x39b0c50249934109454ac958565310, 0x25f3], [0x640c1529ae6aee9a540e7f8f24764, 0x124fb984c0960248acbfcd8ae0c976, 0x2041]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x60b582d6b78e7fb0c447dfeda36bc9, 0xaf8e9955154e13d8906fc34be95ede, 0x1ba7], [0x5bc1a7fdd83c18b027e16b5f031bd5, 0xb86e25bae2296b6dc03d72dad856db, 0x1fcd]),
            r1: fp2_from_limbs([0xde0b31b9e8649bc612ea3276259cca, 0x5e3178933ae66a5f8be2dfae2daf65, 0x2acf], [0x5429bb11b496ee9c1a98257ff47c50, 0xa1c80f4637435f27d2b3e9c8eea7a6, 0x2b2b]),
            r2: fp2_from_limbs([0xe5b64adc43fbef29446811c965070e, 0x7621ea73985a241205c3fdb883a85, 0xe37], [0x71e26b4ec3d0cb9408c7f7426c03e1, 0x6c9ab04a55e9024341302272532f51, 0xde9]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xc4d7672b41810091865ea1f651a5f9, 0xabab9e79fd354df33f63e7529caf15, 0x2920], [0xb81ac78d715dae2b281fbcf9a19429, 0xc208159d2a632e2e6f674dea3d3ff, 0x2f61]),
            r1: fp2_from_limbs([0x57398bf16188832f8b534937805bc7, 0xced852152ad898ddddf81265925369, 0x8e0], [0x6911d0eb6f5733671bbacdfbb21f67, 0xcaba155117f7a9a0ec016b2a116d7, 0x1168]),
            r2: fp2_from_limbs([0x4ea9cf48c882804180b446cfbebdf2, 0xb51781e8e2e0befcd8f9e03a62c957, 0xa1d], [0xb7f7774ad8a9d60993d814db621f23, 0x49038d43ff8e7efaac6d342cdbd90c, 0x21af]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xe22b8219f2965f2b28252010043d74, 0x1cd051027c91457c89f620e34347f5, 0x1fa3], [0xf686f2b30d612f934bfe0003c7dc1b, 0x1a619cd7a87fe1d7dd3bd1e0e5a8f, 0x2250]),
            r1: fp2_from_limbs([0x1aadda180ce32a5ef610924c675bba, 0x15056b90a00487efa91718606f61c6, 0x692], [0x7d0860b8374be8c3b08dc0126da4af, 0xb38b635b3ccd7f77d68eff77b66288, 0x232]),
            r2: fp2_from_limbs([0xc2b02c8571304ec5af46a343cdb5, 0x9f8ff6d390e5f8ab05f57203eb5eb6, 0xb06], [0x46cbb9ea0f4aa3f9e0e5a73cd1de07, 0x541d4315c1dfd127db643d8e821e62, 0x3b2]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x79b22d28910d4ccffa7b15e07a31b3, 0xdb1b849eb380d454cc8bc117f1384a, 0x23ac], [0xd17d1c0b106f71b889044d9c7e5c57, 0x51462ec1037806995b2488023e2f83, 0x9ee]),
            r1: fp2_from_limbs([0xbb72e023c9b69790813b5d99db07ee, 0xc29e417fe6c5dddafe60c13b6927e2, 0x156], [0xdba1e67a68c495fe86d52137c19d97, 0x1e69a89f80ab64042856bec93eb656, 0x214a]),
            r2: fp2_from_limbs([0xb5cf9976fc5527e4a7a4d55351876a, 0x32276317e273e4bfe6d60e3375a35b, 0x141f], [0xf472d4bdbdc42adab3d1da4fd76108, 0xa7face77cfac73ae81c70c11720fc9, 0x15bf]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x715d01747d7303020384dc389cb600, 0xba3b38b04fdbcf3b8d230f534c6653, 0x2100], [0x96151d32365c06064f19d38abbf34, 0x1f985172495c1d8ed14366663776fa, 0x2eba]),
            r1: fp2_from_limbs([0x486802ece760d5847df4b913768e21, 0xb518a143a08046251124335e704fd5, 0x1804], [0x10e784bce10a3269af33eec89e30b6, 0xae52df6ce37d547486751e70a6d4b1, 0x5a7]),
            r2: fp2_from_limbs([0xed07873b5e41cc0c8c382458e002ae, 0xaa708cb3caf28ea9441b7c2067e5e8, 0x197c], [0x53bbca6d343e035200bdae1f932a64, 0xf7457a687b16d0a298b413ac8de6a9, 0x2602]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x15f735bb94c4687ebf1e591bcf8bde, 0x8e2cd1adc6944149173f9cdb2143b, 0x25df], [0x239cb0838d76b36268f08b05e783a1, 0xee79e2ea3d8d05d0afb8c4e0876160, 0x602]),
            r1: fp2_from_limbs([0x3f6f06063104636184e31e0cc3bcfa, 0x2c170992416ac5f4c85edcf4111b91, 0x18ee], [0x40c76125a798fbff9c2781423d0d4c, 0x53d5853753ec53501c02ffe3e625df, 0x1ab0]),
            r2: fp2_from_limbs([0x149a2736e30866afc90ac1ffbe4795, 0xbde4b4227918f27fb3cadfbaeeb168, 0xf23], [0x8e63d79bbafc2b88bd4bcaf93589ed, 0x802dc38042421a69e4700c4ba9ccca, 0x1b3c]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x880b77e23a13fc78116f693f97ff45, 0x2fe83bf9005eb71dd4dc45bef36477, 0x2954], [0x453ff1b8ed8c600076ee7583739689, 0x852c6c5219c75562523700a038a4e, 0x2a2a]),
            r1: fp2_from_limbs([0xcae2b82ae726044b6b088e16eac628, 0xee191a30d1a1cc21948d6bf294f38b, 0x2e7a], [0xf64e0d25a2e1aee0634732b308f10b, 0x6fed6ba29499b1f507f181eed1afb6, 0x14f1]),
            r2: fp2_from_limbs([0xc2444cf8aa8d75034a84db102b1abb, 0x38217d5eed2f5d4499bdb5973ddb8c, 0xdd1], [0x65ef5fd66524ec5ffb484b4229fb0c, 0xfb30e9b48aa3a98c48ceb905012d25, 0x21e0]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x74f0809af7eef03803267a8a5aa0ee, 0xefbeff6b751690fda2ca6eec36b468, 0x1241], [0x26b5bbe0b732845b38d9b7fa109c57, 0xd2d82a561948090181fcdf5b74d597, 0xa92]),
            r1: fp2_from_limbs([0x2188fabe818b2c8e889624e35955bd, 0x3306e1d884cab4f6dc8cb6214895c0, 0x1cc4], [0x542c30d0edf074dc717b64ce2923ea, 0xa87e86c625204f1b7bf73ab469425a, 0x16b4]),
            r2: fp2_from_limbs([0xc06320252291f9bd67ce50c537d398, 0xf669cdc4208a0d98c9970601b3083a, 0x124b], [0xa9880d6513292db8bdabe76cee2c04, 0xf3185296f77e0a7bb7ee4257e79d0d, 0x1d95]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0x84e3f7870793944799aeccdc26e64a, 0x551eaa75a8fabf5f38687aa4fde010, 0x25e8], [0x31743387f996808816ea624fc211c3, 0xc6e7bae857d2a932fce55cc5e0cc8c, 0xa15]),
            r1: fp2_from_limbs([0x87664eb6a75719b5733a8fe4b9b18, 0xbbda224f632d3c1a8d720117363a42, 0x21f], [0xcdd96275ad66ec9e19f0974921f1ab, 0xf7e06bbbecb439c4cb9a4aa91a61d8, 0x1918]),
            r2: fp2_from_limbs([0x893087330590177f89a859fca9355, 0x61d3e316682d11a33cf7db5e6cd2d9, 0x100c], [0xc09fb8b290c510b595ce9dcfe15840, 0x19c9754c7ef072d358fbbb6552271, 0x21a3]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xf97160505f2d67c8d1b9b968741696, 0xc31863f2ea540d824cf8b64db87006, 0x2fcc], [0xd93ae9e8d77d0474fa627154d142cf, 0xbf82c98120acb2fc5afbad1220934b, 0x2e1d]),
            r1: fp2_from_limbs([0x92a35b892507297231d7954a91d050, 0xb9a9aea5012ce105080af93d27b952, 0x11a0], [0x526832756533f40a31ba65259118eb, 0x7f08aa51492013ed99f4f567349d7e, 0x1b51]),
            r2: fp2_from_limbs([0xcdfe51e81f66d7355d9b85b5340f88, 0xff7ae934dfff0b8a7706b7e8153bc4, 0xb83], [0xb0d9617c2bfe7107ccc34f4e7282df, 0xd1a903eba6947b2ae81a82158cfb46, 0x2edf]),
        },
        LineEvaluation {
            r0: fp2_from_limbs([0xb26813929e364ee67a507c3d5da8d7, 0xcc4d92b845655b2921ee690b27eab6, 0x159e], [0xeb9d3692a27ad6d780a12e55252e7c, 0x59ba6c44d590d42ba90e28f275f10, 0x249d]),
            r1: fp2_from_limbs([0x90078225833fffc1136426b5904083, 0x52785dfd341849e764ab50462e3ea, 0x2321], [0x722e7c54d7559ad95da44bce2b79f6, 0x45aa7ed9ffac4e8b8e115b1b630dfb, 0x263]),
            r2: fp2_from_limbs([0x16828624c811908099c60d4078344e, 0x8d1f66bb8773b3da011d7bee547153, 0x23ae], [0x69a7a686ac77d0663f39fd0b85e4fa, 0x6c39261a0a834241bbab79402b799a, 0x1fe5]),
        },
    ]
}
