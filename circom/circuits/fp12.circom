pragma circom 2.0.0;

include "./fp6.circom";
include "./utils.circom";

template Fp12Zero() {
    signal output out[2][3][2];
    component zero = Fp6Zero();
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i = 0; i < 2; i++) {
                out[c][b][i] <== zero.out[b][i];
            }
        }
    }
}

template Fp12One() {
    signal output out[2][3][2];
    component one = Fp6One();
    component zero = Fp6Zero();
    for (var b = 0; b < 3; b++) {
        for (var i = 0; i < 2; i++) {
            out[0][b][i] <== one.out[b][i];
            out[1][b][i] <== zero.out[b][i];
        }
    }
}

template Fp12IsOne() {
    signal input a[2][3][2];
    signal output out;

    component one = Fp2One();
    component zero = Fp2Zero();

    component eqs[12];
    var idx = 0;
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i = 0; i < 2; i++) {
                eqs[idx] = IsEqual();
                eqs[idx].a <== a[c][b][i];
                if (c == 0 && b == 0) {
                    eqs[idx].b <== one.out[i];
                } else {
                    eqs[idx].b <== zero.out[i];
                }
                idx++;
            }
        }
    }

    signal acc[12];
    acc[0] <== eqs[0].out;
    for (var k = 1; k < 12; k++) {
        acc[k] <== acc[k - 1] * eqs[k].out;
    }
    out <== acc[11];
    out * (out - 1) === 0;
}

template Fp12Add() {
    signal input a[2][3][2];
    signal input b[2][3][2];
    signal output out[2][3][2];

    component add0 = Fp6Add();
    component add1 = Fp6Add();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            add0.a[k][i] <== a[0][k][i];
            add0.b[k][i] <== b[0][k][i];
            add1.a[k][i] <== a[1][k][i];
            add1.b[k][i] <== b[1][k][i];
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            out[0][k2][i2] <== add0.out[k2][i2];
            out[1][k2][i2] <== add1.out[k2][i2];
        }
    }
}

template Fp12Sub() {
    signal input a[2][3][2];
    signal input b[2][3][2];
    signal output out[2][3][2];

    component sub0 = Fp6Sub();
    component sub1 = Fp6Sub();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            sub0.a[k][i] <== a[0][k][i];
            sub0.b[k][i] <== b[0][k][i];
            sub1.a[k][i] <== a[1][k][i];
            sub1.b[k][i] <== b[1][k][i];
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            out[0][k2][i2] <== sub0.out[k2][i2];
            out[1][k2][i2] <== sub1.out[k2][i2];
        }
    }
}

template Fp12Neg() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component neg0 = Fp6Neg();
    component neg1 = Fp6Neg();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            neg0.a[k][i] <== a[0][k][i];
            neg1.a[k][i] <== a[1][k][i];
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            out[0][k2][i2] <== neg0.out[k2][i2];
            out[1][k2][i2] <== neg1.out[k2][i2];
        }
    }
}

template Fp12Conjugate() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component neg1 = Fp6Neg();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            out[0][k][i] <== a[0][k][i];
            neg1.a[k][i] <== a[1][k][i];
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            out[1][k2][i2] <== neg1.out[k2][i2];
        }
    }
}

template Fp12Mul() {
    signal input a[2][3][2];
    signal input b[2][3][2];
    signal output out[2][3][2];

    component a_sum = Fp6Add();
    component b_sum = Fp6Add();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            a_sum.a[k][i] <== a[0][k][i];
            a_sum.b[k][i] <== a[1][k][i];
            b_sum.a[k][i] <== b[0][k][i];
            b_sum.b[k][i] <== b[1][k][i];
        }
    }

    component a_mul = Fp6Mul();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            a_mul.a[k2][i2] <== a_sum.out[k2][i2];
            a_mul.b[k2][i2] <== b_sum.out[k2][i2];
        }
    }

    component b_mul = Fp6Mul();
    component c_mul = Fp6Mul();
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i3 = 0; i3 < 2; i3++) {
            b_mul.a[k3][i3] <== a[0][k3][i3];
            b_mul.b[k3][i3] <== b[0][k3][i3];
            c_mul.a[k3][i3] <== a[1][k3][i3];
            c_mul.b[k3][i3] <== b[1][k3][i3];
        }
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            c1_sub1.a[k4][i4] <== a_mul.out[k4][i4];
            c1_sub1.b[k4][i4] <== b_mul.out[k4][i4];
            c1_sub2.a[k4][i4] <== c1_sub1.out[k4][i4];
            c1_sub2.b[k4][i4] <== c_mul.out[k4][i4];
        }
    }

    component c0_nr = Fp6MulByNonResidue();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            c0_nr.a[k5][i5] <== c_mul.out[k5][i5];
        }
    }
    component c0 = Fp6Add();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6 = 0; i6 < 2; i6++) {
            c0.a[k6][i6] <== c0_nr.out[k6][i6];
            c0.b[k6][i6] <== b_mul.out[k6][i6];
        }
    }

    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            out[0][k7][i7] <== c0.out[k7][i7];
            out[1][k7][i7] <== c1_sub2.out[k7][i7];
        }
    }
}

