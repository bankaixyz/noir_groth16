use crate::fp12::{Fp12, fp12_one, mul_034_by_034};
use crate::fp::{Fp, fp_one, fp_two, fp_three, fp_zero};
use crate::fp2::{Fp2, b_twist};
use crate::fp6::Fp6;
use crate::g1::{G1Affine, g1_affine_infinity};
use crate::g2::{
    G2Affine,
    G2Proj,
    G2LineWitness,
    G2AddStepWitness,
    G2DoubleStepWitness,
    G2LineComputeWitness,
    LineEvaluation,
    LineEvalAtP,
    LineSchedule,
    LineScheduleRaw,
    frobenius_g2,
    frobenius_square_g2,
    g2_affine_infinity,
    neg_g2_affine,
    projective_from_affine_g2,
};
/// Signed NAF digits of BN254 parameter x for the optimal Ate loop.
fn loop_counter() -> [i8; 66] {
    [
        0, 0, 0, 1, 0, 1, 0, -1, 0, 0, -1, 0, 0, 0, 1, 0,
        0, -1, 0, -1, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, -1, 0,
        0, 1, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, -1,
        0, 1, 0, -1, 0, 0, 0, -1, 0, -1, 0, 0, 0, 1, 0, -1,
        0, 1,
    ]
}

/// Evaluate line l(X, Y) = r0*Y + r1*X + r2 at affine point P.
fn line_eval_at_point(line: LineEvaluation, p: G1Affine) -> LineEvaluation {
    LineEvaluation {
        r0: line.r0.mul_by_element(p.y),
        r1: line.r1.mul_by_element(p.x),
        r2: line.r2,
    }
}

// #region agent log helpers
// Use fixed-string NDJSON logs to avoid formatting support limitations.
// #endregion agent log helpers

/// Filter out infinity pairs to avoid extra Miller loop work.
fn filter_pairs<let N: u32>(
    p_list: [G1Affine; N],
    q_list: [G2Affine; N],
) -> ([G1Affine; N], [G2Affine; N], u32) {
    let mut p_filtered = [g1_affine_infinity(); N];
    let mut q_filtered = [g2_affine_infinity(); N];
    let mut count: u32 = 0;

    for i in 0..N {
        let p = p_list[i];
        let q = q_list[i];
        if !(p.is_infinity() | q.is_infinity()) {
            p_filtered[count] = p;
            q_filtered[count] = q;
            count = count + 1;
        }
    }

    (p_filtered, q_filtered, count)
}

fn fp2_is_zero(a: Fp2) -> bool {
    let zero = fp_zero();
    (a.c0 == zero) & (a.c1 == zero)
}

fn fp6_is_zero(a: Fp6) -> bool {
    fp2_is_zero(a.b0) & fp2_is_zero(a.b1) & fp2_is_zero(a.b2)
}

fn fp2_eq(a: Fp2, b: Fp2) -> bool {
    let c0_eq = a.c0 == b.c0;
    let c1_eq = a.c1 == b.c1;
    c0_eq & c1_eq
}

fn g2_proj_eq(a: G2Proj, b: G2Proj) -> bool {
    fp2_eq(a.x, b.x) & fp2_eq(a.y, b.y) & fp2_eq(a.z, b.z)
}

fn eval_line_at_p(line: LineEvaluation, p: G1Affine) -> LineEvalAtP {
    LineEvalAtP {
        r0: line.r0.mul_by_element(p.y),
        r1: line.r1.mul_by_element(p.x),
        r2: line.r2,
    }
}

fn line_eval_matches_p(line: LineEvaluation, eval: LineEvalAtP, p: G1Affine) -> bool {
    let expected = eval_line_at_p(line, p);
    fp2_eq(expected.r0, eval.r0) & fp2_eq(expected.r1, eval.r1) & fp2_eq(expected.r2, eval.r2)
}

fn fp2_mul_compressed_check(a: Fp2, b: Fp2, c: Fp2, rho: Fp) -> bool {
    let t0 = a.c0 * b.c0;
    let t1 = a.c1 * b.c1;
    let t2 = (a.c0 + a.c1) * (b.c0 + b.c1) - t0 - t1;
    let left = t0 - t1 + t2 * rho;
    let right = c.c0 + c.c1 * rho;
    left == right
}

