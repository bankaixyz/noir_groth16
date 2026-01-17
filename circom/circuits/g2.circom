pragma circom 2.0.0;

include "./fp2.circom";
include "./fp.circom";

template Fp2Eq() {
    signal input a[2];
    signal input b[2];
    signal output out;

    component eq0 = FpEq();
    component eq1 = FpEq();
    eq0.a <== a[0];
    eq0.b <== b[0];
    eq1.a <== a[1];
    eq1.b <== b[1];
    out <== eq0.out * eq1.out;
    out * (out - 1) === 0;
}

template Fp2IsZero() {
    signal input a[2];
    signal output out;

    component z0 = FpIsZero();
    component z1 = FpIsZero();
    z0.a <== a[0];
    z1.a <== a[1];
    out <== z0.out * z1.out;
    out * (out - 1) === 0;
}

template Fp2Select() {
    signal input a[2];
    signal input b[2];
    signal input sel;
    signal output out[2];

    sel * (sel - 1) === 0;
    component sel0 = FpSelect();
    component sel1 = FpSelect();
    sel0.a <== a[0];
    sel0.b <== b[0];
    sel1.a <== a[1];
    sel1.b <== b[1];
    sel0.sel <== sel;
    sel1.sel <== sel;
    out[0] <== sel0.out;
    out[1] <== sel1.out;
}

template G2AffineInfinity() {
    signal output out[2][2];

    component zero = Fp2Zero();
    for (var i = 0; i < 2; i++) {
        out[0][i] <== zero.out[i];
        out[1][i] <== zero.out[i];
    }
}

template G2JacobianInfinity() {
    signal output out[3][2];

    component one = Fp2One();
    component zero = Fp2Zero();
    for (var i = 0; i < 2; i++) {
        out[0][i] <== one.out[i];
        out[1][i] <== one.out[i];
        out[2][i] <== zero.out[i];
    }
}

template G2AffineIsInfinity() {
    signal input p[2][2];
    signal output out;

    component xZero = Fp2IsZero();
    component yZero = Fp2IsZero();
    for (var i = 0; i < 2; i++) {
        xZero.a[i] <== p[0][i];
        yZero.a[i] <== p[1][i];
    }
    out <== xZero.out * yZero.out;
    out * (out - 1) === 0;
}

template G2JacIsInfinity() {
    signal input p[3][2];
    signal output out;

    component zZero = Fp2IsZero();
    for (var i = 0; i < 2; i++) {
        zZero.a[i] <== p[2][i];
    }
    out <== zZero.out;
    out * (out - 1) === 0;
}

template G2IsOnCurveAffine() {
    signal input p[2][2];
    signal output out;

    component ySq = Fp2Square();
    component xSq = Fp2Square();
    component xCub = Fp2Mul();
    component b = Fp2BTwist();
    component rhs = Fp2Add();
    component eq = Fp2Eq();
    component isInf = G2AffineIsInfinity();

    for (var i = 0; i < 2; i++) {
        ySq.a[i] <== p[1][i];
        xSq.a[i] <== p[0][i];
        isInf.p[0][i] <== p[0][i];
        isInf.p[1][i] <== p[1][i];
    }
    for (var i2 = 0; i2 < 2; i2++) {
        xCub.a[i2] <== xSq.out[i2];
        xCub.b[i2] <== p[0][i2];
        rhs.a[i2] <== xCub.out[i2];
        rhs.b[i2] <== b.out[i2];
        eq.a[i2] <== ySq.out[i2];
        eq.b[i2] <== rhs.out[i2];
    }

    out <== isInf.out + (1 - isInf.out) * eq.out;
    out * (out - 1) === 0;
}

template G2NegAffine() {
    signal input p[2][2];
    signal output out[2][2];

    component neg = Fp2Neg();
    for (var i = 0; i < 2; i++) {
        neg.a[i] <== p[1][i];
    }
    for (var i2 = 0; i2 < 2; i2++) {
        out[0][i2] <== p[0][i2];
        out[1][i2] <== neg.out[i2];
    }
}

