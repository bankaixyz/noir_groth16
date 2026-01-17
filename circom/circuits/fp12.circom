pragma circom 2.0.0;

include "./fp6.circom";
include "./utils.circom";

template Fp12Zero() {
    signal output out[2][3][2][3];
    component zero = Fp6Zero();
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    out[c][b][i][j] <== zero.out[b][i][j];
                }
            }
        }
    }
}

template Fp12One() {
    signal output out[2][3][2][3];
    component one = Fp6One();
    component zero = Fp6Zero();
    for (var b = 0; b < 3; b++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                out[0][b][i][j] <== one.out[b][i][j];
                out[1][b][i][j] <== zero.out[b][i][j];
            }
        }
    }
}

template Fp12IsOne() {
    signal input a[2][3][2][3];
    signal output out;

    component one = Fp2One();
    component zero = Fp2Zero();

    component eqs[36];
    var idx = 0;
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    eqs[idx] = IsEqual();
                    eqs[idx].a <== a[c][b][i][j];
                    if (c == 0 && b == 0) {
                        eqs[idx].b <== one.out[i][j];
                    } else {
                        eqs[idx].b <== zero.out[i][j];
                    }
                    idx++;
                }
            }
        }
    }

    var acc = 1;
    for (var k = 0; k < 36; k++) {
        acc *= eqs[k].out;
    }
    out <== acc;
}

template Fp12Add() {
    signal input a[2][3][2][3];
    signal input b[2][3][2][3];
    signal output out[2][3][2][3];

    component add0 = Fp6Add();
    component add1 = Fp6Add();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                add0.a[k][i][j] <== a[0][k][i][j];
                add0.b[k][i][j] <== b[0][k][i][j];
                add1.a[k][i][j] <== a[1][k][i][j];
                add1.b[k][i][j] <== b[1][k][i][j];
            }
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                out[0][k2][i2][j2] <== add0.out[k2][i2][j2];
                out[1][k2][i2][j2] <== add1.out[k2][i2][j2];
            }
        }
    }
}

template Fp12Sub() {
    signal input a[2][3][2][3];
    signal input b[2][3][2][3];
    signal output out[2][3][2][3];

    component sub0 = Fp6Sub();
    component sub1 = Fp6Sub();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                sub0.a[k][i][j] <== a[0][k][i][j];
                sub0.b[k][i][j] <== b[0][k][i][j];
                sub1.a[k][i][j] <== a[1][k][i][j];
                sub1.b[k][i][j] <== b[1][k][i][j];
            }
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                out[0][k2][i2][j2] <== sub0.out[k2][i2][j2];
                out[1][k2][i2][j2] <== sub1.out[k2][i2][j2];
            }
        }
    }
}

template Fp12Neg() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component neg0 = Fp6Neg();
    component neg1 = Fp6Neg();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                neg0.a[k][i][j] <== a[0][k][i][j];
                neg1.a[k][i][j] <== a[1][k][i][j];
            }
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                out[0][k2][i2][j2] <== neg0.out[k2][i2][j2];
                out[1][k2][i2][j2] <== neg1.out[k2][i2][j2];
            }
        }
    }
}

template Fp12Conjugate() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component neg1 = Fp6Neg();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                out[0][k][i][j] <== a[0][k][i][j];
                neg1.a[k][i][j] <== a[1][k][i][j];
            }
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                out[1][k2][i2][j2] <== neg1.out[k2][i2][j2];
            }
        }
    }
}

template Fp12Mul() {
    signal input a[2][3][2][3];
    signal input b[2][3][2][3];
    signal output out[2][3][2][3];

    component a_sum = Fp6Add();
    component b_sum = Fp6Add();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                a_sum.a[k][i][j] <== a[0][k][i][j];
                a_sum.b[k][i][j] <== a[1][k][i][j];
                b_sum.a[k][i][j] <== b[0][k][i][j];
                b_sum.b[k][i][j] <== b[1][k][i][j];
            }
        }
    }

    component a_mul = Fp6Mul();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                a_mul.a[k2][i2][j2] <== a_sum.out[k2][i2][j2];
                a_mul.b[k2][i2][j2] <== b_sum.out[k2][i2][j2];
            }
        }
    }

    component b_mul = Fp6Mul();
    component c_mul = Fp6Mul();
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i3 = 0; i3 < 2; i3++) {
            for (var j3 = 0; j3 < 3; j3++) {
                b_mul.a[k3][i3][j3] <== a[0][k3][i3][j3];
                b_mul.b[k3][i3][j3] <== b[0][k3][i3][j3];
                c_mul.a[k3][i3][j3] <== a[1][k3][i3][j3];
                c_mul.b[k3][i3][j3] <== b[1][k3][i3][j3];
            }
        }
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            for (var j4 = 0; j4 < 3; j4++) {
                c1_sub1.a[k4][i4][j4] <== a_mul.out[k4][i4][j4];
                c1_sub1.b[k4][i4][j4] <== b_mul.out[k4][i4][j4];
            }
        }
    }
    for (var k4b = 0; k4b < 3; k4b++) {
        for (var i4b = 0; i4b < 2; i4b++) {
            for (var j4b = 0; j4b < 3; j4b++) {
                c1_sub2.a[k4b][i4b][j4b] <== c1_sub1.out[k4b][i4b][j4b];
                c1_sub2.b[k4b][i4b][j4b] <== c_mul.out[k4b][i4b][j4b];
            }
        }
    }

    component c0_nr = Fp6MulByNonResidue();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j5 = 0; j5 < 3; j5++) {
                c0_nr.a[k5][i5][j5] <== c_mul.out[k5][i5][j5];
            }
        }
    }
    component c0 = Fp6Add();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6 = 0; i6 < 2; i6++) {
            for (var j6 = 0; j6 < 3; j6++) {
                c0.a[k6][i6][j6] <== c0_nr.out[k6][i6][j6];
                c0.b[k6][i6][j6] <== b_mul.out[k6][i6][j6];
            }
        }
    }

    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            for (var j7 = 0; j7 < 3; j7++) {
                out[0][k7][i7][j7] <== c0.out[k7][i7][j7];
                out[1][k7][i7][j7] <== c1_sub2.out[k7][i7][j7];
            }
        }
    }
}

template Fp12Square() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component ab = Fp6Mul();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                ab.a[k][i][j] <== a[0][k][i][j];
                ab.b[k][i][j] <== a[1][k][i][j];
            }
        }
    }

    component a_sq = Fp6Square();
    component b_sq = Fp6Square();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                a_sq.a[k2][i2][j2] <== a[0][k2][i2][j2];
                b_sq.a[k2][i2][j2] <== a[1][k2][i2][j2];
            }
        }
    }

    component b_nr = Fp6MulByNonResidue();
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i3 = 0; i3 < 2; i3++) {
            for (var j3 = 0; j3 < 3; j3++) {
                b_nr.a[k3][i3][j3] <== b_sq.out[k3][i3][j3];
            }
        }
    }

    component c0 = Fp6Add();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            for (var j4 = 0; j4 < 3; j4++) {
                c0.a[k4][i4][j4] <== a_sq.out[k4][i4][j4];
                c0.b[k4][i4][j4] <== b_nr.out[k4][i4][j4];
            }
        }
    }

    component c1 = Fp6Double();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j5 = 0; j5 < 3; j5++) {
                c1.a[k5][i5][j5] <== ab.out[k5][i5][j5];
            }
        }
    }

    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6 = 0; i6 < 2; i6++) {
            for (var j6 = 0; j6 < 3; j6++) {
                out[0][k6][i6][j6] <== c0.out[k6][i6][j6];
                out[1][k6][i6][j6] <== c1.out[k6][i6][j6];
            }
        }
    }
}

