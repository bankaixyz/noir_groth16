pragma circom 2.0.0;

include "./fp2.circom";
include "./fp.circom";

template Fp2Eq() {
    signal input a[2][3];
    signal input b[2][3];
    signal output out;

    component eq0 = FpEq();
    component eq1 = FpEq();
    for (var i = 0; i < 3; i++) {
        eq0.a[i] <== a[0][i];
        eq0.b[i] <== b[0][i];
        eq1.a[i] <== a[1][i];
        eq1.b[i] <== b[1][i];
    }
    out <== eq0.out * eq1.out;
    out * (out - 1) === 0;
}

template Fp2IsZero() {
    signal input a[2][3];
    signal output out;

    component z0 = FpIsZero();
    component z1 = FpIsZero();
    for (var i = 0; i < 3; i++) {
        z0.a[i] <== a[0][i];
        z1.a[i] <== a[1][i];
    }
    out <== z0.out * z1.out;
    out * (out - 1) === 0;
}

template Fp2Select() {
    signal input a[2][3];
    signal input b[2][3];
    signal input sel;
    signal output out[2][3];

    sel * (sel - 1) === 0;
    component sel0 = FpSelect();
    component sel1 = FpSelect();
    for (var i = 0; i < 3; i++) {
        sel0.a[i] <== a[0][i];
        sel0.b[i] <== b[0][i];
        sel1.a[i] <== a[1][i];
        sel1.b[i] <== b[1][i];
    }
    sel0.sel <== sel;
    sel1.sel <== sel;
    for (var j = 0; j < 3; j++) {
        out[0][j] <== sel0.out[j];
        out[1][j] <== sel1.out[j];
    }
}

template G2AffineInfinity() {
    signal output out[2][2][3];

    component zero = Fp2Zero();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== zero.out[i][j];
            out[1][i][j] <== zero.out[i][j];
        }
    }
}

template G2JacobianInfinity() {
    signal output out[3][2][3];

    component one = Fp2One();
    component zero = Fp2Zero();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== one.out[i][j];
            out[1][i][j] <== one.out[i][j];
            out[2][i][j] <== zero.out[i][j];
        }
    }
}

template G2AffineIsInfinity() {
    signal input p[2][2][3];
    signal output out;

    component xZero = Fp2IsZero();
    component yZero = Fp2IsZero();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            xZero.a[i][j] <== p[0][i][j];
            yZero.a[i][j] <== p[1][i][j];
        }
    }
    out <== xZero.out * yZero.out;
    out * (out - 1) === 0;
}

template G2JacIsInfinity() {
    signal input p[3][2][3];
    signal output out;

    component zZero = Fp2IsZero();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            zZero.a[i][j] <== p[2][i][j];
        }
    }
    out <== zZero.out;
    out * (out - 1) === 0;
}

template G2IsOnCurveAffine() {
    signal input p[2][2][3];
    signal output out;

    component ySq = Fp2Square();
    component xSq = Fp2Square();
    component xCub = Fp2Mul();
    component b = Fp2BTwist();
    component rhs = Fp2Add();
    component eq = Fp2Eq();
    component isInf = G2AffineIsInfinity();

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            ySq.a[i][j] <== p[1][i][j];
            xSq.a[i][j] <== p[0][i][j];
            isInf.p[0][i][j] <== p[0][i][j];
            isInf.p[1][i][j] <== p[1][i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            xCub.a[i2][j2] <== xSq.out[i2][j2];
            xCub.b[i2][j2] <== p[0][i2][j2];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            rhs.a[i3][j3] <== xCub.out[i3][j3];
            rhs.b[i3][j3] <== b.out[i3][j3];
        }
    }
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            eq.a[i4][j4] <== ySq.out[i4][j4];
            eq.b[i4][j4] <== rhs.out[i4][j4];
        }
    }

    out <== isInf.out + (1 - isInf.out) * eq.out;
    out * (out - 1) === 0;
}

template G2NegAffine() {
    signal input p[2][2][3];
    signal output out[2][2][3];

    component neg = Fp2Neg();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            neg.a[i][j] <== p[1][i][j];
            out[0][i][j] <== p[0][i][j];
            out[1][i][j] <== neg.out[i][j];
        }
    }
}

template G2JacobianToAffine() {
    signal input p[3][2][3];
    signal input inv_z[2][3];
    signal input enable;
    signal output out[2][2][3];

    enable * (enable - 1) === 0;

    component zZero = Fp2IsZero();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            zZero.a[i][j] <== p[2][i][j];
        }
    }
    component mul = Fp2Mul();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            mul.a[i2][j2] <== p[2][i2][j2];
            mul.b[i2][j2] <== inv_z[i2][j2];
        }
    }
    component one = Fp2One();
    component zero = Fp2Zero();
    component expect = Fp2Select();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            expect.a[i3][j3] <== zero.out[i3][j3];
            expect.b[i3][j3] <== one.out[i3][j3];
        }
    }
    expect.sel <== zZero.out;
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            enable * (mul.out[i4][j4] - expect.out[i4][j4]) === 0;
        }
    }

    component invSq = Fp2Square();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            invSq.a[i5][j5] <== inv_z[i5][j5];
        }
    }
    component xMul = Fp2Mul();
    component yMul = Fp2Mul();
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            xMul.a[i6][j6] <== p[0][i6][j6];
            xMul.b[i6][j6] <== invSq.out[i6][j6];
            yMul.a[i6][j6] <== p[1][i6][j6];
            yMul.b[i6][j6] <== invSq.out[i6][j6];
        }
    }
    component yMul2 = Fp2Mul();
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            yMul2.a[i7][j7] <== yMul.out[i7][j7];
            yMul2.b[i7][j7] <== inv_z[i7][j7];
        }
    }

    component selX = Fp2Select();
    component selY = Fp2Select();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            selX.a[i8][j8] <== zero.out[i8][j8];
            selX.b[i8][j8] <== xMul.out[i8][j8];
            selY.a[i8][j8] <== zero.out[i8][j8];
            selY.b[i8][j8] <== yMul2.out[i8][j8];
        }
    }
    selX.sel <== zZero.out;
    selY.sel <== zZero.out;
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            out[0][i9][j9] <== selX.out[i9][j9];
            out[1][i9][j9] <== selY.out[i9][j9];
        }
    }
}

