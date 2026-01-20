use noir_bn254_pairing::fp::fp_from_limbs_checked;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp6::Fp6;
use noir_bn254_pairing::fp12::{Fp12, Mul034Witness};
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_groth16_verify::sp1::{sp1_public_inputs, verify_sp1_pairing_check_fixed_lines_randomized};
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
    rho: Field,
    alpha: Field,
    mul_witnesses: [[[u128; 3]; 12]; 67],
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
    let mul_witnesses = mul_witnesses_from_limbs(mul_witnesses);
    let verified = verify_sp1_pairing_check_fixed_lines_randomized(
        vkey,
        public_values,
        proof,
        c_fp12,
        w_fp12,
        rho,
        alpha,
        mul_witnesses,
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

fn mul_witness_from_limbs(limbs: [[u128; 3]; 12]) -> Mul034Witness {
    let x0 = fp2_from_limbs(limbs[0], limbs[1]);
    let x3 = fp2_from_limbs(limbs[2], limbs[3]);
    let x4 = fp2_from_limbs(limbs[4], limbs[5]);
    let x04 = fp2_from_limbs(limbs[6], limbs[7]);
    let x03 = fp2_from_limbs(limbs[8], limbs[9]);
    let x34 = fp2_from_limbs(limbs[10], limbs[11]);
    Mul034Witness { x0, x3, x4, x04, x03, x34 }
}

fn mul_witnesses_from_limbs(limbs: [[[u128; 3]; 12]; 67]) -> [Mul034Witness; 67] {
    let mut out = [mul_witness_from_limbs(limbs[0]); 67];
    for i in 0..67 {
        out[i] = mul_witness_from_limbs(limbs[i]);
    }
    out
}
