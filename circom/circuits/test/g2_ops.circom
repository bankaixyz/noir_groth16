pragma circom 2.0.0;

include "../g2.circom";

template G2Ops() {
    signal input a[2][2];
    signal input b[2][2];
    signal input neg_a[2][2];
    signal input gen[2][2];
    signal input bad[2][2];

    signal input jac_p[3][2];
    signal input jac_q[3][2];
    signal input jac_inf[3][2];

    signal input inv_jac_fuzzed[2];
    signal input inv_jac_inf[2];
    signal input inv_psi[2];

    signal output is_on_curve_gen;
    signal output is_on_curve_bad;
    signal output jac_sum[3][2];
    signal output jac_dbl[3][2];
    signal output jac_sum_inf1[3][2];
    signal output jac_sum_inf2[3][2];
    signal output jac_sum_neg[3][2];
    signal output jac_add_self[3][2];
    signal output jac_sum_pq[3][2];
    signal output jac_dbl_q[3][2];
    signal output jac_sum_neg_q[3][2];
    signal output jac_add_inf_q1[3][2];
    signal output jac_add_inf_q2[3][2];
    signal output jac_fuzzed_affine[2][2];
    signal output jac_inf_affine[2][2];
    signal output psi_on_curve;
    signal output psi_eq_gen;

    component curve_gen = G2IsOnCurveAffine();
    component curve_bad = G2IsOnCurveAffine();
    for (var i = 0; i < 2; i++) {
        curve_gen.p[0][i] <== gen[0][i];
        curve_gen.p[1][i] <== gen[1][i];
        curve_bad.p[0][i] <== bad[0][i];
        curve_bad.p[1][i] <== bad[1][i];
    }
    is_on_curve_gen <== curve_gen.out;
    is_on_curve_bad <== curve_bad.out;

    component jac_from_a = G2ProjectiveFromAffine();
    component jac_from_b = G2ProjectiveFromAffine();
    component jac_from_neg = G2ProjectiveFromAffine();
    component jac_from_inf = G2ProjectiveFromAffine();
    for (var i2 = 0; i2 < 2; i2++) {
        jac_from_a.a[0][i2] <== a[0][i2];
        jac_from_a.a[1][i2] <== a[1][i2];
        jac_from_b.a[0][i2] <== b[0][i2];
        jac_from_b.a[1][i2] <== b[1][i2];
        jac_from_neg.a[0][i2] <== neg_a[0][i2];
        jac_from_neg.a[1][i2] <== neg_a[1][i2];
        jac_from_inf.a[0][i2] <== 0;
        jac_from_inf.a[1][i2] <== 0;
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

    for (var c = 0; c < 3; c++) {
        for (var i3 = 0; i3 < 2; i3++) {
            add_ab.p[c][i3] <== jac_from_a.out[c][i3];
            add_ab.q[c][i3] <== jac_from_b.out[c][i3];

            add_inf1.p[c][i3] <== jac_from_a.out[c][i3];
            add_inf1.q[c][i3] <== jac_from_inf.out[c][i3];

            add_inf2.p[c][i3] <== jac_from_inf.out[c][i3];
            add_inf2.q[c][i3] <== jac_from_a.out[c][i3];

            add_neg.p[c][i3] <== jac_from_a.out[c][i3];
            add_neg.q[c][i3] <== jac_from_neg.out[c][i3];

            dbl_a.p[c][i3] <== jac_from_a.out[c][i3];

            add_self.p[c][i3] <== jac_from_a.out[c][i3];
            add_self.q[c][i3] <== jac_from_a.out[c][i3];

            add_pq.p[c][i3] <== jac_p[c][i3];
            add_pq.q[c][i3] <== jac_q[c][i3];

            dbl_q.p[c][i3] <== jac_q[c][i3];

            add_q_inf1.p[c][i3] <== jac_q[c][i3];
            add_q_inf1.q[c][i3] <== jac_inf[c][i3];

            add_q_inf2.p[c][i3] <== jac_inf[c][i3];
            add_q_inf2.q[c][i3] <== jac_q[c][i3];
        }
    }

    component neg_q = Fp2Neg();
    for (var i3b = 0; i3b < 2; i3b++) {
        neg_q.a[i3b] <== jac_q[1][i3b];
    }
    for (var c2 = 0; c2 < 3; c2++) {
        for (var i3c = 0; i3c < 2; i3c++) {
            add_q_neg.p[c2][i3c] <== jac_q[c2][i3c];
            if (c2 == 1) {
                add_q_neg.q[c2][i3c] <== neg_q.out[i3c];
            } else {
                add_q_neg.q[c2][i3c] <== jac_q[c2][i3c];
            }
        }
    }

    for (var c3 = 0; c3 < 3; c3++) {
        for (var i4 = 0; i4 < 2; i4++) {
            jac_sum[c3][i4] <== add_ab.out[c3][i4];
            jac_sum_inf1[c3][i4] <== add_inf1.out[c3][i4];
            jac_sum_inf2[c3][i4] <== add_inf2.out[c3][i4];
            jac_sum_neg[c3][i4] <== add_neg.out[c3][i4];
            jac_dbl[c3][i4] <== dbl_a.out[c3][i4];
            jac_add_self[c3][i4] <== add_self.out[c3][i4];
            jac_sum_pq[c3][i4] <== add_pq.out[c3][i4];
            jac_dbl_q[c3][i4] <== dbl_q.out[c3][i4];
            jac_sum_neg_q[c3][i4] <== add_q_neg.out[c3][i4];
            jac_add_inf_q1[c3][i4] <== add_q_inf1.out[c3][i4];
            jac_add_inf_q2[c3][i4] <== add_q_inf2.out[c3][i4];
        }
    }

    component jac_fuzzed = G2JacobianToAffine();
    jac_fuzzed.enable <== 1;
    for (var c4 = 0; c4 < 3; c4++) {
        for (var i5 = 0; i5 < 2; i5++) {
            jac_fuzzed.p[c4][i5] <== jac_q[c4][i5];
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        jac_fuzzed.inv_z[i6] <== inv_jac_fuzzed[i6];
    }
    component jac_inf_aff = G2JacobianToAffine();
    jac_inf_aff.enable <== 1;
    for (var c5 = 0; c5 < 3; c5++) {
        for (var i7 = 0; i7 < 2; i7++) {
            jac_inf_aff.p[c5][i7] <== jac_inf[c5][i7];
        }
    }
    for (var i8 = 0; i8 < 2; i8++) {
        jac_inf_aff.inv_z[i8] <== inv_jac_inf[i8];
    }
    for (var i9 = 0; i9 < 2; i9++) {
        jac_fuzzed_affine[0][i9] <== jac_fuzzed.out[0][i9];
        jac_fuzzed_affine[1][i9] <== jac_fuzzed.out[1][i9];
        jac_inf_affine[0][i9] <== jac_inf_aff.out[0][i9];
        jac_inf_affine[1][i9] <== jac_inf_aff.out[1][i9];
    }

    component psi = G2Psi();
    for (var c6 = 0; c6 < 3; c6++) {
        for (var i10 = 0; i10 < 2; i10++) {
            psi.p[c6][i10] <== jac_p[c6][i10];
        }
    }
    component psi_aff = G2JacobianToAffine();
    psi_aff.enable <== 1;
    for (var c7 = 0; c7 < 3; c7++) {
        for (var i11 = 0; i11 < 2; i11++) {
            psi_aff.p[c7][i11] <== psi.out[c7][i11];
        }
    }
    for (var i12 = 0; i12 < 2; i12++) {
        psi_aff.inv_z[i12] <== inv_psi[i12];
    }
    component psi_curve = G2IsOnCurveAffine();
    for (var i13 = 0; i13 < 2; i13++) {
        psi_curve.p[0][i13] <== psi_aff.out[0][i13];
        psi_curve.p[1][i13] <== psi_aff.out[1][i13];
    }
    psi_on_curve <== psi_curve.out;
    component eq_x = Fp2Eq();
    component eq_y = Fp2Eq();
    for (var i14 = 0; i14 < 2; i14++) {
        eq_x.a[i14] <== psi_aff.out[0][i14];
        eq_x.b[i14] <== gen[0][i14];
        eq_y.a[i14] <== psi_aff.out[1][i14];
        eq_y.b[i14] <== gen[1][i14];
    }
    psi_eq_gen <== eq_x.out * eq_y.out;
    psi_eq_gen * (psi_eq_gen - 1) === 0;
}

component main = G2Ops();