template G2JacobianToAffine() {
    signal input p[3][2];
    signal input inv_z[2];
    signal input enable;
    signal output out[2][2];

    enable * (enable - 1) === 0;

    component zZero = Fp2IsZero();
    for (var i = 0; i < 2; i++) {
        zZero.a[i] <== p[2][i];
    }
    component mul = Fp2Mul();
    for (var i2 = 0; i2 < 2; i2++) {
        mul.a[i2] <== p[2][i2];
        mul.b[i2] <== inv_z[i2];
    }
    component one = Fp2One();
    component zero = Fp2Zero();
    component expect = Fp2Select();
    for (var i3 = 0; i3 < 2; i3++) {
        expect.a[i3] <== zero.out[i3];
        expect.b[i3] <== one.out[i3];
    }
    expect.sel <== zZero.out;
    for (var i4 = 0; i4 < 2; i4++) {
        enable * (mul.out[i4] - expect.out[i4]) === 0;
    }

    component invSq = Fp2Square();
    for (var i5 = 0; i5 < 2; i5++) {
        invSq.a[i5] <== inv_z[i5];
    }
    component xMul = Fp2Mul();
    component yMul = Fp2Mul();
    for (var i6 = 0; i6 < 2; i6++) {
        xMul.a[i6] <== p[0][i6];
        xMul.b[i6] <== invSq.out[i6];
        yMul.a[i6] <== p[1][i6];
        yMul.b[i6] <== invSq.out[i6];
    }
    component yMul2 = Fp2Mul();
    for (var i7 = 0; i7 < 2; i7++) {
        yMul2.a[i7] <== yMul.out[i7];
        yMul2.b[i7] <== inv_z[i7];
    }

    component selX = Fp2Select();
    component selY = Fp2Select();
    for (var i8 = 0; i8 < 2; i8++) {
        selX.a[i8] <== zero.out[i8];
        selX.b[i8] <== xMul.out[i8];
        selY.a[i8] <== zero.out[i8];
        selY.b[i8] <== yMul2.out[i8];
    }
    selX.sel <== zZero.out;
    selY.sel <== zZero.out;
    for (var i9 = 0; i9 < 2; i9++) {
        out[0][i9] <== selX.out[i9];
        out[1][i9] <== selY.out[i9];
    }
}