fn check_double_step_witness(
    p: G1Affine,
    state: G2Proj,
    state_next: G2Proj,
    line: LineEvaluation,
    line_eval: LineEvalAtP,
    wit: G2DoubleStepWitness,
    rho: Fp,
) -> bool {
    let mut ok = line_eval_matches_p(line, line_eval, p);

    let inv_two = fp_one() / fp_two();
    let inv_three = fp_one() / fp_three();

    let a = wit.a;
    let b = wit.b;
    let c = wit.c;
    let ee = wit.ee;

    let h = line.r0.neg();
    let j = line.r1.mul_by_element(inv_three);
    let e = line.r2.add(b);
    let d = c.mul_by_element(fp_three());
    let f = e.mul_by_element(fp_three());
    let k = ee.mul_by_element(fp_three());
    let g = b.add(f).mul_by_element(inv_two);

    ok = ok & fp2_mul_compressed_check(state.x, state.y, a.double(), rho);
    ok = ok & fp2_mul_compressed_check(state.y, state.y, b, rho);
    ok = ok & fp2_mul_compressed_check(state.z, state.z, c, rho);
    ok = ok & fp2_mul_compressed_check(d, b_twist(), e, rho);
    ok = ok & fp2_mul_compressed_check(state.x, state.x, j, rho);
    ok = ok & fp2_mul_compressed_check(e, e, ee, rho);

    let yz = state.y.add(state.z);
    let rhs_h = b.add(c).sub(line.r0);
    ok = ok & fp2_mul_compressed_check(yz, yz, rhs_h, rho);

    let b_minus_f = b.sub(f);
    ok = ok & fp2_mul_compressed_check(b_minus_f, a, state_next.x, rho);

    let y_rhs = state_next.y.add(k);
    ok = ok & fp2_mul_compressed_check(g, g, y_rhs, rho);

    ok = ok & fp2_mul_compressed_check(b, h, state_next.z, rho);

    ok
}

fn check_add_step_witness(
    p: G1Affine,
    state: G2Proj,
    state_next: G2Proj,
    a_aff: G2Affine,
    line: LineEvaluation,
    line_eval: LineEvalAtP,
    wit: G2AddStepWitness,
    rho: Fp,
) -> bool {
    let mut ok = line_eval_matches_p(line, line_eval, p);

    let l = line.r0;
    let o = line.r1.neg();
    let j = line.r2;

    let x2z1 = state.x.sub(l);
    let y2z1 = state.y.sub(o);
    ok = ok & fp2_mul_compressed_check(a_aff.x, state.z, x2z1, rho);
    ok = ok & fp2_mul_compressed_check(a_aff.y, state.z, y2z1, rho);

    ok = ok & fp2_mul_compressed_check(l, a_aff.y, wit.t2, rho);
    ok = ok & fp2_mul_compressed_check(a_aff.x, o, j.add(wit.t2), rho);

    ok = ok & fp2_mul_compressed_check(o, o, wit.c, rho);
    ok = ok & fp2_mul_compressed_check(l, l, wit.d, rho);
    ok = ok & fp2_mul_compressed_check(l, wit.d, wit.e, rho);
    ok = ok & fp2_mul_compressed_check(state.z, wit.c, wit.f, rho);
    ok = ok & fp2_mul_compressed_check(state.x, wit.d, wit.g, rho);
    ok = ok & fp2_mul_compressed_check(state.y, wit.e, wit.t1, rho);

    let h = wit.e.add(wit.f).sub(wit.g.double());
    ok = ok & fp2_mul_compressed_check(l, h, state_next.x, rho);

    let y_rhs = state_next.y.add(wit.t1);
    ok = ok & fp2_mul_compressed_check(wit.g.sub(h), o, y_rhs, rho);

    ok = ok & fp2_mul_compressed_check(wit.e, state.z, state_next.z, rho);

    ok
}

