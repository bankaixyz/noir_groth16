pragma circom 2.0.0;

include "../fp6.circom";

template Fp6Ops() {
    signal input a[3][2];
    signal input b[3][2];
    signal input inv[3][2];
    signal input c0[2];
    signal input c1[2];
    signal input c0_inv_hint[2];

    signal output add[3][2];
    signal output sub[3][2];
    signal output mul[3][2];
    signal output square[3][2];
    signal output inv_a[3][2];
    signal output mul_inv[3][2];
    signal output inv_inverse[3][2];
    signal output neg[3][2];
    signal output double[3][2];
    signal output mul_by_non_residue[3][2];
    signal output mul_by_e2_chain[3][2];
    signal output mul_by_01[3][2];
    signal output mul_by_1[3][2];
    signal output mul_sparse[3][2];

    component add_op = Fp6Add();
    component sub_op = Fp6Sub();
    component mul_op = Fp6Mul();
    component sq_op = Fp6Square();
    component inv_op = Fp6Inverse();
    component mul_inv_op = Fp6Mul();
    component inv_inv_op = Fp6Inverse();
    component neg_op = Fp6Neg();
    component dbl_op = Fp6Double();
    component mul_nr_op = Fp6MulByNonResidue();
    component mul_by_01_op = Fp6MulBy01();
    component mul_by_1_op = Fp6MulBy1();

    for (var k = 0; k < 3; k++) {
        for (var i = 0; i < 2; i++) {
            add_op.a[k][i] <== a[k][i];
            add_op.b[k][i] <== b[k][i];
            sub_op.a[k][i] <== a[k][i];
            sub_op.b[k][i] <== b[k][i];
            mul_op.a[k][i] <== a[k][i];
            mul_op.b[k][i] <== b[k][i];
            sq_op.a[k][i] <== a[k][i];
            inv_op.a[k][i] <== a[k][i];
            inv_op.inv[k][i] <== inv[k][i];
            mul_inv_op.a[k][i] <== a[k][i];
            mul_inv_op.b[k][i] <== inv[k][i];
            inv_inv_op.a[k][i] <== inv[k][i];
            inv_inv_op.inv[k][i] <== a[k][i];
            neg_op.a[k][i] <== a[k][i];
            dbl_op.a[k][i] <== a[k][i];
            mul_nr_op.a[k][i] <== a[k][i];
            mul_by_01_op.a[k][i] <== a[k][i];
            mul_by_1_op.a[k][i] <== a[k][i];
        }
    }

    for (var i2 = 0; i2 < 2; i2++) {
        mul_by_01_op.c0[i2] <== c0[i2];
        mul_by_01_op.c1[i2] <== c1[i2];
        mul_by_1_op.c1[i2] <== c1[i2];
    }

    component c0_inv = Fp2Inverse();
    for (var i3 = 0; i3 < 2; i3++) {
        c0_inv.a[i3] <== c0[i3];
        c0_inv.inv[i3] <== c0_inv_hint[i3];
    }
    component mul_e2 = Fp6MulByE2();
    component mul_e2_inv = Fp6MulByE2();
    for (var k2 = 0; k2 < 3; k2++) {
        for (var i4 = 0; i4 < 2; i4++) {
            mul_e2.a[k2][i4] <== a[k2][i4];
        }
    }
    for (var i5 = 0; i5 < 2; i5++) {
        mul_e2.c0[i5] <== c0[i5];
    }
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i6 = 0; i6 < 2; i6++) {
            mul_e2_inv.a[k3][i6] <== mul_e2.out[k3][i6];
        }
    }
    for (var i7 = 0; i7 < 2; i7++) {
        mul_e2_inv.c0[i7] <== c0_inv.out[i7];
    }

    signal sparse[3][2];
    for (var i6 = 0; i6 < 2; i6++) {
        sparse[0][i6] <== 0;
        sparse[1][i6] <== c1[i6];
        sparse[2][i6] <== 0;
    }
    component mul_sparse_op = Fp6Mul();
    for (var k3 = 0; k3 < 3; k3++) {
        for (var i7 = 0; i7 < 2; i7++) {
            mul_sparse_op.a[k3][i7] <== a[k3][i7];
            mul_sparse_op.b[k3][i7] <== sparse[k3][i7];
        }
    }

    for (var k4 = 0; k4 < 3; k4++) {
        for (var i8 = 0; i8 < 2; i8++) {
            add[k4][i8] <== add_op.out[k4][i8];
            sub[k4][i8] <== sub_op.out[k4][i8];
            mul[k4][i8] <== mul_op.out[k4][i8];
            square[k4][i8] <== sq_op.out[k4][i8];
            inv_a[k4][i8] <== inv_op.out[k4][i8];
            mul_inv[k4][i8] <== mul_inv_op.out[k4][i8];
            inv_inverse[k4][i8] <== inv_inv_op.out[k4][i8];
            neg[k4][i8] <== neg_op.out[k4][i8];
            double[k4][i8] <== dbl_op.out[k4][i8];
            mul_by_non_residue[k4][i8] <== mul_nr_op.out[k4][i8];
            mul_by_e2_chain[k4][i8] <== mul_e2_inv.out[k4][i8];
            mul_by_01[k4][i8] <== mul_by_01_op.out[k4][i8];
            mul_by_1[k4][i8] <== mul_by_1_op.out[k4][i8];
            mul_sparse[k4][i8] <== mul_sparse_op.out[k4][i8];
        }
    }
}

component main = Fp6Ops();