template G2AddJac() {
    signal input p[3][2];
    signal input q[3][2];
    signal output out[3][2];

    component pInf = G2JacIsInfinity();
    component qInf = G2JacIsInfinity();
    for (var c = 0; c < 3; c++) {
        for (var i = 0; i < 2; i++) {
            pInf.p[c][i] <== p[c][i];
            qInf.p[c][i] <== q[c][i];
        }
    }

    component z1z1 = Fp2Square();
    component z2z2 = Fp2Square();
    for (var i2 = 0; i2 < 2; i2++) {
        z1z1.a[i2] <== q[2][i2];
        z2z2.a[i2] <== p[2][i2];
    }
    component u1 = Fp2Mul();
    component u2 = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        u1.a[i3] <== q[0][i3];
        u1.b[i3] <== z2z2.out[i3];
        u2.a[i3] <== p[0][i3];
        u2.b[i3] <== z1z1.out[i3];
    }
    component s1 = Fp2Mul();
    component s2 = Fp2Mul();
    component pz_mul = Fp2Mul();
    component qz_mul = Fp2Mul();
    for (var i4 = 0; i4 < 2; i4++) {
        pz_mul.a[i4] <== q[1][i4];
        pz_mul.b[i4] <== p[2][i4];
        qz_mul.a[i4] <== p[1][i4];
        qz_mul.b[i4] <== q[2][i4];
        s1.a[i4] <== pz_mul.out[i4];
        s1.b[i4] <== z2z2.out[i4];
        s2.a[i4] <== qz_mul.out[i4];
        s2.b[i4] <== z1z1.out[i4];
    }

    component sameU = Fp2Eq();
    component sameS = Fp2Eq();
    for (var i5 = 0; i5 < 2; i5++) {
        sameU.a[i5] <== u1.out[i5];
        sameU.b[i5] <== u2.out[i5];
        sameS.a[i5] <== s1.out[i5];
        sameS.b[i5] <== s2.out[i5];
    }
    signal same;
    same <== sameU.out * sameS.out;
    same * (same - 1) === 0;

    component h = Fp2Sub();
    for (var i6 = 0; i6 < 2; i6++) {
        h.a[i6] <== u2.out[i6];
        h.b[i6] <== u1.out[i6];
    }
    component h_dbl = Fp2Double();
    for (var i7 = 0; i7 < 2; i7++) {
        h_dbl.a[i7] <== h.out[i7];
    }
    component i_sq = Fp2Square();
    for (var i8 = 0; i8 < 2; i8++) {
        i_sq.a[i8] <== h_dbl.out[i8];
    }
    component j = Fp2Mul();
    for (var i9 = 0; i9 < 2; i9++) {
        j.a[i9] <== h.out[i9];
        j.b[i9] <== i_sq.out[i9];
    }
    component r = Fp2Sub();
    for (var i10 = 0; i10 < 2; i10++) {
        r.a[i10] <== s2.out[i10];
        r.b[i10] <== s1.out[i10];
    }
    component r_dbl = Fp2Double();
    for (var i11 = 0; i11 < 2; i11++) {
        r_dbl.a[i11] <== r.out[i11];
    }
    component v = Fp2Mul();
    for (var i12 = 0; i12 < 2; i12++) {
        v.a[i12] <== u1.out[i12];
        v.b[i12] <== i_sq.out[i12];
    }
    component r_sq = Fp2Square();
    for (var i13 = 0; i13 < 2; i13++) {
        r_sq.a[i13] <== r_dbl.out[i13];
    }
    component x3_tmp = Fp2Sub();
    for (var i14 = 0; i14 < 2; i14++) {
        x3_tmp.a[i14] <== r_sq.out[i14];
        x3_tmp.b[i14] <== j.out[i14];
    }
    component v_dbl = Fp2Double();
    for (var i15 = 0; i15 < 2; i15++) {
        v_dbl.a[i15] <== v.out[i15];
    }
    component x3 = Fp2Sub();
    for (var i16 = 0; i16 < 2; i16++) {
        x3.a[i16] <== x3_tmp.out[i16];
        x3.b[i16] <== v_dbl.out[i16];
    }
    component v_minus_x3 = Fp2Sub();
    for (var i17 = 0; i17 < 2; i17++) {
        v_minus_x3.a[i17] <== v.out[i17];
        v_minus_x3.b[i17] <== x3.out[i17];
    }
    component y3_mul = Fp2Mul();
    for (var i18 = 0; i18 < 2; i18++) {
        y3_mul.a[i18] <== r_dbl.out[i18];
        y3_mul.b[i18] <== v_minus_x3.out[i18];
    }
    component s1_dbl = Fp2Double();
    for (var i19 = 0; i19 < 2; i19++) {
        s1_dbl.a[i19] <== s1.out[i19];
    }
    component s1j = Fp2Mul();
    for (var i20 = 0; i20 < 2; i20++) {
        s1j.a[i20] <== s1_dbl.out[i20];
        s1j.b[i20] <== j.out[i20];
    }
    component y3 = Fp2Sub();
    for (var i21 = 0; i21 < 2; i21++) {
        y3.a[i21] <== y3_mul.out[i21];
        y3.b[i21] <== s1j.out[i21];
    }
    component z3_sum = Fp2Add();
    for (var i22 = 0; i22 < 2; i22++) {
        z3_sum.a[i22] <== p[2][i22];
        z3_sum.b[i22] <== q[2][i22];
    }
    component z3_sum_sq = Fp2Square();
    for (var i23 = 0; i23 < 2; i23++) {
        z3_sum_sq.a[i23] <== z3_sum.out[i23];
    }
    component z3_tmp = Fp2Sub();
    for (var i24 = 0; i24 < 2; i24++) {
        z3_tmp.a[i24] <== z3_sum_sq.out[i24];
        z3_tmp.b[i24] <== z1z1.out[i24];
    }
    component z3_tmp2 = Fp2Sub();
    for (var i25 = 0; i25 < 2; i25++) {
        z3_tmp2.a[i25] <== z3_tmp.out[i25];
        z3_tmp2.b[i25] <== z2z2.out[i25];
    }
    component z3 = Fp2Mul();
    for (var i26 = 0; i26 < 2; i26++) {
        z3.a[i26] <== z3_tmp2.out[i26];
        z3.b[i26] <== h.out[i26];
    }

    component dbl = G2DoubleJac();
    for (var i27 = 0; i27 < 2; i27++) {
        dbl.p[0][i27] <== p[0][i27];
        dbl.p[1][i27] <== p[1][i27];
        dbl.p[2][i27] <== p[2][i27];
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

    for (var i28 = 0; i28 < 2; i28++) {
        signal xSel0;
        signal xSel1;
        xSel0 <== p[0][i28] + caseP * (q[0][i28] - p[0][i28]);
        xSel1 <== xSel0 + caseDbl * (dbl.out[0][i28] - xSel0);
        out[0][i28] <== xSel1 + caseAdd * (x3.out[i28] - xSel1);

        signal ySel0;
        signal ySel1;
        ySel0 <== p[1][i28] + caseP * (q[1][i28] - p[1][i28]);
        ySel1 <== ySel0 + caseDbl * (dbl.out[1][i28] - ySel0);
        out[1][i28] <== ySel1 + caseAdd * (y3.out[i28] - ySel1);

        signal zSel0;
        signal zSel1;
        zSel0 <== p[2][i28] + caseP * (q[2][i28] - p[2][i28]);
        zSel1 <== zSel0 + caseDbl * (dbl.out[2][i28] - zSel0);
        out[2][i28] <== zSel1 + caseAdd * (z3.out[i28] - zSel1);
    }
}

