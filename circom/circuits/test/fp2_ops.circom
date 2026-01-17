pragma circom 2.0.0;

include "../fp2.circom";

template Fp2Ops() {
    signal input a[2][3];
    signal input b[2][3];
    signal input inv[2][3];
    signal input inv_elem_hint[3];

    signal output add[2][3];
    signal output sub[2][3];
    signal output mul[2][3];
    signal output square[2][3];
    signal output inv_a[2][3];
    signal output mul_inv[2][3];
    signal output inv_inverse[2][3];
    signal output neg[2][3];
    signal output double[2][3];
    signal output conjugate[2][3];
    signal output sum_conj[2][3];
    signal output diff_conj[2][3];
    signal output mul_by_non_residue[2][3];
    signal output mul_by_element_chain[2][3];

    component add_op = Fp2Add();
    component sub_op = Fp2Sub();
    component mul_op = Fp2Mul();
    component sq_op = Fp2Square();
    component inv_op = Fp2Inverse();
    component mul_inv_op = Fp2Mul();
    component inv_inv_op = Fp2Inverse();
    component neg_op = Fp2Neg();
    component dbl_op = Fp2Double();
    component conj_op = Fp2Conjugate();
    component sum_conj_op = Fp2Add();
    component diff_conj_op = Fp2Sub();
    component mul_nr_op = Fp2MulByNonResidue();

    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            add_op.a[i][j] <== a[i][j];
            add_op.b[i][j] <== b[i][j];
            sub_op.a[i][j] <== a[i][j];
            sub_op.b[i][j] <== b[i][j];
            mul_op.a[i][j] <== a[i][j];
            mul_op.b[i][j] <== b[i][j];
            sq_op.a[i][j] <== a[i][j];
            inv_op.a[i][j] <== a[i][j];
            inv_op.inv[i][j] <== inv[i][j];
            mul_inv_op.a[i][j] <== a[i][j];
            mul_inv_op.b[i][j] <== inv[i][j];
            inv_inv_op.a[i][j] <== inv[i][j];
            inv_inv_op.inv[i][j] <== a[i][j];
            neg_op.a[i][j] <== a[i][j];
            dbl_op.a[i][j] <== a[i][j];
            conj_op.a[i][j] <== a[i][j];
            mul_nr_op.a[i][j] <== a[i][j];
        }
    }

    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            sum_conj_op.a[i2][j2] <== a[i2][j2];
            sum_conj_op.b[i2][j2] <== conj_op.out[i2][j2];
            diff_conj_op.a[i2][j2] <== a[i2][j2];
            diff_conj_op.b[i2][j2] <== conj_op.out[i2][j2];
        }
    }

    component inv_elem = FpInv();
    for (var j3 = 0; j3 < 3; j3++) {
        inv_elem.a[j3] <== a[0][j3];
        inv_elem.inv[j3] <== inv_elem_hint[j3];
    }
    component mul_elem = Fp2MulByElement();
    component mul_elem_inv = Fp2MulByElement();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j4 = 0; j4 < 3; j4++) {
            mul_elem.a[i3][j4] <== a[i3][j4];
        }
    }
    for (var j5 = 0; j5 < 3; j5++) {
        mul_elem.element[j5] <== a[0][j5];
    }
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j6 = 0; j6 < 3; j6++) {
            mul_elem_inv.a[i4][j6] <== mul_elem.out[i4][j6];
        }
    }
    for (var j7 = 0; j7 < 3; j7++) {
        mul_elem_inv.element[j7] <== inv_elem.out[j7];
    }

    for (var i4 = 0; i4 < 2; i4++) {
        for (var j6 = 0; j6 < 3; j6++) {
            add[i4][j6] <== add_op.out[i4][j6];
            sub[i4][j6] <== sub_op.out[i4][j6];
            mul[i4][j6] <== mul_op.out[i4][j6];
            square[i4][j6] <== sq_op.out[i4][j6];
            inv_a[i4][j6] <== inv_op.out[i4][j6];
            mul_inv[i4][j6] <== mul_inv_op.out[i4][j6];
            inv_inverse[i4][j6] <== inv_inv_op.out[i4][j6];
            neg[i4][j6] <== neg_op.out[i4][j6];
            double[i4][j6] <== dbl_op.out[i4][j6];
            conjugate[i4][j6] <== conj_op.out[i4][j6];
            sum_conj[i4][j6] <== sum_conj_op.out[i4][j6];
            diff_conj[i4][j6] <== diff_conj_op.out[i4][j6];
            mul_by_non_residue[i4][j6] <== mul_nr_op.out[i4][j6];
            mul_by_element_chain[i4][j6] <== mul_elem_inv.out[i4][j6];
        }
    }
}

component main = Fp2Ops();
