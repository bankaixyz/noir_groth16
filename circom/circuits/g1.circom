pragma circom 2.0.0;

include "./fp.circom";

template G1AffineInfinity() {
    signal output out[2][3];

    component zero = FpZero();
    for (var i = 0; i < 3; i++) {
        out[0][i] <== zero.out[i];
        out[1][i] <== zero.out[i];
    }
}

template G1JacobianInfinity() {
    signal output out[3][3];

    component one = FpOne();
    component zero = FpZero();
    for (var i = 0; i < 3; i++) {
        out[0][i] <== one.out[i];
        out[1][i] <== one.out[i];
        out[2][i] <== zero.out[i];
    }
}

template G1AffineIsInfinity() {
    signal input p[2][3];
    signal output out;

    component xZero = FpIsZero();
    component yZero = FpIsZero();
    for (var i = 0; i < 3; i++) {
        xZero.a[i] <== p[0][i];
        yZero.a[i] <== p[1][i];
    }
    out <== xZero.out * yZero.out;
    out * (out - 1) === 0;
}

template G1JacIsInfinity() {
    signal input p[3][3];
    signal output out;

    component zZero = FpIsZero();
    for (var i = 0; i < 3; i++) {
        zZero.a[i] <== p[2][i];
    }
    out <== zZero.out;
    out * (out - 1) === 0;
}

template G1IsOnCurveAffine() {
    signal input p[2][3];
    signal output out;

    component ySq = FpSquare();
    component xSq = FpSquare();
    component xCub = FpMul();
    component b = CurveB();
    component rhs = FpAdd();
    component eq = FpEq();
    component isInf = G1AffineIsInfinity();

    for (var i = 0; i < 3; i++) {
        ySq.a[i] <== p[1][i];
        xSq.a[i] <== p[0][i];
        isInf.p[0][i] <== p[0][i];
        isInf.p[1][i] <== p[1][i];
    }
    for (var i2 = 0; i2 < 3; i2++) {
        xCub.a[i2] <== xSq.out[i2];
        xCub.b[i2] <== p[0][i2];
    }
    for (var i3 = 0; i3 < 3; i3++) {
        rhs.a[i3] <== xCub.out[i3];
        rhs.b[i3] <== b.out[i3];
    }
    for (var i4 = 0; i4 < 3; i4++) {
        eq.a[i4] <== ySq.out[i4];
        eq.b[i4] <== rhs.out[i4];
    }

    out <== isInf.out + (1 - isInf.out) * eq.out;
    out * (out - 1) === 0;
}

template G1NegAffine() {
    signal input p[2][3];
    signal output out[2][3];

    component neg = FpNeg();
    for (var i = 0; i < 3; i++) {
        neg.a[i] <== p[1][i];
    }
    for (var j = 0; j < 3; j++) {
        out[0][j] <== p[0][j];
        out[1][j] <== neg.out[j];
    }
}

