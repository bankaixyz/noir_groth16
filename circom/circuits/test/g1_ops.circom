pragma circom 2.0.0;

include "../g1.circom";

template G1Ops() {
    signal input a[2];
    signal input b[2];
    signal input neg_a[2];
    signal input gen[2];
    signal input bad[2];

    signal input inv_add_ab;
    signal input inv_double_a;
    signal input inv_jac_fuzzed;
    signal input inv_jac_inf;

    signal input jac_p[3];
    signal input jac_q[3];
    signal input jac_inf[3];

    signal output is_on_curve_gen;
    signal output is_on_curve_bad;
    signal output add_ab[2];
    signal output add_a_inf[2];
    signal output add_inf_a[2];
    signal output add_a_neg[2];
    signal output double_mixed_a[2];
    signal output add_a_a[2];
    signal output jac_sum[3];
    signal output jac_dbl[3];
    signal output jac_sum_neg[3];
    signal output jac_add_inf1[3];
    signal output jac_add_inf2[3];
    signal output jac_fuzzed_affine[2];
    signal output jac_inf_affine[2];

    component curve_gen = G1IsOnCurveAffine();
    component curve_bad = G1IsOnCurveAffine();
    curve_gen.p[0] <== gen[0];
    curve_gen.p[1] <== gen[1];
    curve_bad.p[0] <== bad[0];
    curve_bad.p[1] <== bad[1];
    is_on_curve_gen <== curve_gen.out;
    is_on_curve_bad <== curve_bad.out;

    component add_ab_op = G1AddAffine();
    add_ab_op.a[0] <== a[0];
    add_ab_op.a[1] <== a[1];
    add_ab_op.b[0] <== b[0];
    add_ab_op.b[1] <== b[1];
    add_ab_op.inv_add_z <== inv_add_ab;
    add_ab_op.inv_double_z <== 0;
    add_ab[0] <== add_ab_op.out[0];
    add_ab[1] <== add_ab_op.out[1];

    component zero = G1AffineInfinity();
    component add_a_inf_op = G1AddAffine();
    component add_inf_a_op = G1AddAffine();
    component add_a_neg_op = G1AddAffine();

    add_a_inf_op.a[0] <== a[0];
    add_a_inf_op.a[1] <== a[1];
    add_a_inf_op.b[0] <== zero.out[0];
    add_a_inf_op.b[1] <== zero.out[1];
    add_a_inf_op.inv_add_z <== 0;
    add_a_inf_op.inv_double_z <== 0;

    add_inf_a_op.a[0] <== zero.out[0];
    add_inf_a_op.a[1] <== zero.out[1];
    add_inf_a_op.b[0] <== a[0];
    add_inf_a_op.b[1] <== a[1];
    add_inf_a_op.inv_add_z <== 0;
    add_inf_a_op.inv_double_z <== 0;

    add_a_neg_op.a[0] <== a[0];
    add_a_neg_op.a[1] <== a[1];
    add_a_neg_op.b[0] <== neg_a[0];
    add_a_neg_op.b[1] <== neg_a[1];
    add_a_neg_op.inv_add_z <== 0;
    add_a_neg_op.inv_double_z <== 0;

    add_a_inf[0] <== add_a_inf_op.out[0];
    add_a_inf[1] <== add_a_inf_op.out[1];
    add_inf_a[0] <== add_inf_a_op.out[0];
    add_inf_a[1] <== add_inf_a_op.out[1];
    add_a_neg[0] <== add_a_neg_op.out[0];
    add_a_neg[1] <== add_a_neg_op.out[1];

    component add_a_a_op = G1AddAffine();
    add_a_a_op.a[0] <== a[0];
    add_a_a_op.a[1] <== a[1];
    add_a_a_op.b[0] <== a[0];
    add_a_a_op.b[1] <== a[1];
    add_a_a_op.inv_add_z <== 0;
    add_a_a_op.inv_double_z <== inv_double_a;
    add_a_a[0] <== add_a_a_op.out[0];
    add_a_a[1] <== add_a_a_op.out[1];

    component dbl_jac = G1DoubleMixed();
    dbl_jac.a[0] <== a[0];
    dbl_jac.a[1] <== a[1];
    component dbl_aff = G1JacobianToAffine();
    dbl_aff.enable <== 1;
    dbl_aff.p[0] <== dbl_jac.out[0];
    dbl_aff.p[1] <== dbl_jac.out[1];
    dbl_aff.p[2] <== dbl_jac.out[2];
    dbl_aff.inv_z <== inv_double_a;
    double_mixed_a[0] <== dbl_aff.out[0];
    double_mixed_a[1] <== dbl_aff.out[1];

    component add_jac = G1AddJac();
    component dbl_jac2 = G1DoubleJac();
    component add_jac_neg = G1AddJac();
    component add_jac_inf1 = G1AddJac();
    component add_jac_inf2 = G1AddJac();
    component neg_q = G1NegAffine();

    for (var i11 = 0; i11 < 3; i11++) {
        add_jac.p[i11] <== jac_p[i11];
        add_jac.q[i11] <== jac_q[i11];

        dbl_jac2.p[i11] <== jac_q[i11];

        add_jac_inf1.p[i11] <== jac_q[i11];
        add_jac_inf1.q[i11] <== jac_inf[i11];

        add_jac_inf2.p[i11] <== jac_inf[i11];
        add_jac_inf2.q[i11] <== jac_q[i11];
    }

    neg_q.p[0] <== jac_q[0];
    neg_q.p[1] <== jac_q[1];

    add_jac_neg.p[0] <== jac_q[0];
    add_jac_neg.p[1] <== jac_q[1];
    add_jac_neg.p[2] <== jac_q[2];
    add_jac_neg.q[0] <== neg_q.out[0];
    add_jac_neg.q[1] <== neg_q.out[1];
    add_jac_neg.q[2] <== jac_q[2];

    for (var i14 = 0; i14 < 3; i14++) {
        jac_sum[i14] <== add_jac.out[i14];
        jac_dbl[i14] <== dbl_jac2.out[i14];
        jac_sum_neg[i14] <== add_jac_neg.out[i14];
        jac_add_inf1[i14] <== add_jac_inf1.out[i14];
        jac_add_inf2[i14] <== add_jac_inf2.out[i14];
    }

    component jac_fuzzed = G1JacobianToAffine();
    jac_fuzzed.enable <== 1;
    jac_fuzzed.p[0] <== jac_q[0];
    jac_fuzzed.p[1] <== jac_q[1];
    jac_fuzzed.p[2] <== jac_q[2];
    jac_fuzzed.inv_z <== inv_jac_fuzzed;
    component jac_inf_aff = G1JacobianToAffine();
    jac_inf_aff.enable <== 1;
    jac_inf_aff.p[0] <== jac_inf[0];
    jac_inf_aff.p[1] <== jac_inf[1];
    jac_inf_aff.p[2] <== jac_inf[2];
    jac_inf_aff.inv_z <== inv_jac_inf;

    jac_fuzzed_affine[0] <== jac_fuzzed.out[0];
    jac_fuzzed_affine[1] <== jac_fuzzed.out[1];
    jac_inf_affine[0] <== jac_inf_aff.out[0];
    jac_inf_affine[1] <== jac_inf_aff.out[1];
}

component main = G1Ops();
