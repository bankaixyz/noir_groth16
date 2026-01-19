use noir_bn254_pairing::fp::fp_from_limbs_checked;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_groth16_verify::sp1::{sp1_public_inputs, verify_sp1};
use noir_groth16_verify::types::Proof;

pub fn main(
    a_x: [u128; 3],
    a_y: [u128; 3],
    b_x_c0: [u128; 3],
    b_x_c1: [u128; 3],
    b_y_c0: [u128; 3],
    b_y_c1: [u128; 3],
    c_x: [u128; 3],
    c_y: [u128; 3],
    vkey: Field,
    public_values: [u8; 32],
) -> pub [Field; 2] {
    let proof = Proof {
        a: G1Affine { x: fp_from_limbs_checked(a_x), y: fp_from_limbs_checked(a_y) },
        b: G2Affine {
            x: Fp2 { c0: fp_from_limbs_checked(b_x_c0), c1: fp_from_limbs_checked(b_x_c1) },
            y: Fp2 { c0: fp_from_limbs_checked(b_y_c0), c1: fp_from_limbs_checked(b_y_c1) },
        },
        c: G1Affine { x: fp_from_limbs_checked(c_x), y: fp_from_limbs_checked(c_y) },
    };

    let verified = verify_sp1(vkey, public_values, proof);
    assert(verified);
    sp1_public_inputs(vkey, public_values)
}
