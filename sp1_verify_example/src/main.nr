use noir_bn254_pairing::fp::fp_from_limbs_checked;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp6::Fp6;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::pairing::PairingMulTrace;
use noir_groth16_verify::sp1::{
    sp1_public_inputs,
    verify_sp1_pairing_check,
    verify_sp1_pairing_check_randomized,
};
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
    c: [[u128; 3]; 12],
    w: [[u128; 3]; 12],
) -> pub [Field; 2] {
    let proof = Proof {
        a: G1Affine { x: fp_from_limbs_checked(a_x), y: fp_from_limbs_checked(a_y) },
        b: G2Affine {
            x: Fp2 { c0: fp_from_limbs_checked(b_x_c0), c1: fp_from_limbs_checked(b_x_c1) },
            y: Fp2 { c0: fp_from_limbs_checked(b_y_c0), c1: fp_from_limbs_checked(b_y_c1) },
        },
        c: G1Affine { x: fp_from_limbs_checked(c_x), y: fp_from_limbs_checked(c_y) },
    };

    let c_fp12 = fp12_from_coeffs(c);
    let w_fp12 = fp12_from_coeffs(w);
    let verified = verify_sp1_pairing_check(vkey, public_values, proof, c_fp12, w_fp12);
    assert(verified);
    sp1_public_inputs(vkey, public_values)
}

pub fn main_randomized(
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
    c: [[u128; 3]; 12],
    w: [[u128; 3]; 12],
    seed: Field,
    trace: PairingMulTrace<3>,
) -> pub [Field; 2] {
    let proof = Proof {
        a: G1Affine { x: fp_from_limbs_checked(a_x), y: fp_from_limbs_checked(a_y) },
        b: G2Affine {
            x: Fp2 { c0: fp_from_limbs_checked(b_x_c0), c1: fp_from_limbs_checked(b_x_c1) },
            y: Fp2 { c0: fp_from_limbs_checked(b_y_c0), c1: fp_from_limbs_checked(b_y_c1) },
        },
        c: G1Affine { x: fp_from_limbs_checked(c_x), y: fp_from_limbs_checked(c_y) },
    };

    let c_fp12 = fp12_from_coeffs(c);
    let w_fp12 = fp12_from_coeffs(w);
    let verified = verify_sp1_pairing_check_randomized(
        vkey,
        public_values,
        proof,
        c_fp12,
        w_fp12,
        seed,
        trace,
    );
    assert(verified);
    sp1_public_inputs(vkey, public_values)
}

fn fp2_from_limbs(c0: [u128; 3], c1: [u128; 3]) -> Fp2 {
    Fp2 { c0: fp_from_limbs_checked(c0), c1: fp_from_limbs_checked(c1) }
}

fn fp12_from_coeffs(coeffs: [[u128; 3]; 12]) -> Fp12 {
    let c0_b0 = fp2_from_limbs(coeffs[0], coeffs[1]);
    let c0_b1 = fp2_from_limbs(coeffs[2], coeffs[3]);
    let c0_b2 = fp2_from_limbs(coeffs[4], coeffs[5]);
    let c1_b0 = fp2_from_limbs(coeffs[6], coeffs[7]);
    let c1_b1 = fp2_from_limbs(coeffs[8], coeffs[9]);
    let c1_b2 = fp2_from_limbs(coeffs[10], coeffs[11]);

    Fp12 {
        c0: Fp6 { b0: c0_b0, b1: c0_b1, b2: c0_b2 },
        c1: Fp6 { b0: c1_b0, b1: c1_b1, b2: c1_b2 },
    }
}