template G1DoubleMixed() {
    signal input a[2][3];
    signal output out[3][3];

    component xx = FpSquare();
    component yy = FpSquare();
    component yyyy = FpSquare();
    component a0_plus_yy = FpAdd();
    component a0_plus_yy_sq = FpSquare();
    component s_tmp = FpSub();
    component s = FpMul();
    component m = FpMul();
    component t = FpSub();
    component s_minus_t = FpSub();
    component y3_mul = FpMul();
    component y3 = FpSub();
    component z3 = FpMul();
    component two = FpTwo();
    component three = FpThree();
    component eight = FpEight();

    for (var i = 0; i < 3; i++) {
        xx.a[i] <== a[0][i];
        yy.a[i] <== a[1][i];
    }
    for (var i2 = 0; i2 < 3; i2++) {
        yyyy.a[i2] <== yy.out[i2];
        a0_plus_yy.a[i2] <== a[0][i2];
        a0_plus_yy.b[i2] <== yy.out[i2];
    }
    for (var i3 = 0; i3 < 3; i3++) {
        a0_plus_yy_sq.a[i3] <== a0_plus_yy.out[i3];
    }
    for (var i4 = 0; i4 < 3; i4++) {
        s_tmp.a[i4] <== a0_plus_yy_sq.out[i4];
        s_tmp.b[i4] <== xx.out[i4];
    }
    component s_tmp2 = FpSub();
    for (var i5 = 0; i5 < 3; i5++) {
        s_tmp2.a[i5] <== s_tmp.out[i5];
        s_tmp2.b[i5] <== yyyy.out[i5];
    }
    for (var i6 = 0; i6 < 3; i6++) {
        s.a[i6] <== two.out[i6];
        s.b[i6] <== s_tmp2.out[i6];
        m.a[i6] <== three.out[i6];
        m.b[i6] <== xx.out[i6];
    }

    component m_sq = FpSquare();
    component s_dbl = FpMul();
    for (var i7 = 0; i7 < 3; i7++) {
        m_sq.a[i7] <== m.out[i7];
        s_dbl.a[i7] <== two.out[i7];
        s_dbl.b[i7] <== s.out[i7];
    }
    for (var i8 = 0; i8 < 3; i8++) {
        t.a[i8] <== m_sq.out[i8];
        t.b[i8] <== s_dbl.out[i8];
    }

    for (var i9 = 0; i9 < 3; i9++) {
        s_minus_t.a[i9] <== s.out[i9];
        s_minus_t.b[i9] <== t.out[i9];
    }
    for (var i10 = 0; i10 < 3; i10++) {
        y3_mul.a[i10] <== m.out[i10];
        y3_mul.b[i10] <== s_minus_t.out[i10];
        z3.a[i10] <== two.out[i10];
        z3.b[i10] <== a[1][i10];
    }

    component yyyy_mul = FpMul();
    for (var i11 = 0; i11 < 3; i11++) {
        yyyy_mul.a[i11] <== eight.out[i11];
        yyyy_mul.b[i11] <== yyyy.out[i11];
    }
    for (var i12 = 0; i12 < 3; i12++) {
        y3.a[i12] <== y3_mul.out[i12];
        y3.b[i12] <== yyyy_mul.out[i12];
    }

    for (var i13 = 0; i13 < 3; i13++) {
        out[0][i13] <== t.out[i13];
        out[1][i13] <== y3.out[i13];
        out[2][i13] <== z3.out[i13];
    }
}

template G1DoubleJac() {
    signal input p[3][3];
    signal output out[3][3];

    component a = FpSquare();
    component b = FpSquare();
    component c = FpSquare();
    component x_plus_b = FpAdd();
    component x_plus_b_sq = FpSquare();
    component d_tmp = FpSub();
    component d = FpMul();
    component e = FpAdd();
    component f = FpSquare();
    component t = FpMul();
    component two = FpTwo();
    component three = FpThree();
    component eight = FpEight();

    for (var i = 0; i < 3; i++) {
        a.a[i] <== p[0][i];
        b.a[i] <== p[1][i];
    }
    for (var i2 = 0; i2 < 3; i2++) {
        c.a[i2] <== b.out[i2];
        x_plus_b.a[i2] <== p[0][i2];
        x_plus_b.b[i2] <== b.out[i2];
        e.a[i2] <== a.out[i2];
        e.b[i2] <== a.out[i2];
    }
    for (var i3 = 0; i3 < 3; i3++) {
        x_plus_b_sq.a[i3] <== x_plus_b.out[i3];
    }
    for (var i4 = 0; i4 < 3; i4++) {
        d_tmp.a[i4] <== x_plus_b_sq.out[i4];
        d_tmp.b[i4] <== a.out[i4];
    }
    component d_tmp2 = FpSub();
    for (var i5 = 0; i5 < 3; i5++) {
        d_tmp2.a[i5] <== d_tmp.out[i5];
        d_tmp2.b[i5] <== c.out[i5];
    }
    for (var i6 = 0; i6 < 3; i6++) {
        d.a[i6] <== two.out[i6];
        d.b[i6] <== d_tmp2.out[i6];
    }
    component e_plus = FpAdd();
    for (var i7 = 0; i7 < 3; i7++) {
        e_plus.a[i7] <== e.out[i7];
        e_plus.b[i7] <== a.out[i7];
    }
    for (var i8 = 0; i8 < 3; i8++) {
        f.a[i8] <== e_plus.out[i8];
        t.a[i8] <== two.out[i8];
        t.b[i8] <== d.out[i8];
    }
    component x3 = FpSub();
    for (var i6 = 0; i6 < 3; i6++) {
        x3.a[i6] <== f.out[i6];
        x3.b[i6] <== t.out[i6];
    }
    component d_minus_x3 = FpSub();
    for (var i7 = 0; i7 < 3; i7++) {
        d_minus_x3.a[i7] <== d.out[i7];
        d_minus_x3.b[i7] <== x3.out[i7];
    }
    component y3_mul = FpMul();
    for (var i8 = 0; i8 < 3; i8++) {
        y3_mul.a[i8] <== e_plus.out[i8];
        y3_mul.b[i8] <== d_minus_x3.out[i8];
    }
    component c_mul = FpMul();
    for (var i9 = 0; i9 < 3; i9++) {
        c_mul.a[i9] <== eight.out[i9];
        c_mul.b[i9] <== c.out[i9];
    }
    component y3 = FpSub();
    for (var i10 = 0; i10 < 3; i10++) {
        y3.a[i10] <== y3_mul.out[i10];
        y3.b[i10] <== c_mul.out[i10];
    }
    component z3 = FpMul();
    for (var i11 = 0; i11 < 3; i11++) {
        z3.a[i11] <== two.out[i11];
        z3.b[i11] <== p[1][i11];
    }
    component z3_mul = FpMul();
    for (var i12 = 0; i12 < 3; i12++) {
        z3_mul.a[i12] <== z3.out[i12];
        z3_mul.b[i12] <== p[2][i12];
    }

    for (var i13 = 0; i13 < 3; i13++) {
        out[0][i13] <== x3.out[i13];
        out[1][i13] <== y3.out[i13];
        out[2][i13] <== z3_mul.out[i13];
    }
}