template G2AddJac() {
    signal input p[3][2][3];
    signal input q[3][2][3];
    signal output out[3][2][3];

    component pInf = G2JacIsInfinity();
    component qInf = G2JacIsInfinity();
    for (var c = 0; c < 3; c++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                pInf.p[c][i][j] <== p[c][i][j];
                qInf.p[c][i][j] <== q[c][i][j];
            }
        }
    }

    component z1z1 = Fp2Square();
    component z2z2 = Fp2Square();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            z1z1.a[i2][j2] <== q[2][i2][j2];
            z2z2.a[i2][j2] <== p[2][i2][j2];
        }
    }
    component u1 = Fp2Mul();
    component u2 = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            u1.a[i3][j3] <== q[0][i3][j3];
            u1.b[i3][j3] <== z2z2.out[i3][j3];
            u2.a[i3][j3] <== p[0][i3][j3];
            u2.b[i3][j3] <== z1z1.out[i3][j3];
        }
    }
    component s1 = Fp2Mul();
    component s2 = Fp2Mul();
    component pz_mul = Fp2Mul();
    component qz_mul = Fp2Mul();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            pz_mul.a[i4][j4] <== q[1][i4][j4];
            pz_mul.b[i4][j4] <== p[2][i4][j4];
            qz_mul.a[i4][j4] <== p[1][i4][j4];
            qz_mul.b[i4][j4] <== q[2][i4][j4];
        }
    }
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            s1.a[i5][j5] <== pz_mul.out[i5][j5];
            s1.b[i5][j5] <== z2z2.out[i5][j5];
            s2.a[i5][j5] <== qz_mul.out[i5][j5];
            s2.b[i5][j5] <== z1z1.out[i5][j5];
        }
    }

    component sameU = Fp2Eq();
    component sameS = Fp2Eq();
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            sameU.a[i6][j6] <== u1.out[i6][j6];
            sameU.b[i6][j6] <== u2.out[i6][j6];
            sameS.a[i6][j6] <== s1.out[i6][j6];
            sameS.b[i6][j6] <== s2.out[i6][j6];
        }
    }
    signal same;
    same <== sameU.out * sameS.out;
    same * (same - 1) === 0;

    component h = Fp2Sub();
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            h.a[i7][j7] <== u2.out[i7][j7];
            h.b[i7][j7] <== u1.out[i7][j7];
        }
    }
    component h_dbl = Fp2Double();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            h_dbl.a[i8][j8] <== h.out[i8][j8];
        }
    }
    component i_sq = Fp2Square();
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            i_sq.a[i9][j9] <== h_dbl.out[i9][j9];
        }
    }
    component j = Fp2Mul();
    for (var i10 = 0; i10 < 2; i10++) {
        for (var j10 = 0; j10 < 3; j10++) {
            j.a[i10][j10] <== h.out[i10][j10];
            j.b[i10][j10] <== i_sq.out[i10][j10];
        }
    }
    component r = Fp2Sub();
    for (var i11 = 0; i11 < 2; i11++) {
        for (var j11 = 0; j11 < 3; j11++) {
            r.a[i11][j11] <== s2.out[i11][j11];
            r.b[i11][j11] <== s1.out[i11][j11];
        }
    }
    component r_dbl = Fp2Double();
    for (var i12 = 0; i12 < 2; i12++) {
        for (var j12 = 0; j12 < 3; j12++) {
            r_dbl.a[i12][j12] <== r.out[i12][j12];
        }
    }
    component v = Fp2Mul();
    for (var i13 = 0; i13 < 2; i13++) {
        for (var j13 = 0; j13 < 3; j13++) {
            v.a[i13][j13] <== u1.out[i13][j13];
            v.b[i13][j13] <== i_sq.out[i13][j13];
        }
    }
    component r_sq = Fp2Square();
    for (var i14 = 0; i14 < 2; i14++) {
        for (var j14 = 0; j14 < 3; j14++) {
            r_sq.a[i14][j14] <== r_dbl.out[i14][j14];
        }
    }
    component x3_tmp = Fp2Sub();
    for (var i15 = 0; i15 < 2; i15++) {
        for (var j15 = 0; j15 < 3; j15++) {
            x3_tmp.a[i15][j15] <== r_sq.out[i15][j15];
            x3_tmp.b[i15][j15] <== j.out[i15][j15];
        }
    }
    component v_dbl = Fp2Double();
    for (var i16 = 0; i16 < 2; i16++) {
        for (var j16 = 0; j16 < 3; j16++) {
            v_dbl.a[i16][j16] <== v.out[i16][j16];
        }
    }
    component x3 = Fp2Sub();
    for (var i17 = 0; i17 < 2; i17++) {
        for (var j17 = 0; j17 < 3; j17++) {
            x3.a[i17][j17] <== x3_tmp.out[i17][j17];
            x3.b[i17][j17] <== v_dbl.out[i17][j17];
        }
    }
    component v_minus_x3 = Fp2Sub();
    for (var i18 = 0; i18 < 2; i18++) {
        for (var j18 = 0; j18 < 3; j18++) {
            v_minus_x3.a[i18][j18] <== v.out[i18][j18];
            v_minus_x3.b[i18][j18] <== x3.out[i18][j18];
        }
    }
    component y3_mul = Fp2Mul();
    for (var i19 = 0; i19 < 2; i19++) {
        for (var j19 = 0; j19 < 3; j19++) {
            y3_mul.a[i19][j19] <== r_dbl.out[i19][j19];
            y3_mul.b[i19][j19] <== v_minus_x3.out[i19][j19];
        }
    }
    component s1_dbl = Fp2Double();
    for (var i20 = 0; i20 < 2; i20++) {
        for (var j20 = 0; j20 < 3; j20++) {
            s1_dbl.a[i20][j20] <== s1.out[i20][j20];
        }
    }
    component s1j = Fp2Mul();
    for (var i21 = 0; i21 < 2; i21++) {
        for (var j21 = 0; j21 < 3; j21++) {
            s1j.a[i21][j21] <== s1_dbl.out[i21][j21];
            s1j.b[i21][j21] <== j.out[i21][j21];
        }
    }
    component y3 = Fp2Sub();
    for (var i22 = 0; i22 < 2; i22++) {
        for (var j22 = 0; j22 < 3; j22++) {
            y3.a[i22][j22] <== y3_mul.out[i22][j22];
            y3.b[i22][j22] <== s1j.out[i22][j22];
        }
    }
    component z3_sum = Fp2Add();
    for (var i23 = 0; i23 < 2; i23++) {
        for (var j23 = 0; j23 < 3; j23++) {
            z3_sum.a[i23][j23] <== p[2][i23][j23];
            z3_sum.b[i23][j23] <== q[2][i23][j23];
        }
    }
    component z3_sum_sq = Fp2Square();
    for (var i24 = 0; i24 < 2; i24++) {
        for (var j24 = 0; j24 < 3; j24++) {
            z3_sum_sq.a[i24][j24] <== z3_sum.out[i24][j24];
        }
    }
    component z3_tmp = Fp2Sub();
    for (var i25 = 0; i25 < 2; i25++) {
        for (var j25 = 0; j25 < 3; j25++) {
            z3_tmp.a[i25][j25] <== z3_sum_sq.out[i25][j25];
            z3_tmp.b[i25][j25] <== z1z1.out[i25][j25];
        }
    }
    component z3_tmp2 = Fp2Sub();
    for (var i26 = 0; i26 < 2; i26++) {
        for (var j26 = 0; j26 < 3; j26++) {
            z3_tmp2.a[i26][j26] <== z3_tmp.out[i26][j26];
            z3_tmp2.b[i26][j26] <== z2z2.out[i26][j26];
        }
    }
    component z3 = Fp2Mul();
    for (var i27 = 0; i27 < 2; i27++) {
        for (var j27 = 0; j27 < 3; j27++) {
            z3.a[i27][j27] <== z3_tmp2.out[i27][j27];
            z3.b[i27][j27] <== h.out[i27][j27];
        }
    }

    component dbl = G2DoubleJac();
    for (var i28 = 0; i28 < 2; i28++) {
        for (var j28 = 0; j28 < 3; j28++) {
            dbl.p[0][i28][j28] <== p[0][i28][j28];
            dbl.p[1][i28][j28] <== p[1][i28][j28];
            dbl.p[2][i28][j28] <== p[2][i28][j28];
        }
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

    signal xSel0[2][3];
    signal xSel1[2][3];
    signal ySel0[2][3];
    signal ySel1[2][3];
    signal zSel0[2][3];
    signal zSel1[2][3];

    xSel0[0][0] <== p[0][0][0] + caseP * (q[0][0][0] - p[0][0][0]);
    xSel1[0][0] <== xSel0[0][0] + caseDbl * (dbl.out[0][0][0] - xSel0[0][0]);
    out[0][0][0] <== xSel1[0][0] + caseAdd * (x3.out[0][0] - xSel1[0][0]);
    xSel0[0][1] <== p[0][0][1] + caseP * (q[0][0][1] - p[0][0][1]);
    xSel1[0][1] <== xSel0[0][1] + caseDbl * (dbl.out[0][0][1] - xSel0[0][1]);
    out[0][0][1] <== xSel1[0][1] + caseAdd * (x3.out[0][1] - xSel1[0][1]);
    xSel0[0][2] <== p[0][0][2] + caseP * (q[0][0][2] - p[0][0][2]);
    xSel1[0][2] <== xSel0[0][2] + caseDbl * (dbl.out[0][0][2] - xSel0[0][2]);
    out[0][0][2] <== xSel1[0][2] + caseAdd * (x3.out[0][2] - xSel1[0][2]);
    xSel0[1][0] <== p[0][1][0] + caseP * (q[0][1][0] - p[0][1][0]);
    xSel1[1][0] <== xSel0[1][0] + caseDbl * (dbl.out[0][1][0] - xSel0[1][0]);
    out[0][1][0] <== xSel1[1][0] + caseAdd * (x3.out[1][0] - xSel1[1][0]);
    xSel0[1][1] <== p[0][1][1] + caseP * (q[0][1][1] - p[0][1][1]);
    xSel1[1][1] <== xSel0[1][1] + caseDbl * (dbl.out[0][1][1] - xSel0[1][1]);
    out[0][1][1] <== xSel1[1][1] + caseAdd * (x3.out[1][1] - xSel1[1][1]);
    xSel0[1][2] <== p[0][1][2] + caseP * (q[0][1][2] - p[0][1][2]);
    xSel1[1][2] <== xSel0[1][2] + caseDbl * (dbl.out[0][1][2] - xSel0[1][2]);
    out[0][1][2] <== xSel1[1][2] + caseAdd * (x3.out[1][2] - xSel1[1][2]);

    ySel0[0][0] <== p[1][0][0] + caseP * (q[1][0][0] - p[1][0][0]);
    ySel1[0][0] <== ySel0[0][0] + caseDbl * (dbl.out[1][0][0] - ySel0[0][0]);
    out[1][0][0] <== ySel1[0][0] + caseAdd * (y3.out[0][0] - ySel1[0][0]);
    ySel0[0][1] <== p[1][0][1] + caseP * (q[1][0][1] - p[1][0][1]);
    ySel1[0][1] <== ySel0[0][1] + caseDbl * (dbl.out[1][0][1] - ySel0[0][1]);
    out[1][0][1] <== ySel1[0][1] + caseAdd * (y3.out[0][1] - ySel1[0][1]);
    ySel0[0][2] <== p[1][0][2] + caseP * (q[1][0][2] - p[1][0][2]);
    ySel1[0][2] <== ySel0[0][2] + caseDbl * (dbl.out[1][0][2] - ySel0[0][2]);
    out[1][0][2] <== ySel1[0][2] + caseAdd * (y3.out[0][2] - ySel1[0][2]);
    ySel0[1][0] <== p[1][1][0] + caseP * (q[1][1][0] - p[1][1][0]);
    ySel1[1][0] <== ySel0[1][0] + caseDbl * (dbl.out[1][1][0] - ySel0[1][0]);
    out[1][1][0] <== ySel1[1][0] + caseAdd * (y3.out[1][0] - ySel1[1][0]);
    ySel0[1][1] <== p[1][1][1] + caseP * (q[1][1][1] - p[1][1][1]);
    ySel1[1][1] <== ySel0[1][1] + caseDbl * (dbl.out[1][1][1] - ySel0[1][1]);
    out[1][1][1] <== ySel1[1][1] + caseAdd * (y3.out[1][1] - ySel1[1][1]);
    ySel0[1][2] <== p[1][1][2] + caseP * (q[1][1][2] - p[1][1][2]);
    ySel1[1][2] <== ySel0[1][2] + caseDbl * (dbl.out[1][1][2] - ySel0[1][2]);
    out[1][1][2] <== ySel1[1][2] + caseAdd * (y3.out[1][2] - ySel1[1][2]);

    zSel0[0][0] <== p[2][0][0] + caseP * (q[2][0][0] - p[2][0][0]);
    zSel1[0][0] <== zSel0[0][0] + caseDbl * (dbl.out[2][0][0] - zSel0[0][0]);
    out[2][0][0] <== zSel1[0][0] + caseAdd * (z3.out[0][0] - zSel1[0][0]);
    zSel0[0][1] <== p[2][0][1] + caseP * (q[2][0][1] - p[2][0][1]);
    zSel1[0][1] <== zSel0[0][1] + caseDbl * (dbl.out[2][0][1] - zSel0[0][1]);
    out[2][0][1] <== zSel1[0][1] + caseAdd * (z3.out[0][1] - zSel1[0][1]);
    zSel0[0][2] <== p[2][0][2] + caseP * (q[2][0][2] - p[2][0][2]);
    zSel1[0][2] <== zSel0[0][2] + caseDbl * (dbl.out[2][0][2] - zSel0[0][2]);
    out[2][0][2] <== zSel1[0][2] + caseAdd * (z3.out[0][2] - zSel1[0][2]);
    zSel0[1][0] <== p[2][1][0] + caseP * (q[2][1][0] - p[2][1][0]);
    zSel1[1][0] <== zSel0[1][0] + caseDbl * (dbl.out[2][1][0] - zSel0[1][0]);
    out[2][1][0] <== zSel1[1][0] + caseAdd * (z3.out[1][0] - zSel1[1][0]);
    zSel0[1][1] <== p[2][1][1] + caseP * (q[2][1][1] - p[2][1][1]);
    zSel1[1][1] <== zSel0[1][1] + caseDbl * (dbl.out[2][1][1] - zSel0[1][1]);
    out[2][1][1] <== zSel1[1][1] + caseAdd * (z3.out[1][1] - zSel1[1][1]);
    zSel0[1][2] <== p[2][1][2] + caseP * (q[2][1][2] - p[2][1][2]);
    zSel1[1][2] <== zSel0[1][2] + caseDbl * (dbl.out[2][1][2] - zSel0[1][2]);
    out[2][1][2] <== zSel1[1][2] + caseAdd * (z3.out[1][2] - zSel1[1][2]);
}

