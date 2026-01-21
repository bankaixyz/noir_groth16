use crate::types::{Proof, VerifyingKey};
use noir_bn254_pairing::fp::{Fp, fp_one};
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::{
    G1Affine,
    G1Jac,
    add_g1_jac,
    add_g1_jac_mixed,
    double_g1_jac,
    g1_affine_infinity,
    g1_jacobian_infinity,
    is_on_curve_g1_affine,
    jacobian_to_affine_g1,
};
use noir_bn254_pairing::g2::{
    G2LineWitness,
    LineSchedule,
    LineScheduleRaw,
    is_in_correct_subgroup_g2,
    is_on_curve_g2_affine,
};
use noir_bn254_pairing::{pairing_check_optimized, pairing_multi};

/// Convert G1 affine to Jacobian without inversion.
fn g1_affine_to_jac(p: G1Affine) -> G1Jac {
    if p.is_infinity() {
        g1_jacobian_infinity()
    } else {
        G1Jac { x: p.x, y: p.y, z: fp_one() }
    }
}

/// Branchless select between two affine points based on a bit.
fn select_g1_affine(cond: u1, a: G1Affine, b: G1Affine) -> G1Affine {
    if cond == 1 { a } else { b }
}

/// Select a point from a 64-entry table using a 6-bit index.
///
/// Implemented as a binary selection tree to keep constraints small.
fn select_g1_affine_by_u6(table: [G1Affine; 64], idx_bits: [u1; 6]) -> G1Affine {
    let mut lvl0 = [g1_affine_infinity(); 32];
    for i in 0..32 {
        lvl0[i] = select_g1_affine(idx_bits[0], table[2 * i + 1], table[2 * i]);
    }

    let mut lvl1 = [g1_affine_infinity(); 16];
    for i in 0..16 {
        lvl1[i] = select_g1_affine(idx_bits[1], lvl0[2 * i + 1], lvl0[2 * i]);
    }

    let mut lvl2 = [g1_affine_infinity(); 8];
    for i in 0..8 {
        lvl2[i] = select_g1_affine(idx_bits[2], lvl1[2 * i + 1], lvl1[2 * i]);
    }

    let mut lvl3 = [g1_affine_infinity(); 4];
    for i in 0..4 {
        lvl3[i] = select_g1_affine(idx_bits[3], lvl2[2 * i + 1], lvl2[2 * i]);
    }

    let mut lvl4 = [g1_affine_infinity(); 2];
    for i in 0..2 {
        lvl4[i] = select_g1_affine(idx_bits[4], lvl3[2 * i + 1], lvl3[2 * i]);
    }

    select_g1_affine(idx_bits[5], lvl4[1], lvl4[0])
}

/// Two-scalar MSM using 3-bit windows (Straus/Shamir's trick).
///
/// Computes a*P + b*Q with a shared precomputed table indexed by
/// (a_digit + 8 * b_digit) for each 3-bit window.
fn msm2_window3_g1_jac(
    table: [G1Affine; 64],
    a: Field,
    b: Field,
) -> G1Jac {
    let a_bits: [u1; 254] = a.to_le_bits();
    let b_bits: [u1; 254] = b.to_le_bits();

    let mut acc = g1_jacobian_infinity();

    // Special top window (w = 84): bits 252, 253, and an implicit 0 bit at position 254.
    for _ in 0..3 {
        acc = double_g1_jac(acc);
    }
    let a0 = a_bits[252];
    let a1 = a_bits[253];
    let a2: u1 = 0;
    let b0 = b_bits[252];
    let b1 = b_bits[253];
    let b2: u1 = 0;
    let add_aff = select_g1_affine_by_u6(table, [a0, a1, a2, b0, b1, b2]);
    acc = add_g1_jac_mixed(acc, add_aff);

    for w in 0..84 {
        let ww = 83 - w;
        for _ in 0..3 {
            acc = double_g1_jac(acc);
        }

        let base = 3 * ww;
        let a0 = a_bits[base];
        let a1 = a_bits[base + 1];
        let a2 = a_bits[base + 2];
        let b0 = b_bits[base];
        let b1 = b_bits[base + 1];
        let b2 = b_bits[base + 2];

        let add_aff = select_g1_affine_by_u6(table, [a0, a1, a2, b0, b1, b2]);
        acc = add_g1_jac_mixed(acc, add_aff);
    }

    acc
}