template Fp12Inverse() {
    signal input a[2][3][2][3];
    signal input inv[2][3][2][3];
    signal output out[2][3][2][3];

    component mul = Fp12Mul();
    for (var c = 0; c < 2; c++) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    mul.a[c][k][i][j] <== a[c][k][i][j];
                    mul.b[c][k][i][j] <== inv[c][k][i][j];
                }
            }
        }
    }

    component one = Fp12One();
    for (var c2 = 0; c2 < 2; c2++) {
        for (var k2 = 0; k2 < 3; k2++) {
            for (var i2 = 0; i2 < 2; i2++) {
                for (var j2 = 0; j2 < 3; j2++) {
                    mul.out[c2][k2][i2][j2] === one.out[c2][k2][i2][j2];
                    out[c2][k2][i2][j2] <== inv[c2][k2][i2][j2];
                }
            }
        }
    }
}

template Fp12CyclotomicSquare() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component t0 = Fp2Square();
    component t1 = Fp2Square();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0.a[i][j] <== a[1][1][i][j];
            t1.a[i][j] <== a[0][0][i][j];
        }
    }

    component t6_add = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            t6_add.a[i2][j2] <== a[1][1][i2][j2];
            t6_add.b[i2][j2] <== a[0][0][i2][j2];
        }
    }
    component t6_sq = Fp2Square();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            t6_sq.a[i3][j3] <== t6_add.out[i3][j3];
        }
    }
    component t6_sub1 = Fp2Sub();
    component t6_sub2 = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            t6_sub1.a[i4][j4] <== t6_sq.out[i4][j4];
            t6_sub1.b[i4][j4] <== t0.out[i4][j4];
        }
    }
    for (var i4b = 0; i4b < 2; i4b++) {
        for (var j4b = 0; j4b < 3; j4b++) {
            t6_sub2.a[i4b][j4b] <== t6_sub1.out[i4b][j4b];
            t6_sub2.b[i4b][j4b] <== t1.out[i4b][j4b];
        }
    }

    component t2 = Fp2Square();
    component t3 = Fp2Square();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            t2.a[i5][j5] <== a[0][2][i5][j5];
            t3.a[i5][j5] <== a[1][0][i5][j5];
        }
    }

    component t7_add = Fp2Add();
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            t7_add.a[i6][j6] <== a[0][2][i6][j6];
            t7_add.b[i6][j6] <== a[1][0][i6][j6];
        }
    }
    component t7_sq = Fp2Square();
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            t7_sq.a[i7][j7] <== t7_add.out[i7][j7];
        }
    }
    component t7_sub1 = Fp2Sub();
    component t7_sub2 = Fp2Sub();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            t7_sub1.a[i8][j8] <== t7_sq.out[i8][j8];
            t7_sub1.b[i8][j8] <== t2.out[i8][j8];
        }
    }
    for (var i8b = 0; i8b < 2; i8b++) {
        for (var j8b = 0; j8b < 3; j8b++) {
            t7_sub2.a[i8b][j8b] <== t7_sub1.out[i8b][j8b];
            t7_sub2.b[i8b][j8b] <== t3.out[i8b][j8b];
        }
    }

    component t4 = Fp2Square();
    component t5 = Fp2Square();
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            t4.a[i9][j9] <== a[1][2][i9][j9];
            t5.a[i9][j9] <== a[0][1][i9][j9];
        }
    }

    component t8_add = Fp2Add();
    for (var i10 = 0; i10 < 2; i10++) {
        for (var j10 = 0; j10 < 3; j10++) {
            t8_add.a[i10][j10] <== a[1][2][i10][j10];
            t8_add.b[i10][j10] <== a[0][1][i10][j10];
        }
    }
    component t8_sq = Fp2Square();
    for (var i11 = 0; i11 < 2; i11++) {
        for (var j11 = 0; j11 < 3; j11++) {
            t8_sq.a[i11][j11] <== t8_add.out[i11][j11];
        }
    }
    component t8_sub1 = Fp2Sub();
    component t8_sub2 = Fp2Sub();
    for (var i12 = 0; i12 < 2; i12++) {
        for (var j12 = 0; j12 < 3; j12++) {
            t8_sub1.a[i12][j12] <== t8_sq.out[i12][j12];
            t8_sub1.b[i12][j12] <== t4.out[i12][j12];
        }
    }
    for (var i12b = 0; i12b < 2; i12b++) {
        for (var j12b = 0; j12b < 3; j12b++) {
            t8_sub2.a[i12b][j12b] <== t8_sub1.out[i12b][j12b];
            t8_sub2.b[i12b][j12b] <== t5.out[i12b][j12b];
        }
    }
    component t8 = Fp2MulByNonResidue();
    for (var i13 = 0; i13 < 2; i13++) {
        for (var j13 = 0; j13 < 3; j13++) {
            t8.a[i13][j13] <== t8_sub2.out[i13][j13];
        }
    }

    component t0_nr = Fp2MulByNonResidue();
    component t2_nr = Fp2MulByNonResidue();
    component t4_nr = Fp2MulByNonResidue();
    for (var i14 = 0; i14 < 2; i14++) {
        for (var j14 = 0; j14 < 3; j14++) {
            t0_nr.a[i14][j14] <== t0.out[i14][j14];
            t2_nr.a[i14][j14] <== t2.out[i14][j14];
            t4_nr.a[i14][j14] <== t4.out[i14][j14];
        }
    }

    component t0_add = Fp2Add();
    component t2_add = Fp2Add();
    component t4_add = Fp2Add();
    for (var i15 = 0; i15 < 2; i15++) {
        for (var j15 = 0; j15 < 3; j15++) {
            t0_add.a[i15][j15] <== t0_nr.out[i15][j15];
            t0_add.b[i15][j15] <== t1.out[i15][j15];
            t2_add.a[i15][j15] <== t2_nr.out[i15][j15];
            t2_add.b[i15][j15] <== t3.out[i15][j15];
            t4_add.a[i15][j15] <== t4_nr.out[i15][j15];
            t4_add.b[i15][j15] <== t5.out[i15][j15];
        }
    }

    component z0_sub = Fp2Sub();
    component z0_dbl = Fp2Double();
    component z0 = Fp2Add();
    for (var i16 = 0; i16 < 2; i16++) {
        for (var j16 = 0; j16 < 3; j16++) {
            z0_sub.a[i16][j16] <== t0_add.out[i16][j16];
            z0_sub.b[i16][j16] <== a[0][0][i16][j16];
        }
    }
    for (var i16b = 0; i16b < 2; i16b++) {
        for (var j16b = 0; j16b < 3; j16b++) {
            z0_dbl.a[i16b][j16b] <== z0_sub.out[i16b][j16b];
        }
    }
    for (var i16c = 0; i16c < 2; i16c++) {
        for (var j16c = 0; j16c < 3; j16c++) {
            z0.a[i16c][j16c] <== z0_dbl.out[i16c][j16c];
            z0.b[i16c][j16c] <== t0_add.out[i16c][j16c];
        }
    }

    component z1_sub = Fp2Sub();
    component z1_dbl = Fp2Double();
    component z1 = Fp2Add();
    for (var i17 = 0; i17 < 2; i17++) {
        for (var j17 = 0; j17 < 3; j17++) {
            z1_sub.a[i17][j17] <== t2_add.out[i17][j17];
            z1_sub.b[i17][j17] <== a[0][1][i17][j17];
        }
    }
    for (var i17b = 0; i17b < 2; i17b++) {
        for (var j17b = 0; j17b < 3; j17b++) {
            z1_dbl.a[i17b][j17b] <== z1_sub.out[i17b][j17b];
        }
    }
    for (var i17c = 0; i17c < 2; i17c++) {
        for (var j17c = 0; j17c < 3; j17c++) {
            z1.a[i17c][j17c] <== z1_dbl.out[i17c][j17c];
            z1.b[i17c][j17c] <== t2_add.out[i17c][j17c];
        }
    }

    component z2_sub = Fp2Sub();
    component z2_dbl = Fp2Double();
    component z2 = Fp2Add();
    for (var i18 = 0; i18 < 2; i18++) {
        for (var j18 = 0; j18 < 3; j18++) {
            z2_sub.a[i18][j18] <== t4_add.out[i18][j18];
            z2_sub.b[i18][j18] <== a[0][2][i18][j18];
        }
    }
    for (var i18b = 0; i18b < 2; i18b++) {
        for (var j18b = 0; j18b < 3; j18b++) {
            z2_dbl.a[i18b][j18b] <== z2_sub.out[i18b][j18b];
        }
    }
    for (var i18c = 0; i18c < 2; i18c++) {
        for (var j18c = 0; j18c < 3; j18c++) {
            z2.a[i18c][j18c] <== z2_dbl.out[i18c][j18c];
            z2.b[i18c][j18c] <== t4_add.out[i18c][j18c];
        }
    }

    component z3_add = Fp2Add();
    component z3_dbl = Fp2Double();
    component z3 = Fp2Add();
    for (var i19 = 0; i19 < 2; i19++) {
        for (var j19 = 0; j19 < 3; j19++) {
            z3_add.a[i19][j19] <== t8.out[i19][j19];
            z3_add.b[i19][j19] <== a[1][0][i19][j19];
        }
    }
    for (var i19b = 0; i19b < 2; i19b++) {
        for (var j19b = 0; j19b < 3; j19b++) {
            z3_dbl.a[i19b][j19b] <== z3_add.out[i19b][j19b];
        }
    }
    for (var i19c = 0; i19c < 2; i19c++) {
        for (var j19c = 0; j19c < 3; j19c++) {
            z3.a[i19c][j19c] <== z3_dbl.out[i19c][j19c];
            z3.b[i19c][j19c] <== t8.out[i19c][j19c];
        }
    }

    component z4_add = Fp2Add();
    component z4_dbl = Fp2Double();
    component z4 = Fp2Add();
    for (var i20 = 0; i20 < 2; i20++) {
        for (var j20 = 0; j20 < 3; j20++) {
            z4_add.a[i20][j20] <== t6_sub2.out[i20][j20];
            z4_add.b[i20][j20] <== a[1][1][i20][j20];
        }
    }
    for (var i20b = 0; i20b < 2; i20b++) {
        for (var j20b = 0; j20b < 3; j20b++) {
            z4_dbl.a[i20b][j20b] <== z4_add.out[i20b][j20b];
        }
    }
    for (var i20c = 0; i20c < 2; i20c++) {
        for (var j20c = 0; j20c < 3; j20c++) {
            z4.a[i20c][j20c] <== z4_dbl.out[i20c][j20c];
            z4.b[i20c][j20c] <== t6_sub2.out[i20c][j20c];
        }
    }

    component z5_add = Fp2Add();
    component z5_dbl = Fp2Double();
    component z5 = Fp2Add();
    for (var i21 = 0; i21 < 2; i21++) {
        for (var j21 = 0; j21 < 3; j21++) {
            z5_add.a[i21][j21] <== t7_sub2.out[i21][j21];
            z5_add.b[i21][j21] <== a[1][2][i21][j21];
        }
    }
    for (var i21b = 0; i21b < 2; i21b++) {
        for (var j21b = 0; j21b < 3; j21b++) {
            z5_dbl.a[i21b][j21b] <== z5_add.out[i21b][j21b];
        }
    }
    for (var i21c = 0; i21c < 2; i21c++) {
        for (var j21c = 0; j21c < 3; j21c++) {
            z5.a[i21c][j21c] <== z5_dbl.out[i21c][j21c];
            z5.b[i21c][j21c] <== t7_sub2.out[i21c][j21c];
        }
    }

    for (var i22 = 0; i22 < 2; i22++) {
        for (var j22 = 0; j22 < 3; j22++) {
            out[0][0][i22][j22] <== z0.out[i22][j22];
            out[0][1][i22][j22] <== z1.out[i22][j22];
            out[0][2][i22][j22] <== z2.out[i22][j22];
            out[1][0][i22][j22] <== z3.out[i22][j22];
            out[1][1][i22][j22] <== z4.out[i22][j22];
            out[1][2][i22][j22] <== z5.out[i22][j22];
        }
    }
}

