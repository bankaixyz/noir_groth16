pragma circom 2.0.0;

include "./utils.circom";

template FpConst(l0, l1, l2) {
    signal output out[3];

    out[0] <== l0;
    out[1] <== l1;
    out[2] <== l2;
}

template FpZero() {
    signal output out[3];
    out[0] <== 0;
    out[1] <== 0;
    out[2] <== 0;
}

template FpOne() {
    signal output out[3];
    out[0] <== 1;
    out[1] <== 0;
    out[2] <== 0;
}

template FpTwo() {
    signal output out[3];
    out[0] <== 2;
    out[1] <== 0;
    out[2] <== 0;
}

template FpThree() {
    signal output out[3];
    out[0] <== 3;
    out[1] <== 0;
    out[2] <== 0;
}

template FpFour() {
    signal output out[3];
    out[0] <== 4;
    out[1] <== 0;
    out[2] <== 0;
}

template FpEight() {
    signal output out[3];
    out[0] <== 8;
    out[1] <== 0;
    out[2] <== 0;
}

template FpNine() {
    signal output out[3];
    out[0] <== 9;
    out[1] <== 0;
    out[2] <== 0;
}

template SeedX0() {
    signal output out;
    out <== 4965661367192848881;
}

template G1GeneratorX() {
    signal output out[3];
    component one = FpOne();
    for (var i = 0; i < 3; i++) {
        out[i] <== one.out[i];
    }
}

template G1GeneratorY() {
    signal output out[3];
    component two = FpTwo();
    for (var i = 0; i < 3; i++) {
        out[i] <== two.out[i];
    }
}

template CurveB() {
    signal output out[3];
    component three = FpThree();
    for (var i = 0; i < 3; i++) {
        out[i] <== three.out[i];
    }
}

template FpRangeCheck() {
    signal input in[3];

    component limb0 = Num2Bits(120);
    component limb1 = Num2Bits(120);
    component limb2 = Num2Bits(14);

    limb0.in <== in[0];
    limb1.in <== in[1];
    limb2.in <== in[2];
}

template FpLt() {
    signal input a[3];
    signal input b[3];
    signal output out;

    component lt2 = Lt(120);
    component eq2 = IsEqual();
    component lt1 = Lt(120);
    component eq1 = IsEqual();
    component lt0 = Lt(120);

    lt2.a <== a[2];
    lt2.b <== b[2];
    eq2.a <== a[2];
    eq2.b <== b[2];

    lt1.a <== a[1];
    lt1.b <== b[1];
    eq1.a <== a[1];
    eq1.b <== b[1];

    lt0.a <== a[0];
    lt0.b <== b[0];

    signal mid_lt;
    mid_lt <== lt1.out + eq1.out * lt0.out;
    out <== lt2.out + eq2.out * mid_lt;
}

template FpSelect() {
    signal input a[3];
    signal input b[3];
    signal input sel;
    signal output out[3];

    sel * (sel - 1) === 0;
    for (var i = 0; i < 3; i++) {
        out[i] <== b[i] + sel * (a[i] - b[i]);
    }
}

