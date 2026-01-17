pragma circom 2.0.0;

include "./fp2.circom";

template Fp6Zero() {
    signal output out[3][2][3];
    component zero = Fp2Zero();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                out[k][i][j] <== zero.out[i][j];
            }
        }
    }
}

template Fp6One() {
    signal output out[3][2][3];
    component one = Fp2One();
    component zero = Fp2Zero();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== one.out[i][j];
            out[1][i][j] <== zero.out[i][j];
            out[2][i][j] <== zero.out[i][j];
        }
    }
}

template Fp6Add() {
    signal input a[3][2][3];
    signal input b[3][2][3];
    signal output out[3][2][3];

    component add0 = Fp2Add();
    component add1 = Fp2Add();
    component add2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            add0.a[i][j] <== a[0][i][j];
            add0.b[i][j] <== b[0][i][j];
            add1.a[i][j] <== a[1][i][j];
            add1.b[i][j] <== b[1][i][j];
            add2.a[i][j] <== a[2][i][j];
            add2.b[i][j] <== b[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== add0.out[i][j];
            out[1][i][j] <== add1.out[i][j];
            out[2][i][j] <== add2.out[i][j];
        }
    }
}

template Fp6Sub() {
    signal input a[3][2][3];
    signal input b[3][2][3];
    signal output out[3][2][3];

    component sub0 = Fp2Sub();
    component sub1 = Fp2Sub();
    component sub2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            sub0.a[i][j] <== a[0][i][j];
            sub0.b[i][j] <== b[0][i][j];
            sub1.a[i][j] <== a[1][i][j];
            sub1.b[i][j] <== b[1][i][j];
            sub2.a[i][j] <== a[2][i][j];
            sub2.b[i][j] <== b[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== sub0.out[i][j];
            out[1][i][j] <== sub1.out[i][j];
            out[2][i][j] <== sub2.out[i][j];
        }
    }
}

template Fp6Neg() {
    signal input a[3][2][3];
    signal output out[3][2][3];

    component neg0 = Fp2Neg();
    component neg1 = Fp2Neg();
    component neg2 = Fp2Neg();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            neg0.a[i][j] <== a[0][i][j];
            neg1.a[i][j] <== a[1][i][j];
            neg2.a[i][j] <== a[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== neg0.out[i][j];
            out[1][i][j] <== neg1.out[i][j];
            out[2][i][j] <== neg2.out[i][j];
        }
    }
}

template Fp6Double() {
    signal input a[3][2][3];
    signal output out[3][2][3];

    component dbl0 = Fp2Double();
    component dbl1 = Fp2Double();
    component dbl2 = Fp2Double();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            dbl0.a[i][j] <== a[0][i][j];
            dbl1.a[i][j] <== a[1][i][j];
            dbl2.a[i][j] <== a[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== dbl0.out[i][j];
            out[1][i][j] <== dbl1.out[i][j];
            out[2][i][j] <== dbl2.out[i][j];
        }
    }
}

template Fp6MulByNonResidue() {
    signal input a[3][2][3];
    signal output out[3][2][3];

    component nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            nr.a[i][j] <== a[2][i][j];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== nr.out[i][j];
            out[1][i][j] <== a[0][i][j];
            out[2][i][j] <== a[1][i][j];
        }
    }
}

template Fp6MulByE2() {
    signal input a[3][2][3];
    signal input c0[2][3];
    signal output out[3][2][3];

    component mul0 = Fp2Mul();
    component mul1 = Fp2Mul();
    component mul2 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul0.a[i][j] <== a[0][i][j];
            mul0.b[i][j] <== c0[i][j];
            mul1.a[i][j] <== a[1][i][j];
            mul1.b[i][j] <== c0[i][j];
            mul2.a[i][j] <== a[2][i][j];
            mul2.b[i][j] <== c0[i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== mul0.out[i][j];
            out[1][i][j] <== mul1.out[i][j];
            out[2][i][j] <== mul2.out[i][j];
        }
    }
}

