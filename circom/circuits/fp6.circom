pragma circom 2.0.0;

include "./fp2.circom";

template Fp6Zero() {
    signal output out[3][2];
    component zero = Fp2Zero();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            out[k][i] <== zero.out[i];
        }
    }
}

template Fp6One() {
    signal output out[3][2];
    component one = Fp2One();
    component zero = Fp2Zero();
    for (var i = 0; i < 2; i++) {
        out[0][i] <== one.out[i];
        out[1][i] <== zero.out[i];
        out[2][i] <== zero.out[i];
    }
}

template Fp6Add() {
    signal input a[3][2];
    signal input b[3][2];
    signal output out[3][2];

    component add[3];
    for (var k = 0; k < 3; k++) {
        add[k] = Fp2Add();
        for (var i = 0; i < 2; i++) {
            add[k].a[i] <== a[k][i];
            add[k].b[i] <== b[k][i];
            out[k][i] <== add[k].out[i];
        }
    }
}

template Fp6Sub() {
    signal input a[3][2];
    signal input b[3][2];
    signal output out[3][2];

    component sub[3];
    for (var k = 0; k < 3; k++) {
        sub[k] = Fp2Sub();
        for (var i = 0; i < 2; i++) {
            sub[k].a[i] <== a[k][i];
            sub[k].b[i] <== b[k][i];
            out[k][i] <== sub[k].out[i];
        }
    }
}

template Fp6Neg() {
    signal input a[3][2];
    signal output out[3][2];

    component neg[3];
    for (var k = 0; k < 3; k++) {
        neg[k] = Fp2Neg();
        for (var i = 0; i < 2; i++) {
            neg[k].a[i] <== a[k][i];
            out[k][i] <== neg[k].out[i];
        }
    }
}

template Fp6Double() {
    signal input a[3][2];
    signal output out[3][2];

    component dbl[3];
    for (var k = 0; k < 3; k++) {
        dbl[k] = Fp2Double();
        for (var i = 0; i < 2; i++) {
            dbl[k].a[i] <== a[k][i];
            out[k][i] <== dbl[k].out[i];
        }
    }
}

template Fp6MulByNonResidue() {
    signal input a[3][2];
    signal output out[3][2];

    component nr = Fp2MulByNonResidue();
    for (var i = 0; i < 2; i++) {
        nr.a[i] <== a[2][i];
    }

    for (var i = 0; i < 2; i++) {
        out[0][i] <== nr.out[i];
        out[1][i] <== a[0][i];
        out[2][i] <== a[1][i];
    }
}

template Fp6MulByE2() {
    signal input a[3][2];
    signal input c0[2];
    signal output out[3][2];

    component mul[3];
    for (var k = 0; k < 3; k++) {
        mul[k] = Fp2Mul();
        for (var i = 0; i < 2; i++) {
            mul[k].a[i] <== a[k][i];
            mul[k].b[i] <== c0[i];
            out[k][i] <== mul[k].out[i];
        }
    }
}