template G2DoubleJac() {
    signal input p[3][2][3];
    signal output out[3][2][3];

    component a = Fp2Square();
    component b = Fp2Square();
    component c = Fp2Square();
    component x_plus_b = Fp2Add();
    component x_plus_b_sq = Fp2Square();
    component d_tmp = Fp2Sub();
    component d = Fp2Double();
    component a_dbl = Fp2Double();
    component e = Fp2Add();
    component f = Fp2Square();
    component t = Fp2Double();

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a.a[i][j] <== p[0][i][j];
            b.a[i][j] <== p[1][i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            c.a[i2][j2] <== b.out[i2][j2];
            x_plus_b.a[i2][j2] <== p[0][i2][j2];
            x_plus_b.b[i2][j2] <== b.out[i2][j2];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            x_plus_b_sq.a[i3][j3] <== x_plus_b.out[i3][j3];
        }
    }
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            d_tmp.a[i4][j4] <== x_plus_b_sq.out[i4][j4];
            d_tmp.b[i4][j4] <== a.out[i4][j4];
        }
    }
    component d_tmp2 = Fp2Sub();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            d_tmp2.a[i5][j5] <== d_tmp.out[i5][j5];
            d_tmp2.b[i5][j5] <== c.out[i5][j5];
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            d.a[i6][j6] <== d_tmp2.out[i6][j6];
            a_dbl.a[i6][j6] <== a.out[i6][j6];
        }
    }
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            e.a[i7][j7] <== a_dbl.out[i7][j7];
            e.b[i7][j7] <== a.out[i7][j7];
        }
    }
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            f.a[i8][j8] <== e.out[i8][j8];
            t.a[i8][j8] <== d.out[i8][j8];
        }
    }

    component x3 = Fp2Sub();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            x3.a[i8][j8] <== f.out[i8][j8];
            x3.b[i8][j8] <== t.out[i8][j8];
        }
    }
    component d_minus_x3 = Fp2Sub();
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            d_minus_x3.a[i9][j9] <== d.out[i9][j9];
            d_minus_x3.b[i9][j9] <== x3.out[i9][j9];
        }
    }
    component y3_mul = Fp2Mul();
    for (var i10 = 0; i10 < 2; i10++) {
        for (var j10 = 0; j10 < 3; j10++) {
            y3_mul.a[i10][j10] <== e.out[i10][j10];
            y3_mul.b[i10][j10] <== d_minus_x3.out[i10][j10];
        }
    }
    component c_dbl = Fp2Double();
    for (var i11 = 0; i11 < 2; i11++) {
        for (var j11 = 0; j11 < 3; j11++) {
            c_dbl.a[i11][j11] <== c.out[i11][j11];
        }
    }
    component c_dbl2 = Fp2Double();
    for (var i12 = 0; i12 < 2; i12++) {
        for (var j12 = 0; j12 < 3; j12++) {
            c_dbl2.a[i12][j12] <== c_dbl.out[i12][j12];
        }
    }
    component c_dbl3 = Fp2Double();
    for (var i13 = 0; i13 < 2; i13++) {
        for (var j13 = 0; j13 < 3; j13++) {
            c_dbl3.a[i13][j13] <== c_dbl2.out[i13][j13];
        }
    }
    component y3 = Fp2Sub();
    for (var i14 = 0; i14 < 2; i14++) {
        for (var j14 = 0; j14 < 3; j14++) {
            y3.a[i14][j14] <== y3_mul.out[i14][j14];
            y3.b[i14][j14] <== c_dbl3.out[i14][j14];
        }
    }
    component z3 = Fp2Mul();
    component z3_dbl = Fp2Double();
    for (var i15 = 0; i15 < 2; i15++) {
        for (var j15 = 0; j15 < 3; j15++) {
            z3.a[i15][j15] <== p[1][i15][j15];
            z3.b[i15][j15] <== p[2][i15][j15];
        }
    }
    for (var i16 = 0; i16 < 2; i16++) {
        for (var j16 = 0; j16 < 3; j16++) {
            z3_dbl.a[i16][j16] <== z3.out[i16][j16];
        }
    }

    for (var i17 = 0; i17 < 2; i17++) {
        for (var j17 = 0; j17 < 3; j17++) {
            out[0][i17][j17] <== x3.out[i17][j17];
            out[1][i17][j17] <== y3.out[i17][j17];
            out[2][i17][j17] <== z3_dbl.out[i17][j17];
        }
    }
}