template G2DoubleJac() {
    signal input p[3][2];
    signal output out[3][2];

    component a = Fp2Square();
    component b = Fp2Square();
    component c = Fp2Square();
    component x_plus_b = Fp2Add();
    component x_plus_b_sq = Fp2Square();
    component d_tmp = Fp2Sub();
    component d_tmp2 = Fp2Sub();
    component d = Fp2Double();
    component a_dbl = Fp2Double();
    component e = Fp2Add();
    component f = Fp2Square();
    component t = Fp2Double();

    for (var i = 0; i < 2; i++) {
        a.a[i] <== p[0][i];
        b.a[i] <== p[1][i];
    }
    for (var i2 = 0; i2 < 2; i2++) {
        c.a[i2] <== b.out[i2];
        x_plus_b.a[i2] <== p[0][i2];
        x_plus_b.b[i2] <== b.out[i2];
    }
    for (var i3 = 0; i3 < 2; i3++) {
        x_plus_b_sq.a[i3] <== x_plus_b.out[i3];
    }
    for (var i4 = 0; i4 < 2; i4++) {
        d_tmp.a[i4] <== x_plus_b_sq.out[i4];
        d_tmp.b[i4] <== a.out[i4];
    }
    for (var i5 = 0; i5 < 2; i5++) {
        d_tmp2.a[i5] <== d_tmp.out[i5];
        d_tmp2.b[i5] <== c.out[i5];
        d.a[i5] <== d_tmp2.out[i5];
        a_dbl.a[i5] <== a.out[i5];
    }
    for (var i6 = 0; i6 < 2; i6++) {
        e.a[i6] <== a_dbl.out[i6];
        e.b[i6] <== a.out[i6];
    }
    for (var i7 = 0; i7 < 2; i7++) {
        f.a[i7] <== e.out[i7];
        t.a[i7] <== d.out[i7];
    }

    component x3 = Fp2Sub();
    for (var i8 = 0; i8 < 2; i8++) {
        x3.a[i8] <== f.out[i8];
        x3.b[i8] <== t.out[i8];
    }
    component d_minus_x3 = Fp2Sub();
    for (var i9 = 0; i9 < 2; i9++) {
        d_minus_x3.a[i9] <== d.out[i9];
        d_minus_x3.b[i9] <== x3.out[i9];
    }
    component y3_mul = Fp2Mul();
    for (var i10 = 0; i10 < 2; i10++) {
        y3_mul.a[i10] <== e.out[i10];
        y3_mul.b[i10] <== d_minus_x3.out[i10];
    }
    component c_dbl = Fp2Double();
    for (var i11 = 0; i11 < 2; i11++) {
        c_dbl.a[i11] <== c.out[i11];
    }
    component c_dbl2 = Fp2Double();
    for (var i12 = 0; i12 < 2; i12++) {
        c_dbl2.a[i12] <== c_dbl.out[i12];
    }
    component c_dbl3 = Fp2Double();
    for (var i13 = 0; i13 < 2; i13++) {
        c_dbl3.a[i13] <== c_dbl2.out[i13];
    }
    component y3 = Fp2Sub();
    for (var i14 = 0; i14 < 2; i14++) {
        y3.a[i14] <== y3_mul.out[i14];
        y3.b[i14] <== c_dbl3.out[i14];
    }
    component z3 = Fp2Mul();
    component z3_dbl = Fp2Double();
    for (var i15 = 0; i15 < 2; i15++) {
        z3.a[i15] <== p[1][i15];
        z3.b[i15] <== p[2][i15];
    }
    for (var i16 = 0; i16 < 2; i16++) {
        z3_dbl.a[i16] <== z3.out[i16];
    }

    for (var i17 = 0; i17 < 2; i17++) {
        out[0][i17] <== x3.out[i17];
        out[1][i17] <== y3.out[i17];
        out[2][i17] <== z3_dbl.out[i17];
    }
}