template Fp12Square() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component ab = Fp6Mul();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            ab.a[k][i] <== a[0][k][i];
            ab.b[k][i] <== a[1][k][i];
        }
    }

    component a_sq = Fp6Square();
    component b_sq = Fp6Square();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            a_sq.a[k2][i2] <== a[0][k2][i2];
            b_sq.a[k2][i2] <== a[1][k2][i2];
        }
    }

    component b_nr = Fp6MulByNonResidue();
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i3 = 0; i3 < 2; i3++) {
            b_nr.a[k3][i3] <== b_sq.out[k3][i3];
        }
    }

    component c0 = Fp6Add();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            c0.a[k4][i4] <== a_sq.out[k4][i4];
            c0.b[k4][i4] <== b_nr.out[k4][i4];
        }
    }

    component c1 = Fp6Double();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            c1.a[k5][i5] <== ab.out[k5][i5];
        }
    }

    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6 = 0; i6 < 2; i6++) {
            out[0][k6][i6] <== c0.out[k6][i6];
            out[1][k6][i6] <== c1.out[k6][i6];
        }
    }
}

template Fp12Inverse() {
    signal input a[2][3][2];
    signal input inv[2][3][2];
    signal output out[2][3][2];

    component mul = Fp12Mul();
    for (var c = 0; c < 2; c++) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                mul.a[c][k][i] <== a[c][k][i];
                mul.b[c][k][i] <== inv[c][k][i];
            }
        }
    }

    component one = Fp12One();
    for (var c2 = 0; c2 < 2; c2++) {
        for (var k2 = 0; k2 < 3; k2++) {
            for (var i2 = 0; i2 < 2; i2++) {
                mul.out[c2][k2][i2] === one.out[c2][k2][i2];
                out[c2][k2][i2] <== inv[c2][k2][i2];
            }
        }
    }
}

template Fp12CyclotomicSquare() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component t0 = Fp2Square();
    component t1 = Fp2Square();
    for (var i = 0; i < 2; i++) {
        t0.a[i] <== a[1][1][i];
        t1.a[i] <== a[0][0][i];
    }

    component t6_add = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        t6_add.a[i2] <== a[1][1][i2];
        t6_add.b[i2] <== a[0][0][i2];
    }
    component t6_sq = Fp2Square();
    for (var i3 = 0; i3 < 2; i3++) {
        t6_sq.a[i3] <== t6_add.out[i3];
    }
    component t6_sub1 = Fp2Sub();
    component t6_sub2 = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        t6_sub1.a[i4] <== t6_sq.out[i4];
        t6_sub1.b[i4] <== t0.out[i4];
        t6_sub2.a[i4] <== t6_sub1.out[i4];
        t6_sub2.b[i4] <== t1.out[i4];
    }

    component t2 = Fp2Square();
    component t3 = Fp2Square();
    for (var i5 = 0; i5 < 2; i5++) {
        t2.a[i5] <== a[0][2][i5];
        t3.a[i5] <== a[1][0][i5];
    }

    component t7_add = Fp2Add();
    for (var i6 = 0; i6 < 2; i6++) {
        t7_add.a[i6] <== a[0][2][i6];
        t7_add.b[i6] <== a[1][0][i6];
    }
    component t7_sq = Fp2Square();
    for (var i7 = 0; i7 < 2; i7++) {
        t7_sq.a[i7] <== t7_add.out[i7];
    }
    component t7_sub1 = Fp2Sub();
    component t7_sub2 = Fp2Sub();
    for (var i8 = 0; i8 < 2; i8++) {
        t7_sub1.a[i8] <== t7_sq.out[i8];
        t7_sub1.b[i8] <== t2.out[i8];
        t7_sub2.a[i8] <== t7_sub1.out[i8];
        t7_sub2.b[i8] <== t3.out[i8];
    }

    component t4 = Fp2Square();
    component t5 = Fp2Square();
    for (var i9 = 0; i9 < 2; i9++) {
        t4.a[i9] <== a[1][2][i9];
        t5.a[i9] <== a[0][1][i9];
    }

    component t8_add = Fp2Add();
    for (var i10 = 0; i10 < 2; i10++) {
        t8_add.a[i10] <== a[1][2][i10];
        t8_add.b[i10] <== a[0][1][i10];
    }
    component t8_sq = Fp2Square();
    for (var i11 = 0; i11 < 2; i11++) {
        t8_sq.a[i11] <== t8_add.out[i11];
    }
    component t8_sub1 = Fp2Sub();
    component t8_sub2 = Fp2Sub();
    for (var i12 = 0; i12 < 2; i12++) {
        t8_sub1.a[i12] <== t8_sq.out[i12];
        t8_sub1.b[i12] <== t4.out[i12];
        t8_sub2.a[i12] <== t8_sub1.out[i12];
        t8_sub2.b[i12] <== t5.out[i12];
    }
    component t8 = Fp2MulByNonResidue();
    for (var i13 = 0; i13 < 2; i13++) {
        t8.a[i13] <== t8_sub2.out[i13];
    }

    component t0_nr = Fp2MulByNonResidue();
    component t2_nr = Fp2MulByNonResidue();
    component t4_nr = Fp2MulByNonResidue();
    for (var i14 = 0; i14 < 2; i14++) {
        t0_nr.a[i14] <== t0.out[i14];
        t2_nr.a[i14] <== t2.out[i14];
        t4_nr.a[i14] <== t4.out[i14];
    }

    component t0_add = Fp2Add();
    component t2_add = Fp2Add();
    component t4_add = Fp2Add();
    for (var i15 = 0; i15 < 2; i15++) {
        t0_add.a[i15] <== t0_nr.out[i15];
        t0_add.b[i15] <== t1.out[i15];
        t2_add.a[i15] <== t2_nr.out[i15];
        t2_add.b[i15] <== t3.out[i15];
        t4_add.a[i15] <== t4_nr.out[i15];
        t4_add.b[i15] <== t5.out[i15];
    }

    component z0_sub = Fp2Sub();
    component z0_dbl = Fp2Double();
    component z0 = Fp2Add();
    for (var i16 = 0; i16 < 2; i16++) {
        z0_sub.a[i16] <== t0_add.out[i16];
        z0_sub.b[i16] <== a[0][0][i16];
        z0_dbl.a[i16] <== z0_sub.out[i16];
        z0.a[i16] <== z0_dbl.out[i16];
        z0.b[i16] <== t0_add.out[i16];
    }

    component z1_sub = Fp2Sub();
    component z1_dbl = Fp2Double();
    component z1 = Fp2Add();
    for (var i17 = 0; i17 < 2; i17++) {
        z1_sub.a[i17] <== t2_add.out[i17];
        z1_sub.b[i17] <== a[0][1][i17];
        z1_dbl.a[i17] <== z1_sub.out[i17];
        z1.a[i17] <== z1_dbl.out[i17];
        z1.b[i17] <== t2_add.out[i17];
    }

    component z2_sub = Fp2Sub();
    component z2_dbl = Fp2Double();
    component z2 = Fp2Add();
    for (var i18 = 0; i18 < 2; i18++) {
        z2_sub.a[i18] <== t4_add.out[i18];
        z2_sub.b[i18] <== a[0][2][i18];
        z2_dbl.a[i18] <== z2_sub.out[i18];
        z2.a[i18] <== z2_dbl.out[i18];
        z2.b[i18] <== t4_add.out[i18];
    }

    component z3_add = Fp2Add();
    component z3_dbl = Fp2Double();
    component z3 = Fp2Add();
    for (var i19 = 0; i19 < 2; i19++) {
        z3_add.a[i19] <== t8.out[i19];
        z3_add.b[i19] <== a[1][0][i19];
        z3_dbl.a[i19] <== z3_add.out[i19];
        z3.a[i19] <== z3_dbl.out[i19];
        z3.b[i19] <== t8.out[i19];
    }

    component z4_add = Fp2Add();
    component z4_dbl = Fp2Double();
    component z4 = Fp2Add();
    for (var i20 = 0; i20 < 2; i20++) {
        z4_add.a[i20] <== t6_sub2.out[i20];
        z4_add.b[i20] <== a[1][1][i20];
        z4_dbl.a[i20] <== z4_add.out[i20];
        z4.a[i20] <== z4_dbl.out[i20];
        z4.b[i20] <== t6_sub2.out[i20];
    }

    component z5_add = Fp2Add();
    component z5_dbl = Fp2Double();
    component z5 = Fp2Add();
    for (var i21 = 0; i21 < 2; i21++) {
        z5_add.a[i21] <== t7_sub2.out[i21];
        z5_add.b[i21] <== a[1][2][i21];
        z5_dbl.a[i21] <== z5_add.out[i21];
        z5.a[i21] <== z5_dbl.out[i21];
        z5.b[i21] <== t7_sub2.out[i21];
    }

    for (var i22 = 0; i22 < 2; i22++) {
        out[0][0][i22] <== z0.out[i22];
        out[0][1][i22] <== z1.out[i22];
        out[0][2][i22] <== z2.out[i22];
        out[1][0][i22] <== z3.out[i22];
        out[1][1][i22] <== z4.out[i22];
        out[1][2][i22] <== z5.out[i22];
    }
}

