use noir_bn254_pairing::fp::Fp;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp6::Fp6;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::pairing::pairing_multi_with_miller_inverse;

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

fn g1_vector_single_generators() -> G1Affine {
    G1Affine { x: fp_from_limbs(0x1, 0x0, 0x0), y: fp_from_limbs(0x2, 0x0, 0x0) }
}

fn g2_vector_single_generators() -> G2Affine {
    G2Affine {
        x: fp2_from_limbs(
            [0x4322d4f75edadd46debd5cd992f6ed, 0xdeef121f1e76426a00665e5c447967, 0x1800],
            [0xaa493335a9e71297e485b7aef312c2, 0x9393920d483a7260bfb731fb5d25f1, 0x198e],
        ),
        y: fp2_from_limbs(
            [0xd1e7690c43d37b4ce6cc0166fa7daa, 0x5ea5db8c6deb4aab71808dcb408fe3, 0x12c8],
            [0x4b313370b38ef355acdadcd122975b, 0x89d0585ff075ec9e99ad690c3395bc, 0x906],
        ),
    }
}

fn g1_vector_single_2g1_g2() -> G1Affine {
    G1Affine {
        x: fp_from_limbs(0x7816a916871ca8d3c208c16d87cfd3, 0x44e72e131a029b85045b68181585d9, 0x306),
        y: fp_from_limbs(0xa6a449e3538fc7ff3ebf7a5a18a2c4, 0x738c0e0a7c92e7845f96b2ae9c0a68, 0x15ed),
    }
}

fn g2_vector_single_3g2() -> G2Affine {
    G2Affine {
        x: fp2_from_limbs(
            [0x7e478cb09a5e0012defa0694fbc7f5, 0x4e784db10e9051e52826e192715e8d, 0x606],
            [0x4156b6878a0a7c9824f32ffb66e85, 0x772f57bb9742735191cd5dcfe4ebbc, 0x1014],
        ),
        y: fp2_from_limbs(
            [0xb920d74521e79765036d57666c5597, 0x1d5681b5b9e0074b0f9c8d2c68a069, 0x58e],
            [0x9453ac49b55441452aeaca147711b2, 0x2335f3354bb7922ffcc2f38d3323dd, 0x21e],
        ),
    }
}

fn miller_inverse_multi_2_pairs() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0xb675e55a2308616fc6d19b38643c9d, 0xf1eb151d788fba48dc733436b39fb2, 0x1dc6],
        [0x74f14d0df14f6c9bf5629af7ae82d9, 0x562938bde4decacfb50473c66a85ab, 0x395],
    );
    let c0_b1 = fp2_from_limbs(
        [0xb6ce0f03f932e806ccbf1509035a5c, 0xb4f0681c819b8856e861ae1cbe85ce, 0xc58],
        [0x33f5858f7cc75e5102c308ea60be1f, 0xfac3ce2a338b70754ad221beb77ea5, 0xf7c],
    );
    let c0_b2 = fp2_from_limbs(
        [0x1655e0582b65a072e2365535af4d7e, 0x7edf0a9840e88654079c70b4eed525, 0x2f01],
        [0xc88eafc1a558d9f771802d9aec4f10, 0xf45a21cfc61aa938691e76adbc9a33, 0xa4d],
    );
    let c1_b0 = fp2_from_limbs(
        [0xc222030380a17ece7fdd6f736f90a8, 0xad4750bc1ea97db81e60a97eb436c9, 0x13a1],
        [0x886b36200f6adc0195233e0e893ec4, 0x1b7c301aff232f23f3bc03e9146449, 0x2115],
    );
    let c1_b1 = fp2_from_limbs(
        [0xba9ade83e6a85e54f4f59dfc1af52b, 0x564b560f310b330cba9018606e5d84, 0x8f0],
        [0xe785aacbe0eede290063c4361c94a8, 0x4e7a4168018b672a21f57bb0e1ef78, 0x13f2],
    );
    let c1_b2 = fp2_from_limbs(
        [0x22a3e2c47334b42cf2c665a22a11f6, 0x3a1749add4f941d0f03ca76c67e32d, 0x2219],
        [0x69281b4a4cf2fe77fc8e870936164b, 0x5bb75af54a6a0a3491733c3c4bfe7b, 0xf1e],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}

pub fn main() -> pub Fp12 {
    let p0 = g1_vector_single_generators();
    let p1 = g1_vector_single_2g1_g2();
    let q0 = g2_vector_single_generators();
    let q1 = g2_vector_single_3g2();
    let f_inv = miller_inverse_multi_2_pairs();
    pairing_multi_with_miller_inverse([p0, p1], [q0, q1], f_inv)
}