template G2ProjectiveFromAffine() {
    signal input a[2][2];
    signal output out[3][2];

    component isInf = G2AffineIsInfinity();
    for (var i = 0; i < 2; i++) {
        isInf.p[0][i] <== a[0][i];
        isInf.p[1][i] <== a[1][i];
    }
    component one = Fp2One();
    component zero = Fp2Zero();
    component selX = Fp2Select();
    component selY = Fp2Select();
    component selZ = Fp2Select();
    for (var i2 = 0; i2 < 2; i2++) {
        selX.a[i2] <== one.out[i2];
        selX.b[i2] <== a[0][i2];
        selY.a[i2] <== one.out[i2];
        selY.b[i2] <== a[1][i2];
        selZ.a[i2] <== zero.out[i2];
        selZ.b[i2] <== one.out[i2];
    }
    selX.sel <== isInf.out;
    selY.sel <== isInf.out;
    selZ.sel <== isInf.out;
    for (var i3 = 0; i3 < 2; i3++) {
        out[0][i3] <== selX.out[i3];
        out[1][i3] <== selY.out[i3];
        out[2][i3] <== selZ.out[i3];
    }
}

template G2Frobenius() {
    signal input p[2][2];
    signal output out[2][2];

    component xConj = Fp2Conjugate();
    component yConj = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        xConj.a[i] <== p[0][i];
        yConj.a[i] <== p[1][i];
    }
    component xMul = Fp2MulByNonResidue1Power2();
    component yMul = Fp2MulByNonResidue1Power3();
    for (var i2 = 0; i2 < 2; i2++) {
        xMul.a[i2] <== xConj.out[i2];
        yMul.a[i2] <== yConj.out[i2];
    }
    for (var i3 = 0; i3 < 2; i3++) {
        out[0][i3] <== xMul.out[i3];
        out[1][i3] <== yMul.out[i3];
    }
}

template G2FrobeniusSquare() {
    signal input p[2][2];
    signal output out[2][2];

    component xMul = Fp2MulByNonResidue2Power2();
    component yMul = Fp2MulByNonResidue2Power3();
    component yNeg = Fp2Neg();
    for (var i = 0; i < 2; i++) {
        xMul.a[i] <== p[0][i];
        yMul.a[i] <== p[1][i];
    }
    for (var i2 = 0; i2 < 2; i2++) {
        yNeg.a[i2] <== yMul.out[i2];
    }
    for (var i3 = 0; i3 < 2; i3++) {
        out[0][i3] <== xMul.out[i3];
        out[1][i3] <== yNeg.out[i3];
    }
}