template Fp12Frobenius() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component t0 = Fp2Conjugate();
    component t1 = Fp2Conjugate();
    component t2 = Fp2Conjugate();
    component t3 = Fp2Conjugate();
    component t4 = Fp2Conjugate();
    component t5 = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        t0.a[i] <== a[0][0][i];
        t1.a[i] <== a[0][1][i];
        t2.a[i] <== a[0][2][i];
        t3.a[i] <== a[1][0][i];
        t4.a[i] <== a[1][1][i];
        t5.a[i] <== a[1][2][i];
    }

    component t1_mul = Fp2MulByNonResidue1Power2();
    component t2_mul = Fp2MulByNonResidue1Power4();
    component t3_mul = Fp2MulByNonResidue1Power1();
    component t4_mul = Fp2MulByNonResidue1Power3();
    component t5_mul = Fp2MulByNonResidue1Power5();
    for (var i2 = 0; i2 < 2; i2++) {
        t1_mul.a[i2] <== t1.out[i2];
        t2_mul.a[i2] <== t2.out[i2];
        t3_mul.a[i2] <== t3.out[i2];
        t4_mul.a[i2] <== t4.out[i2];
        t5_mul.a[i2] <== t5.out[i2];
    }

    for (var i3 = 0; i3 < 2; i3++) {
        out[0][0][i3] <== t0.out[i3];
        out[0][1][i3] <== t1_mul.out[i3];
        out[0][2][i3] <== t2_mul.out[i3];
        out[1][0][i3] <== t3_mul.out[i3];
        out[1][1][i3] <== t4_mul.out[i3];
        out[1][2][i3] <== t5_mul.out[i3];
    }
}