template G2ProjectiveFromAffine() {
    signal input a[2][2][3];
    signal output out[3][2][3];

    component isInf = G2AffineIsInfinity();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            isInf.p[0][i][j] <== a[0][i][j];
            isInf.p[1][i][j] <== a[1][i][j];
        }
    }
    component one = Fp2One();
    component zero = Fp2Zero();
    component selX = Fp2Select();
    component selY = Fp2Select();
    component selZ = Fp2Select();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            selX.a[i2][j2] <== one.out[i2][j2];
            selX.b[i2][j2] <== a[0][i2][j2];
            selY.a[i2][j2] <== one.out[i2][j2];
            selY.b[i2][j2] <== a[1][i2][j2];
            selZ.a[i2][j2] <== zero.out[i2][j2];
            selZ.b[i2][j2] <== one.out[i2][j2];
        }
    }
    selX.sel <== isInf.out;
    selY.sel <== isInf.out;
    selZ.sel <== isInf.out;
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            out[0][i3][j3] <== selX.out[i3][j3];
            out[1][i3][j3] <== selY.out[i3][j3];
            out[2][i3][j3] <== selZ.out[i3][j3];
        }
    }
}

template G2Frobenius() {
    signal input p[2][2][3];
    signal output out[2][2][3];

    component xConj = Fp2Conjugate();
    component yConj = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            xConj.a[i][j] <== p[0][i][j];
            yConj.a[i][j] <== p[1][i][j];
        }
    }
    component xMul = Fp2MulByNonResidue1Power2();
    component yMul = Fp2MulByNonResidue1Power3();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            xMul.a[i2][j2] <== xConj.out[i2][j2];
            yMul.a[i2][j2] <== yConj.out[i2][j2];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            out[0][i3][j3] <== xMul.out[i3][j3];
            out[1][i3][j3] <== yMul.out[i3][j3];
        }
    }
}