template Fp12Frobenius() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component t0 = Fp2Conjugate();
    component t1 = Fp2Conjugate();
    component t2 = Fp2Conjugate();
    component t3 = Fp2Conjugate();
    component t4 = Fp2Conjugate();
    component t5 = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0.a[i][j] <== a[0][0][i][j];
            t1.a[i][j] <== a[0][1][i][j];
            t2.a[i][j] <== a[0][2][i][j];
            t3.a[i][j] <== a[1][0][i][j];
            t4.a[i][j] <== a[1][1][i][j];
            t5.a[i][j] <== a[1][2][i][j];
        }
    }

    component t1_mul = Fp2MulByNonResidue1Power2();
    component t2_mul = Fp2MulByNonResidue1Power4();
    component t3_mul = Fp2MulByNonResidue1Power1();
    component t4_mul = Fp2MulByNonResidue1Power3();
    component t5_mul = Fp2MulByNonResidue1Power5();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            t1_mul.a[i2][j2] <== t1.out[i2][j2];
            t2_mul.a[i2][j2] <== t2.out[i2][j2];
            t3_mul.a[i2][j2] <== t3.out[i2][j2];
            t4_mul.a[i2][j2] <== t4.out[i2][j2];
            t5_mul.a[i2][j2] <== t5.out[i2][j2];
        }
    }

    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            out[0][0][i3][j3] <== t0.out[i3][j3];
            out[0][1][i3][j3] <== t1_mul.out[i3][j3];
            out[0][2][i3][j3] <== t2_mul.out[i3][j3];
            out[1][0][i3][j3] <== t3_mul.out[i3][j3];
            out[1][1][i3][j3] <== t4_mul.out[i3][j3];
            out[1][2][i3][j3] <== t5_mul.out[i3][j3];
        }
    }
}