template G2Psi() {
    signal input p[3][2];
    signal output out[3][2];

    component u = Fp2EndoU();
    component v = Fp2EndoV();
    component xConj = Fp2Conjugate();
    component yConj = Fp2Conjugate();
    component zConj = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        xConj.a[i] <== p[0][i];
        yConj.a[i] <== p[1][i];
        zConj.a[i] <== p[2][i];
    }
    component xMul = Fp2Mul();
    component yMul = Fp2Mul();
    for (var i2 = 0; i2 < 2; i2++) {
        xMul.a[i2] <== xConj.out[i2];
        xMul.b[i2] <== u.out[i2];
        yMul.a[i2] <== yConj.out[i2];
        yMul.b[i2] <== v.out[i2];
        out[2][i2] <== zConj.out[i2];
    }
    for (var i3 = 0; i3 < 2; i3++) {
        out[0][i3] <== xMul.out[i3];
        out[1][i3] <== yMul.out[i3];
    }
}

template G2ProjDoubleStep() {
    signal input p[3][2];
    signal output out[3][2];
    signal output line[3][2];

    component a_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        a_mul.a[i] <== p[0][i];
        a_mul.b[i] <== p[1][i];
    }
    component a = Fp2Halve();
    for (var i2 = 0; i2 < 2; i2++) {
        a.a[i2] <== a_mul.out[i2];
    }
    component b = Fp2Square();
    component c = Fp2Square();
    for (var i3 = 0; i3 < 2; i3++) {
        b.a[i3] <== p[1][i3];
        c.a[i3] <== p[2][i3];
    }
    component three = FpThree();
    component d = Fp2MulByElement();
    d.element <== three.out;
    for (var i4 = 0; i4 < 2; i4++) {
        d.a[i4] <== c.out[i4];
    }
    component e = Fp2MulByBTwistCoeff();
    for (var i5 = 0; i5 < 2; i5++) {
        e.a[i5] <== d.out[i5];
    }
    component f = Fp2MulByElement();
    f.element <== three.out;
    for (var i6 = 0; i6 < 2; i6++) {
        f.a[i6] <== e.out[i6];
    }
    component g = Fp2Add();
    for (var i7 = 0; i7 < 2; i7++) {
        g.a[i7] <== b.out[i7];
        g.b[i7] <== f.out[i7];
    }
    component g_half = Fp2Halve();
    for (var i8 = 0; i8 < 2; i8++) {
        g_half.a[i8] <== g.out[i8];
    }
    component h_sum = Fp2Add();
    for (var i9 = 0; i9 < 2; i9++) {
        h_sum.a[i9] <== p[1][i9];
        h_sum.b[i9] <== p[2][i9];
    }
    component h_sq = Fp2Square();
    for (var i10 = 0; i10 < 2; i10++) {
        h_sq.a[i10] <== h_sum.out[i10];
    }
    component h_tmp = Fp2Sub();
    for (var i11 = 0; i11 < 2; i11++) {
        h_tmp.a[i11] <== h_sq.out[i11];
        h_tmp.b[i11] <== b.out[i11];
    }
    component h = Fp2Sub();
    for (var i12 = 0; i12 < 2; i12++) {
        h.a[i12] <== h_tmp.out[i12];
        h.b[i12] <== c.out[i12];
    }
    component i = Fp2Sub();
    for (var i13 = 0; i13 < 2; i13++) {
        i.a[i13] <== e.out[i13];
        i.b[i13] <== b.out[i13];
    }
    component j = Fp2Square();
    for (var i14 = 0; i14 < 2; i14++) {
        j.a[i14] <== p[0][i14];
    }
    component ee = Fp2Square();
    for (var i15 = 0; i15 < 2; i15++) {
        ee.a[i15] <== e.out[i15];
    }
    component k = Fp2MulByElement();
    k.element <== three.out;
    for (var i16 = 0; i16 < 2; i16++) {
        k.a[i16] <== ee.out[i16];
    }

    component x = Fp2Sub();
    for (var i17 = 0; i17 < 2; i17++) {
        x.a[i17] <== b.out[i17];
        x.b[i17] <== f.out[i17];
    }
    component x_mul = Fp2Mul();
    for (var i18 = 0; i18 < 2; i18++) {
        x_mul.a[i18] <== x.out[i18];
        x_mul.b[i18] <== a.out[i18];
    }
    component y = Fp2Square();
    for (var i19 = 0; i19 < 2; i19++) {
        y.a[i19] <== g_half.out[i19];
    }
    component y_sub = Fp2Sub();
    for (var i20 = 0; i20 < 2; i20++) {
        y_sub.a[i20] <== y.out[i20];
        y_sub.b[i20] <== k.out[i20];
    }
    component z = Fp2Mul();
    for (var i21 = 0; i21 < 2; i21++) {
        z.a[i21] <== b.out[i21];
        z.b[i21] <== h.out[i21];
    }

    component h_neg = Fp2Neg();
    for (var i22 = 0; i22 < 2; i22++) {
        h_neg.a[i22] <== h.out[i22];
    }
    component j_mul = Fp2MulByElement();
    j_mul.element <== three.out;
    for (var i23 = 0; i23 < 2; i23++) {
        j_mul.a[i23] <== j.out[i23];
    }

    for (var i24 = 0; i24 < 2; i24++) {
        out[0][i24] <== x_mul.out[i24];
        out[1][i24] <== y_sub.out[i24];
        out[2][i24] <== z.out[i24];

        line[0][i24] <== h_neg.out[i24];
        line[1][i24] <== j_mul.out[i24];
        line[2][i24] <== i.out[i24];
    }
}