template Fp6Mul() {
    signal input a[3][2][3];
    signal input b[3][2][3];
    signal output out[3][2][3];

    component t0 = Fp2Mul();
    component t1 = Fp2Mul();
    component t2 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0.a[i][j] <== a[0][i][j];
            t0.b[i][j] <== b[0][i][j];
            t1.a[i][j] <== a[1][i][j];
            t1.b[i][j] <== b[1][i][j];
            t2.a[i][j] <== a[2][i][j];
            t2.b[i][j] <== b[2][i][j];
        }
    }

    component a1_plus_a2 = Fp2Add();
    component b1_plus_b2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a1_plus_a2.a[i][j] <== a[1][i][j];
            a1_plus_a2.b[i][j] <== a[2][i][j];
            b1_plus_b2.a[i][j] <== b[1][i][j];
            b1_plus_b2.b[i][j] <== b[2][i][j];
        }
    }

    component c0_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_mul.a[i][j] <== a1_plus_a2.out[i][j];
            c0_mul.b[i][j] <== b1_plus_b2.out[i][j];
        }
    }

    component c0_sub1 = Fp2Sub();
    component c0_sub2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_sub1.a[i][j] <== c0_mul.out[i][j];
            c0_sub1.b[i][j] <== t1.out[i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            c0_sub2.a[i2][j2] <== c0_sub1.out[i2][j2];
            c0_sub2.b[i2][j2] <== t2.out[i2][j2];
        }
    }

    component c0_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_nr.a[i][j] <== c0_sub2.out[i][j];
        }
    }

    component c0 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0.a[i][j] <== c0_nr.out[i][j];
            c0.b[i][j] <== t0.out[i][j];
        }
    }

    component a0_plus_a1 = Fp2Add();
    component b0_plus_b1 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a0_plus_a1.a[i][j] <== a[0][i][j];
            a0_plus_a1.b[i][j] <== a[1][i][j];
            b0_plus_b1.a[i][j] <== b[0][i][j];
            b0_plus_b1.b[i][j] <== b[1][i][j];
        }
    }

    component c1_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1_mul.a[i][j] <== a0_plus_a1.out[i][j];
            c1_mul.b[i][j] <== b0_plus_b1.out[i][j];
        }
    }

    component c1_sub1 = Fp2Sub();
    component c1_sub2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1_sub1.a[i][j] <== c1_mul.out[i][j];
            c1_sub1.b[i][j] <== t0.out[i][j];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            c1_sub2.a[i3][j3] <== c1_sub1.out[i3][j3];
            c1_sub2.b[i3][j3] <== t1.out[i3][j3];
        }
    }

    component tmp = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            tmp.a[i][j] <== t2.out[i][j];
        }
    }

    component c1 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1.a[i][j] <== c1_sub2.out[i][j];
            c1.b[i][j] <== tmp.out[i][j];
        }
    }

    component a0_plus_a2 = Fp2Add();
    component b0_plus_b2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a0_plus_a2.a[i][j] <== a[0][i][j];
            a0_plus_a2.b[i][j] <== a[2][i][j];
            b0_plus_b2.a[i][j] <== b[0][i][j];
            b0_plus_b2.b[i][j] <== b[2][i][j];
        }
    }

    component c2_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c2_mul.a[i][j] <== a0_plus_a2.out[i][j];
            c2_mul.b[i][j] <== b0_plus_b2.out[i][j];
        }
    }

    component c2_sub1 = Fp2Sub();
    component c2_sub2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c2_sub1.a[i][j] <== c2_mul.out[i][j];
            c2_sub1.b[i][j] <== t0.out[i][j];
        }
    }
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            c2_sub2.a[i4][j4] <== c2_sub1.out[i4][j4];
            c2_sub2.b[i4][j4] <== t2.out[i4][j4];
        }
    }

    component c2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c2.a[i][j] <== c2_sub2.out[i][j];
            c2.b[i][j] <== t1.out[i][j];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== c0.out[i][j];
            out[1][i][j] <== c1.out[i][j];
            out[2][i][j] <== c2.out[i][j];
        }
    }
}