template G1AddJac() {
    signal input p[3][3];
    signal input q[3][3];
    signal output out[3][3];

    component pInf = G1JacIsInfinity();
    component qInf = G1JacIsInfinity();
    for (var i = 0; i < 3; i++) {
        pInf.p[i] <== p[i];
        qInf.p[i] <== q[i];
    }

    component z1z1 = FpSquare();
    component z2z2 = FpSquare();
    for (var i2 = 0; i2 < 3; i2++) {
        z1z1.a[i2] <== q[2][i2];
        z2z2.a[i2] <== p[2][i2];
    }
    component u1 = FpMul();
    component u2 = FpMul();
    for (var i3 = 0; i3 < 3; i3++) {
        u1.a[i3] <== q[0][i3];
        u1.b[i3] <== z2z2.out[i3];
        u2.a[i3] <== p[0][i3];
        u2.b[i3] <== z1z1.out[i3];
    }
    component s1 = FpMul();
    component s2 = FpMul();
    component pz_mul = FpMul();
    component qz_mul = FpMul();
    for (var i4 = 0; i4 < 3; i4++) {
        pz_mul.a[i4] <== q[1][i4];
        pz_mul.b[i4] <== p[2][i4];
        qz_mul.a[i4] <== p[1][i4];
        qz_mul.b[i4] <== q[2][i4];
    }
    for (var i5 = 0; i5 < 3; i5++) {
        s1.a[i5] <== pz_mul.out[i5];
        s1.b[i5] <== z2z2.out[i5];
        s2.a[i5] <== qz_mul.out[i5];
        s2.b[i5] <== z1z1.out[i5];
    }

    component sameU = FpEq();
    component sameS = FpEq();
    for (var i6 = 0; i6 < 3; i6++) {
        sameU.a[i6] <== u1.out[i6];
        sameU.b[i6] <== u2.out[i6];
        sameS.a[i6] <== s1.out[i6];
        sameS.b[i6] <== s2.out[i6];
    }
    signal same;
    same <== sameU.out * sameS.out;
    same * (same - 1) === 0;

    component h = FpSub();
    for (var i7 = 0; i7 < 3; i7++) {
        h.a[i7] <== u2.out[i7];
        h.b[i7] <== u1.out[i7];
    }
    component i_mul = FpMul();
    component two = FpTwo();
    for (var i8 = 0; i8 < 3; i8++) {
        i_mul.a[i8] <== two.out[i8];
        i_mul.b[i8] <== h.out[i8];
    }
    component i_sq = FpSquare();
    for (var i9 = 0; i9 < 3; i9++) {
        i_sq.a[i9] <== i_mul.out[i9];
    }
    component j = FpMul();
    for (var i10 = 0; i10 < 3; i10++) {
        j.a[i10] <== h.out[i10];
        j.b[i10] <== i_sq.out[i10];
    }
    component r = FpSub();
    for (var i11 = 0; i11 < 3; i11++) {
        r.a[i11] <== s2.out[i11];
        r.b[i11] <== s1.out[i11];
    }
    component r2 = FpMul();
    for (var i12 = 0; i12 < 3; i12++) {
        r2.a[i12] <== two.out[i12];
        r2.b[i12] <== r.out[i12];
    }
    component v = FpMul();
    for (var i13 = 0; i13 < 3; i13++) {
        v.a[i13] <== u1.out[i13];
        v.b[i13] <== i_sq.out[i13];
    }
    component r_sq = FpSquare();
    for (var i14 = 0; i14 < 3; i14++) {
        r_sq.a[i14] <== r2.out[i14];
    }
    component x3_tmp = FpSub();
    for (var i15 = 0; i15 < 3; i15++) {
        x3_tmp.a[i15] <== r_sq.out[i15];
        x3_tmp.b[i15] <== j.out[i15];
    }
    component v2 = FpMul();
    for (var i16 = 0; i16 < 3; i16++) {
        v2.a[i16] <== two.out[i16];
        v2.b[i16] <== v.out[i16];
    }
    component x3 = FpSub();
    for (var i17 = 0; i17 < 3; i17++) {
        x3.a[i17] <== x3_tmp.out[i17];
        x3.b[i17] <== v2.out[i17];
    }
    component v_minus_x3 = FpSub();
    for (var i18 = 0; i18 < 3; i18++) {
        v_minus_x3.a[i18] <== v.out[i18];
        v_minus_x3.b[i18] <== x3.out[i18];
    }
    component y3_mul = FpMul();
    for (var i19 = 0; i19 < 3; i19++) {
        y3_mul.a[i19] <== r2.out[i19];
        y3_mul.b[i19] <== v_minus_x3.out[i19];
    }
    component s1j = FpMul();
    for (var i20 = 0; i20 < 3; i20++) {
        s1j.a[i20] <== s1.out[i20];
        s1j.b[i20] <== j.out[i20];
    }
    component s1j2 = FpMul();
    for (var i21 = 0; i21 < 3; i21++) {
        s1j2.a[i21] <== two.out[i21];
        s1j2.b[i21] <== s1j.out[i21];
    }
    component y3 = FpSub();
    for (var i22 = 0; i22 < 3; i22++) {
        y3.a[i22] <== y3_mul.out[i22];
        y3.b[i22] <== s1j2.out[i22];
    }
    component z3_sum = FpAdd();
    for (var i23 = 0; i23 < 3; i23++) {
        z3_sum.a[i23] <== p[2][i23];
        z3_sum.b[i23] <== q[2][i23];
    }
    component z3_sum_sq = FpSquare();
    for (var i24 = 0; i24 < 3; i24++) {
        z3_sum_sq.a[i24] <== z3_sum.out[i24];
    }
    component z3_tmp = FpSub();
    for (var i25 = 0; i25 < 3; i25++) {
        z3_tmp.a[i25] <== z3_sum_sq.out[i25];
        z3_tmp.b[i25] <== z1z1.out[i25];
    }
    component z3_tmp2 = FpSub();
    for (var i26 = 0; i26 < 3; i26++) {
        z3_tmp2.a[i26] <== z3_tmp.out[i26];
        z3_tmp2.b[i26] <== z2z2.out[i26];
    }
    component z3 = FpMul();
    for (var i27 = 0; i27 < 3; i27++) {
        z3.a[i27] <== z3_tmp2.out[i27];
        z3.b[i27] <== h.out[i27];
    }

    component dbl = G1DoubleJac();
    for (var i28 = 0; i28 < 3; i28++) {
        dbl.p[i28] <== p[i28];
    }

    signal caseP;
    signal caseQ;
    signal caseDbl;
    signal caseAdd;
    caseP <== pInf.out;
    signal notP;
    signal notQ;
    signal nonInf;
    notP <== 1 - caseP;
    notQ <== 1 - qInf.out;
    nonInf <== notP * notQ;
    caseQ <== notP * qInf.out;
    caseDbl <== nonInf * same;
    caseAdd <== nonInf * (1 - same);
    caseP * (caseP - 1) === 0;
    caseQ * (caseQ - 1) === 0;
    caseDbl * (caseDbl - 1) === 0;
    caseAdd * (caseAdd - 1) === 0;
    caseP + caseQ + caseDbl + caseAdd === 1;

    signal sel0x[3];
    signal sel1x[3];
    signal sel0y[3];
    signal sel1y[3];
    signal sel0z[3];
    signal sel1z[3];
    for (var k = 0; k < 3; k++) {
        sel0x[k] <== p[0][k] + caseP * (q[0][k] - p[0][k]);
        sel1x[k] <== sel0x[k] + caseDbl * (dbl.out[0][k] - sel0x[k]);
        out[0][k] <== sel1x[k] + caseAdd * (x3.out[k] - sel1x[k]);

        sel0y[k] <== p[1][k] + caseP * (q[1][k] - p[1][k]);
        sel1y[k] <== sel0y[k] + caseDbl * (dbl.out[1][k] - sel0y[k]);
        out[1][k] <== sel1y[k] + caseAdd * (y3.out[k] - sel1y[k]);

        sel0z[k] <== p[2][k] + caseP * (q[2][k] - p[2][k]);
        sel1z[k] <== sel0z[k] + caseDbl * (dbl.out[2][k] - sel0z[k]);
        out[2][k] <== sel1z[k] + caseAdd * (z3.out[k] - sel1z[k]);
    }
}