template G2ProjAddMixedStep() {
    signal input p[3][2];
    signal input a[2][2];
    signal output out[3][2];
    signal output line[3][2];

    component y2z1 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        y2z1.a[i] <== a[1][i];
        y2z1.b[i] <== p[2][i];
    }
    component o = Fp2Sub();
    for (var i2 = 0; i2 < 2; i2++) {
        o.a[i2] <== p[1][i2];
        o.b[i2] <== y2z1.out[i2];
    }
    component x2z1 = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        x2z1.a[i3] <== a[0][i3];
        x2z1.b[i3] <== p[2][i3];
    }
    component l = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        l.a[i4] <== p[0][i4];
        l.b[i4] <== x2z1.out[i4];
    }
    component c = Fp2Square();
    component d = Fp2Square();
    for (var i5 = 0; i5 < 2; i5++) {
        c.a[i5] <== o.out[i5];
        d.a[i5] <== l.out[i5];
    }
    component e = Fp2Mul();
    for (var i6 = 0; i6 < 2; i6++) {
        e.a[i6] <== l.out[i6];
        e.b[i6] <== d.out[i6];
    }
    component f = Fp2Mul();
    for (var i7 = 0; i7 < 2; i7++) {
        f.a[i7] <== p[2][i7];
        f.b[i7] <== c.out[i7];
    }
    component g = Fp2Mul();
    for (var i8 = 0; i8 < 2; i8++) {
        g.a[i8] <== p[0][i8];
        g.b[i8] <== d.out[i8];
    }
    component g_dbl = Fp2Double();
    for (var i9 = 0; i9 < 2; i9++) {
        g_dbl.a[i9] <== g.out[i9];
    }
    component h = Fp2Add();
    for (var i10 = 0; i10 < 2; i10++) {
        h.a[i10] <== e.out[i10];
        h.b[i10] <== f.out[i10];
    }
    component h_sub = Fp2Sub();
    for (var i11 = 0; i11 < 2; i11++) {
        h_sub.a[i11] <== h.out[i11];
        h_sub.b[i11] <== g_dbl.out[i11];
    }
    component t1 = Fp2Mul();
    for (var i12 = 0; i12 < 2; i12++) {
        t1.a[i12] <== p[1][i12];
        t1.b[i12] <== e.out[i12];
    }
    component x = Fp2Mul();
    for (var i13 = 0; i13 < 2; i13++) {
        x.a[i13] <== l.out[i13];
        x.b[i13] <== h_sub.out[i13];
    }
    component y = Fp2Sub();
    component g_minus_h = Fp2Sub();
    for (var i14 = 0; i14 < 2; i14++) {
        g_minus_h.a[i14] <== g.out[i14];
        g_minus_h.b[i14] <== h_sub.out[i14];
    }
    component g_minus_h_mul = Fp2Mul();
    for (var i15 = 0; i15 < 2; i15++) {
        g_minus_h_mul.a[i15] <== g_minus_h.out[i15];
        g_minus_h_mul.b[i15] <== o.out[i15];
    }
    for (var i16 = 0; i16 < 2; i16++) {
        y.a[i16] <== g_minus_h_mul.out[i16];
        y.b[i16] <== t1.out[i16];
    }
    component z = Fp2Mul();
    for (var i17 = 0; i17 < 2; i17++) {
        z.a[i17] <== e.out[i17];
        z.b[i17] <== p[2][i17];
    }
    component t2 = Fp2Mul();
    for (var i18 = 0; i18 < 2; i18++) {
        t2.a[i18] <== l.out[i18];
        t2.b[i18] <== a[1][i18];
    }
    component j = Fp2Mul();
    for (var i19 = 0; i19 < 2; i19++) {
        j.a[i19] <== a[0][i19];
        j.b[i19] <== o.out[i19];
    }
    component j_sub = Fp2Sub();
    for (var i20 = 0; i20 < 2; i20++) {
        j_sub.a[i20] <== j.out[i20];
        j_sub.b[i20] <== t2.out[i20];
    }
    component o_neg = Fp2Neg();
    for (var i21 = 0; i21 < 2; i21++) {
        o_neg.a[i21] <== o.out[i21];
    }

    for (var i22 = 0; i22 < 2; i22++) {
        out[0][i22] <== x.out[i22];
        out[1][i22] <== y.out[i22];
        out[2][i22] <== z.out[i22];

        line[0][i22] <== l.out[i22];
        line[1][i22] <== o_neg.out[i22];
        line[2][i22] <== j_sub.out[i22];
    }
}

