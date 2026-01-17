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
    overflow * (overflow - 1) === 0;
    signal borrow0;
    signal borrow1;
    borrow0 * (borrow0 - 1) === 0;
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

    signal t0;
    signal t1;
    signal t2;
    signal t3;
    signal t4;
    t0 <== a[0] * b[0];
    t1 <== a[0] * b[1] + a[1] * b[0];
    t2 <== a[0] * b[2] + a[1] * b[1] + a[2] * b[0];
    t3 <== a[1] * b[2] + a[2] * b[1];
    t4 <== a[2] * b[2];

    signal prod[5];
    signal carry0;
    signal carry1;
    signal carry2;
    signal carry3;
    prod[0] <== t0 - carry0 * base;
    prod[1] <== t1 + carry0 - carry1 * base;
    prod[2] <== t2 + carry1 - carry2 * base;
    prod[3] <== t3 + carry2 - carry3 * base;
    prod[4] <== t4 + carry3;

    component prod0Bits = Num2Bits(120);
    component prod1Bits = Num2Bits(120);
    component prod2Bits = Num2Bits(120);
    component prod3Bits = Num2Bits(120);
    component prod4Bits = Num2Bits(120);
    prod0Bits.in <== prod[0];
    prod1Bits.in <== prod[1];
    prod2Bits.in <== prod[2];
    prod3Bits.in <== prod[3];
    prod4Bits.in <== prod[4];

    component carry0Bits = Num2Bits(134);
    component carry1Bits = Num2Bits(134);
    component carry2Bits = Num2Bits(134);
    component carry3Bits = Num2Bits(134);
    carry0Bits.in <== carry0;
    carry1Bits.in <== carry1;
    carry2Bits.in <== carry2;
    carry3Bits.in <== carry3;

    signal q[3];
    component qCheck = FpRangeCheck();
    for (var j = 0; j < 3; j++) {
        qCheck.in[j] <== q[j];
    }

    signal qt0;
    signal qt1;
    signal qt2;
    signal qt3;
    signal qt4;
    qt0 <== q[0] * mod0;
    qt1 <== q[0] * mod1 + q[1] * mod0;
    qt2 <== q[0] * mod2 + q[1] * mod1 + q[2] * mod0;
    qt3 <== q[1] * mod2 + q[2] * mod1;
    qt4 <== q[2] * mod2;

    signal qmod[5];
    signal qcarry0;
    signal qcarry1;
    signal qcarry2;
    signal qcarry3;
    qmod[0] <== qt0 - qcarry0 * base;
    qmod[1] <== qt1 + qcarry0 - qcarry1 * base;
    qmod[2] <== qt2 + qcarry1 - qcarry2 * base;
    qmod[3] <== qt3 + qcarry2 - qcarry3 * base;
    qmod[4] <== qt4 + qcarry3;

    component qmod0Bits = Num2Bits(120);
    component qmod1Bits = Num2Bits(120);
    component qmod2Bits = Num2Bits(120);
    component qmod3Bits = Num2Bits(120);
    component qmod4Bits = Num2Bits(120);
    qmod0Bits.in <== qmod[0];
    qmod1Bits.in <== qmod[1];
    qmod2Bits.in <== qmod[2];
    qmod3Bits.in <== qmod[3];
    qmod4Bits.in <== qmod[4];

    component qcarry0Bits = Num2Bits(134);
    component qcarry1Bits = Num2Bits(134);
    component qcarry2Bits = Num2Bits(134);
    component qcarry3Bits = Num2Bits(134);
    qcarry0Bits.in <== qcarry0;
    qcarry1Bits.in <== qcarry1;
    qcarry2Bits.in <== qcarry2;
    qcarry3Bits.in <== qcarry3;

    signal addc0;
    signal addc1;
    signal addc2;
    signal addc3;
    addc0 * (addc0 - 1) === 0;
    addc1 * (addc1 - 1) === 0;
    addc2 * (addc2 - 1) === 0;
    addc3 * (addc3 - 1) === 0;

    qmod[0] + out[0] - prod[0] - addc0 * base === 0;
    qmod[1] + out[1] + addc0 - prod[1] - addc1 * base === 0;
    qmod[2] + out[2] + addc1 - prod[2] - addc2 * base === 0;
    qmod[3] + addc2 - prod[3] - addc3 * base === 0;
    qmod[4] + addc3 - prod[4] === 0;

    component outCheck = FpRangeCheck();
    for (var k = 0; k < 3; k++) {
        outCheck.in[k] <== out[k];
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