template G2FrobeniusSquare() {
    signal input p[2][2][3];
    signal output out[2][2][3];

    component xMul = Fp2MulByNonResidue2Power2();
    component yMul = Fp2MulByNonResidue2Power3();
    component yNeg = Fp2Neg();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            xMul.a[i][j] <== p[0][i][j];
            yMul.a[i][j] <== p[1][i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            yNeg.a[i2][j2] <== yMul.out[i2][j2];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            out[0][i3][j3] <== xMul.out[i3][j3];
            out[1][i3][j3] <== yNeg.out[i3][j3];
        }
    }
}

template G2Psi() {
    signal input p[3][2][3];
    signal output out[3][2][3];

    component u = Fp2EndoU();
    component v = Fp2EndoV();
    component xConj = Fp2Conjugate();
    component yConj = Fp2Conjugate();
    component zConj = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            xConj.a[i][j] <== p[0][i][j];
            yConj.a[i][j] <== p[1][i][j];
            zConj.a[i][j] <== p[2][i][j];
        }
    }
    component xMul = Fp2Mul();
    component yMul = Fp2Mul();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            xMul.a[i2][j2] <== xConj.out[i2][j2];
            xMul.b[i2][j2] <== u.out[i2][j2];
            yMul.a[i2][j2] <== yConj.out[i2][j2];
            yMul.b[i2][j2] <== v.out[i2][j2];
            out[2][i2][j2] <== zConj.out[i2][j2];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            out[0][i3][j3] <== xMul.out[i3][j3];
            out[1][i3][j3] <== yMul.out[i3][j3];
        }
    }
}

