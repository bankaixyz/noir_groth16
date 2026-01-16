use crate::fp12::{Fp12, fp12_one, mul_034_by_034};
use crate::fp::{fp_zero};
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

fn loop_counter() -> [i8; 66] {
    [
        0, 0, 0, 1, 0, 1, 0, -1, 0, 0, -1, 0, 0, 0, 1, 0,
        0, -1, 0, -1, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, -1, 0,
        0, 1, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, -1,
        0, 1, 0, -1, 0, 0, 0, -1, 0, -1, 0, 0, 0, 1, 0, -1,
        0, 1,
    ]
}

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

pub fn miller_loop<let N: u32>(p_list: [G1Affine; N], q_list: [G2Affine; N]) -> Fp12 {
    let (p, q, n) = filter_pairs(p_list, q_list);
    let mut result = fp12_one();
    // #region agent log
    if n == 0 {
        println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:60\",\"message\":\"pair_count\",\"data\":{\"val\":\"n_eq_0\"},\"timestamp\":0}");
    } else if n == 1 {
        println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:60\",\"message\":\"pair_count\",\"data\":{\"val\":\"n_eq_1\"},\"timestamp\":0}");
    } else {
        println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:60\",\"message\":\"pair_count\",\"data\":{\"val\":\"n_gt_1\"},\"timestamp\":0}");
    }
    // #endregion agent log

    if n != 0 {
        let mut q_proj = [projective_from_affine_g2(g2_affine_infinity()); N];
        let mut q_neg = [g2_affine_infinity(); N];
        for i in 0..N {
            if i < n {
                q_proj[i] = projective_from_affine_g2(q[i]);
                q_neg[i] = neg_g2_affine(q[i]);
            }
        }

        if n >= 1 {
            let (q0, line) = q_proj[0].double_step();
            q_proj[0] = q0;
            let line = line_eval_at_point(line, p[0]);
            result.c0.b0 = line.r0;
            result.c1.b0 = line.r1;
            result.c1.b1 = line.r2;
            // #region agent log
            let r0_zero = (line.r0.c0 == fp_zero()) & (line.r0.c1 == fp_zero());
            let r1_zero = (line.r1.c0 == fp_zero()) & (line.r1.c1 == fp_zero());
            let r2_zero = (line.r2.c0 == fp_zero()) & (line.r2.c1 == fp_zero());
            if r0_zero {
                println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H2\",\"location\":\"pairing.nr:79\",\"message\":\"line0_r0_zero\",\"data\":{\"val\":\"true\"},\"timestamp\":0}");
            } else {
                println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H2\",\"location\":\"pairing.nr:79\",\"message\":\"line0_r0_zero\",\"data\":{\"val\":\"false\"},\"timestamp\":0}");
            }
            if r1_zero {
                println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H2\",\"location\":\"pairing.nr:80\",\"message\":\"line0_r1_zero\",\"data\":{\"val\":\"true\"},\"timestamp\":0}");
            } else {
                println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H2\",\"location\":\"pairing.nr:80\",\"message\":\"line0_r1_zero\",\"data\":{\"val\":\"false\"},\"timestamp\":0}");
            }
            if r2_zero {
                println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H2\",\"location\":\"pairing.nr:81\",\"message\":\"line0_r2_zero\",\"data\":{\"val\":\"true\"},\"timestamp\":0}");
            } else {
                println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H2\",\"location\":\"pairing.nr:81\",\"message\":\"line0_r2_zero\",\"data\":{\"val\":\"false\"},\"timestamp\":0}");
            }
            // #endregion agent log
        }

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
        // #region agent log
        if result.is_one() {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H3\",\"location\":\"pairing.nr:132\",\"message\":\"after_i63_is_one\",\"data\":{\"val\":\"true\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H3\",\"location\":\"pairing.nr:132\",\"message\":\"after_i63_is_one\",\"data\":{\"val\":\"false\"},\"timestamp\":0}");
        }
        // #endregion agent log

        let loop_digits = loop_counter();
        // #region agent log
        if loop_digits[65] == 0i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:136\",\"message\":\"loop_digit_65\",\"data\":{\"val\":\"0\"},\"timestamp\":0}");
        } else if loop_digits[65] == 1i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:136\",\"message\":\"loop_digit_65\",\"data\":{\"val\":\"1\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:136\",\"message\":\"loop_digit_65\",\"data\":{\"val\":\"-1\"},\"timestamp\":0}");
        }
        if loop_digits[64] == 0i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:137\",\"message\":\"loop_digit_64\",\"data\":{\"val\":\"0\"},\"timestamp\":0}");
        } else if loop_digits[64] == 1i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:137\",\"message\":\"loop_digit_64\",\"data\":{\"val\":\"1\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:137\",\"message\":\"loop_digit_64\",\"data\":{\"val\":\"-1\"},\"timestamp\":0}");
        }
        if loop_digits[63] == 0i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:138\",\"message\":\"loop_digit_63\",\"data\":{\"val\":\"0\"},\"timestamp\":0}");
        } else if loop_digits[63] == 1i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:138\",\"message\":\"loop_digit_63\",\"data\":{\"val\":\"1\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:138\",\"message\":\"loop_digit_63\",\"data\":{\"val\":\"-1\"},\"timestamp\":0}");
        }
        if loop_digits[62] == 0i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:139\",\"message\":\"loop_digit_62\",\"data\":{\"val\":\"0\"},\"timestamp\":0}");
        } else if loop_digits[62] == 1i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:139\",\"message\":\"loop_digit_62\",\"data\":{\"val\":\"1\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:139\",\"message\":\"loop_digit_62\",\"data\":{\"val\":\"-1\"},\"timestamp\":0}");
        }
        if loop_digits[0] == 0i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:140\",\"message\":\"loop_digit_0\",\"data\":{\"val\":\"0\"},\"timestamp\":0}");
        } else if loop_digits[0] == 1i8 {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:140\",\"message\":\"loop_digit_0\",\"data\":{\"val\":\"1\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H1\",\"location\":\"pairing.nr:140\",\"message\":\"loop_digit_0\",\"data\":{\"val\":\"-1\"},\"timestamp\":0}");
        }
        // #endregion agent log
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
        // #region agent log
        if result.is_one() {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H4\",\"location\":\"pairing.nr:171\",\"message\":\"after_loop_is_one\",\"data\":{\"val\":\"true\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H4\",\"location\":\"pairing.nr:171\",\"message\":\"after_loop_is_one\",\"data\":{\"val\":\"false\"},\"timestamp\":0}");
        }
        // #endregion agent log

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
        // #region agent log
        if result.is_one() {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H4\",\"location\":\"pairing.nr:189\",\"message\":\"after_final_lines_is_one\",\"data\":{\"val\":\"true\"},\"timestamp\":0}");
        } else {
            println("{\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"H4\",\"location\":\"pairing.nr:189\",\"message\":\"after_final_lines_is_one\",\"data\":{\"val\":\"false\"},\"timestamp\":0}");
        }
        // #endregion agent log
    }

    result
}

pub fn final_exp_easy_part(z: Fp12) -> Fp12 {
    let t0 = z.conjugate();
    let result = z.inverse();
    let t0 = t0.mul(result);
    let result = t0.frobenius_square().mul(t0);
    result
}

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

pub fn final_exponentiation(z: Fp12) -> Fp12 {
    let result = final_exp_easy_part(z);
    let mut output = result;
    if result.is_one() {
    } else {
        output = final_exp_hard_part(result);
    }
    output
}

pub fn pairing(p: G1Affine, q: G2Affine) -> Fp12 {
    let p_list = [p];
    let q_list = [q];
    let f = miller_loop(p_list, q_list);
    final_exponentiation(f)
}

pub fn pairing_multi<let N: u32>(p_list: [G1Affine; N], q_list: [G2Affine; N]) -> Fp12 {
    let f = miller_loop(p_list, q_list);
    final_exponentiation(f)
}