template G1AddJacMixed() {
    signal input p[3][3];
    signal input q[2][3];
    signal output out[3][3];

    component pInf = G1JacIsInfinity();
    component qInf = G1AffineIsInfinity();
    for (var i = 0; i < 3; i++) {
        pInf.p[i] <== p[i];
        if (i < 2) {
            qInf.p[i][0] <== q[i][0];
            qInf.p[i][1] <== q[i][1];
            qInf.p[i][2] <== q[i][2];
        }
    }

    component z2z2 = FpSquare();
    for (var i2 = 0; i2 < 3; i2++) {
        z2z2.a[i2] <== p[2][i2];
    }
    component u1 = FpMul();
    for (var i3 = 0; i3 < 3; i3++) {
        u1.a[i3] <== q[0][i3];
        u1.b[i3] <== z2z2.out[i3];
    }
    component s1 = FpMul();
    component pz_mul = FpMul();
    for (var i4 = 0; i4 < 3; i4++) {
        pz_mul.a[i4] <== q[1][i4];
        pz_mul.b[i4] <== p[2][i4];
    }
    for (var i5 = 0; i5 < 3; i5++) {
        s1.a[i5] <== pz_mul.out[i5];
        s1.b[i5] <== z2z2.out[i5];
    }
    component sameU = FpEq();
    component sameS = FpEq();
    for (var i6 = 0; i6 < 3; i6++) {
        sameU.a[i6] <== u1.out[i6];
        sameU.b[i6] <== p[0][i6];
        sameS.a[i6] <== s1.out[i6];
        sameS.b[i6] <== p[1][i6];
    }
    signal same;
    same <== sameU.out * sameS.out;
    same * (same - 1) === 0;

    component h = FpSub();
    for (var i7 = 0; i7 < 3; i7++) {
        h.a[i7] <== p[0][i7];
        h.b[i7] <== u1.out[i7];
    }
    component i_mul = FpMul();
    component two = FpTwo();
    for (var i8 = 0; i8 < 3; i8++) {
        i_mul.a[i8] <== two.out[i8];
        i_mul.b[i8] <== h.out[i8];
    }
    component i_sq = FpSquare();
    for (var i9 = 0; i9 < 3; i9++) {
        i_sq.a[i9] <== i_mul.out[i9];
    }
    component j = FpMul();
    for (var i10 = 0; i10 < 3; i10++) {
        j.a[i10] <== h.out[i10];
        j.b[i10] <== i_sq.out[i10];
    }
    component r = FpSub();
    for (var i11 = 0; i11 < 3; i11++) {
        r.a[i11] <== p[1][i11];
        r.b[i11] <== s1.out[i11];
    }
    component r2 = FpMul();
    for (var i12 = 0; i12 < 3; i12++) {
        r2.a[i12] <== two.out[i12];
        r2.b[i12] <== r.out[i12];
    }
    component v = FpMul();
    for (var i13 = 0; i13 < 3; i13++) {
        v.a[i13] <== u1.out[i13];
        v.b[i13] <== i_sq.out[i13];
    }
    component r_sq = FpSquare();
    for (var i14 = 0; i14 < 3; i14++) {
        r_sq.a[i14] <== r2.out[i14];
    }
    component x3_tmp = FpSub();
    for (var i15 = 0; i15 < 3; i15++) {
        x3_tmp.a[i15] <== r_sq.out[i15];
        x3_tmp.b[i15] <== j.out[i15];
    }
    component v2 = FpMul();
    for (var i16 = 0; i16 < 3; i16++) {
        v2.a[i16] <== two.out[i16];
        v2.b[i16] <== v.out[i16];
    }
    component x3 = FpSub();
    for (var i17 = 0; i17 < 3; i17++) {
        x3.a[i17] <== x3_tmp.out[i17];
        x3.b[i17] <== v2.out[i17];
    }
    component v_minus_x3 = FpSub();
    for (var i18 = 0; i18 < 3; i18++) {
        v_minus_x3.a[i18] <== v.out[i18];
        v_minus_x3.b[i18] <== x3.out[i18];
    }
    component y3_mul = FpMul();
    for (var i19 = 0; i19 < 3; i19++) {
        y3_mul.a[i19] <== r2.out[i19];
        y3_mul.b[i19] <== v_minus_x3.out[i19];
    }
    component s1j = FpMul();
    for (var i20 = 0; i20 < 3; i20++) {
        s1j.a[i20] <== s1.out[i20];
        s1j.b[i20] <== j.out[i20];
    }
    component s1j2 = FpMul();
    for (var i21 = 0; i21 < 3; i21++) {
        s1j2.a[i21] <== two.out[i21];
        s1j2.b[i21] <== s1j.out[i21];
    }
    component y3 = FpSub();
    for (var i22 = 0; i22 < 3; i22++) {
        y3.a[i22] <== y3_mul.out[i22];
        y3.b[i22] <== s1j2.out[i22];
    }
    component z3_sum = FpAdd();
    for (var i23 = 0; i23 < 3; i23++) {
        z3_sum.a[i23] <== p[2][i23];
        z3_sum.b[i23] <== h.out[i23];
    }
    component z3_sum_sq = FpSquare();
    for (var i24 = 0; i24 < 3; i24++) {
        z3_sum_sq.a[i24] <== z3_sum.out[i24];
    }
    component h_sq = FpSquare();
    for (var i25 = 0; i25 < 3; i25++) {
        h_sq.a[i25] <== h.out[i25];
    }
    component z3_tmp = FpSub();
    for (var i26 = 0; i26 < 3; i26++) {
        z3_tmp.a[i26] <== z3_sum_sq.out[i26];
        z3_tmp.b[i26] <== z2z2.out[i26];
    }
    component z3 = FpSub();
    for (var i27 = 0; i27 < 3; i27++) {
        z3.a[i27] <== z3_tmp.out[i27];
        z3.b[i27] <== h_sq.out[i27];
    }

    component dbl = G1DoubleJac();
    for (var i28 = 0; i28 < 3; i28++) {
        dbl.p[i28] <== p[i28];
    }

    component one = FpOne();
    component zero = FpZero();
    signal qjac[3][3];
    for (var i29 = 0; i29 < 3; i29++) {
        qjac[0][i29] <== q[0][i29];
        qjac[1][i29] <== q[1][i29];
        qjac[2][i29] <== one.out[i29];
    }

    component inf = G1JacobianInfinity();

    signal caseInf;
    signal caseQ;
    signal casePOnly;
    signal caseDbl;
    signal caseAdd;
    caseInf <== pInf.out * qInf.out;
    caseQ <== pInf.out * (1 - qInf.out);
    casePOnly <== (1 - pInf.out) * qInf.out;
    caseDbl <== (1 - pInf.out) * (1 - qInf.out) * same;
    caseAdd <== (1 - pInf.out) * (1 - qInf.out) * (1 - same);
    caseInf * (caseInf - 1) === 0;
    caseQ * (caseQ - 1) === 0;
    casePOnly * (casePOnly - 1) === 0;
    caseDbl * (caseDbl - 1) === 0;
    caseAdd * (caseAdd - 1) === 0;
    caseInf + caseQ + casePOnly + caseDbl + caseAdd === 1;

    for (var k = 0; k < 3; k++) {
        out[0][k] <== caseInf * inf.out[0][k] + caseQ * qjac[0][k] + casePOnly * p[0][k] + caseDbl * dbl.out[0][k] + caseAdd * x3.out[k];
        out[1][k] <== caseInf * inf.out[1][k] + caseQ * qjac[1][k] + casePOnly * p[1][k] + caseDbl * dbl.out[1][k] + caseAdd * y3.out[k];
        out[2][k] <== caseInf * inf.out[2][k] + caseQ * qjac[2][k] + casePOnly * p[2][k] + caseDbl * dbl.out[2][k] + caseAdd * z3.out[k];
    }
}