/// Equality check for Fp2 elements (component-wise).
fn fp2_eq(a: Fp2, b: Fp2) -> bool {
    let c0 = a.c0 == b.c0;
    let c1 = a.c1 == b.c1;
    c0 & c1
}

/// Equality check for Fp12 elements (component-wise).
fn fp12_eq(a: Fp12, b: Fp12) -> bool {
    let c0 = fp2_eq(a.c0.b0, b.c0.b0);
    let c1 = fp2_eq(a.c0.b1, b.c0.b1);
    let c2 = fp2_eq(a.c0.b2, b.c0.b2);
    let c3 = fp2_eq(a.c1.b0, b.c1.b0);
    let c4 = fp2_eq(a.c1.b1, b.c1.b1);
    let c5 = fp2_eq(a.c1.b2, b.c1.b2);
    c0 & c1 & c2 & c3 & c4 & c5
}

/// Double-and-add scalar multiplication in G1.
fn scalar_mul_g1(p: G1Affine, scalar: Field) -> G1Affine {
    let mut acc = g1_jacobian_infinity();
    if !p.is_infinity() {
        let bits: [u1; 254] = scalar.to_le_bits();
        let mut base = g1_affine_to_jac(p);

        for i in 0..254 {
            let bit: u8 = bits[i] as u8;
            if bit == 1 {
                acc = add_g1_jac(acc, base);
            }
            base = double_g1_jac(base);
        }
    }

    jacobian_to_affine_g1(acc)
}

/// Groth16 verification:
///   L = IC_0 + sum_{i=1}^N IC_i * input_i
///   Check e(A, B) * e(C, -delta) * e(L, -gamma) = e(alpha, beta)
pub fn verify<let N: u32, let L: u32>(
    vk: VerifyingKey<L>,
    proof: Proof,
    public_inputs: [Field; N],
) -> bool {
    assert(L == N + 1);
    assert(is_on_curve_g1_affine(proof.a));
    assert(is_on_curve_g1_affine(proof.c));
    assert(is_on_curve_g2_affine(proof.b));
    assert(!proof.a.is_infinity());
    assert(!proof.b.is_infinity());
    assert(!proof.c.is_infinity());
    assert(is_in_correct_subgroup_g2(proof.b));

    let mut acc = g1_affine_to_jac(vk.ic[0]);
    for i in 0..N {
        let term = scalar_mul_g1(vk.ic[i + 1], public_inputs[i]);
        acc = add_g1_jac(acc, g1_affine_to_jac(term));
    }
    let l = jacobian_to_affine_g1(acc);

    let result = pairing_multi(
        [proof.a, proof.c, l],
        [proof.b, vk.delta_neg, vk.gamma_neg],
    );

    fp12_eq(result, vk.alpha_beta)
}

/// Optimized Groth16 verification for two public inputs.
///
/// Uses a joint-window MSM table, a witnessed line schedule, and a pairing
/// preimage check. The caller must supply trusted constants and line data.
pub fn verify_optimized(
    vk: VerifyingKey<3>,
    proof: Proof,
    public_inputs: [Field; 2],
    msm2_w3_table: [G1Affine; 64],
    t_preimage: Fp12,
    delta_lines: LineScheduleRaw,
    gamma_lines: LineScheduleRaw,
    lines: LineSchedule,
    b_lines_raw: LineScheduleRaw,
    b_line_witness: G2LineWitness,
    rho: Fp,
    c: Fp12,
    w: Fp12,
) -> bool {
    assert(is_on_curve_g1_affine(proof.a));
    assert(is_on_curve_g1_affine(proof.c));
    assert(is_on_curve_g2_affine(proof.b));
    assert(!proof.a.is_infinity());
    assert(!proof.b.is_infinity());
    assert(!proof.c.is_infinity());
    // ToDo: deactivate for now
    // assert(is_in_correct_subgroup_g2(proof.b));

    let msm = msm2_window3_g1_jac(msm2_w3_table, public_inputs[0], public_inputs[1]);
    let acc = add_g1_jac_mixed(msm, vk.ic[0]);
    let l = jacobian_to_affine_g1(acc);

    pairing_check_optimized(
        [proof.a, proof.c, l],
        [proof.b, vk.delta_neg, vk.gamma_neg],
        t_preimage,
        delta_lines,
        gamma_lines,
        lines,
        b_lines_raw,
        b_line_witness,
        rho,
        c,
        w,
    )
}
