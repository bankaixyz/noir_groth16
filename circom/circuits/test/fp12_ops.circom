pragma circom 2.0.0;

include "../fp12.circom";

template Fp12Ops() {
    signal input a[2][3][2][3];
    signal input b[2][3][2][3];
    signal input inv[2][3][2][3];
    signal input cyclo[2][3][2][3];
    signal input d0[2][3];
    signal input d3[2][3];
    signal input d4[2][3];

    signal output add[2][3][2][3];
    signal output sub[2][3][2][3];
    signal output mul[2][3][2][3];
    signal output square[2][3][2][3];
    signal output inv_a[2][3][2][3];
    signal output mul_inv[2][3][2][3];
    signal output inv_inverse[2][3][2][3];
    signal output conjugate[2][3][2][3];
    signal output double[2][3][2][3];
    signal output frob[2][3][2][3];
    signal output frob_square[2][3][2][3];
    signal output frob_cube[2][3][2][3];
    signal output cyclotomic_square[2][3][2][3];
    signal output mul_by_034[2][3][2][3];

    component add_op = Fp12Add();
    component sub_op = Fp12Sub();
    component mul_op = Fp12Mul();
    component sq_op = Fp12Square();
    component inv_op = Fp12Inverse();
    component mul_inv_op = Fp12Mul();
    component inv_inv_op = Fp12Inverse();
    component conj_op = Fp12Conjugate();
    component dbl_op = Fp12Add();
    component frob_op = Fp12Frobenius();
    component frob_sq_op = Fp12FrobeniusSquare();
    component frob_cube_op = Fp12FrobeniusCube();
    component cyclo_sq_op = Fp12CyclotomicSquare();
    component mul_034_op = Fp12MulBy034();

    for (var c = 0; c < 2; c++) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    add_op.a[c][k][i][j] <== a[c][k][i][j];
                    add_op.b[c][k][i][j] <== b[c][k][i][j];
                    sub_op.a[c][k][i][j] <== a[c][k][i][j];
                    sub_op.b[c][k][i][j] <== b[c][k][i][j];
                    mul_op.a[c][k][i][j] <== a[c][k][i][j];
                    mul_op.b[c][k][i][j] <== b[c][k][i][j];
                    sq_op.a[c][k][i][j] <== a[c][k][i][j];
                    inv_op.a[c][k][i][j] <== a[c][k][i][j];
                    mul_inv_op.a[c][k][i][j] <== a[c][k][i][j];
                    mul_inv_op.b[c][k][i][j] <== inv[c][k][i][j];
                    inv_inv_op.a[c][k][i][j] <== inv[c][k][i][j];
                    conj_op.a[c][k][i][j] <== a[c][k][i][j];
                    dbl_op.a[c][k][i][j] <== a[c][k][i][j];
                    dbl_op.b[c][k][i][j] <== a[c][k][i][j];
                    frob_op.a[c][k][i][j] <== a[c][k][i][j];
                    frob_sq_op.a[c][k][i][j] <== a[c][k][i][j];
                    frob_cube_op.a[c][k][i][j] <== a[c][k][i][j];
                    cyclo_sq_op.a[c][k][i][j] <== cyclo[c][k][i][j];
                    mul_034_op.a[c][k][i][j] <== a[c][k][i][j];
                }
            }
        }
    }

    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            mul_034_op.c0[i2][j2] <== d0[i2][j2];
            mul_034_op.c3[i2][j2] <== d3[i2][j2];
            mul_034_op.c4[i2][j2] <== d4[i2][j2];
        }
    }

    for (var c2 = 0; c2 < 2; c2++) {
        for (var k2 = 0; k2 < 3; k2++) {
            for (var i3 = 0; i3 < 2; i3++) {
                for (var j3 = 0; j3 < 3; j3++) {
                    add[c2][k2][i3][j3] <== add_op.out[c2][k2][i3][j3];
                    sub[c2][k2][i3][j3] <== sub_op.out[c2][k2][i3][j3];
                    mul[c2][k2][i3][j3] <== mul_op.out[c2][k2][i3][j3];
                    square[c2][k2][i3][j3] <== sq_op.out[c2][k2][i3][j3];
                    inv_a[c2][k2][i3][j3] <== inv_op.out[c2][k2][i3][j3];
                    mul_inv[c2][k2][i3][j3] <== mul_inv_op.out[c2][k2][i3][j3];
                    inv_inverse[c2][k2][i3][j3] <== inv_inv_op.out[c2][k2][i3][j3];
                    conjugate[c2][k2][i3][j3] <== conj_op.out[c2][k2][i3][j3];
                    double[c2][k2][i3][j3] <== dbl_op.out[c2][k2][i3][j3];
                    frob[c2][k2][i3][j3] <== frob_op.out[c2][k2][i3][j3];
                    frob_square[c2][k2][i3][j3] <== frob_sq_op.out[c2][k2][i3][j3];
                    frob_cube[c2][k2][i3][j3] <== frob_cube_op.out[c2][k2][i3][j3];
                    cyclotomic_square[c2][k2][i3][j3] <== cyclo_sq_op.out[c2][k2][i3][j3];
                    mul_by_034[c2][k2][i3][j3] <== mul_034_op.out[c2][k2][i3][j3];
                }
            }
        }
    }
}

component main = Fp12Ops();