template Fp12FrobeniusSquare() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component t1 = Fp2MulByNonResidue2Power2();
    component t2 = Fp2MulByNonResidue2Power4();
    component t3 = Fp2MulByNonResidue2Power1();
    component t4 = Fp2MulByNonResidue2Power3();
    component t5 = Fp2MulByNonResidue2Power5();
    for (var i = 0; i < 2; i++) {
        t1.a[i] <== a[0][1][i];
        t2.a[i] <== a[0][2][i];
        t3.a[i] <== a[1][0][i];
        t4.a[i] <== a[1][1][i];
        t5.a[i] <== a[1][2][i];
    }

    for (var i2 = 0; i2 < 2; i2++) {
        out[0][0][i2] <== a[0][0][i2];
        out[0][1][i2] <== t1.out[i2];
        out[0][2][i2] <== t2.out[i2];
        out[1][0][i2] <== t3.out[i2];
        out[1][1][i2] <== t4.out[i2];
        out[1][2][i2] <== t5.out[i2];
    }
}

template Fp12FrobeniusCube() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component t0 = Fp2Conjugate();
    component t1 = Fp2Conjugate();
    component t2 = Fp2Conjugate();
    component t3 = Fp2Conjugate();
    component t4 = Fp2Conjugate();
    component t5 = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        t0.a[i] <== a[0][0][i];
        t1.a[i] <== a[0][1][i];
        t2.a[i] <== a[0][2][i];
        t3.a[i] <== a[1][0][i];
        t4.a[i] <== a[1][1][i];
        t5.a[i] <== a[1][2][i];
    }

    component t1_mul = Fp2MulByNonResidue3Power2();
    component t2_mul = Fp2MulByNonResidue3Power4();
    component t3_mul = Fp2MulByNonResidue3Power1();
    component t4_mul = Fp2MulByNonResidue3Power3();
    component t5_mul = Fp2MulByNonResidue3Power5();
    for (var i2 = 0; i2 < 2; i2++) {
        t1_mul.a[i2] <== t1.out[i2];
        t2_mul.a[i2] <== t2.out[i2];
        t3_mul.a[i2] <== t3.out[i2];
        t4_mul.a[i2] <== t4.out[i2];
        t5_mul.a[i2] <== t5.out[i2];
    }

    for (var i3 = 0; i3 < 2; i3++) {
        out[0][0][i3] <== t0.out[i3];
        out[0][1][i3] <== t1_mul.out[i3];
        out[0][2][i3] <== t2_mul.out[i3];
        out[1][0][i3] <== t3_mul.out[i3];
        out[1][1][i3] <== t4_mul.out[i3];
        out[1][2][i3] <== t5_mul.out[i3];
    }
}

template Fp12MulBy034() {
    signal input a[2][3][2];
    signal input c0[2];
    signal input c3[2];
    signal input c4[2];
    signal output out[2][3][2];

    component a_mul = Fp6MulByE2();
    component b_mul = Fp6MulBy01();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            a_mul.a[k][i] <== a[0][k][i];
            b_mul.a[k][i] <== a[1][k][i];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        a_mul.c0[i2] <== c0[i2];
        b_mul.c0[i2] <== c3[i2];
        b_mul.c1[i2] <== c4[i2];
    }

    component d0 = Fp2Add();
    for (var i3 = 0; i3 < 2; i3++) {
        d0.a[i3] <== c0[i3];
        d0.b[i3] <== c3[i3];
    }

    component d_sum = Fp6Add();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            d_sum.a[k4][i4] <== a[0][k4][i4];
            d_sum.b[k4][i4] <== a[1][k4][i4];
        }
    }

    component d_mul = Fp6MulBy01();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            d_mul.a[k5][i5] <== d_sum.out[k5][i5];
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        d_mul.c0[i6] <== d0.out[i6];
        d_mul.c1[i6] <== c4[i6];
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6b = 0; i6b < 2; i6b++) {
            c1_sub1.a[k6][i6b] <== d_mul.out[k6][i6b];
            c1_sub1.b[k6][i6b] <== a_mul.out[k6][i6b];
            c1_sub2.a[k6][i6b] <== c1_sub1.out[k6][i6b];
            c1_sub2.b[k6][i6b] <== b_mul.out[k6][i6b];
        }
    }

    component b_nr = Fp6MulByNonResidue();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            b_nr.a[k7][i7] <== b_mul.out[k7][i7];
        }
    }
    component c0_sum = Fp6Add();
    for (var k8 = 0; k8 < 3; k8++) {
        for (var i8 = 0; i8 < 2; i8++) {
            c0_sum.a[k8][i8] <== b_nr.out[k8][i8];
            c0_sum.b[k8][i8] <== a_mul.out[k8][i8];
        }
    }

    for (var k9 = 0; k9 < 3; k9++) {
        for (var i9 = 0; i9 < 2; i9++) {
            out[0][k9][i9] <== c0_sum.out[k9][i9];
            out[1][k9][i9] <== c1_sub2.out[k9][i9];
        }
    }
}