template Fp6Square() {
    signal input a[3][2][3];
    signal output out[3][2][3];

    component c4_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c4_mul.a[i][j] <== a[0][i][j];
            c4_mul.b[i][j] <== a[1][i][j];
        }
    }
    component c4 = Fp2Double();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c4.a[i][j] <== c4_mul.out[i][j];
        }
    }

    component c5 = Fp2Square();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c5.a[i][j] <== a[2][i][j];
        }
    }

    component c1_tmp = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1_tmp.a[i][j] <== c5.out[i][j];
        }
    }
    component c1 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1.a[i][j] <== c1_tmp.out[i][j];
            c1.b[i][j] <== c4.out[i][j];
        }
    }

    component c2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c2.a[i][j] <== c4.out[i][j];
            c2.b[i][j] <== c5.out[i][j];
        }
    }

    component c3 = Fp2Square();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c3.a[i][j] <== a[0][i][j];
        }
    }

    component c4_tmp1 = Fp2Sub();
    component c4_tmp2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c4_tmp1.a[i][j] <== a[0][i][j];
            c4_tmp1.b[i][j] <== a[1][i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            c4_tmp2.a[i2][j2] <== c4_tmp1.out[i2][j2];
            c4_tmp2.b[i2][j2] <== a[2][i2][j2];
        }
    }
    component c4_sq = Fp2Square();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c4_sq.a[i][j] <== c4_tmp2.out[i][j];
        }
    }

    component c5_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c5_mul.a[i][j] <== a[1][i][j];
            c5_mul.b[i][j] <== a[2][i][j];
        }
    }
    component c5_dbl = Fp2Double();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c5_dbl.a[i][j] <== c5_mul.out[i][j];
        }
    }

    component c0_tmp = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_tmp.a[i][j] <== c5_dbl.out[i][j];
        }
    }
    component c0 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0.a[i][j] <== c0_tmp.out[i][j];
            c0.b[i][j] <== c3.out[i][j];
        }
    }

    component b2_tmp1 = Fp2Add();
    component b2_tmp2 = Fp2Add();
    component b2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            b2_tmp1.a[i][j] <== c2.out[i][j];
            b2_tmp1.b[i][j] <== c4_sq.out[i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            b2_tmp2.a[i2][j2] <== b2_tmp1.out[i2][j2];
            b2_tmp2.b[i2][j2] <== c5_dbl.out[i2][j2];
        }
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            b2.a[i3][j3] <== b2_tmp2.out[i3][j3];
            b2.b[i3][j3] <== c3.out[i3][j3];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== c0.out[i][j];
            out[1][i][j] <== c1.out[i][j];
            out[2][i][j] <== b2.out[i][j];
        }
    }
}

template Fp6Inverse() {
    signal input a[3][2][3];
    signal output out[3][2][3];

    component t0 = Fp2Square();
    component t1 = Fp2Square();
    component t2 = Fp2Square();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0.a[i][j] <== a[0][i][j];
            t1.a[i][j] <== a[1][i][j];
            t2.a[i][j] <== a[2][i][j];
        }
    }

    component t3 = Fp2Mul();
    component t4 = Fp2Mul();
    component t5 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t3.a[i][j] <== a[0][i][j];
            t3.b[i][j] <== a[1][i][j];
            t4.a[i][j] <== a[0][i][j];
            t4.b[i][j] <== a[2][i][j];
            t5.a[i][j] <== a[1][i][j];
            t5.b[i][j] <== a[2][i][j];
        }
    }

    component t5_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t5_nr.a[i][j] <== t5.out[i][j];
        }
    }

    component c0 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0.a[i][j] <== t0.out[i][j];
            c0.b[i][j] <== t5_nr.out[i][j];
        }
    }

    component t2_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t2_nr.a[i][j] <== t2.out[i][j];
        }
    }
    component c1 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1.a[i][j] <== t2_nr.out[i][j];
            c1.b[i][j] <== t3.out[i][j];
        }
    }

    component c2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c2.a[i][j] <== t1.out[i][j];
            c2.b[i][j] <== t4.out[i][j];
        }
    }

    component t6 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t6.a[i][j] <== a[0][i][j];
            t6.b[i][j] <== c0.out[i][j];
        }
    }

    component d1 = Fp2Mul();
    component d2 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            d1.a[i][j] <== a[2][i][j];
            d1.b[i][j] <== c1.out[i][j];
            d2.a[i][j] <== a[1][i][j];
            d2.b[i][j] <== c2.out[i][j];
        }
    }

    component d1_sum = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            d1_sum.a[i][j] <== d1.out[i][j];
            d1_sum.b[i][j] <== d2.out[i][j];
        }
    }
    component d1_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            d1_nr.a[i][j] <== d1_sum.out[i][j];
        }
    }

    component t6_sum = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t6_sum.a[i][j] <== t6.out[i][j];
            t6_sum.b[i][j] <== d1_nr.out[i][j];
        }
    }

    component t6_inv = Fp2Inverse();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t6_inv.a[i][j] <== t6_sum.out[i][j];
        }
    }

    component out0 = Fp2Mul();
    component out1 = Fp2Mul();
    component out2 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out0.a[i][j] <== c0.out[i][j];
            out0.b[i][j] <== t6_inv.out[i][j];
            out1.a[i][j] <== c1.out[i][j];
            out1.b[i][j] <== t6_inv.out[i][j];
            out2.a[i][j] <== c2.out[i][j];
            out2.b[i][j] <== t6_inv.out[i][j];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== out0.out[i][j];
            out[1][i][j] <== out1.out[i][j];
            out[2][i][j] <== out2.out[i][j];
        }
    }
}