template G2ProjDoubleStep() {
    signal input p[3][2][3];
    signal output out[3][2][3];
    signal output line[3][2][3];

    component a_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a_mul.a[i][j] <== p[0][i][j];
            a_mul.b[i][j] <== p[1][i][j];
        }
    }
    component a = Fp2Halve();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            a.a[i2][j2] <== a_mul.out[i2][j2];
        }
    }
    component b = Fp2Square();
    component c = Fp2Square();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            b.a[i3][j3] <== p[1][i3][j3];
            c.a[i3][j3] <== p[2][i3][j3];
        }
    }
    component three = FpThree();
    component d = Fp2MulByElement();
    for (var j4 = 0; j4 < 3; j4++) {
        d.element[j4] <== three.out[j4];
    }
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            d.a[i4][j4] <== c.out[i4][j4];
        }
    }
    component e = Fp2MulByBTwistCoeff();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            e.a[i5][j5] <== d.out[i5][j5];
        }
    }
    component f = Fp2MulByElement();
    for (var j6 = 0; j6 < 3; j6++) {
        f.element[j6] <== three.out[j6];
    }
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            f.a[i6][j6] <== e.out[i6][j6];
        }
    }
    component g = Fp2Add();
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            g.a[i7][j7] <== b.out[i7][j7];
            g.b[i7][j7] <== f.out[i7][j7];
        }
    }
    component g_half = Fp2Halve();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            g_half.a[i8][j8] <== g.out[i8][j8];
        }
    }
    component h_sum = Fp2Add();
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            h_sum.a[i9][j9] <== p[1][i9][j9];
            h_sum.b[i9][j9] <== p[2][i9][j9];
        }
    }
    component h_sq = Fp2Square();
    for (var i10 = 0; i10 < 2; i10++) {
        for (var j10 = 0; j10 < 3; j10++) {
            h_sq.a[i10][j10] <== h_sum.out[i10][j10];
        }
    }
    component h_tmp = Fp2Sub();
    for (var i11 = 0; i11 < 2; i11++) {
        for (var j11 = 0; j11 < 3; j11++) {
            h_tmp.a[i11][j11] <== h_sq.out[i11][j11];
            h_tmp.b[i11][j11] <== b.out[i11][j11];
        }
    }
    component h = Fp2Sub();
    for (var i12 = 0; i12 < 2; i12++) {
        for (var j12 = 0; j12 < 3; j12++) {
            h.a[i12][j12] <== h_tmp.out[i12][j12];
            h.b[i12][j12] <== c.out[i12][j12];
        }
    }
    component i = Fp2Sub();
    for (var i13 = 0; i13 < 2; i13++) {
        for (var j13 = 0; j13 < 3; j13++) {
            i.a[i13][j13] <== e.out[i13][j13];
            i.b[i13][j13] <== b.out[i13][j13];
        }
    }
    component j = Fp2Square();
    for (var i14 = 0; i14 < 2; i14++) {
        for (var j14 = 0; j14 < 3; j14++) {
            j.a[i14][j14] <== p[0][i14][j14];
        }
    }
    component ee = Fp2Square();
    for (var i15 = 0; i15 < 2; i15++) {
        for (var j15 = 0; j15 < 3; j15++) {
            ee.a[i15][j15] <== e.out[i15][j15];
        }
    }
    component k = Fp2MulByElement();
    for (var j16 = 0; j16 < 3; j16++) {
        k.element[j16] <== three.out[j16];
    }
    for (var i16 = 0; i16 < 2; i16++) {
        for (var j16 = 0; j16 < 3; j16++) {
            k.a[i16][j16] <== ee.out[i16][j16];
        }
    }

    component x = Fp2Sub();
    for (var i17 = 0; i17 < 2; i17++) {
        for (var j17 = 0; j17 < 3; j17++) {
            x.a[i17][j17] <== b.out[i17][j17];
            x.b[i17][j17] <== f.out[i17][j17];
        }
    }
    component x_mul = Fp2Mul();
    for (var i18 = 0; i18 < 2; i18++) {
        for (var j18 = 0; j18 < 3; j18++) {
            x_mul.a[i18][j18] <== x.out[i18][j18];
            x_mul.b[i18][j18] <== a.out[i18][j18];
        }
    }
    component y = Fp2Square();
    for (var i19 = 0; i19 < 2; i19++) {
        for (var j19 = 0; j19 < 3; j19++) {
            y.a[i19][j19] <== g_half.out[i19][j19];
        }
    }
    component y_sub = Fp2Sub();
    for (var i20 = 0; i20 < 2; i20++) {
        for (var j20 = 0; j20 < 3; j20++) {
            y_sub.a[i20][j20] <== y.out[i20][j20];
            y_sub.b[i20][j20] <== k.out[i20][j20];
        }
    }
    component z = Fp2Mul();
    for (var i21 = 0; i21 < 2; i21++) {
        for (var j21 = 0; j21 < 3; j21++) {
            z.a[i21][j21] <== b.out[i21][j21];
            z.b[i21][j21] <== h.out[i21][j21];
        }
    }

    component h_neg = Fp2Neg();
    for (var i22 = 0; i22 < 2; i22++) {
        for (var j22 = 0; j22 < 3; j22++) {
            h_neg.a[i22][j22] <== h.out[i22][j22];
        }
    }
    component j_mul = Fp2MulByElement();
    for (var j23 = 0; j23 < 3; j23++) {
        j_mul.element[j23] <== three.out[j23];
    }
    for (var i23 = 0; i23 < 2; i23++) {
        for (var j23 = 0; j23 < 3; j23++) {
            j_mul.a[i23][j23] <== j.out[i23][j23];
        }
    }

    for (var i24 = 0; i24 < 2; i24++) {
        for (var j24 = 0; j24 < 3; j24++) {
            out[0][i24][j24] <== x_mul.out[i24][j24];
            out[1][i24][j24] <== y_sub.out[i24][j24];
            out[2][i24][j24] <== z.out[i24][j24];

            line[0][i24][j24] <== h_neg.out[i24][j24];
            line[1][i24][j24] <== j_mul.out[i24][j24];
            line[2][i24][j24] <== i.out[i24][j24];
        }
    }
}