fn check_line_compute_witness(
    p: G1Affine,
    state: G2Proj,
    a_aff: G2Affine,
    line: LineEvaluation,
    line_eval: LineEvalAtP,
    wit: G2LineComputeWitness,
    rho: Fp,
) -> bool {
    let mut ok = line_eval_matches_p(line, line_eval, p);

    let l = line.r0;
    let o = line.r1.neg();
    let j = line.r2;

    let x2z1 = state.x.sub(l);
    let y2z1 = state.y.sub(o);
    ok = ok & fp2_mul_compressed_check(a_aff.x, state.z, x2z1, rho);
    ok = ok & fp2_mul_compressed_check(a_aff.y, state.z, y2z1, rho);

    ok = ok & fp2_mul_compressed_check(l, a_aff.y, wit.t2, rho);
    ok = ok & fp2_mul_compressed_check(a_aff.x, o, j.add(wit.t2), rho);

    ok
}

/// Verify line witness and projective transitions for the variable G2 point.
fn check_b_line_witness(
    p: G1Affine,
    q: G2Affine,
    raw_lines: LineScheduleRaw,
    lines: LineSchedule,
    witness: G2LineWitness,
    rho: Fp,
) -> bool {
    let mut ok = true;
    let q_neg = neg_g2_affine(q);
    let q1 = frobenius_g2(q);
    let q2 = frobenius_square_g2(q);

    let mut state = projective_from_affine_g2(q);
    let double0 = witness.double_outputs[0];
    ok = ok & check_double_step_witness(
        p,
        state,
        double0,
        raw_lines.initial_double,
        lines.initial_doubles[0],
        witness.double_witnesses[0],
        rho,
    );
    state = double0;

    ok = ok & check_line_compute_witness(
        p,
        state,
        q_neg,
        raw_lines.pre_loop_line,
        lines.pre_loop_lines[0],
        witness.pre_loop_line_witness,
        rho,
    );

    let pre_loop_add_out = witness.pre_loop_add_output;
    ok = ok & check_add_step_witness(
        p,
        state,
        pre_loop_add_out,
        q,
        raw_lines.pre_loop_add,
        lines.pre_loop_adds[0],
        witness.pre_loop_add_witness,
        rho,
    );
    state = pre_loop_add_out;

    let loop_digits = loop_counter();
    for idx in 0..63 {
        let digit = loop_digits[62 - idx];
        let double_out = witness.double_outputs[idx + 1];
        ok = ok & check_double_step_witness(
            p,
            state,
            double_out,
            raw_lines.loop_doubles[idx],
            lines.loop_doubles[idx][0],
            witness.double_witnesses[idx + 1],
            rho,
        );

        if digit == 1i8 {
            let add_out = witness.loop_add_outputs[idx];
            ok = ok & check_add_step_witness(
                p,
                double_out,
                add_out,
                q,
                raw_lines.loop_adds_pos[idx],
                lines.loop_adds_pos[idx][0],
                witness.loop_add_witness_pos[idx],
                rho,
            );
            state = add_out;
        } else if digit == -1i8 {
            let add_out = witness.loop_add_outputs[idx];
            ok = ok & check_add_step_witness(
                p,
                double_out,
                add_out,
                q_neg,
                raw_lines.loop_adds_neg[idx],
                lines.loop_adds_neg[idx][0],
                witness.loop_add_witness_neg[idx],
                rho,
            );
            state = add_out;
        } else {
            let add_out = witness.loop_add_outputs[idx];
            ok = ok & g2_proj_eq(double_out, add_out);
            state = add_out;
        }
    }

    let final_add_out = witness.final_add_output;
    ok = ok & check_add_step_witness(
        p,
        state,
        final_add_out,
        q1,
        raw_lines.final_add,
        lines.final_adds[0],
        witness.final_add_witness,
        rho,
    );
    state = final_add_out;

    ok = ok & check_line_compute_witness(
        p,
        state,
        q2,
        raw_lines.final_line,
        lines.final_lines[0],
        witness.final_line_witness,
        rho,
    );

    ok
}