template Fp12MulBy34() {
    signal input a[2][3][2];
    signal input c3[2];
    signal input c4[2];
    signal output out[2][3][2];

    component b_mul = Fp6MulBy01();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            b_mul.a[k][i] <== a[1][k][i];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        b_mul.c0[i2] <== c3[i2];
        b_mul.c1[i2] <== c4[i2];
    }

    component d0 = Fp2Add();
    component one = Fp2One();
    for (var i3 = 0; i3 < 2; i3++) {
        d0.a[i3] <== one.out[i3];
        d0.b[i3] <== c3[i3];
    }

    component d_sum = Fp6Add();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            d_sum.a[k4][i4] <== a[0][k4][i4];
            d_sum.b[k4][i4] <== a[1][k4][i4];
        }
    }

    component d_mul = Fp6MulBy01();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            d_mul.a[k5][i5] <== d_sum.out[k5][i5];
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        d_mul.c0[i6] <== d0.out[i6];
        d_mul.c1[i6] <== c4[i6];
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6b = 0; i6b < 2; i6b++) {
            c1_sub1.a[k6][i6b] <== d_mul.out[k6][i6b];
            c1_sub1.b[k6][i6b] <== a[0][k6][i6b];
            c1_sub2.a[k6][i6b] <== c1_sub1.out[k6][i6b];
            c1_sub2.b[k6][i6b] <== b_mul.out[k6][i6b];
        }
    }

    component b_nr = Fp6MulByNonResidue();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            b_nr.a[k7][i7] <== b_mul.out[k7][i7];
        }
    }
    component c0 = Fp6Add();
    for (var k8 = 0; k8 < 3; k8++) {
        for (var i8 = 0; i8 < 2; i8++) {
            c0.a[k8][i8] <== b_nr.out[k8][i8];
            c0.b[k8][i8] <== a[0][k8][i8];
        }
    }

    for (var k9 = 0; k9 < 3; k9++) {
        for (var i9 = 0; i9 < 2; i9++) {
            out[0][k9][i9] <== c0.out[k9][i9];
            out[1][k9][i9] <== c1_sub2.out[k9][i9];
        }
    }
}

template Fp12MulBy01234() {
    signal input a[2][3][2];
    signal input x[5][2];
    signal output out[2][3][2];

    signal c0[3][2];
    signal c1[3][2];
    for (var i = 0; i < 2; i++) {
        c0[0][i] <== x[0][i];
        c0[1][i] <== x[1][i];
        c0[2][i] <== x[2][i];
        c1[0][i] <== x[3][i];
        c1[1][i] <== x[4][i];
        c1[2][i] <== 0;
    }

    component a_sum = Fp6Add();
    component c_sum = Fp6Add();
    for (var k = 0; k < 3; k++) {
        for (var i2 = 0; i2 < 2; i2++) {
            a_sum.a[k][i2] <== a[0][k][i2];
            a_sum.b[k][i2] <== a[1][k][i2];
            c_sum.a[k][i2] <== c0[k][i2];
            c_sum.b[k][i2] <== c1[k][i2];
        }
    }

    component a_mul = Fp6Mul();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i3 = 0; i3 < 2; i3++) {
            a_mul.a[k2][i3] <== a_sum.out[k2][i3];
            a_mul.b[k2][i3] <== c_sum.out[k2][i3];
        }
    }

    component b_mul = Fp6Mul();
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i4 = 0; i4 < 2; i4++) {
            b_mul.a[k3][i4] <== a[0][k3][i4];
            b_mul.b[k3][i4] <== c0[k3][i4];
        }
    }

    component c_mul = Fp6MulBy01();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i5 = 0; i5 < 2; i5++) {
            c_mul.a[k4][i5] <== a[1][k4][i5];
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        c_mul.c0[i6] <== x[3][i6];
        c_mul.c1[i6] <== x[4][i6];
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i7 = 0; i7 < 2; i7++) {
            c1_sub1.a[k5][i7] <== a_mul.out[k5][i7];
            c1_sub1.b[k5][i7] <== b_mul.out[k5][i7];
            c1_sub2.a[k5][i7] <== c1_sub1.out[k5][i7];
            c1_sub2.b[k5][i7] <== c_mul.out[k5][i7];
        }
    }

    component c_nr = Fp6MulByNonResidue();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i8 = 0; i8 < 2; i8++) {
            c_nr.a[k6][i8] <== c_mul.out[k6][i8];
        }
    }
    component c0_out = Fp6Add();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i9 = 0; i9 < 2; i9++) {
            c0_out.a[k7][i9] <== c_nr.out[k7][i9];
            c0_out.b[k7][i9] <== b_mul.out[k7][i9];
        }
    }

    for (var k8 = 0; k8 < 3; k8++) {
        for (var i10 = 0; i10 < 2; i10++) {
            out[0][k8][i10] <== c0_out.out[k8][i10];
            out[1][k8][i10] <== c1_sub2.out[k8][i10];
        }
    }
}