template G2ProjAddMixedStep() {
    signal input p[3][2][3];
    signal input a[2][2][3];
    signal output out[3][2][3];
    signal output line[3][2][3];

    component y2z1 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            y2z1.a[i][j] <== a[1][i][j];
            y2z1.b[i][j] <== p[2][i][j];
        }
    }
    component o = Fp2Sub();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            o.a[i2][j2] <== p[1][i2][j2];
            o.b[i2][j2] <== y2z1.out[i2][j2];
        }
    }
    component x2z1 = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            x2z1.a[i3][j3] <== a[0][i3][j3];
            x2z1.b[i3][j3] <== p[2][i3][j3];
        }
    }
    component l = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            l.a[i4][j4] <== p[0][i4][j4];
            l.b[i4][j4] <== x2z1.out[i4][j4];
        }
    }
    component c = Fp2Square();
    component d = Fp2Square();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            c.a[i5][j5] <== o.out[i5][j5];
            d.a[i5][j5] <== l.out[i5][j5];
        }
    }
    component e = Fp2Mul();
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            e.a[i6][j6] <== l.out[i6][j6];
            e.b[i6][j6] <== d.out[i6][j6];
        }
    }
    component f = Fp2Mul();
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            f.a[i7][j7] <== p[2][i7][j7];
            f.b[i7][j7] <== c.out[i7][j7];
        }
    }
    component g = Fp2Mul();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            g.a[i8][j8] <== p[0][i8][j8];
            g.b[i8][j8] <== d.out[i8][j8];
        }
    }
    component g_dbl = Fp2Double();
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            g_dbl.a[i9][j9] <== g.out[i9][j9];
        }
    }
    component h = Fp2Add();
    for (var i10 = 0; i10 < 2; i10++) {
        for (var j10 = 0; j10 < 3; j10++) {
            h.a[i10][j10] <== e.out[i10][j10];
            h.b[i10][j10] <== f.out[i10][j10];
        }
    }
    component h_sub = Fp2Sub();
    for (var i11 = 0; i11 < 2; i11++) {
        for (var j11 = 0; j11 < 3; j11++) {
            h_sub.a[i11][j11] <== h.out[i11][j11];
            h_sub.b[i11][j11] <== g_dbl.out[i11][j11];
        }
    }
    component t1 = Fp2Mul();
    for (var i12 = 0; i12 < 2; i12++) {
        for (var j12 = 0; j12 < 3; j12++) {
            t1.a[i12][j12] <== p[1][i12][j12];
            t1.b[i12][j12] <== e.out[i12][j12];
        }
    }
    component x = Fp2Mul();
    for (var i13 = 0; i13 < 2; i13++) {
        for (var j13 = 0; j13 < 3; j13++) {
            x.a[i13][j13] <== l.out[i13][j13];
            x.b[i13][j13] <== h_sub.out[i13][j13];
        }
    }
    component y = Fp2Sub();
    component g_minus_h = Fp2Sub();
    for (var i14 = 0; i14 < 2; i14++) {
        for (var j14 = 0; j14 < 3; j14++) {
            g_minus_h.a[i14][j14] <== g.out[i14][j14];
            g_minus_h.b[i14][j14] <== h_sub.out[i14][j14];
        }
    }
    component g_minus_h_mul = Fp2Mul();
    for (var i15 = 0; i15 < 2; i15++) {
        for (var j15 = 0; j15 < 3; j15++) {
            g_minus_h_mul.a[i15][j15] <== g_minus_h.out[i15][j15];
            g_minus_h_mul.b[i15][j15] <== o.out[i15][j15];
        }
    }
    for (var i16 = 0; i16 < 2; i16++) {
        for (var j16 = 0; j16 < 3; j16++) {
            y.a[i16][j16] <== g_minus_h_mul.out[i16][j16];
            y.b[i16][j16] <== t1.out[i16][j16];
        }
    }
    component z = Fp2Mul();
    for (var i17 = 0; i17 < 2; i17++) {
        for (var j17 = 0; j17 < 3; j17++) {
            z.a[i17][j17] <== e.out[i17][j17];
            z.b[i17][j17] <== p[2][i17][j17];
        }
    }
    component t2 = Fp2Mul();
    for (var i18 = 0; i18 < 2; i18++) {
        for (var j18 = 0; j18 < 3; j18++) {
            t2.a[i18][j18] <== l.out[i18][j18];
            t2.b[i18][j18] <== a[1][i18][j18];
        }
    }
    component j = Fp2Mul();
    for (var i19 = 0; i19 < 2; i19++) {
        for (var j19 = 0; j19 < 3; j19++) {
            j.a[i19][j19] <== a[0][i19][j19];
            j.b[i19][j19] <== o.out[i19][j19];
        }
    }
    component j_sub = Fp2Sub();
    for (var i20 = 0; i20 < 2; i20++) {
        for (var j20 = 0; j20 < 3; j20++) {
            j_sub.a[i20][j20] <== j.out[i20][j20];
            j_sub.b[i20][j20] <== t2.out[i20][j20];
        }
    }
    component o_neg = Fp2Neg();
    for (var i21 = 0; i21 < 2; i21++) {
        for (var j21 = 0; j21 < 3; j21++) {
            o_neg.a[i21][j21] <== o.out[i21][j21];
        }
    }

    for (var i22 = 0; i22 < 2; i22++) {
        for (var j22 = 0; j22 < 3; j22++) {
            out[0][i22][j22] <== x.out[i22][j22];
            out[1][i22][j22] <== y.out[i22][j22];
            out[2][i22][j22] <== z.out[i22][j22];

            line[0][i22][j22] <== l.out[i22][j22];
            line[1][i22][j22] <== o_neg.out[i22][j22];
            line[2][i22][j22] <== j_sub.out[i22][j22];
        }
    }
}