fn check_fixed_line_schedule(
    p: G1Affine,
    raw: LineScheduleRaw,
    lines: LineSchedule,
    pair_idx: u32,
) -> bool {
    let mut ok = true;

    ok = ok & line_eval_matches_p(raw.initial_double, lines.initial_doubles[pair_idx], p);
    ok = ok & line_eval_matches_p(raw.pre_loop_line, lines.pre_loop_lines[pair_idx], p);
    ok = ok & line_eval_matches_p(raw.pre_loop_add, lines.pre_loop_adds[pair_idx], p);

    let digits = loop_counter();
    for idx in 0..63 {
        let digit = digits[62 - idx];
        ok = ok & line_eval_matches_p(raw.loop_doubles[idx], lines.loop_doubles[idx][pair_idx], p);
        if digit == 1i8 {
            ok = ok & line_eval_matches_p(raw.loop_adds_pos[idx], lines.loop_adds_pos[idx][pair_idx], p);
        } else if digit == -1i8 {
            ok = ok & line_eval_matches_p(raw.loop_adds_neg[idx], lines.loop_adds_neg[idx][pair_idx], p);
        }
    }

    ok = ok & line_eval_matches_p(raw.final_add, lines.final_adds[pair_idx], p);
    ok = ok & line_eval_matches_p(raw.final_line, lines.final_lines[pair_idx], p);

    ok
}

/// Multi-pairing Miller loop for BN254.
///
/// Computes f = prod_{i=0..n-1} f_{x,Q_i}(P_i) using signed NAF digits of x
/// (optimal Ate pairing). Uses sparse line multiplication and mixed additions
/// to reduce Fp12 costs.
pub fn miller_loop<let N: u32>(p_list: [G1Affine; N], q_list: [G2Affine; N]) -> Fp12 {
    let (p, q, n) = filter_pairs(p_list, q_list);
    let mut result = fp12_one();

    if n != 0 {
        let mut q_proj = [projective_from_affine_g2(g2_affine_infinity()); N];
        let mut q_neg = [g2_affine_infinity(); N];
        for i in 0..N {
            if i < n {
                q_proj[i] = projective_from_affine_g2(q[i]);
                q_neg[i] = neg_g2_affine(q[i]);
            }
        }

        // Seed with the first line to avoid an extra Fp12 multiply by 1.
        if n >= 1 {
            let (q0, line) = q_proj[0].double_step();
            q_proj[0] = q0;
            let line = line_eval_at_point(line, p[0]);
            result.c0.b0 = line.r0;
            result.c1.b0 = line.r1;
            result.c1.b1 = line.r2;
        }

        // Fuse the second line with the first using sparse multiplication.
        if n >= 2 {
            let (q1, line) = q_proj[1].double_step();
            q_proj[1] = q1;
            let line = line_eval_at_point(line, p[1]);
            let prod_lines = mul_034_by_034(
                line.r0,
                line.r1,
                line.r2,
                result.c0.b0,
                result.c1.b0,
                result.c1.b1,
            );
            result.c0.b0 = prod_lines[0];
            result.c0.b1 = prod_lines[1];
            result.c0.b2 = prod_lines[2];
            result.c1.b0 = prod_lines[3];
            result.c1.b1 = prod_lines[4];
        }

        for k in 2..N {
            if k < n {
                let (qk, line) = q_proj[k].double_step();
                q_proj[k] = qk;
                let line = line_eval_at_point(line, p[k]);
                result = result.mul_by_034(line.r0, line.r1, line.r2);
            }
        }

        result = result.square();
        for k in 0..N {
            if k < n {
                let (qk, l2) = q_proj[k].line_compute(q_neg[k]);
                q_proj[k] = qk;
                let l2 = line_eval_at_point(l2, p[k]);

                let (qk, l1) = q_proj[k].add_mixed_step(q[k]);
                q_proj[k] = qk;
                let l1 = line_eval_at_point(l1, p[k]);

                let prod_lines = mul_034_by_034(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2);
                result = result.mul_by_01234(prod_lines);
            }
        }

        let loop_digits = loop_counter();
        for idx in 0..63 {
            let i = 62 - idx;
            result = result.square();

            for k in 0..N {
                if k < n {
                    let (qk, l1) = q_proj[k].double_step();
                    q_proj[k] = qk;
                    let l1 = line_eval_at_point(l1, p[k]);

                    if loop_digits[i] == 1i8 {
                        let (qk, l2) = q_proj[k].add_mixed_step(q[k]);
                        q_proj[k] = qk;
                        let l2 = line_eval_at_point(l2, p[k]);
                        let prod_lines = mul_034_by_034(
                            l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2,
                        );
                        result = result.mul_by_01234(prod_lines);
                    } else if loop_digits[i] == -1i8 {
                        let (qk, l2) = q_proj[k].add_mixed_step(q_neg[k]);
                        q_proj[k] = qk;
                        let l2 = line_eval_at_point(l2, p[k]);
                        let prod_lines = mul_034_by_034(
                            l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2,
                        );
                        result = result.mul_by_01234(prod_lines);
                    } else {
                        result = result.mul_by_034(l1.r0, l1.r1, l1.r2);
                    }
                }
            }
        }

        // Final steps: Frobenius-related additions for BN curves.
        for k in 0..N {
            if k < n {
                let q1 = frobenius_g2(q[k]);
                let q2 = frobenius_square_g2(q[k]);

                let (qk, l2) = q_proj[k].add_mixed_step(q1);
                q_proj[k] = qk;
                let l2 = line_eval_at_point(l2, p[k]);

                let (qk, l1) = q_proj[k].line_compute(q2);
                q_proj[k] = qk;
                let l1 = line_eval_at_point(l1, p[k]);

                let prod_lines = mul_034_by_034(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2);
                result = result.mul_by_01234(prod_lines);
            }
        }
    }

    result
}