template Fp6Mul() {
    signal input a[3][2];
    signal input b[3][2];
    signal output out[3][2];

    component t0 = Fp2Mul();
    component t1 = Fp2Mul();
    component t2 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        t0.a[i] <== a[0][i];
        t0.b[i] <== b[0][i];
        t1.a[i] <== a[1][i];
        t1.b[i] <== b[1][i];
        t2.a[i] <== a[2][i];
        t2.b[i] <== b[2][i];
    }

    component a1_plus_a2 = Fp2Add();
    component b1_plus_b2 = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        a1_plus_a2.a[i2] <== a[1][i2];
        a1_plus_a2.b[i2] <== a[2][i2];
        b1_plus_b2.a[i2] <== b[1][i2];
        b1_plus_b2.b[i2] <== b[2][i2];
    }

    component c0_mul = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        c0_mul.a[i3] <== a1_plus_a2.out[i3];
        c0_mul.b[i3] <== b1_plus_b2.out[i3];
    }

    component c0_sub1 = Fp2Sub();
    component c0_sub2 = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        c0_sub1.a[i4] <== c0_mul.out[i4];
        c0_sub1.b[i4] <== t1.out[i4];
        c0_sub2.a[i4] <== c0_sub1.out[i4];
        c0_sub2.b[i4] <== t2.out[i4];
    }

    component c0_nr = Fp2MulByNonResidue();
    for (var i5 = 0; i5 < 2; i5++) {
        c0_nr.a[i5] <== c0_sub2.out[i5];
    }

    component c0 = Fp2Add();
    for (var i6 = 0; i6 < 2; i6++) {
        c0.a[i6] <== c0_nr.out[i6];
        c0.b[i6] <== t0.out[i6];
    }

    component a0_plus_a1 = Fp2Add();
    component b0_plus_b1 = Fp2Add();
    for (var i7 = 0; i7 < 2; i7++) {
        a0_plus_a1.a[i7] <== a[0][i7];
        a0_plus_a1.b[i7] <== a[1][i7];
        b0_plus_b1.a[i7] <== b[0][i7];
        b0_plus_b1.b[i7] <== b[1][i7];
    }

    component c1_mul = Fp2Mul();
    for (var i8 = 0; i8 < 2; i8++) {
        c1_mul.a[i8] <== a0_plus_a1.out[i8];
        c1_mul.b[i8] <== b0_plus_b1.out[i8];
    }

    component c1_sub1 = Fp2Sub();
    component c1_sub2 = Fp2Sub();
    for (var i9 = 0; i9 < 2; i9++) {
        c1_sub1.a[i9] <== c1_mul.out[i9];
        c1_sub1.b[i9] <== t0.out[i9];
        c1_sub2.a[i9] <== c1_sub1.out[i9];
        c1_sub2.b[i9] <== t1.out[i9];
    }

    component tmp = Fp2MulByNonResidue();
    for (var i10 = 0; i10 < 2; i10++) {
        tmp.a[i10] <== t2.out[i10];
    }

    component c1 = Fp2Add();
    for (var i11 = 0; i11 < 2; i11++) {
        c1.a[i11] <== c1_sub2.out[i11];
        c1.b[i11] <== tmp.out[i11];
    }

    component a0_plus_a2 = Fp2Add();
    component b0_plus_b2 = Fp2Add();
    for (var i12 = 0; i12 < 2; i12++) {
        a0_plus_a2.a[i12] <== a[0][i12];
        a0_plus_a2.b[i12] <== a[2][i12];
        b0_plus_b2.a[i12] <== b[0][i12];
        b0_plus_b2.b[i12] <== b[2][i12];
    }

    component c2_mul = Fp2Mul();
    for (var i13 = 0; i13 < 2; i13++) {
        c2_mul.a[i13] <== a0_plus_a2.out[i13];
        c2_mul.b[i13] <== b0_plus_b2.out[i13];
    }

    component c2_sub1 = Fp2Sub();
    component c2_sub2 = Fp2Sub();
    for (var i14 = 0; i14 < 2; i14++) {
        c2_sub1.a[i14] <== c2_mul.out[i14];
        c2_sub1.b[i14] <== t0.out[i14];
        c2_sub2.a[i14] <== c2_sub1.out[i14];
        c2_sub2.b[i14] <== t2.out[i14];
    }

    component c2 = Fp2Add();
    for (var i15 = 0; i15 < 2; i15++) {
        c2.a[i15] <== c2_sub2.out[i15];
        c2.b[i15] <== t1.out[i15];
    }

    for (var i16 = 0; i16 < 2; i16++) {
        out[0][i16] <== c0.out[i16];
        out[1][i16] <== c1.out[i16];
        out[2][i16] <== c2.out[i16];
    }
}

