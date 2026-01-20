use crate::fp12::{Fp12, fp12_one, mul_034_by_034};
use crate::fp::{fp_zero};
use crate::fp2::Fp2;
use crate::fp6::Fp6;
use crate::g1::{G1Affine, g1_affine_infinity};
use crate::g2::{
    G2Affine,
    LineEvaluation,
    frobenius_g2,
    frobenius_square_g2,
    g2_affine_infinity,
    neg_g2_affine,
    projective_from_affine_g2,
};
use std::println;

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

/// Miller loop accumulator divided by c^{6x+2}, using the same NAF schedule.
fn miller_loop_div_c<let N: u32>(
    p_list: [G1Affine; N],
    q_list: [G2Affine; N],
    c: Fp12,
    c_inv: Fp12,
) -> Fp12 {
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

        let c_inv_sq = c_inv.square();
        result = result.mul(c_inv_sq);

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
        let digit = loop_digits[63];
        if digit == 1i8 {
            result = result.mul(c_inv);
        } else if digit == -1i8 {
            result = result.mul(c);
        }

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

            let digit = loop_digits[i];
            if digit == 1i8 {
                result = result.mul(c_inv);
            } else if digit == -1i8 {
                result = result.mul(c);
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

/// Pairing check with an Fp12 preimage t: FE(miller * t) == 1.
pub fn pairing_check_with_preimage<let N: u32>(
    p_list: [G1Affine; N],
    q_list: [G2Affine; N],
    t_preimage: Fp12,
    c: Fp12,
    w: Fp12,
) -> bool {
    let c_inv = c.inverse();
    let f_div_c = miller_loop_div_c(p_list, q_list, c, c_inv);
    let f_t = f_div_c.mul(t_preimage);

    let w_in_fp6 = fp6_is_zero(w.c1);
    let mut acc = f_t.mul(w);
    acc = acc.mul(c_inv.frobenius());
    acc = acc.mul(c.frobenius_square());
    acc = acc.mul(c_inv.frobenius_cube());

    w_in_fp6 & acc.is_one()
}