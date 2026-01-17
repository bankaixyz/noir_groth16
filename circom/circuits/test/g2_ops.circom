pragma circom 2.0.0;

include "../g2.circom";

template G2Ops() {
    signal input a[2][2][3];
    signal input b[2][2][3];
    signal input neg_a[2][2][3];
    signal input gen[2][2][3];
    signal input bad[2][2][3];

    signal input jac_p[3][2][3];
    signal input jac_q[3][2][3];
    signal input jac_inf[3][2][3];

    signal input inv_jac_fuzzed[2][3];
    signal input inv_jac_inf[2][3];
    signal input inv_psi[2][3];

    signal output is_on_curve_gen;
    signal output is_on_curve_bad;
    signal output jac_sum[3][2][3];
    signal output jac_dbl[3][2][3];
    signal output jac_sum_inf1[3][2][3];
    signal output jac_sum_inf2[3][2][3];
    signal output jac_sum_neg[3][2][3];
    signal output jac_add_self[3][2][3];
    signal output jac_sum_pq[3][2][3];
    signal output jac_dbl_q[3][2][3];
    signal output jac_sum_neg_q[3][2][3];
    signal output jac_add_inf_q1[3][2][3];
    signal output jac_add_inf_q2[3][2][3];
    signal output jac_fuzzed_affine[2][2][3];
    signal output jac_inf_affine[2][2][3];
    signal output psi_on_curve;
    signal output psi_eq_gen;

    component curve_gen = G2IsOnCurveAffine();
    component curve_bad = G2IsOnCurveAffine();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            curve_gen.p[0][i][j] <== gen[0][i][j];
            curve_gen.p[1][i][j] <== gen[1][i][j];
            curve_bad.p[0][i][j] <== bad[0][i][j];
            curve_bad.p[1][i][j] <== bad[1][i][j];
        }
    }
    is_on_curve_gen <== curve_gen.out;
    is_on_curve_bad <== curve_bad.out;

    component jac_from_a = G2ProjectiveFromAffine();
    component jac_from_b = G2ProjectiveFromAffine();
    component jac_from_neg = G2ProjectiveFromAffine();
    component jac_from_inf = G2ProjectiveFromAffine();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            jac_from_a.a[0][i2][j2] <== a[0][i2][j2];
            jac_from_a.a[1][i2][j2] <== a[1][i2][j2];
            jac_from_b.a[0][i2][j2] <== b[0][i2][j2];
            jac_from_b.a[1][i2][j2] <== b[1][i2][j2];
            jac_from_neg.a[0][i2][j2] <== neg_a[0][i2][j2];
            jac_from_neg.a[1][i2][j2] <== neg_a[1][i2][j2];
            jac_from_inf.a[0][i2][j2] <== 0;
            jac_from_inf.a[1][i2][j2] <== 0;
        }
    }

    component add_ab = G2AddJac();
    component add_pq = G2AddJac();
    component dbl_q = G2DoubleJac();
    component add_q_neg = G2AddJac();
    component add_q_inf1 = G2AddJac();
    component add_q_inf2 = G2AddJac();
    component add_inf1 = G2AddJac();
    component add_inf2 = G2AddJac();
    component add_neg = G2AddJac();
    component dbl_a = G2DoubleJac();
    component add_self = G2AddJac();

    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            add_ab.p[0][i3][j3] <== jac_from_a.out[0][i3][j3];
            add_ab.p[1][i3][j3] <== jac_from_a.out[1][i3][j3];
            add_ab.p[2][i3][j3] <== jac_from_a.out[2][i3][j3];
            add_ab.q[0][i3][j3] <== jac_from_b.out[0][i3][j3];
            add_ab.q[1][i3][j3] <== jac_from_b.out[1][i3][j3];
            add_ab.q[2][i3][j3] <== jac_from_b.out[2][i3][j3];

            add_inf1.p[0][i3][j3] <== jac_from_a.out[0][i3][j3];
            add_inf1.p[1][i3][j3] <== jac_from_a.out[1][i3][j3];
            add_inf1.p[2][i3][j3] <== jac_from_a.out[2][i3][j3];
            add_inf1.q[0][i3][j3] <== jac_from_inf.out[0][i3][j3];
            add_inf1.q[1][i3][j3] <== jac_from_inf.out[1][i3][j3];
            add_inf1.q[2][i3][j3] <== jac_from_inf.out[2][i3][j3];

            add_inf2.p[0][i3][j3] <== jac_from_inf.out[0][i3][j3];
            add_inf2.p[1][i3][j3] <== jac_from_inf.out[1][i3][j3];
            add_inf2.p[2][i3][j3] <== jac_from_inf.out[2][i3][j3];
            add_inf2.q[0][i3][j3] <== jac_from_a.out[0][i3][j3];
            add_inf2.q[1][i3][j3] <== jac_from_a.out[1][i3][j3];
            add_inf2.q[2][i3][j3] <== jac_from_a.out[2][i3][j3];

            add_neg.p[0][i3][j3] <== jac_from_a.out[0][i3][j3];
            add_neg.p[1][i3][j3] <== jac_from_a.out[1][i3][j3];
            add_neg.p[2][i3][j3] <== jac_from_a.out[2][i3][j3];
            add_neg.q[0][i3][j3] <== jac_from_neg.out[0][i3][j3];
            add_neg.q[1][i3][j3] <== jac_from_neg.out[1][i3][j3];
            add_neg.q[2][i3][j3] <== jac_from_neg.out[2][i3][j3];

            dbl_a.p[0][i3][j3] <== jac_from_a.out[0][i3][j3];
            dbl_a.p[1][i3][j3] <== jac_from_a.out[1][i3][j3];
            dbl_a.p[2][i3][j3] <== jac_from_a.out[2][i3][j3];

            add_self.p[0][i3][j3] <== jac_from_a.out[0][i3][j3];
            add_self.p[1][i3][j3] <== jac_from_a.out[1][i3][j3];
            add_self.p[2][i3][j3] <== jac_from_a.out[2][i3][j3];
            add_self.q[0][i3][j3] <== jac_from_a.out[0][i3][j3];
            add_self.q[1][i3][j3] <== jac_from_a.out[1][i3][j3];
            add_self.q[2][i3][j3] <== jac_from_a.out[2][i3][j3];

            add_pq.p[0][i3][j3] <== jac_p[0][i3][j3];
            add_pq.p[1][i3][j3] <== jac_p[1][i3][j3];
            add_pq.p[2][i3][j3] <== jac_p[2][i3][j3];
            add_pq.q[0][i3][j3] <== jac_q[0][i3][j3];
            add_pq.q[1][i3][j3] <== jac_q[1][i3][j3];
            add_pq.q[2][i3][j3] <== jac_q[2][i3][j3];

            dbl_q.p[0][i3][j3] <== jac_q[0][i3][j3];
            dbl_q.p[1][i3][j3] <== jac_q[1][i3][j3];
            dbl_q.p[2][i3][j3] <== jac_q[2][i3][j3];

            add_q_inf1.p[0][i3][j3] <== jac_q[0][i3][j3];
            add_q_inf1.p[1][i3][j3] <== jac_q[1][i3][j3];
            add_q_inf1.p[2][i3][j3] <== jac_q[2][i3][j3];
            add_q_inf1.q[0][i3][j3] <== jac_inf[0][i3][j3];
            add_q_inf1.q[1][i3][j3] <== jac_inf[1][i3][j3];
            add_q_inf1.q[2][i3][j3] <== jac_inf[2][i3][j3];

            add_q_inf2.p[0][i3][j3] <== jac_inf[0][i3][j3];
            add_q_inf2.p[1][i3][j3] <== jac_inf[1][i3][j3];
            add_q_inf2.p[2][i3][j3] <== jac_inf[2][i3][j3];
            add_q_inf2.q[0][i3][j3] <== jac_q[0][i3][j3];
            add_q_inf2.q[1][i3][j3] <== jac_q[1][i3][j3];
            add_q_inf2.q[2][i3][j3] <== jac_q[2][i3][j3];
        }
    }

    component neg_q = Fp2Neg();
    for (var i3b = 0; i3b < 2; i3b++) {
        for (var j3b = 0; j3b < 3; j3b++) {
            neg_q.a[i3b][j3b] <== jac_q[1][i3b][j3b];
        }
    }
    for (var i3c = 0; i3c < 2; i3c++) {
        for (var j3c = 0; j3c < 3; j3c++) {
            add_q_neg.p[0][i3c][j3c] <== jac_q[0][i3c][j3c];
            add_q_neg.p[1][i3c][j3c] <== jac_q[1][i3c][j3c];
            add_q_neg.p[2][i3c][j3c] <== jac_q[2][i3c][j3c];
            add_q_neg.q[0][i3c][j3c] <== jac_q[0][i3c][j3c];
            add_q_neg.q[1][i3c][j3c] <== neg_q.out[i3c][j3c];
            add_q_neg.q[2][i3c][j3c] <== jac_q[2][i3c][j3c];
        }
    }

    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            jac_sum[0][i4][j4] <== add_ab.out[0][i4][j4];
            jac_sum[1][i4][j4] <== add_ab.out[1][i4][j4];
            jac_sum[2][i4][j4] <== add_ab.out[2][i4][j4];

            jac_sum_inf1[0][i4][j4] <== add_inf1.out[0][i4][j4];
            jac_sum_inf1[1][i4][j4] <== add_inf1.out[1][i4][j4];
            jac_sum_inf1[2][i4][j4] <== add_inf1.out[2][i4][j4];

            jac_sum_inf2[0][i4][j4] <== add_inf2.out[0][i4][j4];
            jac_sum_inf2[1][i4][j4] <== add_inf2.out[1][i4][j4];
            jac_sum_inf2[2][i4][j4] <== add_inf2.out[2][i4][j4];

            jac_sum_neg[0][i4][j4] <== add_neg.out[0][i4][j4];
            jac_sum_neg[1][i4][j4] <== add_neg.out[1][i4][j4];
            jac_sum_neg[2][i4][j4] <== add_neg.out[2][i4][j4];

            jac_dbl[0][i4][j4] <== dbl_a.out[0][i4][j4];
            jac_dbl[1][i4][j4] <== dbl_a.out[1][i4][j4];
            jac_dbl[2][i4][j4] <== dbl_a.out[2][i4][j4];

            jac_add_self[0][i4][j4] <== add_self.out[0][i4][j4];
            jac_add_self[1][i4][j4] <== add_self.out[1][i4][j4];
            jac_add_self[2][i4][j4] <== add_self.out[2][i4][j4];

            jac_sum_pq[0][i4][j4] <== add_pq.out[0][i4][j4];
            jac_sum_pq[1][i4][j4] <== add_pq.out[1][i4][j4];
            jac_sum_pq[2][i4][j4] <== add_pq.out[2][i4][j4];

            jac_dbl_q[0][i4][j4] <== dbl_q.out[0][i4][j4];
            jac_dbl_q[1][i4][j4] <== dbl_q.out[1][i4][j4];
            jac_dbl_q[2][i4][j4] <== dbl_q.out[2][i4][j4];

            jac_sum_neg_q[0][i4][j4] <== add_q_neg.out[0][i4][j4];
            jac_sum_neg_q[1][i4][j4] <== add_q_neg.out[1][i4][j4];
            jac_sum_neg_q[2][i4][j4] <== add_q_neg.out[2][i4][j4];

            jac_add_inf_q1[0][i4][j4] <== add_q_inf1.out[0][i4][j4];
            jac_add_inf_q1[1][i4][j4] <== add_q_inf1.out[1][i4][j4];
            jac_add_inf_q1[2][i4][j4] <== add_q_inf1.out[2][i4][j4];

            jac_add_inf_q2[0][i4][j4] <== add_q_inf2.out[0][i4][j4];
            jac_add_inf_q2[1][i4][j4] <== add_q_inf2.out[1][i4][j4];
            jac_add_inf_q2[2][i4][j4] <== add_q_inf2.out[2][i4][j4];
        }
    }

    component jac_fuzzed = G2JacobianToAffine();
    jac_fuzzed.enable <== 1;
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            jac_fuzzed.p[0][i5][j5] <== jac_q[0][i5][j5];
            jac_fuzzed.p[1][i5][j5] <== jac_q[1][i5][j5];
            jac_fuzzed.p[2][i5][j5] <== jac_q[2][i5][j5];
            jac_fuzzed.inv_z[i5][j5] <== inv_jac_fuzzed[i5][j5];
        }
    }
    component jac_inf_aff = G2JacobianToAffine();
    jac_inf_aff.enable <== 1;
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            jac_inf_aff.p[0][i6][j6] <== jac_inf[0][i6][j6];
            jac_inf_aff.p[1][i6][j6] <== jac_inf[1][i6][j6];
            jac_inf_aff.p[2][i6][j6] <== jac_inf[2][i6][j6];
            jac_inf_aff.inv_z[i6][j6] <== inv_jac_inf[i6][j6];
        }
    }
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            jac_fuzzed_affine[0][i7][j7] <== jac_fuzzed.out[0][i7][j7];
            jac_fuzzed_affine[1][i7][j7] <== jac_fuzzed.out[1][i7][j7];
            jac_inf_affine[0][i7][j7] <== jac_inf_aff.out[0][i7][j7];
            jac_inf_affine[1][i7][j7] <== jac_inf_aff.out[1][i7][j7];
        }
    }

    component psi = G2Psi();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            psi.p[0][i8][j8] <== jac_p[0][i8][j8];
            psi.p[1][i8][j8] <== jac_p[1][i8][j8];
            psi.p[2][i8][j8] <== jac_p[2][i8][j8];
        }
    }
    component psi_aff = G2JacobianToAffine();
    psi_aff.enable <== 1;
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            psi_aff.p[0][i9][j9] <== psi.out[0][i9][j9];
            psi_aff.p[1][i9][j9] <== psi.out[1][i9][j9];
            psi_aff.p[2][i9][j9] <== psi.out[2][i9][j9];
            psi_aff.inv_z[i9][j9] <== inv_psi[i9][j9];
        }
    }
    component psi_curve = G2IsOnCurveAffine();
    for (var i10 = 0; i10 < 2; i10++) {
        for (var j10 = 0; j10 < 3; j10++) {
            psi_curve.p[0][i10][j10] <== psi_aff.out[0][i10][j10];
            psi_curve.p[1][i10][j10] <== psi_aff.out[1][i10][j10];
        }
    }
    psi_on_curve <== psi_curve.out;
    component eq_x = Fp2Eq();
    component eq_y = Fp2Eq();
    for (var i11 = 0; i11 < 2; i11++) {
        for (var j11 = 0; j11 < 3; j11++) {
            eq_x.a[i11][j11] <== psi_aff.out[0][i11][j11];
            eq_x.b[i11][j11] <== gen[0][i11][j11];
            eq_y.a[i11][j11] <== psi_aff.out[1][i11][j11];
            eq_y.b[i11][j11] <== gen[1][i11][j11];
        }
    }
    psi_eq_gen <== eq_x.out * eq_y.out;
    psi_eq_gen * (psi_eq_gen - 1) === 0;
}

component main = G2Ops();