template Fp6Square() {
    signal input a[3][2];
    signal output out[3][2];

    component c4_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        c4_mul.a[i] <== a[0][i];
        c4_mul.b[i] <== a[1][i];
    }
    component c4 = Fp2Double();
    for (var i2 = 0; i2 < 2; i2++) {
        c4.a[i2] <== c4_mul.out[i2];
    }

    component c5 = Fp2Square();
    for (var i3 = 0; i3 < 2; i3++) {
        c5.a[i3] <== a[2][i3];
    }

    component c1_tmp = Fp2MulByNonResidue();
    for (var i4 = 0; i4 < 2; i4++) {
        c1_tmp.a[i4] <== c5.out[i4];
    }
    component c1 = Fp2Add();
    for (var i5 = 0; i5 < 2; i5++) {
        c1.a[i5] <== c1_tmp.out[i5];
        c1.b[i5] <== c4.out[i5];
    }

    component c2 = Fp2Sub();
    for (var i6 = 0; i6 < 2; i6++) {
        c2.a[i6] <== c4.out[i6];
        c2.b[i6] <== c5.out[i6];
    }

    component c3 = Fp2Square();
    for (var i7 = 0; i7 < 2; i7++) {
        c3.a[i7] <== a[0][i7];
    }

    component c4_tmp1 = Fp2Sub();
    component c4_tmp2 = Fp2Add();
    for (var i8 = 0; i8 < 2; i8++) {
        c4_tmp1.a[i8] <== a[0][i8];
        c4_tmp1.b[i8] <== a[1][i8];
        c4_tmp2.a[i8] <== c4_tmp1.out[i8];
        c4_tmp2.b[i8] <== a[2][i8];
    }
    component c4_sq = Fp2Square();
    for (var i9 = 0; i9 < 2; i9++) {
        c4_sq.a[i9] <== c4_tmp2.out[i9];
    }

    component c5_mul = Fp2Mul();
    for (var i10 = 0; i10 < 2; i10++) {
        c5_mul.a[i10] <== a[1][i10];
        c5_mul.b[i10] <== a[2][i10];
    }
    component c5_dbl = Fp2Double();
    for (var i11 = 0; i11 < 2; i11++) {
        c5_dbl.a[i11] <== c5_mul.out[i11];
    }

    component c0_tmp = Fp2MulByNonResidue();
    for (var i12 = 0; i12 < 2; i12++) {
        c0_tmp.a[i12] <== c5_dbl.out[i12];
    }
    component c0 = Fp2Add();
    for (var i13 = 0; i13 < 2; i13++) {
        c0.a[i13] <== c0_tmp.out[i13];
        c0.b[i13] <== c3.out[i13];
    }

    component b2_tmp1 = Fp2Add();
    component b2_tmp2 = Fp2Add();
    component b2 = Fp2Sub();
    for (var i14 = 0; i14 < 2; i14++) {
        b2_tmp1.a[i14] <== c2.out[i14];
        b2_tmp1.b[i14] <== c4_sq.out[i14];
        b2_tmp2.a[i14] <== b2_tmp1.out[i14];
        b2_tmp2.b[i14] <== c5_dbl.out[i14];
        b2.a[i14] <== b2_tmp2.out[i14];
        b2.b[i14] <== c3.out[i14];
    }

    for (var i15 = 0; i15 < 2; i15++) {
        out[0][i15] <== c0.out[i15];
        out[1][i15] <== c1.out[i15];
        out[2][i15] <== b2.out[i15];
    }
}

template Fp6Inverse() {
    signal input a[3][2];
    signal input inv[3][2];
    signal output out[3][2];

    component mul = Fp6Mul();
    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            mul.a[k][i] <== a[k][i];
            mul.b[k][i] <== inv[k][i];
        }
    }

    component one = Fp6One();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i2 = 0; i2 < 2; i2++) {
            mul.out[k2][i2] === one.out[k2][i2];
            out[k2][i2] <== inv[k2][i2];
        }
    }
}