template FpAdd() {
    signal input a[3];
    signal input b[3];
    signal output out[3];

    var base = 1 << 120;
    var mod0 = 0x816a916871ca8d3c208c16d87cfd47;
    var mod1 = 0x4e72e131a029b85045b68181585d97;
    var mod2 = 0x3064;

    component aCheck = FpRangeCheck();
    component bCheck = FpRangeCheck();
    for (var i = 0; i < 3; i++) {
        aCheck.in[i] <== a[i];
        bCheck.in[i] <== b[i];
    }

    signal sum[3];
    signal carry0;
    signal carry1;
    carry0 <-- (a[0] + b[0]) >> 120;
    carry1 <-- (a[1] + b[1] + carry0) >> 120;
    carry0 * (carry0 - 1) === 0;
    carry1 * (carry1 - 1) === 0;

    sum[0] <== a[0] + b[0] - carry0 * base;
    sum[1] <== a[1] + b[1] + carry0 - carry1 * base;
    sum[2] <== a[2] + b[2] + carry1;

    component sum0Bits = Num2Bits(120);
    component sum1Bits = Num2Bits(120);
    component sum2Bits = Num2Bits(120);
    sum0Bits.in <== sum[0];
    sum1Bits.in <== sum[1];
    sum2Bits.in <== sum[2];

    signal overflow;
    component sum_lt = FpLt();
    sum_lt.a[0] <== sum[0];
    sum_lt.a[1] <== sum[1];
    sum_lt.a[2] <== sum[2];
    sum_lt.b[0] <== mod0;
    sum_lt.b[1] <== mod1;
    sum_lt.b[2] <== mod2;
    overflow <== 1 - sum_lt.out;
    overflow * (overflow - 1) === 0;

    signal borrow0;
    component borrow0_lt = Lt(120);
    borrow0_lt.a <== sum[0];
    borrow0_lt.b <== mod0;
    borrow0 <== overflow * borrow0_lt.out;
    borrow0 * (borrow0 - 1) === 0;

    signal borrow1;
    signal mod1_plus_borrow;
    mod1_plus_borrow <== mod1 + borrow0;
    component borrow1_lt = Lt(120);
    borrow1_lt.a <== sum[1];
    borrow1_lt.b <== mod1_plus_borrow;
    borrow1 <== overflow * borrow1_lt.out;
    borrow1 * (borrow1 - 1) === 0;

    out[0] <== sum[0] - overflow * mod0 + borrow0 * base;
    out[1] <== sum[1] - overflow * mod1 - borrow0 + borrow1 * base;
    out[2] <== sum[2] - overflow * mod2 - borrow1;

    component outCheck = FpRangeCheck();
    for (var j = 0; j < 3; j++) {
        outCheck.in[j] <== out[j];
    }

    component lt = FpLt();
    lt.a[0] <== out[0];
    lt.a[1] <== out[1];
    lt.a[2] <== out[2];
    lt.b[0] <== mod0;
    lt.b[1] <== mod1;
    lt.b[2] <== mod2;
    lt.out === 1;
}

template FpSub() {
    signal input a[3];
    signal input b[3];
    signal output out[3];

    var base = 1 << 120;
    var mod0 = 0x816a916871ca8d3c208c16d87cfd47;
    var mod1 = 0x4e72e131a029b85045b68181585d97;
    var mod2 = 0x3064;

    component aCheck = FpRangeCheck();
    component bCheck = FpRangeCheck();
    for (var i = 0; i < 3; i++) {
        aCheck.in[i] <== a[i];
        bCheck.in[i] <== b[i];
    }

    component underflow = FpLt();
    underflow.a[0] <== a[0];
    underflow.a[1] <== a[1];
    underflow.a[2] <== a[2];
    underflow.b[0] <== b[0];
    underflow.b[1] <== b[1];
    underflow.b[2] <== b[2];

    signal borrow0;
    signal borrow1;
    borrow0 <-- (a[0] + underflow.out * mod0) < b[0] ? 1 : 0;
    borrow1 <-- (a[1] + underflow.out * mod1 - borrow0) < b[1] ? 1 : 0;
    borrow0 * (borrow0 - 1) === 0;
    borrow1 * (borrow1 - 1) === 0;

    out[0] <== a[0] - b[0] + underflow.out * mod0 + borrow0 * base;
    out[1] <== a[1] - b[1] + underflow.out * mod1 - borrow0 + borrow1 * base;
    out[2] <== a[2] - b[2] + underflow.out * mod2 - borrow1;

    component outCheck = FpRangeCheck();
    for (var j = 0; j < 3; j++) {
        outCheck.in[j] <== out[j];
    }

    component lt = FpLt();
    lt.a[0] <== out[0];
    lt.a[1] <== out[1];
    lt.a[2] <== out[2];
    lt.b[0] <== mod0;
    lt.b[1] <== mod1;
    lt.b[2] <== mod2;
    lt.out === 1;
}