template Fp12FrobeniusSquare() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component t1 = Fp2MulByNonResidue2Power2();
    component t2 = Fp2MulByNonResidue2Power4();
    component t3 = Fp2MulByNonResidue2Power1();
    component t4 = Fp2MulByNonResidue2Power3();
    component t5 = Fp2MulByNonResidue2Power5();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t1.a[i][j] <== a[0][1][i][j];
            t2.a[i][j] <== a[0][2][i][j];
            t3.a[i][j] <== a[1][0][i][j];
            t4.a[i][j] <== a[1][1][i][j];
            t5.a[i][j] <== a[1][2][i][j];
        }
    }

    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            out[0][0][i2][j2] <== a[0][0][i2][j2];
            out[0][1][i2][j2] <== t1.out[i2][j2];
            out[0][2][i2][j2] <== t2.out[i2][j2];
            out[1][0][i2][j2] <== t3.out[i2][j2];
            out[1][1][i2][j2] <== t4.out[i2][j2];
            out[1][2][i2][j2] <== t5.out[i2][j2];
        }
    }
}

template Fp12FrobeniusCube() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component t0 = Fp2Conjugate();
    component t1 = Fp2Conjugate();
    component t2 = Fp2Conjugate();
    component t3 = Fp2Conjugate();
    component t4 = Fp2Conjugate();
    component t5 = Fp2Conjugate();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0.a[i][j] <== a[0][0][i][j];
            t1.a[i][j] <== a[0][1][i][j];
            t2.a[i][j] <== a[0][2][i][j];
            t3.a[i][j] <== a[1][0][i][j];
            t4.a[i][j] <== a[1][1][i][j];
            t5.a[i][j] <== a[1][2][i][j];
        }
    }

    component t1_mul = Fp2MulByNonResidue3Power2();
    component t2_mul = Fp2MulByNonResidue3Power4();
    component t3_mul = Fp2MulByNonResidue3Power1();
    component t4_mul = Fp2MulByNonResidue3Power3();
    component t5_mul = Fp2MulByNonResidue3Power5();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            t1_mul.a[i2][j2] <== t1.out[i2][j2];
            t2_mul.a[i2][j2] <== t2.out[i2][j2];
            t3_mul.a[i2][j2] <== t3.out[i2][j2];
            t4_mul.a[i2][j2] <== t4.out[i2][j2];
            t5_mul.a[i2][j2] <== t5.out[i2][j2];
        }
    }

    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            out[0][0][i3][j3] <== t0.out[i3][j3];
            out[0][1][i3][j3] <== t1_mul.out[i3][j3];
            out[0][2][i3][j3] <== t2_mul.out[i3][j3];
            out[1][0][i3][j3] <== t3_mul.out[i3][j3];
            out[1][1][i3][j3] <== t4_mul.out[i3][j3];
            out[1][2][i3][j3] <== t5_mul.out[i3][j3];
        }
    }
}

template Fp12MulBy034() {
    signal input a[2][3][2][3];
    signal input c0[2][3];
    signal input c3[2][3];
    signal input c4[2][3];
    signal output out[2][3][2][3];

    component a_mul = Fp6MulByE2();
    component b_mul = Fp6MulBy01();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                a_mul.a[k][i][j] <== a[0][k][i][j];
                b_mul.a[k][i][j] <== a[1][k][i][j];
            }
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            a_mul.c0[i2][j2] <== c0[i2][j2];
            b_mul.c0[i2][j2] <== c3[i2][j2];
            b_mul.c1[i2][j2] <== c4[i2][j2];
        }
    }

    component d0 = Fp2Add();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            d0.a[i3][j3] <== c0[i3][j3];
            d0.b[i3][j3] <== c3[i3][j3];
        }
    }

    component d_sum = Fp6Add();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            for (var j4 = 0; j4 < 3; j4++) {
                d_sum.a[k4][i4][j4] <== a[0][k4][i4][j4];
                d_sum.b[k4][i4][j4] <== a[1][k4][i4][j4];
            }
        }
    }

    component d_mul = Fp6MulBy01();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j5 = 0; j5 < 3; j5++) {
                d_mul.a[k5][i5][j5] <== d_sum.out[k5][i5][j5];
            }
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            d_mul.c0[i6][j6] <== d0.out[i6][j6];
            d_mul.c1[i6][j6] <== c4[i6][j6];
        }
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6b = 0; i6b < 2; i6b++) {
            for (var j6b = 0; j6b < 3; j6b++) {
                c1_sub1.a[k6][i6b][j6b] <== d_mul.out[k6][i6b][j6b];
                c1_sub1.b[k6][i6b][j6b] <== a_mul.out[k6][i6b][j6b];
            }
        }
    }
    for (var k6b = 0; k6b < 3; k6b++) {
        for (var i6c = 0; i6c < 2; i6c++) {
            for (var j6c = 0; j6c < 3; j6c++) {
                c1_sub2.a[k6b][i6c][j6c] <== c1_sub1.out[k6b][i6c][j6c];
                c1_sub2.b[k6b][i6c][j6c] <== b_mul.out[k6b][i6c][j6c];
            }
        }
    }

    component b_nr = Fp6MulByNonResidue();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            for (var j7 = 0; j7 < 3; j7++) {
                b_nr.a[k7][i7][j7] <== b_mul.out[k7][i7][j7];
            }
        }
    }
    component c0_sum = Fp6Add();
    for (var k8 = 0; k8 < 3; k8++) {
        for (var i8 = 0; i8 < 2; i8++) {
            for (var j8 = 0; j8 < 3; j8++) {
                c0_sum.a[k8][i8][j8] <== b_nr.out[k8][i8][j8];
                c0_sum.b[k8][i8][j8] <== a_mul.out[k8][i8][j8];
            }
        }
    }

    for (var k9 = 0; k9 < 3; k9++) {
        for (var i9 = 0; i9 < 2; i9++) {
            for (var j9 = 0; j9 < 3; j9++) {
                out[0][k9][i9][j9] <== c0_sum.out[k9][i9][j9];
                out[1][k9][i9][j9] <== c1_sub2.out[k9][i9][j9];
            }
        }
    }
}

