pragma circom 2.0.0;

include "../g1.circom";

template G1Ops() {
    signal input a[2][3];
    signal input b[2][3];
    signal input neg_a[2][3];
    signal input gen[2][3];
    signal input bad[2][3];

    signal input inv_add_ab[3];
    signal input inv_double_a[3];
    signal input inv_jac_fuzzed[3];
    signal input inv_jac_inf[3];

    signal input jac_p[3][3];
    signal input jac_q[3][3];
    signal input jac_inf[3][3];

    signal output is_on_curve_gen;
    signal output is_on_curve_bad;
    signal output add_ab[2][3];
    signal output add_a_inf[2][3];
    signal output add_inf_a[2][3];
    signal output add_a_neg[2][3];
    signal output double_mixed_a[2][3];
    signal output add_a_a[2][3];
    signal output jac_sum[3][3];
    signal output jac_dbl[3][3];
    signal output jac_sum_neg[3][3];
    signal output jac_add_inf1[3][3];
    signal output jac_add_inf2[3][3];
    signal output jac_fuzzed_affine[2][3];
    signal output jac_inf_affine[2][3];

    component curve_gen = G1IsOnCurveAffine();
    component curve_bad = G1IsOnCurveAffine();
    for (var i = 0; i < 3; i++) {
        curve_gen.p[0][i] <== gen[0][i];
        curve_gen.p[1][i] <== gen[1][i];
        curve_bad.p[0][i] <== bad[0][i];
        curve_bad.p[1][i] <== bad[1][i];
    }
    is_on_curve_gen <== curve_gen.out;
    is_on_curve_bad <== curve_bad.out;

    component add_ab_op = G1AddAffine();
    for (var i2 = 0; i2 < 3; i2++) {
        add_ab_op.a[0][i2] <== a[0][i2];
        add_ab_op.a[1][i2] <== a[1][i2];
        add_ab_op.b[0][i2] <== b[0][i2];
        add_ab_op.b[1][i2] <== b[1][i2];
        add_ab_op.inv_add_z[i2] <== inv_add_ab[i2];
        add_ab_op.inv_double_z[i2] <== 0;
    }
    for (var i3 = 0; i3 < 3; i3++) {
        add_ab[0][i3] <== add_ab_op.out[0][i3];
        add_ab[1][i3] <== add_ab_op.out[1][i3];
    }

    component zero = G1AffineInfinity();
    component add_a_inf_op = G1AddAffine();
    component add_inf_a_op = G1AddAffine();
    component add_a_neg_op = G1AddAffine();
    for (var i4 = 0; i4 < 3; i4++) {
        add_a_inf_op.a[0][i4] <== a[0][i4];
        add_a_inf_op.a[1][i4] <== a[1][i4];
        add_a_inf_op.b[0][i4] <== zero.out[0][i4];
        add_a_inf_op.b[1][i4] <== zero.out[1][i4];
        add_a_inf_op.inv_add_z[i4] <== 0;
        add_a_inf_op.inv_double_z[i4] <== 0;

        add_inf_a_op.a[0][i4] <== zero.out[0][i4];
        add_inf_a_op.a[1][i4] <== zero.out[1][i4];
        add_inf_a_op.b[0][i4] <== a[0][i4];
        add_inf_a_op.b[1][i4] <== a[1][i4];
        add_inf_a_op.inv_add_z[i4] <== 0;
        add_inf_a_op.inv_double_z[i4] <== 0;

        add_a_neg_op.a[0][i4] <== a[0][i4];
        add_a_neg_op.a[1][i4] <== a[1][i4];
        add_a_neg_op.b[0][i4] <== neg_a[0][i4];
        add_a_neg_op.b[1][i4] <== neg_a[1][i4];
        add_a_neg_op.inv_add_z[i4] <== 0;
        add_a_neg_op.inv_double_z[i4] <== 0;
    }
    for (var i5 = 0; i5 < 3; i5++) {
        add_a_inf[0][i5] <== add_a_inf_op.out[0][i5];
        add_a_inf[1][i5] <== add_a_inf_op.out[1][i5];
        add_inf_a[0][i5] <== add_inf_a_op.out[0][i5];
        add_inf_a[1][i5] <== add_inf_a_op.out[1][i5];
        add_a_neg[0][i5] <== add_a_neg_op.out[0][i5];
        add_a_neg[1][i5] <== add_a_neg_op.out[1][i5];
    }

    component add_a_a_op = G1AddAffine();
    for (var i6 = 0; i6 < 3; i6++) {
        add_a_a_op.a[0][i6] <== a[0][i6];
        add_a_a_op.a[1][i6] <== a[1][i6];
        add_a_a_op.b[0][i6] <== a[0][i6];
        add_a_a_op.b[1][i6] <== a[1][i6];
        add_a_a_op.inv_add_z[i6] <== 0;
        add_a_a_op.inv_double_z[i6] <== inv_double_a[i6];
    }
    for (var i7 = 0; i7 < 3; i7++) {
        add_a_a[0][i7] <== add_a_a_op.out[0][i7];
        add_a_a[1][i7] <== add_a_a_op.out[1][i7];
    }

    component dbl_jac = G1DoubleMixed();
    for (var i8 = 0; i8 < 3; i8++) {
        dbl_jac.a[0][i8] <== a[0][i8];
        dbl_jac.a[1][i8] <== a[1][i8];
    }
    component dbl_aff = G1JacobianToAffine();
    dbl_aff.enable <== 1;
    for (var i9 = 0; i9 < 3; i9++) {
        dbl_aff.p[0][i9] <== dbl_jac.out[0][i9];
        dbl_aff.p[1][i9] <== dbl_jac.out[1][i9];
        dbl_aff.p[2][i9] <== dbl_jac.out[2][i9];
        dbl_aff.inv_z[i9] <== inv_double_a[i9];
    }
    for (var i10 = 0; i10 < 3; i10++) {
        double_mixed_a[0][i10] <== dbl_aff.out[0][i10];
        double_mixed_a[1][i10] <== dbl_aff.out[1][i10];
    }

    component add_jac = G1AddJac();
    component dbl_jac2 = G1DoubleJac();
    component add_jac_neg = G1AddJac();
    component add_jac_inf1 = G1AddJac();
    component add_jac_inf2 = G1AddJac();
    component neg_q = G1NegAffine();

    for (var i11 = 0; i11 < 3; i11++) {
        add_jac.p[0][i11] <== jac_p[0][i11];
        add_jac.p[1][i11] <== jac_p[1][i11];
        add_jac.p[2][i11] <== jac_p[2][i11];
        add_jac.q[0][i11] <== jac_q[0][i11];
        add_jac.q[1][i11] <== jac_q[1][i11];
        add_jac.q[2][i11] <== jac_q[2][i11];

        dbl_jac2.p[0][i11] <== jac_q[0][i11];
        dbl_jac2.p[1][i11] <== jac_q[1][i11];
        dbl_jac2.p[2][i11] <== jac_q[2][i11];

        add_jac_inf1.p[0][i11] <== jac_q[0][i11];
        add_jac_inf1.p[1][i11] <== jac_q[1][i11];
        add_jac_inf1.p[2][i11] <== jac_q[2][i11];
        add_jac_inf1.q[0][i11] <== jac_inf[0][i11];
        add_jac_inf1.q[1][i11] <== jac_inf[1][i11];
        add_jac_inf1.q[2][i11] <== jac_inf[2][i11];

        add_jac_inf2.p[0][i11] <== jac_inf[0][i11];
        add_jac_inf2.p[1][i11] <== jac_inf[1][i11];
        add_jac_inf2.p[2][i11] <== jac_inf[2][i11];
        add_jac_inf2.q[0][i11] <== jac_q[0][i11];
        add_jac_inf2.q[1][i11] <== jac_q[1][i11];
        add_jac_inf2.q[2][i11] <== jac_q[2][i11];
    }

    for (var i12 = 0; i12 < 3; i12++) {
        neg_q.p[0][i12] <== jac_q[0][i12];
        neg_q.p[1][i12] <== jac_q[1][i12];
    }
    for (var i13 = 0; i13 < 3; i13++) {
        add_jac_neg.p[0][i13] <== jac_q[0][i13];
        add_jac_neg.p[1][i13] <== jac_q[1][i13];
        add_jac_neg.p[2][i13] <== jac_q[2][i13];
        add_jac_neg.q[0][i13] <== neg_q.out[0][i13];
        add_jac_neg.q[1][i13] <== neg_q.out[1][i13];
        add_jac_neg.q[2][i13] <== jac_q[2][i13];
    }

    for (var i14 = 0; i14 < 3; i14++) {
        jac_sum[0][i14] <== add_jac.out[0][i14];
        jac_sum[1][i14] <== add_jac.out[1][i14];
        jac_sum[2][i14] <== add_jac.out[2][i14];

        jac_dbl[0][i14] <== dbl_jac2.out[0][i14];
        jac_dbl[1][i14] <== dbl_jac2.out[1][i14];
        jac_dbl[2][i14] <== dbl_jac2.out[2][i14];

        jac_sum_neg[0][i14] <== add_jac_neg.out[0][i14];
        jac_sum_neg[1][i14] <== add_jac_neg.out[1][i14];
        jac_sum_neg[2][i14] <== add_jac_neg.out[2][i14];

        jac_add_inf1[0][i14] <== add_jac_inf1.out[0][i14];
        jac_add_inf1[1][i14] <== add_jac_inf1.out[1][i14];
        jac_add_inf1[2][i14] <== add_jac_inf1.out[2][i14];

        jac_add_inf2[0][i14] <== add_jac_inf2.out[0][i14];
        jac_add_inf2[1][i14] <== add_jac_inf2.out[1][i14];
        jac_add_inf2[2][i14] <== add_jac_inf2.out[2][i14];
    }

    component jac_fuzzed = G1JacobianToAffine();
    jac_fuzzed.enable <== 1;
    for (var i15 = 0; i15 < 3; i15++) {
        jac_fuzzed.p[0][i15] <== jac_q[0][i15];
        jac_fuzzed.p[1][i15] <== jac_q[1][i15];
        jac_fuzzed.p[2][i15] <== jac_q[2][i15];
        jac_fuzzed.inv_z[i15] <== inv_jac_fuzzed[i15];
    }
    component jac_inf_aff = G1JacobianToAffine();
    jac_inf_aff.enable <== 1;
    for (var i16 = 0; i16 < 3; i16++) {
        jac_inf_aff.p[0][i16] <== jac_inf[0][i16];
        jac_inf_aff.p[1][i16] <== jac_inf[1][i16];
        jac_inf_aff.p[2][i16] <== jac_inf[2][i16];
        jac_inf_aff.inv_z[i16] <== inv_jac_inf[i16];
    }
    for (var i17 = 0; i17 < 3; i17++) {
        jac_fuzzed_affine[0][i17] <== jac_fuzzed.out[0][i17];
        jac_fuzzed_affine[1][i17] <== jac_fuzzed.out[1][i17];
        jac_inf_affine[0][i17] <== jac_inf_aff.out[0][i17];
        jac_inf_affine[1][i17] <== jac_inf_aff.out[1][i17];
    }
}

component main = G1Ops();