template Fp6MulBy01() {
    signal input a[3][2];
    signal input c0[2];
    signal input c1[2];
    signal output out[3][2];

    component a_mul = Fp2Mul();
    component b_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        a_mul.a[i] <== a[0][i];
        a_mul.b[i] <== c0[i];
        b_mul.a[i] <== a[1][i];
        b_mul.b[i] <== c1[i];
    }

    component t0_mul = Fp2Mul();
    component b1_plus_b2 = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        b1_plus_b2.a[i2] <== a[1][i2];
        b1_plus_b2.b[i2] <== a[2][i2];
        t0_mul.a[i2] <== c1[i2];
        t0_mul.b[i2] <== b1_plus_b2.out[i2];
    }
    component t0_sub = Fp2Sub();
    for (var i3 = 0; i3 < 2; i3++) {
        t0_sub.a[i3] <== t0_mul.out[i3];
        t0_sub.b[i3] <== b_mul.out[i3];
    }
    component t0_nr = Fp2MulByNonResidue();
    for (var i4 = 0; i4 < 2; i4++) {
        t0_nr.a[i4] <== t0_sub.out[i4];
    }
    component t0 = Fp2Add();
    for (var i5 = 0; i5 < 2; i5++) {
        t0.a[i5] <== t0_nr.out[i5];
        t0.b[i5] <== a_mul.out[i5];
    }

    component t2_mul = Fp2Mul();
    component b0_plus_b2 = Fp2Add();
    for (var i6 = 0; i6 < 2; i6++) {
        b0_plus_b2.a[i6] <== a[0][i6];
        b0_plus_b2.b[i6] <== a[2][i6];
        t2_mul.a[i6] <== c0[i6];
        t2_mul.b[i6] <== b0_plus_b2.out[i6];
    }
    component t2_sub = Fp2Sub();
    for (var i7 = 0; i7 < 2; i7++) {
        t2_sub.a[i7] <== t2_mul.out[i7];
        t2_sub.b[i7] <== a_mul.out[i7];
    }
    component t2 = Fp2Add();
    for (var i8 = 0; i8 < 2; i8++) {
        t2.a[i8] <== t2_sub.out[i8];
        t2.b[i8] <== b_mul.out[i8];
    }

    component t1_mul = Fp2Mul();
    component c0_plus_c1 = Fp2Add();
    component b0_plus_b1 = Fp2Add();
    for (var i9 = 0; i9 < 2; i9++) {
        c0_plus_c1.a[i9] <== c0[i9];
        c0_plus_c1.b[i9] <== c1[i9];
        b0_plus_b1.a[i9] <== a[0][i9];
        b0_plus_b1.b[i9] <== a[1][i9];
        t1_mul.a[i9] <== c0_plus_c1.out[i9];
        t1_mul.b[i9] <== b0_plus_b1.out[i9];
    }
    component t1_sub1 = Fp2Sub();
    component t1_sub2 = Fp2Sub();
    for (var i10 = 0; i10 < 2; i10++) {
        t1_sub1.a[i10] <== t1_mul.out[i10];
        t1_sub1.b[i10] <== a_mul.out[i10];
        t1_sub2.a[i10] <== t1_sub1.out[i10];
        t1_sub2.b[i10] <== b_mul.out[i10];
    }

    for (var i11 = 0; i11 < 2; i11++) {
        out[0][i11] <== t0.out[i11];
        out[1][i11] <== t1_sub2.out[i11];
        out[2][i11] <== t2.out[i11];
    }
}

template Fp6MulBy1() {
    signal input a[3][2];
    signal input c1[2];
    signal output out[3][2];

    component b_mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        b_mul.a[i] <== a[1][i];
        b_mul.b[i] <== c1[i];
    }

    component t0_mul = Fp2Mul();
    component b1_plus_b2 = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        b1_plus_b2.a[i2] <== a[1][i2];
        b1_plus_b2.b[i2] <== a[2][i2];
        t0_mul.a[i2] <== c1[i2];
        t0_mul.b[i2] <== b1_plus_b2.out[i2];
    }
    component t0_sub = Fp2Sub();
    for (var i3 = 0; i3 < 2; i3++) {
        t0_sub.a[i3] <== t0_mul.out[i3];
        t0_sub.b[i3] <== b_mul.out[i3];
    }
    component t0_nr = Fp2MulByNonResidue();
    for (var i4 = 0; i4 < 2; i4++) {
        t0_nr.a[i4] <== t0_sub.out[i4];
    }

    component t1_mul = Fp2Mul();
    component b0_plus_b1 = Fp2Add();
    for (var i5 = 0; i5 < 2; i5++) {
        b0_plus_b1.a[i5] <== a[0][i5];
        b0_plus_b1.b[i5] <== a[1][i5];
        t1_mul.a[i5] <== c1[i5];
        t1_mul.b[i5] <== b0_plus_b1.out[i5];
    }
    component t1_sub = Fp2Sub();
    for (var i6 = 0; i6 < 2; i6++) {
        t1_sub.a[i6] <== t1_mul.out[i6];
        t1_sub.b[i6] <== b_mul.out[i6];
    }

    for (var i7 = 0; i7 < 2; i7++) {
        out[0][i7] <== t0_nr.out[i7];
        out[1][i7] <== t1_sub.out[i7];
        out[2][i7] <== b_mul.out[i7];
    }
}