template Mul034By034() {
    signal input d0[2];
    signal input d3[2];
    signal input d4[2];
    signal input c0[2];
    signal input c3[2];
    signal input c4[2];
    signal output out[5][2];

    component x0 = Fp2Mul();
    component x3 = Fp2Mul();
    component x4 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        x0.a[i] <== c0[i];
        x0.b[i] <== d0[i];
        x3.a[i] <== c3[i];
        x3.b[i] <== d3[i];
        x4.a[i] <== c4[i];
        x4.b[i] <== d4[i];
    }

    component x04_mul = Fp2Mul();
    component c0_plus_c4 = Fp2Add();
    component d0_plus_d4 = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        c0_plus_c4.a[i2] <== c0[i2];
        c0_plus_c4.b[i2] <== c4[i2];
        d0_plus_d4.a[i2] <== d0[i2];
        d0_plus_d4.b[i2] <== d4[i2];
        x04_mul.a[i2] <== c0_plus_c4.out[i2];
        x04_mul.b[i2] <== d0_plus_d4.out[i2];
    }
    component x04_sub1 = Fp2Sub();
    component x04 = Fp2Sub();
    for (var i3 = 0; i3 < 2; i3++) {
        x04_sub1.a[i3] <== x04_mul.out[i3];
        x04_sub1.b[i3] <== x0.out[i3];
        x04.a[i3] <== x04_sub1.out[i3];
        x04.b[i3] <== x4.out[i3];
    }

    component x03_mul = Fp2Mul();
    component c0_plus_c3 = Fp2Add();
    component d0_plus_d3 = Fp2Add();
    for (var i4 = 0; i4 < 2; i4++) {
        c0_plus_c3.a[i4] <== c0[i4];
        c0_plus_c3.b[i4] <== c3[i4];
        d0_plus_d3.a[i4] <== d0[i4];
        d0_plus_d3.b[i4] <== d3[i4];
        x03_mul.a[i4] <== c0_plus_c3.out[i4];
        x03_mul.b[i4] <== d0_plus_d3.out[i4];
    }
    component x03_sub1 = Fp2Sub();
    component x03 = Fp2Sub();
    for (var i5 = 0; i5 < 2; i5++) {
        x03_sub1.a[i5] <== x03_mul.out[i5];
        x03_sub1.b[i5] <== x0.out[i5];
        x03.a[i5] <== x03_sub1.out[i5];
        x03.b[i5] <== x3.out[i5];
    }

    component x34_mul = Fp2Mul();
    component c3_plus_c4 = Fp2Add();
    component d3_plus_d4 = Fp2Add();
    for (var i6 = 0; i6 < 2; i6++) {
        c3_plus_c4.a[i6] <== c3[i6];
        c3_plus_c4.b[i6] <== c4[i6];
        d3_plus_d4.a[i6] <== d3[i6];
        d3_plus_d4.b[i6] <== d4[i6];
        x34_mul.a[i6] <== c3_plus_c4.out[i6];
        x34_mul.b[i6] <== d3_plus_d4.out[i6];
    }
    component x34_sub1 = Fp2Sub();
    component x34 = Fp2Sub();
    for (var i7 = 0; i7 < 2; i7++) {
        x34_sub1.a[i7] <== x34_mul.out[i7];
        x34_sub1.b[i7] <== x3.out[i7];
        x34.a[i7] <== x34_sub1.out[i7];
        x34.b[i7] <== x4.out[i7];
    }

    component z00_nr = Fp2MulByNonResidue();
    for (var i8 = 0; i8 < 2; i8++) {
        z00_nr.a[i8] <== x4.out[i8];
    }
    component z00 = Fp2Add();
    for (var i9 = 0; i9 < 2; i9++) {
        z00.a[i9] <== z00_nr.out[i9];
        z00.b[i9] <== x0.out[i9];
    }

    for (var i10 = 0; i10 < 2; i10++) {
        out[0][i10] <== z00.out[i10];
        out[1][i10] <== x3.out[i10];
        out[2][i10] <== x34.out[i10];
        out[3][i10] <== x03.out[i10];
        out[4][i10] <== x04.out[i10];
    }
}

template Fp12NSquare(n) {
    signal input a[2][3][2];
    signal output out[2][3][2];

    if (n == 0) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                out[0][k][i] <== a[0][k][i];
                out[1][k][i] <== a[1][k][i];
            }
        }
    } else {
        component sq[n];
        for (var idx = 0; idx < n; idx++) {
            sq[idx] = Fp12CyclotomicSquare();
            if (idx == 0) {
                for (var k2 = 0; k2 < 3; k2++) {
                    for (var i2 = 0; i2 < 2; i2++) {
                        sq[idx].a[0][k2][i2] <== a[0][k2][i2];
                        sq[idx].a[1][k2][i2] <== a[1][k2][i2];
                    }
                }
            } else {
                for (var k3 = 0; k3 < 3; k3++) {
                    for (var i3 = 0; i3 < 2; i3++) {
                        sq[idx].a[0][k3][i3] <== sq[idx - 1].out[0][k3][i3];
                        sq[idx].a[1][k3][i3] <== sq[idx - 1].out[1][k3][i3];
                    }
                }
            }
        }
        for (var k4 = 0; k4 < 3; k4++) {
            for (var i4 = 0; i4 < 2; i4++) {
                out[0][k4][i4] <== sq[n - 1].out[0][k4][i4];
                out[1][k4][i4] <== sq[n - 1].out[1][k4][i4];
            }
        }
    }
}