template FpNeg() {
    signal input a[3];
    signal output out[3];

    var base = 1 << 120;
    var mod0 = 0x816a916871ca8d3c208c16d87cfd47;
    var mod1 = 0x4e72e131a029b85045b68181585d97;
    var mod2 = 0x3064;

    component aCheck = FpRangeCheck();
    for (var i = 0; i < 3; i++) {
        aCheck.in[i] <== a[i];
    }

    signal borrow0;
    signal borrow1;
    borrow0 <-- mod0 < a[0] ? 1 : 0;
    borrow1 <-- (mod1 - borrow0) < a[1] ? 1 : 0;
    borrow0 * (borrow0 - 1) === 0;
    borrow1 * (borrow1 - 1) === 0;

    out[0] <== mod0 - a[0] + borrow0 * base;
    out[1] <== mod1 - a[1] - borrow0 + borrow1 * base;
    out[2] <== mod2 - a[2] - borrow1;

    component outCheck = FpRangeCheck();
    for (var j = 0; j < 3; j++) {
        outCheck.in[j] <== out[j];
    }
}

template FpDouble() {
    signal input a[3];
    signal output out[3];

    component add = FpAdd();
    for (var i = 0; i < 3; i++) {
        add.a[i] <== a[i];
        add.b[i] <== a[i];
    }
    for (var j = 0; j < 3; j++) {
        out[j] <== add.out[j];
    }
}

template FpMul() {
    signal input a[3];
    signal input b[3];
    signal output out[3];

    component aCheck = FpRangeCheck();
    component bCheck = FpRangeCheck();
    for (var i = 0; i < 3; i++) {
        aCheck.in[i] <== a[i];
        bCheck.in[i] <== b[i];
    }

    component b0Bits = Num2Bits(120);
    component b1Bits = Num2Bits(120);
    component b2Bits = Num2Bits(14);
    b0Bits.in <== b[0];
    b1Bits.in <== b[1];
    b2Bits.in <== b[2];

    signal acc[255][3];
    signal tmp[255][3];
    component add[254];
    component sel[254];
    component dbl[254];
    acc[0][0] <== 0;
    acc[0][1] <== 0;
    acc[0][2] <== 0;
    for (var j = 0; j < 3; j++) {
        tmp[0][j] <== a[j];
    }

    for (var i2 = 0; i2 < 254; i2++) {
        add[i2] = FpAdd();
        sel[i2] = FpSelect();
        dbl[i2] = FpDouble();

        for (var j2 = 0; j2 < 3; j2++) {
            add[i2].a[j2] <== acc[i2][j2];
            add[i2].b[j2] <== tmp[i2][j2];
            sel[i2].a[j2] <== add[i2].out[j2];
            sel[i2].b[j2] <== acc[i2][j2];
            dbl[i2].a[j2] <== tmp[i2][j2];
        }

        if (i2 < 120) {
            sel[i2].sel <== b0Bits.out[i2];
        } else if (i2 < 240) {
            sel[i2].sel <== b1Bits.out[i2 - 120];
        } else {
            sel[i2].sel <== b2Bits.out[i2 - 240];
        }

        for (var j3 = 0; j3 < 3; j3++) {
            acc[i2 + 1][j3] <== sel[i2].out[j3];
            tmp[i2 + 1][j3] <== dbl[i2].out[j3];
        }
    }

    for (var j4 = 0; j4 < 3; j4++) {
        out[j4] <== acc[254][j4];
    }
}

template FpSquare() {
    signal input a[3];
    signal output out[3];

    component mul = FpMul();
    for (var i = 0; i < 3; i++) {
        mul.a[i] <== a[i];
        mul.b[i] <== a[i];
    }
    for (var j = 0; j < 3; j++) {
        out[j] <== mul.out[j];
    }
}

template FpInv() {
    signal input a[3];
    signal input inv[3];
    signal output out[3];

    component mul = FpMul();
    for (var i = 0; i < 3; i++) {
        mul.a[i] <== a[i];
        mul.b[i] <== inv[i];
    }

    component one = FpOne();
    for (var j = 0; j < 3; j++) {
        mul.out[j] === one.out[j];
        out[j] <== inv[j];
    }
}

template FpDiv() {
    signal input a[3];
    signal input b[3];
    signal input inv_b[3];
    signal output out[3];

    component inv = FpInv();
    for (var i = 0; i < 3; i++) {
        inv.a[i] <== b[i];
        inv.inv[i] <== inv_b[i];
    }

    component mul = FpMul();
    for (var j = 0; j < 3; j++) {
        mul.a[j] <== a[j];
        mul.b[j] <== inv_b[j];
        out[j] <== mul.out[j];
    }
}