template G2ProjLineCompute() {
    signal input p[3][2];
    signal input a[2][2];
    signal output out[3][2];
    signal output line[3][2];

    component y2z1 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        y2z1.a[i] <== a[1][i];
        y2z1.b[i] <== p[2][i];
    }
    component o = Fp2Sub();
    for (var i2 = 0; i2 < 2; i2++) {
        o.a[i2] <== p[1][i2];
        o.b[i2] <== y2z1.out[i2];
    }
    component x2z1 = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        x2z1.a[i3] <== a[0][i3];
        x2z1.b[i3] <== p[2][i3];
    }
    component l = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        l.a[i4] <== p[0][i4];
        l.b[i4] <== x2z1.out[i4];
    }
    component t2 = Fp2Mul();
    for (var i5 = 0; i5 < 2; i5++) {
        t2.a[i5] <== l.out[i5];
        t2.b[i5] <== a[1][i5];
    }
    component j = Fp2Mul();
    for (var i6 = 0; i6 < 2; i6++) {
        j.a[i6] <== a[0][i6];
        j.b[i6] <== o.out[i6];
    }
    component j_sub = Fp2Sub();
    for (var i7 = 0; i7 < 2; i7++) {
        j_sub.a[i7] <== j.out[i7];
        j_sub.b[i7] <== t2.out[i7];
    }
    component o_neg = Fp2Neg();
    for (var i8 = 0; i8 < 2; i8++) {
        o_neg.a[i8] <== o.out[i8];
    }

    for (var i9 = 0; i9 < 2; i9++) {
        out[0][i9] <== p[0][i9];
        out[1][i9] <== p[1][i9];
        out[2][i9] <== p[2][i9];

        line[0][i9] <== l.out[i9];
        line[1][i9] <== o_neg.out[i9];
        line[2][i9] <== j_sub.out[i9];
    }
}
