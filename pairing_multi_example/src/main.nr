use noir_bn254_pairing::fp::Fp;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g1::neg_g1_affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::pairing::pairing_multi;
use noir_bn254_pairing::BigNum;

fn fp_from_limbs(l0: u128, l1: u128, l2: u128) -> Fp {
    Fp::from_limbs([l0, l1, l2])
}

fn fp2_from_limbs(a0: [u128; 3], a1: [u128; 3]) -> Fp2 {
    Fp2 { c0: fp_from_limbs(a0[0], a0[1], a0[2]), c1: fp_from_limbs(a1[0], a1[1], a1[2]) }
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

pub fn main(negate_p1: bool) -> pub Fp12 {
    let p0 = g1_vector_single_generators();
    let p1 = g1_vector_single_2g1_g2();
    let p1 = if negate_p1 { neg_g1_affine(p1) } else { p1 };
    let q0 = g2_vector_single_generators();
    let q1 = g2_vector_single_3g2();
    pairing_multi([p0, p1], [q0, q1])
}
    