template Fp6MulBy01() {
    signal input a[3][2][3];
    signal input c0[2][3];
    signal input c1[2][3];
    signal output out[3][2][3];

    component a_mul = Fp2Mul();
    component b_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a_mul.a[i][j] <== a[0][i][j];
            a_mul.b[i][j] <== c0[i][j];
            b_mul.a[i][j] <== a[1][i][j];
            b_mul.b[i][j] <== c1[i][j];
        }
    }

    component t0_mul = Fp2Mul();
    component b1_plus_b2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            b1_plus_b2.a[i][j] <== a[1][i][j];
            b1_plus_b2.b[i][j] <== a[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0_mul.a[i][j] <== c1[i][j];
            t0_mul.b[i][j] <== b1_plus_b2.out[i][j];
        }
    }
    component t0_sub = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0_sub.a[i][j] <== t0_mul.out[i][j];
            t0_sub.b[i][j] <== b_mul.out[i][j];
        }
    }
    component t0_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0_nr.a[i][j] <== t0_sub.out[i][j];
        }
    }
    component t0 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0.a[i][j] <== t0_nr.out[i][j];
            t0.b[i][j] <== a_mul.out[i][j];
        }
    }

    component t2_mul = Fp2Mul();
    component b0_plus_b2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            b0_plus_b2.a[i][j] <== a[0][i][j];
            b0_plus_b2.b[i][j] <== a[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t2_mul.a[i][j] <== c0[i][j];
            t2_mul.b[i][j] <== b0_plus_b2.out[i][j];
        }
    }
    component t2_sub = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t2_sub.a[i][j] <== t2_mul.out[i][j];
            t2_sub.b[i][j] <== a_mul.out[i][j];
        }
    }
    component t2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t2.a[i][j] <== t2_sub.out[i][j];
            t2.b[i][j] <== b_mul.out[i][j];
        }
    }

    component t1_mul = Fp2Mul();
    component c0_plus_c1 = Fp2Add();
    component b0_plus_b1 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_plus_c1.a[i][j] <== c0[i][j];
            c0_plus_c1.b[i][j] <== c1[i][j];
            b0_plus_b1.a[i][j] <== a[0][i][j];
            b0_plus_b1.b[i][j] <== a[1][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t1_mul.a[i][j] <== c0_plus_c1.out[i][j];
            t1_mul.b[i][j] <== b0_plus_b1.out[i][j];
        }
    }
    component t1_sub1 = Fp2Sub();
    component t1_sub2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t1_sub1.a[i][j] <== t1_mul.out[i][j];
            t1_sub1.b[i][j] <== a_mul.out[i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            t1_sub2.a[i2][j2] <== t1_sub1.out[i2][j2];
            t1_sub2.b[i2][j2] <== b_mul.out[i2][j2];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== t0.out[i][j];
            out[1][i][j] <== t1_sub2.out[i][j];
            out[2][i][j] <== t2.out[i][j];
        }
    }
}

