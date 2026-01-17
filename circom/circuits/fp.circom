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

    signal sum0Raw;
    signal sum1Raw;
    signal sum0;
    signal sum1;
    signal sum2;
    signal carry0;
    signal carry1;
    sum0Raw <== a[0] + underflow.out * mod0;
    carry0 <-- sum0Raw >> 120;
    sum0 <== sum0Raw - carry0 * base;
    sum1Raw <== a[1] + underflow.out * mod1 + carry0;
    carry1 <-- sum1Raw >> 120;
    sum1 <== sum1Raw - carry1 * base;
    sum2 <== a[2] + underflow.out * mod2 + carry1;
    carry0 * (carry0 - 1) === 0;
    carry1 * (carry1 - 1) === 0;

    signal borrow0;
    signal borrow1;
    borrow0 <-- sum0 < b[0] ? 1 : 0;
    borrow1 <-- (sum1 - borrow0) < b[1] ? 1 : 0;
    borrow0 * (borrow0 - 1) === 0;
    borrow1 * (borrow1 - 1) === 0;

    out[0] <== sum0 - b[0] + borrow0 * base;
    out[1] <== sum1 - b[1] - borrow0 + borrow1 * base;
    out[2] <== sum2 - b[2] - borrow1;

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

    var base = 1 << 120;
    var mod0 = 0x816a916871ca8d3c208c16d87cfd47;
    var mod1 = 0x4e72e131a029b85045b68181585d97;
    var mod2 = 0x3064;
    var mu0 = 0x65e1767cd4c086f3aed8a19bf90e51;
    var mu1 = 0x462623a04a7ab074a5868073013ae9;
    var mu2 = 0x54a47;
    var mask32 = (1 << 32) - 1;

    signal t0;
    signal c0;
    signal p0;
    t0 <== a[0] * b[0];
    c0 <-- t0 >> 120;
    p0 <== t0 - c0 * base;
    component p0Bits = Num2Bits(120);
    p0Bits.in <== p0;

    signal t1;
    signal t1a;
    signal t1b;
    signal c1;
    signal p1;
    t1a <== a[0] * b[1];
    t1b <== a[1] * b[0];
    t1 <== t1a + t1b + c0;
    c1 <-- t1 >> 120;
    p1 <== t1 - c1 * base;
    component p1Bits = Num2Bits(120);
    p1Bits.in <== p1;

    signal t2;
    signal t2a;
    signal t2b;
    signal t2c;
    signal c2;
    signal p2;
    t2a <== a[0] * b[2];
    t2b <== a[1] * b[1];
    t2c <== a[2] * b[0];
    t2 <== t2a + t2b + t2c + c1;
    c2 <-- t2 >> 120;
    p2 <== t2 - c2 * base;
    component p2Bits = Num2Bits(120);
    p2Bits.in <== p2;

    signal t3;
    signal t3a;
    signal t3b;
    signal c3;
    signal p3;
    t3a <== a[1] * b[2];
    t3b <== a[2] * b[1];
    t3 <== t3a + t3b + c2;
    c3 <-- t3 >> 120;
    p3 <== t3 - c3 * base;
    component p3Bits = Num2Bits(120);
    p3Bits.in <== p3;

    signal t4;
    signal c4;
    signal p4;
    t4 <== a[2] * b[2] + c3;
    c4 <-- t4 >> 120;
    p4 <== t4 - c4 * base;
    component p4Bits = Num2Bits(120);
    p4Bits.in <== p4;
    c4 === 0;

    signal m0;
    signal m1;
    signal m2;
    signal m3;
    signal m4;
    signal m5;
    signal m6;
    signal m7;
    m0 <-- p0 * mu0;
    m1 <-- p0 * mu1 + p1 * mu0;
    m2 <-- p0 * mu2 + p1 * mu1 + p2 * mu0;
    m3 <-- p1 * mu2 + p2 * mu1 + p3 * mu0;
    m4 <-- p2 * mu2 + p3 * mu1 + p4 * mu0;
    m5 <-- p3 * mu2 + p4 * mu1;
    m6 <-- p4 * mu2;
    m7 <-- 0;

    signal l0;
    signal l1;
    signal l2;
    signal l3;
    signal l4;
    signal l5;
    signal l6;
    signal l7;
    signal l8;
    signal mc0;
    signal mc1;
    signal mc2;
    signal mc3;
    signal mc4;
    signal mc5;
    signal mc6;
    signal mc7;
    mc0 <-- m0 >> 120;
    l0 <-- m0 - mc0 * base;
    mc1 <-- (m1 + mc0) >> 120;
    l1 <-- m1 + mc0 - mc1 * base;
    mc2 <-- (m2 + mc1) >> 120;
    l2 <-- m2 + mc1 - mc2 * base;
    mc3 <-- (m3 + mc2) >> 120;
    l3 <-- m3 + mc2 - mc3 * base;
    mc4 <-- (m4 + mc3) >> 120;
    l4 <-- m4 + mc3 - mc4 * base;
    mc5 <-- (m5 + mc4) >> 120;
    l5 <-- m5 + mc4 - mc5 * base;
    mc6 <-- (m6 + mc5) >> 120;
    l6 <-- m6 + mc5 - mc6 * base;
    mc7 <-- (m7 + mc6) >> 120;
    l7 <-- m7 + mc6 - mc7 * base;
    l8 <-- mc7;

    signal q0Approx;
    signal q1Approx;
    signal q2Approx;
    q0Approx <-- (l4 >> 32) + ((l5 & mask32) << 88);
    q1Approx <-- (l5 >> 32) + ((l6 & mask32) << 88);
    q2Approx <-- (l6 >> 32) + ((l7 & mask32) << 88);

    signal aq0Raw;
    signal aq1Raw;
    signal aq2Raw;
    signal aq3Raw;
    signal aq4Raw;
    signal aq0;
    signal aq1;
    signal aq2;
    signal aq3;
    signal aq4;
    signal aqc0;
    signal aqc1;
    signal aqc2;
    signal aqc3;
    signal aqc4;
    aq0Raw <-- q0Approx * mod0;
    aqc0 <-- aq0Raw >> 120;
    aq0 <-- aq0Raw - aqc0 * base;
    aq1Raw <-- q0Approx * mod1 + q1Approx * mod0 + aqc0;
    aqc1 <-- aq1Raw >> 120;
    aq1 <-- aq1Raw - aqc1 * base;
    aq2Raw <-- q0Approx * mod2 + q1Approx * mod1 + q2Approx * mod0 + aqc1;
    aqc2 <-- aq2Raw >> 120;
    aq2 <-- aq2Raw - aqc2 * base;
    aq3Raw <-- q1Approx * mod2 + q2Approx * mod1 + aqc2;
    aqc3 <-- aq3Raw >> 120;
    aq3 <-- aq3Raw - aqc3 * base;
    aq4Raw <-- q2Approx * mod2 + aqc3;
    aqc4 <-- aq4Raw >> 120;
    aq4 <-- aq4Raw - aqc4 * base;

    signal rb0;
    signal rb1;
    signal rb2;
    signal rb3;
    signal rb4;
    signal r0Approx;
    signal r1Approx;
    signal r2Approx;
    signal r3Approx;
    signal r4Approx;
    rb0 <-- p0 < aq0 ? 1 : 0;
    r0Approx <-- p0 - aq0 + rb0 * base;
    rb1 <-- (p1 - rb0) < aq1 ? 1 : 0;
    r1Approx <-- p1 - aq1 - rb0 + rb1 * base;
    rb2 <-- (p2 - rb1) < aq2 ? 1 : 0;
    r2Approx <-- p2 - aq2 - rb1 + rb2 * base;
    rb3 <-- (p3 - rb2) < aq3 ? 1 : 0;
    r3Approx <-- p3 - aq3 - rb2 + rb3 * base;
    rb4 <-- (p4 - rb3) < aq4 ? 1 : 0;
    r4Approx <-- p4 - aq4 - rb3 + rb4 * base;

    signal r3NonZero;
    signal r4NonZero;
    signal bigFlag;
    r3NonZero <-- r3Approx == 0 ? 0 : 1;
    r4NonZero <-- r4Approx == 0 ? 0 : 1;
    bigFlag <-- (r3NonZero + r4NonZero) > 0 ? 1 : 0;

    signal gt2;
    signal eq2;
    signal gt1;
    signal eq1;
    signal gt0;
    signal eq0;
    gt2 <-- r2Approx > mod2 ? 1 : 0;
    eq2 <-- r2Approx == mod2 ? 1 : 0;
    gt1 <-- r1Approx > mod1 ? 1 : 0;
    eq1 <-- r1Approx == mod1 ? 1 : 0;
    gt0 <-- r0Approx > mod0 ? 1 : 0;
    eq0 <-- r0Approx == mod0 ? 1 : 0;

    signal ge0;
    signal eq1Ge0;
    signal ge1;
    signal eq2Ge1;
    signal geFlag;
    ge0 <-- gt0 + eq0 - gt0 * eq0;
    eq1Ge0 <-- eq1 * ge0;
    ge1 <-- gt1 + eq1Ge0 - gt1 * eq1Ge0;
    eq2Ge1 <-- eq2 * ge1;
    geFlag <-- gt2 + eq2Ge1 - gt2 * eq2Ge1;

    signal needsSub;
    needsSub <-- (bigFlag == 1) ? 1 : geFlag;

    signal q0Adj;
    signal q1Adj;
    signal q2Adj;
    signal qc0;
    signal qc1;
    signal qc2;
    signal q0;
    signal q1;
    signal q2;
    q0Adj <-- q0Approx + needsSub;
    qc0 <-- q0Adj >> 120;
    q0 <-- q0Adj - qc0 * base;
    q1Adj <-- q1Approx + qc0;
    qc1 <-- q1Adj >> 120;
    q1 <-- q1Adj - qc1 * base;
    q2Adj <-- q2Approx + qc1;
    qc2 <-- q2Adj >> 120;
    q2 <-- q2Adj - qc2 * base;

    component q0Bits = Num2Bits(120);
    component q1Bits = Num2Bits(120);
    component q2Bits = Num2Bits(14);
    q0Bits.in <== q0;
    q1Bits.in <== q1;
    q2Bits.in <== q2;

    signal qm0Raw;
    signal qm1Raw;
    signal qm2Raw;
    signal qm3Raw;
    signal qm4Raw;
    signal qm0;
    signal qm1;
    signal qm2;
    signal qm3;
    signal qm4;
    signal qcMul0;
    signal qcMul1;
    signal qcMul2;
    signal qcMul3;
    signal qcMul4;
    qm0Raw <== q0 * mod0;
    qcMul0 <-- qm0Raw >> 120;
    qm0 <== qm0Raw - qcMul0 * base;
    signal qm1a;
    signal qm1b;
    qm1a <== q0 * mod1;
    qm1b <== q1 * mod0;
    qm1Raw <== qm1a + qm1b + qcMul0;
    qcMul1 <-- qm1Raw >> 120;
    qm1 <== qm1Raw - qcMul1 * base;
    signal qm2a;
    signal qm2b;
    signal qm2c;
    qm2a <== q0 * mod2;
    qm2b <== q1 * mod1;
    qm2c <== q2 * mod0;
    qm2Raw <== qm2a + qm2b + qm2c + qcMul1;
    qcMul2 <-- qm2Raw >> 120;
    qm2 <== qm2Raw - qcMul2 * base;
    signal qm3a;
    signal qm3b;
    qm3a <== q1 * mod2;
    qm3b <== q2 * mod1;
    qm3Raw <== qm3a + qm3b + qcMul2;
    qcMul3 <-- qm3Raw >> 120;
    qm3 <== qm3Raw - qcMul3 * base;
    qm4Raw <== q2 * mod2 + qcMul3;
    qcMul4 <-- qm4Raw >> 120;
    qm4 <== qm4Raw - qcMul4 * base;

    component qm0Bits = Num2Bits(120);
    component qm1Bits = Num2Bits(120);
    component qm2Bits = Num2Bits(120);
    component qm3Bits = Num2Bits(120);
    component qm4Bits = Num2Bits(120);
    qm0Bits.in <== qm0;
    qm1Bits.in <== qm1;
    qm2Bits.in <== qm2;
    qm3Bits.in <== qm3;
    qm4Bits.in <== qm4;

    signal borrow0;
    signal borrow1;
    signal borrow2;
    signal borrow3;
    signal borrow4;
    signal r0;
    signal r1;
    signal r2;
    signal r3;
    signal r4;
    borrow0 <-- p0 < qm0 ? 1 : 0;
    r0 <== p0 - qm0 + borrow0 * base;
    borrow1 <-- (p1 - borrow0) < qm1 ? 1 : 0;
    r1 <== p1 - qm1 - borrow0 + borrow1 * base;
    borrow2 <-- (p2 - borrow1) < qm2 ? 1 : 0;
    r2 <== p2 - qm2 - borrow1 + borrow2 * base;
    borrow3 <-- (p3 - borrow2) < qm3 ? 1 : 0;
    r3 <== p3 - qm3 - borrow2 + borrow3 * base;
    borrow4 <-- (p4 - borrow3) < qm4 ? 1 : 0;
    r4 <== p4 - qm4 - borrow3 + borrow4 * base;

    borrow0 * (borrow0 - 1) === 0;
    borrow1 * (borrow1 - 1) === 0;
    borrow2 * (borrow2 - 1) === 0;
    borrow3 * (borrow3 - 1) === 0;
    borrow4 * (borrow4 - 1) === 0;
    borrow4 === 0;
    r3 === 0;
    r4 === 0;

    out[0] <== r0;
    out[1] <== r1;
    out[2] <== r2;

    component outCheck = FpRangeCheck();
    outCheck.in[0] <== out[0];
    outCheck.in[1] <== out[1];
    outCheck.in[2] <== out[2];

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

template FpEq() {
    signal input a[3];
    signal input b[3];
    signal output out;

    component eq0 = IsEqual();
    component eq1 = IsEqual();
    component eq2 = IsEqual();
    eq0.a <== a[0];
    eq0.b <== b[0];
    eq1.a <== a[1];
    eq1.b <== b[1];
    eq2.a <== a[2];
    eq2.b <== b[2];

    signal tmp;
    tmp <== eq0.out * eq1.out;
    out <== tmp * eq2.out;
    out * (out - 1) === 0;
}

template FpIsZero() {
    signal input a[3];
    signal output out;

    component eq0 = IsEqual();
    component eq1 = IsEqual();
    component eq2 = IsEqual();
    eq0.a <== a[0];
    eq0.b <== 0;
    eq1.a <== a[1];
    eq1.b <== 0;
    eq2.a <== a[2];
    eq2.b <== 0;

    signal tmp;
    tmp <== eq0.out * eq1.out;
    out <== tmp * eq2.out;
    out * (out - 1) === 0;
}
