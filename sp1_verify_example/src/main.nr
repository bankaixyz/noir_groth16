use noir_bn254_pairing::fp::fp_from_limbs_checked;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp6::Fp6;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g2::{G2LineWitness, LineSchedule, LineScheduleRaw};
use noir_groth16_verify::sp1::verify_optimized;

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
    lines: LineSchedule,
    b_lines_raw: LineScheduleRaw,
    b_line_witness: G2LineWitness,
) -> pub ([u8; 32], Field) {
    let c_fp12 = fp12_from_coeffs(c);
    let w_fp12 = fp12_from_coeffs(w);
    let verified = verify_optimized(
        vkey,
        public_values,
        a_x,
        a_y,
        b_x_c0,
        b_x_c1,
        b_y_c0,
        b_y_c1,
        c_x,
        c_y,
        c_fp12,
        w_fp12,
        lines,
        b_lines_raw,
        b_line_witness,
    );
    assert(verified);

    // Todo: add rho_seed to the public inputs
    (public_values, vkey)
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