template Fp6MulBy1() {
    signal input a[3][2][3];
    signal input c1[2][3];
    signal output out[3][2][3];

    component b_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            b_mul.a[i][j] <== a[1][i][j];
            b_mul.b[i][j] <== c1[i][j];
        }
    }

    component t0_mul = Fp2Mul();
    component b1_plus_b2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            b1_plus_b2.a[i][j] <== a[1][i][j];
            b1_plus_b2.b[i][j] <== a[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0_mul.a[i][j] <== c1[i][j];
            t0_mul.b[i][j] <== b1_plus_b2.out[i][j];
        }
    }
    component t0_sub = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0_sub.a[i][j] <== t0_mul.out[i][j];
            t0_sub.b[i][j] <== b_mul.out[i][j];
        }
    }
    component t0_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t0_nr.a[i][j] <== t0_sub.out[i][j];
        }
    }

    component t1_mul = Fp2Mul();
    component b0_plus_b1 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            b0_plus_b1.a[i][j] <== a[0][i][j];
            b0_plus_b1.b[i][j] <== a[1][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t1_mul.a[i][j] <== c1[i][j];
            t1_mul.b[i][j] <== b0_plus_b1.out[i][j];
        }
    }
    component t1_sub = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t1_sub.a[i][j] <== t1_mul.out[i][j];
            t1_sub.b[i][j] <== b_mul.out[i][j];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== t0_nr.out[i][j];
            out[1][i][j] <== t1_sub.out[i][j];
            out[2][i][j] <== b_mul.out[i][j];
        }
    }
}

template Fp6MulBy12() {
    signal input a[3][2][3];
    signal input b1[2][3];
    signal input b2[2][3];
    signal output out[3][2][3];

    component t1 = Fp2Mul();
    component t2 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t1.a[i][j] <== a[1][i][j];
            t1.b[i][j] <== b1[i][j];
            t2.a[i][j] <== a[2][i][j];
            t2.b[i][j] <== b2[i][j];
        }
    }

    component c0_mul = Fp2Mul();
    component b1_plus_b2 = Fp2Add();
    component a1_plus_a2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            b1_plus_b2.a[i][j] <== b1[i][j];
            b1_plus_b2.b[i][j] <== b2[i][j];
            a1_plus_a2.a[i][j] <== a[1][i][j];
            a1_plus_a2.b[i][j] <== a[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_mul.a[i][j] <== a1_plus_a2.out[i][j];
            c0_mul.b[i][j] <== b1_plus_b2.out[i][j];
        }
    }
    component c0_sub1 = Fp2Sub();
    component c0_sub2 = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_sub1.a[i][j] <== c0_mul.out[i][j];
            c0_sub1.b[i][j] <== t1.out[i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            c0_sub2.a[i2][j2] <== c0_sub1.out[i2][j2];
            c0_sub2.b[i2][j2] <== t2.out[i2][j2];
        }
    }
    component c0_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c0_nr.a[i][j] <== c0_sub2.out[i][j];
        }
    }

    component c1_mul = Fp2Mul();
    component a0_plus_a1 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a0_plus_a1.a[i][j] <== a[0][i][j];
            a0_plus_a1.b[i][j] <== a[1][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1_mul.a[i][j] <== a0_plus_a1.out[i][j];
            c1_mul.b[i][j] <== b1[i][j];
        }
    }
    component c1_sub = Fp2Sub();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1_sub.a[i][j] <== c1_mul.out[i][j];
            c1_sub.b[i][j] <== t1.out[i][j];
        }
    }
    component t2_nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            t2_nr.a[i][j] <== t2.out[i][j];
        }
    }
    component c1 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c1.a[i][j] <== c1_sub.out[i][j];
            c1.b[i][j] <== t2_nr.out[i][j];
        }
    }

    component c2_mul = Fp2Mul();
    component a0_plus_a2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            a0_plus_a2.a[i][j] <== a[0][i][j];
            a0_plus_a2.b[i][j] <== a[2][i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c2_mul.a[i][j] <== b2[i][j];
            c2_mul.b[i][j] <== a0_plus_a2.out[i][j];
        }
    }
    component c2_sub = Fp2Sub();
    component c2 = Fp2Add();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            c2_sub.a[i][j] <== c2_mul.out[i][j];
            c2_sub.b[i][j] <== t2.out[i][j];
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            c2.a[i2][j2] <== c2_sub.out[i2][j2];
            c2.b[i2][j2] <== t1.out[i2][j2];
        }
    }

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[0][i][j] <== c0_nr.out[i][j];
            out[1][i][j] <== c1.out[i][j];
            out[2][i][j] <== c2.out[i][j];
        }
    }
}