template G2ProjLineCompute() {
    signal input p[3][2][3];
    signal input a[2][2][3];
    signal output out[3][2][3];
    signal output line[3][2][3];

    component y2z1 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            y2z1.a[i][j] <== a[1][i][j];
            y2z1.b[i][j] <== p[2][i][j];
        }
    }
    component o = Fp2Sub();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            o.a[i2][j2] <== p[1][i2][j2];
            o.b[i2][j2] <== y2z1.out[i2][j2];
        }
    }
    component x2z1 = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            x2z1.a[i3][j3] <== a[0][i3][j3];
            x2z1.b[i3][j3] <== p[2][i3][j3];
        }
    }
    component l = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            l.a[i4][j4] <== p[0][i4][j4];
            l.b[i4][j4] <== x2z1.out[i4][j4];
        }
    }
    component t2 = Fp2Mul();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            t2.a[i5][j5] <== l.out[i5][j5];
            t2.b[i5][j5] <== a[1][i5][j5];
        }
    }
    component j = Fp2Mul();
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            j.a[i6][j6] <== a[0][i6][j6];
            j.b[i6][j6] <== o.out[i6][j6];
        }
    }
    component j_sub = Fp2Sub();
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            j_sub.a[i7][j7] <== j.out[i7][j7];
            j_sub.b[i7][j7] <== t2.out[i7][j7];
        }
    }
    component o_neg = Fp2Neg();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            o_neg.a[i8][j8] <== o.out[i8][j8];
        }
    }

    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            out[0][i9][j9] <== p[0][i9][j9];
            out[1][i9][j9] <== p[1][i9][j9];
            out[2][i9][j9] <== p[2][i9][j9];

            line[0][i9][j9] <== l.out[i9][j9];
            line[1][i9][j9] <== o_neg.out[i9][j9];
            line[2][i9][j9] <== j_sub.out[i9][j9];
        }
    }
}