template Fp12MulBy34() {
    signal input a[2][3][2][3];
    signal input c3[2][3];
    signal input c4[2][3];
    signal output out[2][3][2][3];

    component b_mul = Fp6MulBy01();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                b_mul.a[k][i][j] <== a[1][k][i][j];
            }
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            b_mul.c0[i2][j2] <== c3[i2][j2];
            b_mul.c1[i2][j2] <== c4[i2][j2];
        }
    }

    component d0 = Fp2Add();
    component one = Fp2One();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            d0.a[i3][j3] <== one.out[i3][j3];
            d0.b[i3][j3] <== c3[i3][j3];
        }
    }

    component d_sum = Fp6Add();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            for (var j4 = 0; j4 < 3; j4++) {
                d_sum.a[k4][i4][j4] <== a[0][k4][i4][j4];
                d_sum.b[k4][i4][j4] <== a[1][k4][i4][j4];
            }
        }
    }

    component d_mul = Fp6MulBy01();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j5 = 0; j5 < 3; j5++) {
                d_mul.a[k5][i5][j5] <== d_sum.out[k5][i5][j5];
            }
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            d_mul.c0[i6][j6] <== d0.out[i6][j6];
            d_mul.c1[i6][j6] <== c4[i6][j6];
        }
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6b = 0; i6b < 2; i6b++) {
            for (var j6b = 0; j6b < 3; j6b++) {
                c1_sub1.a[k6][i6b][j6b] <== d_mul.out[k6][i6b][j6b];
                c1_sub1.b[k6][i6b][j6b] <== a[0][k6][i6b][j6b];
            }
        }
    }
    for (var k6b = 0; k6b < 3; k6b++) {
        for (var i6c = 0; i6c < 2; i6c++) {
            for (var j6c = 0; j6c < 3; j6c++) {
                c1_sub2.a[k6b][i6c][j6c] <== c1_sub1.out[k6b][i6c][j6c];
                c1_sub2.b[k6b][i6c][j6c] <== b_mul.out[k6b][i6c][j6c];
            }
        }
    }

    component b_nr = Fp6MulByNonResidue();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            for (var j7 = 0; j7 < 3; j7++) {
                b_nr.a[k7][i7][j7] <== b_mul.out[k7][i7][j7];
            }
        }
    }
    component c0 = Fp6Add();
    for (var k8 = 0; k8 < 3; k8++) {
        for (var i8 = 0; i8 < 2; i8++) {
            for (var j8 = 0; j8 < 3; j8++) {
                c0.a[k8][i8][j8] <== b_nr.out[k8][i8][j8];
                c0.b[k8][i8][j8] <== a[0][k8][i8][j8];
            }
        }
    }

    for (var k9 = 0; k9 < 3; k9++) {
        for (var i9 = 0; i9 < 2; i9++) {
            for (var j9 = 0; j9 < 3; j9++) {
                out[0][k9][i9][j9] <== c0.out[k9][i9][j9];
                out[1][k9][i9][j9] <== c1_sub2.out[k9][i9][j9];
            }
        }
    }
}

template Fp12MulBy01234() {
    signal input a[2][3][2][3];
    signal input x[5][2][3];
    signal output out[2][3][2][3];

    signal c0[3][2][3];
    signal c1[3][2][3];
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0[0][i][j] <== x[0][i][j];
            c0[1][i][j] <== x[1][i][j];
            c0[2][i][j] <== x[2][i][j];
            c1[0][i][j] <== x[3][i][j];
            c1[1][i][j] <== x[4][i][j];
            c1[2][i][j] <== 0;
        }
    }

    component a_sum = Fp6Add();
    component c_sum = Fp6Add();
    for (var k = 0; k < 3; k++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                a_sum.a[k][i2][j2] <== a[0][k][i2][j2];
                a_sum.b[k][i2][j2] <== a[1][k][i2][j2];
                c_sum.a[k][i2][j2] <== c0[k][i2][j2];
                c_sum.b[k][i2][j2] <== c1[k][i2][j2];
            }
        }
    }

    component a_mul = Fp6Mul();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i3 = 0; i3 < 2; i3++) {
            for (var j3 = 0; j3 < 3; j3++) {
                a_mul.a[k2][i3][j3] <== a_sum.out[k2][i3][j3];
                a_mul.b[k2][i3][j3] <== c_sum.out[k2][i3][j3];
            }
        }
    }

    component b_mul = Fp6Mul();
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i4 = 0; i4 < 2; i4++) {
            for (var j4 = 0; j4 < 3; j4++) {
                b_mul.a[k3][i4][j4] <== a[0][k3][i4][j4];
                b_mul.b[k3][i4][j4] <== c0[k3][i4][j4];
            }
        }
    }

    component c_mul = Fp6MulBy01();
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j5 = 0; j5 < 3; j5++) {
                c_mul.a[k4][i5][j5] <== a[1][k4][i5][j5];
            }
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            c_mul.c0[i6][j6] <== x[3][i6][j6];
            c_mul.c1[i6][j6] <== x[4][i6][j6];
        }
    }

    component c1_sub1 = Fp6Sub();
    component c1_sub2 = Fp6Sub();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i7 = 0; i7 < 2; i7++) {
            for (var j7 = 0; j7 < 3; j7++) {
                c1_sub1.a[k5][i7][j7] <== a_mul.out[k5][i7][j7];
                c1_sub1.b[k5][i7][j7] <== b_mul.out[k5][i7][j7];
            }
        }
    }
    for (var k5b = 0; k5b < 3; k5b++) {
        for (var i7b = 0; i7b < 2; i7b++) {
            for (var j7b = 0; j7b < 3; j7b++) {
                c1_sub2.a[k5b][i7b][j7b] <== c1_sub1.out[k5b][i7b][j7b];
                c1_sub2.b[k5b][i7b][j7b] <== c_mul.out[k5b][i7b][j7b];
            }
        }
    }

    component c_nr = Fp6MulByNonResidue();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i8 = 0; i8 < 2; i8++) {
            for (var j8 = 0; j8 < 3; j8++) {
                c_nr.a[k6][i8][j8] <== c_mul.out[k6][i8][j8];
            }
        }
    }
    component c0_out = Fp6Add();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i9 = 0; i9 < 2; i9++) {
            for (var j9 = 0; j9 < 3; j9++) {
                c0_out.a[k7][i9][j9] <== c_nr.out[k7][i9][j9];
                c0_out.b[k7][i9][j9] <== b_mul.out[k7][i9][j9];
            }
        }
    }

    for (var k8 = 0; k8 < 3; k8++) {
        for (var i10 = 0; i10 < 2; i10++) {
            for (var j10 = 0; j10 < 3; j10++) {
                out[0][k8][i10][j10] <== c0_out.out[k8][i10][j10];
                out[1][k8][i10][j10] <== c1_sub2.out[k8][i10][j10];
            }
        }
    }
}