template Fp12Expt() {
    signal input a[2][3][2];
    signal output out[2][3][2];

    component t3 = Fp12CyclotomicSquare();
    component t5 = Fp12CyclotomicSquare();
    component result = Fp12CyclotomicSquare();
    component t0_sq = Fp12CyclotomicSquare();

    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            t3.a[0][k][i] <== a[0][k][i];
            t3.a[1][k][i] <== a[1][k][i];
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            t5.a[0][k2][i2] <== t3.out[0][k2][i2];
            t5.a[1][k2][i2] <== t3.out[1][k2][i2];
        }
    }
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i3 = 0; i3 < 2; i3++) {
            result.a[0][k3][i3] <== t5.out[0][k3][i3];
            result.a[1][k3][i3] <== t5.out[1][k3][i3];
        }
    }
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            t0_sq.a[0][k4][i4] <== result.out[0][k4][i4];
            t0_sq.a[1][k4][i4] <== result.out[1][k4][i4];
        }
    }

    component t2 = Fp12Mul();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            t2.a[0][k5][i5] <== a[0][k5][i5];
            t2.a[1][k5][i5] <== a[1][k5][i5];
            t2.b[0][k5][i5] <== t0_sq.out[0][k5][i5];
            t2.b[1][k5][i5] <== t0_sq.out[1][k5][i5];
        }
    }

    component t0 = Fp12Mul();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6 = 0; i6 < 2; i6++) {
            t0.a[0][k6][i6] <== t3.out[0][k6][i6];
            t0.a[1][k6][i6] <== t3.out[1][k6][i6];
            t0.b[0][k6][i6] <== t2.out[0][k6][i6];
            t0.b[1][k6][i6] <== t2.out[1][k6][i6];
        }
    }

    component t1 = Fp12Mul();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            t1.a[0][k7][i7] <== a[0][k7][i7];
            t1.a[1][k7][i7] <== a[1][k7][i7];
            t1.b[0][k7][i7] <== t0.out[0][k7][i7];
            t1.b[1][k7][i7] <== t0.out[1][k7][i7];
        }
    }

    component t4 = Fp12Mul();
    for (var k8 = 0; k8 < 3; k8++) {
        for (var i8 = 0; i8 < 2; i8++) {
            t4.a[0][k8][i8] <== result.out[0][k8][i8];
            t4.a[1][k8][i8] <== result.out[1][k8][i8];
            t4.b[0][k8][i8] <== t2.out[0][k8][i8];
            t4.b[1][k8][i8] <== t2.out[1][k8][i8];
        }
    }

    component t6 = Fp12CyclotomicSquare();
    for (var k9 = 0; k9 < 3; k9++) {
        for (var i9 = 0; i9 < 2; i9++) {
            t6.a[0][k9][i9] <== t2.out[0][k9][i9];
            t6.a[1][k9][i9] <== t2.out[1][k9][i9];
        }
    }

    component t1b = Fp12Mul();
    for (var k10 = 0; k10 < 3; k10++) {
        for (var i10 = 0; i10 < 2; i10++) {
            t1b.a[0][k10][i10] <== t0.out[0][k10][i10];
            t1b.a[1][k10][i10] <== t0.out[1][k10][i10];
            t1b.b[0][k10][i10] <== t1.out[0][k10][i10];
            t1b.b[1][k10][i10] <== t1.out[1][k10][i10];
        }
    }

    component t0b = Fp12Mul();
    for (var k11 = 0; k11 < 3; k11++) {
        for (var i11 = 0; i11 < 2; i11++) {
            t0b.a[0][k11][i11] <== t3.out[0][k11][i11];
            t0b.a[1][k11][i11] <== t3.out[1][k11][i11];
            t0b.b[0][k11][i11] <== t1b.out[0][k11][i11];
            t0b.b[1][k11][i11] <== t1b.out[1][k11][i11];
        }
    }

    component t6_ns = Fp12NSquare(6);
    for (var k12 = 0; k12 < 3; k12++) {
        for (var i12 = 0; i12 < 2; i12++) {
            t6_ns.a[0][k12][i12] <== t6.out[0][k12][i12];
            t6_ns.a[1][k12][i12] <== t6.out[1][k12][i12];
        }
    }

    component t5b = Fp12Mul();
    for (var k13 = 0; k13 < 3; k13++) {
        for (var i13 = 0; i13 < 2; i13++) {
            t5b.a[0][k13][i13] <== t5.out[0][k13][i13];
            t5b.a[1][k13][i13] <== t5.out[1][k13][i13];
            t5b.b[0][k13][i13] <== t6_ns.out[0][k13][i13];
            t5b.b[1][k13][i13] <== t6_ns.out[1][k13][i13];
        }
    }

    component t5c = Fp12Mul();
    for (var k14 = 0; k14 < 3; k14++) {
        for (var i14 = 0; i14 < 2; i14++) {
            t5c.a[0][k14][i14] <== t4.out[0][k14][i14];
            t5c.a[1][k14][i14] <== t4.out[1][k14][i14];
            t5c.b[0][k14][i14] <== t5b.out[0][k14][i14];
            t5c.b[1][k14][i14] <== t5b.out[1][k14][i14];
        }
    }

    component t5_ns = Fp12NSquare(7);
    for (var k15 = 0; k15 < 3; k15++) {
        for (var i15 = 0; i15 < 2; i15++) {
            t5_ns.a[0][k15][i15] <== t5c.out[0][k15][i15];
            t5_ns.a[1][k15][i15] <== t5c.out[1][k15][i15];
        }
    }

    component t4b = Fp12Mul();
    for (var k16 = 0; k16 < 3; k16++) {
        for (var i16 = 0; i16 < 2; i16++) {
            t4b.a[0][k16][i16] <== t4.out[0][k16][i16];
            t4b.a[1][k16][i16] <== t4.out[1][k16][i16];
            t4b.b[0][k16][i16] <== t5_ns.out[0][k16][i16];
            t4b.b[1][k16][i16] <== t5_ns.out[1][k16][i16];
        }
    }

    component t4_ns = Fp12NSquare(8);
    for (var k17 = 0; k17 < 3; k17++) {
        for (var i17 = 0; i17 < 2; i17++) {
            t4_ns.a[0][k17][i17] <== t4b.out[0][k17][i17];
            t4_ns.a[1][k17][i17] <== t4b.out[1][k17][i17];
        }
    }

    component t4c = Fp12Mul();
    for (var k18 = 0; k18 < 3; k18++) {
        for (var i18 = 0; i18 < 2; i18++) {
            t4c.a[0][k18][i18] <== t4_ns.out[0][k18][i18];
            t4c.a[1][k18][i18] <== t4_ns.out[1][k18][i18];
            t4c.b[0][k18][i18] <== t0b.out[0][k18][i18];
            t4c.b[1][k18][i18] <== t0b.out[1][k18][i18];
        }
    }

    component t3b = Fp12Mul();
    for (var k19 = 0; k19 < 3; k19++) {
        for (var i19 = 0; i19 < 2; i19++) {
            t3b.a[0][k19][i19] <== t3.out[0][k19][i19];
            t3b.a[1][k19][i19] <== t3.out[1][k19][i19];
            t3b.b[0][k19][i19] <== t4c.out[0][k19][i19];
            t3b.b[1][k19][i19] <== t4c.out[1][k19][i19];
        }
    }

    component t3_ns = Fp12NSquare(6);
    for (var k20 = 0; k20 < 3; k20++) {
        for (var i20 = 0; i20 < 2; i20++) {
            t3_ns.a[0][k20][i20] <== t3b.out[0][k20][i20];
            t3_ns.a[1][k20][i20] <== t3b.out[1][k20][i20];
        }
    }

    component t2b = Fp12Mul();
    for (var k21 = 0; k21 < 3; k21++) {
        for (var i21 = 0; i21 < 2; i21++) {
            t2b.a[0][k21][i21] <== t2.out[0][k21][i21];
            t2b.a[1][k21][i21] <== t2.out[1][k21][i21];
            t2b.b[0][k21][i21] <== t3_ns.out[0][k21][i21];
            t2b.b[1][k21][i21] <== t3_ns.out[1][k21][i21];
        }
    }

    component t2_ns = Fp12NSquare(8);
    for (var k22 = 0; k22 < 3; k22++) {
        for (var i22 = 0; i22 < 2; i22++) {
            t2_ns.a[0][k22][i22] <== t2b.out[0][k22][i22];
            t2_ns.a[1][k22][i22] <== t2b.out[1][k22][i22];
        }
    }

    component t2c = Fp12Mul();
    for (var k23 = 0; k23 < 3; k23++) {
        for (var i23 = 0; i23 < 2; i23++) {
            t2c.a[0][k23][i23] <== t2_ns.out[0][k23][i23];
            t2c.a[1][k23][i23] <== t2_ns.out[1][k23][i23];
            t2c.b[0][k23][i23] <== t0b.out[0][k23][i23];
            t2c.b[1][k23][i23] <== t0b.out[1][k23][i23];
        }
    }

    component t2_ns2 = Fp12NSquare(6);
    for (var k24 = 0; k24 < 3; k24++) {
        for (var i24 = 0; i24 < 2; i24++) {
            t2_ns2.a[0][k24][i24] <== t2c.out[0][k24][i24];
            t2_ns2.a[1][k24][i24] <== t2c.out[1][k24][i24];
        }
    }

    component t2d = Fp12Mul();
    for (var k25 = 0; k25 < 3; k25++) {
        for (var i25 = 0; i25 < 2; i25++) {
            t2d.a[0][k25][i25] <== t2_ns2.out[0][k25][i25];
            t2d.a[1][k25][i25] <== t2_ns2.out[1][k25][i25];
            t2d.b[0][k25][i25] <== t0b.out[0][k25][i25];
            t2d.b[1][k25][i25] <== t0b.out[1][k25][i25];
        }
    }

    component t2_ns3 = Fp12NSquare(10);
    for (var k26 = 0; k26 < 3; k26++) {
        for (var i26 = 0; i26 < 2; i26++) {
            t2_ns3.a[0][k26][i26] <== t2d.out[0][k26][i26];
            t2_ns3.a[1][k26][i26] <== t2d.out[1][k26][i26];
        }
    }

    component t1c = Fp12Mul();
    for (var k27 = 0; k27 < 3; k27++) {
        for (var i27 = 0; i27 < 2; i27++) {
            t1c.a[0][k27][i27] <== t1b.out[0][k27][i27];
            t1c.a[1][k27][i27] <== t1b.out[1][k27][i27];
            t1c.b[0][k27][i27] <== t2_ns3.out[0][k27][i27];
            t1c.b[1][k27][i27] <== t2_ns3.out[1][k27][i27];
        }
    }

    component t1_ns = Fp12NSquare(6);
    for (var k28 = 0; k28 < 3; k28++) {
        for (var i28 = 0; i28 < 2; i28++) {
            t1_ns.a[0][k28][i28] <== t1c.out[0][k28][i28];
            t1_ns.a[1][k28][i28] <== t1c.out[1][k28][i28];
        }
    }

    component t0c = Fp12Mul();
    for (var k29 = 0; k29 < 3; k29++) {
        for (var i29 = 0; i29 < 2; i29++) {
            t0c.a[0][k29][i29] <== t0b.out[0][k29][i29];
            t0c.a[1][k29][i29] <== t0b.out[1][k29][i29];
            t0c.b[0][k29][i29] <== t1_ns.out[0][k29][i29];
            t0c.b[1][k29][i29] <== t1_ns.out[1][k29][i29];
        }
    }

    component result_out = Fp12Mul();
    for (var k30 = 0; k30 < 3; k30++) {
        for (var i30 = 0; i30 < 2; i30++) {
            result_out.a[0][k30][i30] <== result.out[0][k30][i30];
            result_out.a[1][k30][i30] <== result.out[1][k30][i30];
            result_out.b[0][k30][i30] <== t0c.out[0][k30][i30];
            result_out.b[1][k30][i30] <== t0c.out[1][k30][i30];
        }
    }

    for (var k31 = 0; k31 < 3; k31++) {
        for (var i31 = 0; i31 < 2; i31++) {
            out[0][k31][i31] <== result_out.out[0][k31][i31];
            out[1][k31][i31] <== result_out.out[1][k31][i31];
        }
    }
}