/// Miller loop accumulator divided by c^{6x+2}, using pre-evaluated lines.
fn miller_loop_div_c_with_lines(
    p_list: [G1Affine; 3],
    lines: LineSchedule,
    c: Fp12,
    c_inv: Fp12,
) -> Fp12 {
    let _ = p_list;
    let mut result = fp12_one();

    let line0 = lines.initial_doubles[0];
    result.c0.b0 = line0.r0;
    result.c1.b0 = line0.r1;
    result.c1.b1 = line0.r2;

    let line1 = lines.initial_doubles[1];
    let prod_lines = mul_034_by_034(
        line1.r0,
        line1.r1,
        line1.r2,
        result.c0.b0,
        result.c1.b0,
        result.c1.b1,
    );
    result.c0.b0 = prod_lines[0];
    result.c0.b1 = prod_lines[1];
    result.c0.b2 = prod_lines[2];
    result.c1.b0 = prod_lines[3];
    result.c1.b1 = prod_lines[4];

    let line2 = lines.initial_doubles[2];
    result = result.mul_by_034(line2.r0, line2.r1, line2.r2);

    let c_inv_sq = c_inv.square();
    result = result.mul(c_inv_sq);

    result = result.square();
    for k in 0..3 {
        let l2 = lines.pre_loop_lines[k];
        let l1 = lines.pre_loop_adds[k];
        let prod_lines = mul_034_by_034(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2);
        result = result.mul_by_01234(prod_lines);
    }

    let loop_digits = loop_counter();
    let digit = loop_digits[63];
    if digit == 1i8 {
        result = result.mul(c_inv);
    } else if digit == -1i8 {
        result = result.mul(c);
    }

    for idx in 0..63 {
        let digit = loop_digits[62 - idx];
        result = result.square();
        for k in 0..3 {
            let l1 = lines.loop_doubles[idx][k];
            if digit == 1i8 {
                let l2 = lines.loop_adds_pos[idx][k];
                let prod_lines = mul_034_by_034(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2);
                result = result.mul_by_01234(prod_lines);
            } else if digit == -1i8 {
                let l2 = lines.loop_adds_neg[idx][k];
                let prod_lines = mul_034_by_034(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2);
                result = result.mul_by_01234(prod_lines);
            } else {
                result = result.mul_by_034(l1.r0, l1.r1, l1.r2);
            }
        }

        if digit == 1i8 {
            result = result.mul(c_inv);
        } else if digit == -1i8 {
            result = result.mul(c);
        }
    }

    for k in 0..3 {
        let l2 = lines.final_adds[k];
        let l1 = lines.final_lines[k];
        let prod_lines = mul_034_by_034(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2);
        result = result.mul_by_01234(prod_lines);
    }

    result
}