template Fp6MulBy12() {
    signal input a[3][2];
    signal input b1[2];
    signal input b2[2];
    signal output out[3][2];

    component t1 = Fp2Mul();
    component t2 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        t1.a[i] <== a[1][i];
        t1.b[i] <== b1[i];
        t2.a[i] <== a[2][i];
        t2.b[i] <== b2[i];
    }

    component c0_mul = Fp2Mul();
    component b1_plus_b2 = Fp2Add();
    component a1_plus_a2 = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        b1_plus_b2.a[i2] <== b1[i2];
        b1_plus_b2.b[i2] <== b2[i2];
        a1_plus_a2.a[i2] <== a[1][i2];
        a1_plus_a2.b[i2] <== a[2][i2];
        c0_mul.a[i2] <== a1_plus_a2.out[i2];
        c0_mul.b[i2] <== b1_plus_b2.out[i2];
    }
    component c0_sub1 = Fp2Sub();
    component c0_sub2 = Fp2Sub();
    for (var i3 = 0; i3 < 2; i3++) {
        c0_sub1.a[i3] <== c0_mul.out[i3];
        c0_sub1.b[i3] <== t1.out[i3];
        c0_sub2.a[i3] <== c0_sub1.out[i3];
        c0_sub2.b[i3] <== t2.out[i3];
    }
    component c0_nr = Fp2MulByNonResidue();
    for (var i4 = 0; i4 < 2; i4++) {
        c0_nr.a[i4] <== c0_sub2.out[i4];
    }

    component c1_mul = Fp2Mul();
    component a0_plus_a1 = Fp2Add();
    for (var i5 = 0; i5 < 2; i5++) {
        a0_plus_a1.a[i5] <== a[0][i5];
        a0_plus_a1.b[i5] <== a[1][i5];
        c1_mul.a[i5] <== a0_plus_a1.out[i5];
        c1_mul.b[i5] <== b1[i5];
    }
    component c1_sub = Fp2Sub();
    for (var i6 = 0; i6 < 2; i6++) {
        c1_sub.a[i6] <== c1_mul.out[i6];
        c1_sub.b[i6] <== t1.out[i6];
    }
    component t2_nr = Fp2MulByNonResidue();
    for (var i7 = 0; i7 < 2; i7++) {
        t2_nr.a[i7] <== t2.out[i7];
    }
    component c1 = Fp2Add();
    for (var i8 = 0; i8 < 2; i8++) {
        c1.a[i8] <== c1_sub.out[i8];
        c1.b[i8] <== t2_nr.out[i8];
    }

    component c2_mul = Fp2Mul();
    component a0_plus_a2 = Fp2Add();
    for (var i9 = 0; i9 < 2; i9++) {
        a0_plus_a2.a[i9] <== a[0][i9];
        a0_plus_a2.b[i9] <== a[2][i9];
        c2_mul.a[i9] <== b2[i9];
        c2_mul.b[i9] <== a0_plus_a2.out[i9];
    }
    component c2_sub = Fp2Sub();
    for (var i10 = 0; i10 < 2; i10++) {
        c2_sub.a[i10] <== c2_mul.out[i10];
        c2_sub.b[i10] <== t2.out[i10];
    }
    component c2 = Fp2Add();
    for (var i11 = 0; i11 < 2; i11++) {
        c2.a[i11] <== c2_sub.out[i11];
        c2.b[i11] <== t1.out[i11];
    }

    for (var i12 = 0; i12 < 2; i12++) {
        out[0][i12] <== c0_nr.out[i12];
        out[1][i12] <== c1.out[i12];
        out[2][i12] <== c2.out[i12];
    }
}