template G1JacobianToAffine() {
    signal input p[3][3];
    signal input inv_z[3];
    signal input enable;
    signal output out[2][3];

    enable * (enable - 1) === 0;

    component zZero = FpIsZero();
    for (var i = 0; i < 3; i++) {
        zZero.a[i] <== p[2][i];
    }
    component mul = FpMul();
    for (var i2 = 0; i2 < 3; i2++) {
        mul.a[i2] <== p[2][i2];
        mul.b[i2] <== inv_z[i2];
    }
    component one = FpOne();
    component zero = FpZero();
    component expect = FpSelect();
    for (var i3 = 0; i3 < 3; i3++) {
        expect.a[i3] <== zero.out[i3];
        expect.b[i3] <== one.out[i3];
    }
    expect.sel <== zZero.out;
    for (var i4 = 0; i4 < 3; i4++) {
        enable * (mul.out[i4] - expect.out[i4]) === 0;
    }

    component invSq = FpSquare();
    for (var i5 = 0; i5 < 3; i5++) {
        invSq.a[i5] <== inv_z[i5];
    }
    component xMul = FpMul();
    for (var i6 = 0; i6 < 3; i6++) {
        xMul.a[i6] <== p[0][i6];
        xMul.b[i6] <== invSq.out[i6];
    }
    component yMul = FpMul();
    for (var i7 = 0; i7 < 3; i7++) {
        yMul.a[i7] <== p[1][i7];
        yMul.b[i7] <== invSq.out[i7];
    }
    component yMul2 = FpMul();
    for (var i8 = 0; i8 < 3; i8++) {
        yMul2.a[i8] <== yMul.out[i8];
        yMul2.b[i8] <== inv_z[i8];
    }

    component selX = FpSelect();
    component selY = FpSelect();
    for (var i9 = 0; i9 < 3; i9++) {
        selX.a[i9] <== zero.out[i9];
        selX.b[i9] <== xMul.out[i9];
        selY.a[i9] <== zero.out[i9];
        selY.b[i9] <== yMul2.out[i9];
    }
    selX.sel <== zZero.out;
    selY.sel <== zZero.out;
    for (var i10 = 0; i10 < 3; i10++) {
        out[0][i10] <== selX.out[i10];
        out[1][i10] <== selY.out[i10];
    }
}