/// Final exponentiation easy part: z^{p^6-1} * z^{p^2+1}.
pub fn final_exp_easy_part(z: Fp12) -> Fp12 {
    let t0 = z.conjugate();
    let result = z.inverse();
    let t0 = t0.mul(result);
    let result = t0.frobenius_square().mul(t0);
    result
}

/// Final exponentiation hard part: exponent (p^4 - p^2 + 1) / r.
///
/// Uses cyclotomic squaring and Frobenius maps with a fixed addition chain
/// (Fuentes-Castaneda et al. 2011) optimized for BN254.
pub fn final_exp_hard_part(result: Fp12) -> Fp12 {
    let mut output = result;
    if result.is_one() {
    } else {
        let t0 = result.expt();
        let t0 = t0.conjugate();
        let t0 = t0.cyclotomic_square();
        let t1 = t0.cyclotomic_square();
        let t1 = t0.mul(t1);

        let t2 = t1.expt();
        let t2 = t2.conjugate();

        let t3 = t1.conjugate();
        let t1 = t2.mul(t3);

        let t3 = t2.cyclotomic_square();
        let t4 = t3.expt();
        let t4 = t1.mul(t4);

        let t3 = t0.mul(t4);
        let t0 = t2.mul(t4);
        let t0 = result.mul(t0);

        let t2 = t3.frobenius();
        let t0 = t2.mul(t0);

        let t2 = t4.frobenius_square();
        let t0 = t2.mul(t0);

        let t2 = result.conjugate();
        let t2 = t2.mul(t3);
        let t2 = t2.frobenius_cube();
        let t0 = t2.mul(t0);

        output = t0;
    }

    output
}

/// Full final exponentiation: z^{(p^12 - 1) / r}.
pub fn final_exponentiation(z: Fp12) -> Fp12 {
    let result = final_exp_easy_part(z);
    let mut output = result;
    if result.is_one() {
    } else {
        output = final_exp_hard_part(result);
    }
    output
}

/// Compute BN254 pairing e(P, Q).
pub fn pairing(p: G1Affine, q: G2Affine) -> Fp12 {
    let p_list = [p];
    let q_list = [q];
    let f = miller_loop(p_list, q_list);
    final_exponentiation(f)
}

/// Compute product of pairings: prod_i e(P_i, Q_i).
pub fn pairing_multi<let N: u32>(p_list: [G1Affine; N], q_list: [G2Affine; N]) -> Fp12 {
    let f = miller_loop(p_list, q_list);
    final_exponentiation(f)
}

/// Optimized pairing check using a pre-evaluated 3-pair line schedule and a preimage.
///
/// Expects line evaluations at P for each pair and a preimage `t_preimage` such that
/// the final exponentiation check can be reduced to a single `is_one` test.
pub fn pairing_check_optimized(
    p_list: [G1Affine; 3],
    q_list: [G2Affine; 3],
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
    let b_lines_ok = check_b_line_witness(p_list[0], q_list[0], b_lines_raw, lines, b_line_witness, rho);
    let delta_ok = check_fixed_line_schedule(p_list[1], delta_lines, lines, 1);
    let gamma_ok = check_fixed_line_schedule(p_list[2], gamma_lines, lines, 2);
    let lines_ok = b_lines_ok & delta_ok & gamma_ok;

    let c_inv = c.inverse();
    let f_div_c = miller_loop_div_c_with_lines(p_list, lines, c, c_inv);
    let f_t = f_div_c.mul(t_preimage);

    let w_in_fp6 = fp6_is_zero(w.c1);
    let mut acc = f_t.mul(w);
    acc = acc.mul(c_inv.frobenius());
    acc = acc.mul(c.frobenius_square());
    acc = acc.mul(c_inv.frobenius_cube());

    lines_ok & w_in_fp6 & acc.is_one()
}