template Mul034By034() {
    signal input d0[2][3];
    signal input d3[2][3];
    signal input d4[2][3];
    signal input c0[2][3];
    signal input c3[2][3];
    signal input c4[2][3];
    signal output out[5][2][3];

    component x0 = Fp2Mul();
    component x3 = Fp2Mul();
    component x4 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            x0.a[i][j] <== c0[i][j];
            x0.b[i][j] <== d0[i][j];
            x3.a[i][j] <== c3[i][j];
            x3.b[i][j] <== d3[i][j];
            x4.a[i][j] <== c4[i][j];
            x4.b[i][j] <== d4[i][j];
        }
    }

    component x04_mul = Fp2Mul();
    component c0_plus_c4 = Fp2Add();
    component d0_plus_d4 = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            c0_plus_c4.a[i2][j2] <== c0[i2][j2];
            c0_plus_c4.b[i2][j2] <== c4[i2][j2];
            d0_plus_d4.a[i2][j2] <== d0[i2][j2];
            d0_plus_d4.b[i2][j2] <== d4[i2][j2];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            x04_mul.a[i3][j3] <== c0_plus_c4.out[i3][j3];
            x04_mul.b[i3][j3] <== d0_plus_d4.out[i3][j3];
        }
    }
    component x04_sub1 = Fp2Sub();
    component x04 = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            x04_sub1.a[i4][j4] <== x04_mul.out[i4][j4];
            x04_sub1.b[i4][j4] <== x0.out[i4][j4];
        }
    }
    for (var i4b = 0; i4b < 2; i4b++) {
        for (var j4b = 0; j4b < 3; j4b++) {
            x04.a[i4b][j4b] <== x04_sub1.out[i4b][j4b];
            x04.b[i4b][j4b] <== x4.out[i4b][j4b];
        }
    }

    component x03_mul = Fp2Mul();
    component c0_plus_c3 = Fp2Add();
    component d0_plus_d3 = Fp2Add();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            c0_plus_c3.a[i5][j5] <== c0[i5][j5];
            c0_plus_c3.b[i5][j5] <== c3[i5][j5];
            d0_plus_d3.a[i5][j5] <== d0[i5][j5];
            d0_plus_d3.b[i5][j5] <== d3[i5][j5];
        }
    }
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            x03_mul.a[i6][j6] <== c0_plus_c3.out[i6][j6];
            x03_mul.b[i6][j6] <== d0_plus_d3.out[i6][j6];
        }
    }
    component x03_sub1 = Fp2Sub();
    component x03 = Fp2Sub();
    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            x03_sub1.a[i7][j7] <== x03_mul.out[i7][j7];
            x03_sub1.b[i7][j7] <== x0.out[i7][j7];
        }
    }
    for (var i7b = 0; i7b < 2; i7b++) {
        for (var j7b = 0; j7b < 3; j7b++) {
            x03.a[i7b][j7b] <== x03_sub1.out[i7b][j7b];
            x03.b[i7b][j7b] <== x3.out[i7b][j7b];
        }
    }

    component x34_mul = Fp2Mul();
    component c3_plus_c4 = Fp2Add();
    component d3_plus_d4 = Fp2Add();
    for (var i8 = 0; i8 < 2; i8++) {
        for (var j8 = 0; j8 < 3; j8++) {
            c3_plus_c4.a[i8][j8] <== c3[i8][j8];
            c3_plus_c4.b[i8][j8] <== c4[i8][j8];
            d3_plus_d4.a[i8][j8] <== d3[i8][j8];
            d3_plus_d4.b[i8][j8] <== d4[i8][j8];
        }
    }
    for (var i9 = 0; i9 < 2; i9++) {
        for (var j9 = 0; j9 < 3; j9++) {
            x34_mul.a[i9][j9] <== c3_plus_c4.out[i9][j9];
            x34_mul.b[i9][j9] <== d3_plus_d4.out[i9][j9];
        }
    }
    component x34_sub1 = Fp2Sub();
    component x34 = Fp2Sub();
    for (var i10 = 0; i10 < 2; i10++) {
        for (var j10 = 0; j10 < 3; j10++) {
            x34_sub1.a[i10][j10] <== x34_mul.out[i10][j10];
            x34_sub1.b[i10][j10] <== x3.out[i10][j10];
        }
    }
    for (var i10b = 0; i10b < 2; i10b++) {
        for (var j10b = 0; j10b < 3; j10b++) {
            x34.a[i10b][j10b] <== x34_sub1.out[i10b][j10b];
            x34.b[i10b][j10b] <== x4.out[i10b][j10b];
        }
    }

    component z00_nr = Fp2MulByNonResidue();
    for (var i11 = 0; i11 < 2; i11++) {
        for (var j11 = 0; j11 < 3; j11++) {
            z00_nr.a[i11][j11] <== x4.out[i11][j11];
        }
    }
    component z00 = Fp2Add();
    for (var i12 = 0; i12 < 2; i12++) {
        for (var j12 = 0; j12 < 3; j12++) {
            z00.a[i12][j12] <== z00_nr.out[i12][j12];
            z00.b[i12][j12] <== x0.out[i12][j12];
        }
    }

    for (var i13 = 0; i13 < 2; i13++) {
        for (var j13 = 0; j13 < 3; j13++) {
            out[0][i13][j13] <== z00.out[i13][j13];
            out[1][i13][j13] <== x3.out[i13][j13];
            out[2][i13][j13] <== x34.out[i13][j13];
            out[3][i13][j13] <== x03.out[i13][j13];
            out[4][i13][j13] <== x04.out[i13][j13];
        }
    }
}

template Fp12NSquare(n) {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    if (n == 0) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    out[0][k][i][j] <== a[0][k][i][j];
                    out[1][k][i][j] <== a[1][k][i][j];
                }
            }
        }
    } else {
        component sq[n];
        for (var idx = 0; idx < n; idx++) {
            sq[idx] = Fp12CyclotomicSquare();
            if (idx == 0) {
                for (var k2 = 0; k2 < 3; k2++) {
                    for (var i2 = 0; i2 < 2; i2++) {
                        for (var j2 = 0; j2 < 3; j2++) {
                            sq[idx].a[0][k2][i2][j2] <== a[0][k2][i2][j2];
                            sq[idx].a[1][k2][i2][j2] <== a[1][k2][i2][j2];
                        }
                    }
                }
            } else {
                for (var k3 = 0; k3 < 3; k3++) {
                    for (var i3 = 0; i3 < 2; i3++) {
                        for (var j3 = 0; j3 < 3; j3++) {
                            sq[idx].a[0][k3][i3][j3] <== sq[idx - 1].out[0][k3][i3][j3];
                            sq[idx].a[1][k3][i3][j3] <== sq[idx - 1].out[1][k3][i3][j3];
                        }
                    }
                }
            }
        }
        for (var k4 = 0; k4 < 3; k4++) {
            for (var i4 = 0; i4 < 2; i4++) {
                for (var j4 = 0; j4 < 3; j4++) {
                    out[0][k4][i4][j4] <== sq[n - 1].out[0][k4][i4][j4];
                    out[1][k4][i4][j4] <== sq[n - 1].out[1][k4][i4][j4];
                }
            }
        }
    }
}

