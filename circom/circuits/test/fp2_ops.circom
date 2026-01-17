pragma circom 2.0.0;

include "../fp2.circom";

template Fp2Ops() {
    signal input a[2];
    signal input b[2];
    signal input inv[2];
    signal input inv_elem_hint;

    signal output add[2];
    signal output sub[2];
    signal output mul[2];
    signal output square[2];
    signal output inv_a[2];
    signal output mul_inv[2];
    signal output inv_inverse[2];
    signal output neg[2];
    signal output double[2];
    signal output conjugate[2];
    signal output sum_conj[2];
    signal output diff_conj[2];
    signal output mul_by_non_residue[2];
    signal output mul_by_element_chain[2];

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
        add_op.a[i] <== a[i];
        add_op.b[i] <== b[i];
        sub_op.a[i] <== a[i];
        sub_op.b[i] <== b[i];
        mul_op.a[i] <== a[i];
        mul_op.b[i] <== b[i];
        sq_op.a[i] <== a[i];
        inv_op.a[i] <== a[i];
        inv_op.inv[i] <== inv[i];
        mul_inv_op.a[i] <== a[i];
        mul_inv_op.b[i] <== inv[i];
        inv_inv_op.a[i] <== inv[i];
        inv_inv_op.inv[i] <== a[i];
        neg_op.a[i] <== a[i];
        dbl_op.a[i] <== a[i];
        conj_op.a[i] <== a[i];
        mul_nr_op.a[i] <== a[i];
    }

    for (var i2 = 0; i2 < 2; i2++) {
        sum_conj_op.a[i2] <== a[i2];
        sum_conj_op.b[i2] <== conj_op.out[i2];
        diff_conj_op.a[i2] <== a[i2];
        diff_conj_op.b[i2] <== conj_op.out[i2];
    }

    component inv_elem = FpInv();
    inv_elem.a <== a[0];
    inv_elem.inv <== inv_elem_hint;
    component mul_elem = Fp2MulByElement();
    component mul_elem_inv = Fp2MulByElement();
    for (var i3 = 0; i3 < 2; i3++) {
        mul_elem.a[i3] <== a[i3];
    }
    mul_elem.element <== a[0];
    for (var i4 = 0; i4 < 2; i4++) {
        mul_elem_inv.a[i4] <== mul_elem.out[i4];
    }
    mul_elem_inv.element <== inv_elem.out;

    for (var i4 = 0; i4 < 2; i4++) {
        add[i4] <== add_op.out[i4];
        sub[i4] <== sub_op.out[i4];
        mul[i4] <== mul_op.out[i4];
        square[i4] <== sq_op.out[i4];
        inv_a[i4] <== inv_op.out[i4];
        mul_inv[i4] <== mul_inv_op.out[i4];
        inv_inverse[i4] <== inv_inv_op.out[i4];
        neg[i4] <== neg_op.out[i4];
        double[i4] <== dbl_op.out[i4];
        conjugate[i4] <== conj_op.out[i4];
        sum_conj[i4] <== sum_conj_op.out[i4];
        diff_conj[i4] <== diff_conj_op.out[i4];
        mul_by_non_residue[i4] <== mul_nr_op.out[i4];
        mul_by_element_chain[i4] <== mul_elem_inv.out[i4];
    }
}

component main = Fp2Ops();