template G1AddAffine() {
    signal input a[2][3];
    signal input b[2][3];
    signal input inv_add_z[3];
    signal input inv_double_z[3];
    signal output out[2][3];

    component aInf = G1AffineIsInfinity();
    component bInf = G1AffineIsInfinity();
    for (var i = 0; i < 3; i++) {
        aInf.p[0][i] <== a[0][i];
        aInf.p[1][i] <== a[1][i];
        bInf.p[0][i] <== b[0][i];
        bInf.p[1][i] <== b[1][i];
    }
    component eqX = FpEq();
    component eqY = FpEq();
    for (var i2 = 0; i2 < 3; i2++) {
        eqX.a[i2] <== a[0][i2];
        eqX.b[i2] <== b[0][i2];
        eqY.a[i2] <== a[1][i2];
        eqY.b[i2] <== b[1][i2];
    }
    signal same;
    signal diffY;
    signal notSameX;
    same <== eqX.out * eqY.out;
    same * (same - 1) === 0;
    diffY <== eqX.out * (1 - eqY.out);
    diffY * (diffY - 1) === 0;
    notSameX <== 1 - eqX.out;

    component h = FpSub();
    component hh = FpSquare();
    component i_mul = FpMul();
    component j = FpMul();
    component r_tmp = FpSub();
    component r = FpMul();
    component v = FpMul();
    component two = FpTwo();
    component four = FpFour();

    for (var i3 = 0; i3 < 3; i3++) {
        h.a[i3] <== b[0][i3];
        h.b[i3] <== a[0][i3];
        r_tmp.a[i3] <== b[1][i3];
        r_tmp.b[i3] <== a[1][i3];
    }
    for (var i4 = 0; i4 < 3; i4++) {
        hh.a[i4] <== h.out[i4];
    }
    for (var i5 = 0; i5 < 3; i5++) {
        i_mul.a[i5] <== four.out[i5];
        i_mul.b[i5] <== hh.out[i5];
    }
    for (var i6 = 0; i6 < 3; i6++) {
        j.a[i6] <== h.out[i6];
        j.b[i6] <== i_mul.out[i6];
        r.a[i6] <== two.out[i6];
        r.b[i6] <== r_tmp.out[i6];
        v.a[i6] <== a[0][i6];
        v.b[i6] <== i_mul.out[i6];
    }
    component r_sq = FpSquare();
    for (var i7 = 0; i7 < 3; i7++) {
        r_sq.a[i7] <== r.out[i7];
    }
    component x3_tmp = FpSub();
    for (var i8 = 0; i8 < 3; i8++) {
        x3_tmp.a[i8] <== r_sq.out[i8];
        x3_tmp.b[i8] <== j.out[i8];
    }
    component v2 = FpMul();
    for (var i9 = 0; i9 < 3; i9++) {
        v2.a[i9] <== two.out[i9];
        v2.b[i9] <== v.out[i9];
    }
    component x3 = FpSub();
    for (var i10 = 0; i10 < 3; i10++) {
        x3.a[i10] <== x3_tmp.out[i10];
        x3.b[i10] <== v2.out[i10];
    }
    component v_minus_x3 = FpSub();
    for (var i11 = 0; i11 < 3; i11++) {
        v_minus_x3.a[i11] <== v.out[i11];
        v_minus_x3.b[i11] <== x3.out[i11];
    }
    component y3_mul = FpMul();
    for (var i12 = 0; i12 < 3; i12++) {
        y3_mul.a[i12] <== r.out[i12];
        y3_mul.b[i12] <== v_minus_x3.out[i12];
    }
    component ayj = FpMul();
    for (var i13 = 0; i13 < 3; i13++) {
        ayj.a[i13] <== a[1][i13];
        ayj.b[i13] <== j.out[i13];
    }
    component ayj2 = FpMul();
    for (var i14 = 0; i14 < 3; i14++) {
        ayj2.a[i14] <== two.out[i14];
        ayj2.b[i14] <== ayj.out[i14];
    }
    component y3 = FpSub();
    for (var i15 = 0; i15 < 3; i15++) {
        y3.a[i15] <== y3_mul.out[i15];
        y3.b[i15] <== ayj2.out[i15];
    }
    component z3 = FpMul();
    for (var i16 = 0; i16 < 3; i16++) {
        z3.a[i16] <== two.out[i16];
        z3.b[i16] <== h.out[i16];
    }

    signal addJac[3][3];
    for (var i16 = 0; i16 < 3; i16++) {
        addJac[0][i16] <== x3.out[i16];
        addJac[1][i16] <== y3.out[i16];
        addJac[2][i16] <== z3.out[i16];
    }

    signal notAInf;
    signal notBInf;
    notAInf <== 1 - aInf.out;
    notBInf <== 1 - bInf.out;
    signal addEnableTmp;
    signal dblEnableTmp;
    component addAff = G1JacobianToAffine();
    addEnableTmp <== notSameX * notAInf;
    addAff.enable <== addEnableTmp * notBInf;
    for (var i17 = 0; i17 < 3; i17++) {
        addAff.p[0][i17] <== addJac[0][i17];
        addAff.p[1][i17] <== addJac[1][i17];
        addAff.p[2][i17] <== addJac[2][i17];
        addAff.inv_z[i17] <== inv_add_z[i17];
    }

    component dblJac = G1DoubleMixed();
    for (var i18 = 0; i18 < 3; i18++) {
        dblJac.a[0][i18] <== a[0][i18];
        dblJac.a[1][i18] <== a[1][i18];
    }
    component dblAff = G1JacobianToAffine();
    dblEnableTmp <== same * notAInf;
    dblAff.enable <== dblEnableTmp * notBInf;
    for (var i19 = 0; i19 < 3; i19++) {
        dblAff.p[0][i19] <== dblJac.out[0][i19];
        dblAff.p[1][i19] <== dblJac.out[1][i19];
        dblAff.p[2][i19] <== dblJac.out[2][i19];
        dblAff.inv_z[i19] <== inv_double_z[i19];
    }

    component inf = G1AffineInfinity();

    signal caseA;
    signal caseB;
    signal caseSame;
    signal caseInf;
    signal caseAdd;
    caseA <== aInf.out;
    signal nonInf;
    nonInf <== notAInf * notBInf;
    caseB <== notAInf * bInf.out;
    caseSame <== nonInf * same;
    caseInf <== nonInf * diffY;
    caseAdd <== nonInf * notSameX;
    caseA * (caseA - 1) === 0;
    caseB * (caseB - 1) === 0;
    caseSame * (caseSame - 1) === 0;
    caseInf * (caseInf - 1) === 0;
    caseAdd * (caseAdd - 1) === 0;
    caseA + caseB + caseSame + caseInf + caseAdd === 1;

    signal sel0x[3];
    signal sel1x[3];
    signal sel2x[3];
    signal sel0y[3];
    signal sel1y[3];
    signal sel2y[3];
    for (var k = 0; k < 3; k++) {
        sel0x[k] <== a[0][k] + caseA * (b[0][k] - a[0][k]);
        sel1x[k] <== sel0x[k] + caseSame * (dblAff.out[0][k] - sel0x[k]);
        sel2x[k] <== sel1x[k] + caseInf * (inf.out[0][k] - sel1x[k]);
        out[0][k] <== sel2x[k] + caseAdd * (addAff.out[0][k] - sel2x[k]);

        sel0y[k] <== a[1][k] + caseA * (b[1][k] - a[1][k]);
        sel1y[k] <== sel0y[k] + caseSame * (dblAff.out[1][k] - sel0y[k]);
        sel2y[k] <== sel1y[k] + caseInf * (inf.out[1][k] - sel1y[k]);
        out[1][k] <== sel2y[k] + caseAdd * (addAff.out[1][k] - sel2y[k]);
    }
}