template Fp12Expt() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component t3 = Fp12CyclotomicSquare();
    component t5 = Fp12CyclotomicSquare();
    component result = Fp12CyclotomicSquare();
    component t0_sq = Fp12CyclotomicSquare();

    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                t3.a[0][k][i][j] <== a[0][k][i][j];
                t3.a[1][k][i][j] <== a[1][k][i][j];
            }
        }
    }
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                t5.a[0][k2][i2][j2] <== t3.out[0][k2][i2][j2];
                t5.a[1][k2][i2][j2] <== t3.out[1][k2][i2][j2];
            }
        }
    }
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i3 = 0; i3 < 2; i3++) {
            for (var j3 = 0; j3 < 3; j3++) {
                result.a[0][k3][i3][j3] <== t5.out[0][k3][i3][j3];
                result.a[1][k3][i3][j3] <== t5.out[1][k3][i3][j3];
            }
        }
    }
    for (var k4 = 0; k4 < 3; k4++) {
        for (var i4 = 0; i4 < 2; i4++) {
            for (var j4 = 0; j4 < 3; j4++) {
                t0_sq.a[0][k4][i4][j4] <== result.out[0][k4][i4][j4];
                t0_sq.a[1][k4][i4][j4] <== result.out[1][k4][i4][j4];
            }
        }
    }

    component t2 = Fp12Mul();
    for (var k5 = 0; k5 < 3; k5++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j5 = 0; j5 < 3; j5++) {
                t2.a[0][k5][i5][j5] <== a[0][k5][i5][j5];
                t2.a[1][k5][i5][j5] <== a[1][k5][i5][j5];
                t2.b[0][k5][i5][j5] <== t0_sq.out[0][k5][i5][j5];
                t2.b[1][k5][i5][j5] <== t0_sq.out[1][k5][i5][j5];
            }
        }
    }

    component t0 = Fp12Mul();
    for (var k6 = 0; k6 < 3; k6++) {
        for (var i6 = 0; i6 < 2; i6++) {
            for (var j6 = 0; j6 < 3; j6++) {
                t0.a[0][k6][i6][j6] <== t3.out[0][k6][i6][j6];
                t0.a[1][k6][i6][j6] <== t3.out[1][k6][i6][j6];
                t0.b[0][k6][i6][j6] <== t2.out[0][k6][i6][j6];
                t0.b[1][k6][i6][j6] <== t2.out[1][k6][i6][j6];
            }
        }
    }

    component t1 = Fp12Mul();
    for (var k7 = 0; k7 < 3; k7++) {
        for (var i7 = 0; i7 < 2; i7++) {
            for (var j7 = 0; j7 < 3; j7++) {
                t1.a[0][k7][i7][j7] <== a[0][k7][i7][j7];
                t1.a[1][k7][i7][j7] <== a[1][k7][i7][j7];
                t1.b[0][k7][i7][j7] <== t0.out[0][k7][i7][j7];
                t1.b[1][k7][i7][j7] <== t0.out[1][k7][i7][j7];
            }
        }
    }

    component t4 = Fp12Mul();
    for (var k8 = 0; k8 < 3; k8++) {
        for (var i8 = 0; i8 < 2; i8++) {
            for (var j8 = 0; j8 < 3; j8++) {
                t4.a[0][k8][i8][j8] <== result.out[0][k8][i8][j8];
                t4.a[1][k8][i8][j8] <== result.out[1][k8][i8][j8];
                t4.b[0][k8][i8][j8] <== t2.out[0][k8][i8][j8];
                t4.b[1][k8][i8][j8] <== t2.out[1][k8][i8][j8];
            }
        }
    }

    component t6 = Fp12CyclotomicSquare();
    for (var k9 = 0; k9 < 3; k9++) {
        for (var i9 = 0; i9 < 2; i9++) {
            for (var j9 = 0; j9 < 3; j9++) {
                t6.a[0][k9][i9][j9] <== t2.out[0][k9][i9][j9];
                t6.a[1][k9][i9][j9] <== t2.out[1][k9][i9][j9];
            }
        }
    }

    component t1b = Fp12Mul();
    for (var k10 = 0; k10 < 3; k10++) {
        for (var i10 = 0; i10 < 2; i10++) {
            for (var j10 = 0; j10 < 3; j10++) {
                t1b.a[0][k10][i10][j10] <== t0.out[0][k10][i10][j10];
                t1b.a[1][k10][i10][j10] <== t0.out[1][k10][i10][j10];
                t1b.b[0][k10][i10][j10] <== t1.out[0][k10][i10][j10];
                t1b.b[1][k10][i10][j10] <== t1.out[1][k10][i10][j10];
            }
        }
    }

    component t0b = Fp12Mul();
    for (var k11 = 0; k11 < 3; k11++) {
        for (var i11 = 0; i11 < 2; i11++) {
            for (var j11 = 0; j11 < 3; j11++) {
                t0b.a[0][k11][i11][j11] <== t3.out[0][k11][i11][j11];
                t0b.a[1][k11][i11][j11] <== t3.out[1][k11][i11][j11];
                t0b.b[0][k11][i11][j11] <== t1b.out[0][k11][i11][j11];
                t0b.b[1][k11][i11][j11] <== t1b.out[1][k11][i11][j11];
            }
        }
    }

    component t6_ns = Fp12NSquare(6);
    for (var k12 = 0; k12 < 3; k12++) {
        for (var i12 = 0; i12 < 2; i12++) {
            for (var j12 = 0; j12 < 3; j12++) {
                t6_ns.a[0][k12][i12][j12] <== t6.out[0][k12][i12][j12];
                t6_ns.a[1][k12][i12][j12] <== t6.out[1][k12][i12][j12];
            }
        }
    }

    component t5b = Fp12Mul();
    for (var k13 = 0; k13 < 3; k13++) {
        for (var i13 = 0; i13 < 2; i13++) {
            for (var j13 = 0; j13 < 3; j13++) {
                t5b.a[0][k13][i13][j13] <== t5.out[0][k13][i13][j13];
                t5b.a[1][k13][i13][j13] <== t5.out[1][k13][i13][j13];
                t5b.b[0][k13][i13][j13] <== t6_ns.out[0][k13][i13][j13];
                t5b.b[1][k13][i13][j13] <== t6_ns.out[1][k13][i13][j13];
            }
        }
    }

    component t5c = Fp12Mul();
    for (var k14 = 0; k14 < 3; k14++) {
        for (var i14 = 0; i14 < 2; i14++) {
            for (var j14 = 0; j14 < 3; j14++) {
                t5c.a[0][k14][i14][j14] <== t4.out[0][k14][i14][j14];
                t5c.a[1][k14][i14][j14] <== t4.out[1][k14][i14][j14];
                t5c.b[0][k14][i14][j14] <== t5b.out[0][k14][i14][j14];
                t5c.b[1][k14][i14][j14] <== t5b.out[1][k14][i14][j14];
            }
        }
    }

    component t5_ns = Fp12NSquare(7);
    for (var k15 = 0; k15 < 3; k15++) {
        for (var i15 = 0; i15 < 2; i15++) {
            for (var j15 = 0; j15 < 3; j15++) {
                t5_ns.a[0][k15][i15][j15] <== t5c.out[0][k15][i15][j15];
                t5_ns.a[1][k15][i15][j15] <== t5c.out[1][k15][i15][j15];
            }
        }
    }

    component t4b = Fp12Mul();
    for (var k16 = 0; k16 < 3; k16++) {
        for (var i16 = 0; i16 < 2; i16++) {
            for (var j16 = 0; j16 < 3; j16++) {
                t4b.a[0][k16][i16][j16] <== t4.out[0][k16][i16][j16];
                t4b.a[1][k16][i16][j16] <== t4.out[1][k16][i16][j16];
                t4b.b[0][k16][i16][j16] <== t5_ns.out[0][k16][i16][j16];
                t4b.b[1][k16][i16][j16] <== t5_ns.out[1][k16][i16][j16];
            }
        }
    }

    component t4_ns = Fp12NSquare(8);
    for (var k17 = 0; k17 < 3; k17++) {
        for (var i17 = 0; i17 < 2; i17++) {
            for (var j17 = 0; j17 < 3; j17++) {
                t4_ns.a[0][k17][i17][j17] <== t4b.out[0][k17][i17][j17];
                t4_ns.a[1][k17][i17][j17] <== t4b.out[1][k17][i17][j17];
            }
        }
    }

    component t4c = Fp12Mul();
    for (var k18 = 0; k18 < 3; k18++) {
        for (var i18 = 0; i18 < 2; i18++) {
            for (var j18 = 0; j18 < 3; j18++) {
                t4c.a[0][k18][i18][j18] <== t4_ns.out[0][k18][i18][j18];
                t4c.a[1][k18][i18][j18] <== t4_ns.out[1][k18][i18][j18];
                t4c.b[0][k18][i18][j18] <== t0b.out[0][k18][i18][j18];
                t4c.b[1][k18][i18][j18] <== t0b.out[1][k18][i18][j18];
            }
        }
    }

    component t3b = Fp12Mul();
    for (var k19 = 0; k19 < 3; k19++) {
        for (var i19 = 0; i19 < 2; i19++) {
            for (var j19 = 0; j19 < 3; j19++) {
                t3b.a[0][k19][i19][j19] <== t3.out[0][k19][i19][j19];
                t3b.a[1][k19][i19][j19] <== t3.out[1][k19][i19][j19];
                t3b.b[0][k19][i19][j19] <== t4c.out[0][k19][i19][j19];
                t3b.b[1][k19][i19][j19] <== t4c.out[1][k19][i19][j19];
            }
        }
    }

    component t3_ns = Fp12NSquare(6);
    for (var k20 = 0; k20 < 3; k20++) {
        for (var i20 = 0; i20 < 2; i20++) {
            for (var j20 = 0; j20 < 3; j20++) {
                t3_ns.a[0][k20][i20][j20] <== t3b.out[0][k20][i20][j20];
                t3_ns.a[1][k20][i20][j20] <== t3b.out[1][k20][i20][j20];
            }
        }
    }

    component t2b = Fp12Mul();
    for (var k21 = 0; k21 < 3; k21++) {
        for (var i21 = 0; i21 < 2; i21++) {
            for (var j21 = 0; j21 < 3; j21++) {
                t2b.a[0][k21][i21][j21] <== t2.out[0][k21][i21][j21];
                t2b.a[1][k21][i21][j21] <== t2.out[1][k21][i21][j21];
                t2b.b[0][k21][i21][j21] <== t3_ns.out[0][k21][i21][j21];
                t2b.b[1][k21][i21][j21] <== t3_ns.out[1][k21][i21][j21];
            }
        }
    }

    component t2_ns = Fp12NSquare(8);
    for (var k22 = 0; k22 < 3; k22++) {
        for (var i22 = 0; i22 < 2; i22++) {
            for (var j22 = 0; j22 < 3; j22++) {
                t2_ns.a[0][k22][i22][j22] <== t2b.out[0][k22][i22][j22];
                t2_ns.a[1][k22][i22][j22] <== t2b.out[1][k22][i22][j22];
            }
        }
    }

    component t2c = Fp12Mul();
    for (var k23 = 0; k23 < 3; k23++) {
        for (var i23 = 0; i23 < 2; i23++) {
            for (var j23 = 0; j23 < 3; j23++) {
                t2c.a[0][k23][i23][j23] <== t2_ns.out[0][k23][i23][j23];
                t2c.a[1][k23][i23][j23] <== t2_ns.out[1][k23][i23][j23];
                t2c.b[0][k23][i23][j23] <== t0b.out[0][k23][i23][j23];
                t2c.b[1][k23][i23][j23] <== t0b.out[1][k23][i23][j23];
            }
        }
    }

    component t2_ns2 = Fp12NSquare(6);
    for (var k24 = 0; k24 < 3; k24++) {
        for (var i24 = 0; i24 < 2; i24++) {
            for (var j24 = 0; j24 < 3; j24++) {
                t2_ns2.a[0][k24][i24][j24] <== t2c.out[0][k24][i24][j24];
                t2_ns2.a[1][k24][i24][j24] <== t2c.out[1][k24][i24][j24];
            }
        }
    }

    component t2d = Fp12Mul();
    for (var k25 = 0; k25 < 3; k25++) {
        for (var i25 = 0; i25 < 2; i25++) {
            for (var j25 = 0; j25 < 3; j25++) {
                t2d.a[0][k25][i25][j25] <== t2_ns2.out[0][k25][i25][j25];
                t2d.a[1][k25][i25][j25] <== t2_ns2.out[1][k25][i25][j25];
                t2d.b[0][k25][i25][j25] <== t0b.out[0][k25][i25][j25];
                t2d.b[1][k25][i25][j25] <== t0b.out[1][k25][i25][j25];
            }
        }
    }

    component t2_ns3 = Fp12NSquare(10);
    for (var k26 = 0; k26 < 3; k26++) {
        for (var i26 = 0; i26 < 2; i26++) {
            for (var j26 = 0; j26 < 3; j26++) {
                t2_ns3.a[0][k26][i26][j26] <== t2d.out[0][k26][i26][j26];
                t2_ns3.a[1][k26][i26][j26] <== t2d.out[1][k26][i26][j26];
            }
        }
    }

    component t1c = Fp12Mul();
    for (var k27 = 0; k27 < 3; k27++) {
        for (var i27 = 0; i27 < 2; i27++) {
            for (var j27 = 0; j27 < 3; j27++) {
                t1c.a[0][k27][i27][j27] <== t1b.out[0][k27][i27][j27];
                t1c.a[1][k27][i27][j27] <== t1b.out[1][k27][i27][j27];
                t1c.b[0][k27][i27][j27] <== t2_ns3.out[0][k27][i27][j27];
                t1c.b[1][k27][i27][j27] <== t2_ns3.out[1][k27][i27][j27];
            }
        }
    }

    component t1_ns = Fp12NSquare(6);
    for (var k28 = 0; k28 < 3; k28++) {
        for (var i28 = 0; i28 < 2; i28++) {
            for (var j28 = 0; j28 < 3; j28++) {
                t1_ns.a[0][k28][i28][j28] <== t1c.out[0][k28][i28][j28];
                t1_ns.a[1][k28][i28][j28] <== t1c.out[1][k28][i28][j28];
            }
        }
    }

    component t0c = Fp12Mul();
    for (var k29 = 0; k29 < 3; k29++) {
        for (var i29 = 0; i29 < 2; i29++) {
            for (var j29 = 0; j29 < 3; j29++) {
                t0c.a[0][k29][i29][j29] <== t0b.out[0][k29][i29][j29];
                t0c.a[1][k29][i29][j29] <== t0b.out[1][k29][i29][j29];
                t0c.b[0][k29][i29][j29] <== t1_ns.out[0][k29][i29][j29];
                t0c.b[1][k29][i29][j29] <== t1_ns.out[1][k29][i29][j29];
            }
        }
    }

    component result_out = Fp12Mul();
    for (var k30 = 0; k30 < 3; k30++) {
        for (var i30 = 0; i30 < 2; i30++) {
            for (var j30 = 0; j30 < 3; j30++) {
                result_out.a[0][k30][i30][j30] <== result.out[0][k30][i30][j30];
                result_out.a[1][k30][i30][j30] <== result.out[1][k30][i30][j30];
                result_out.b[0][k30][i30][j30] <== t0c.out[0][k30][i30][j30];
                result_out.b[1][k30][i30][j30] <== t0c.out[1][k30][i30][j30];
            }
        }
    }

    for (var k31 = 0; k31 < 3; k31++) {
        for (var i31 = 0; i31 < 2; i31++) {
            for (var j31 = 0; j31 < 3; j31++) {
                out[0][k31][i31][j31] <== result_out.out[0][k31][i31][j31];
                out[1][k31][i31][j31] <== result_out.out[1][k31][i31][j31];
            }
        }
    }
}
