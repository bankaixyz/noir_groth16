pragma circom 2.0.0;

include "./fp.circom";

template Fp2Const(c0_l0, c0_l1, c0_l2, c1_l0, c1_l1, c1_l2) {
    signal output out[2];

    component c0 = FpConst(c0_l0, c0_l1, c0_l2);
    component c1 = FpConst(c1_l0, c1_l1, c1_l2);
    out[0] <== c0.out;
    out[1] <== c1.out;
}

template Fp2Zero() {
    signal output out[2];
    component c = Fp2Const(0, 0, 0, 0, 0, 0);
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2One() {
    signal output out[2];
    component c = Fp2Const(1, 0, 0, 0, 0, 0);
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2NonResidue() {
    signal output out[2];
    component c = Fp2Const(9, 0, 0, 1, 0, 0);
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2NonResidueInv() {
    signal output out[2];
    component c = Fp2Const(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2BTwist() {
    signal output out[2];
    component c = Fp2Const(
        0xb4c5e559dbefa33267e6dc24a138e5, 0x9d40ceb8aaae81be18991be06ac3b5, 0x2b14,
        0x4fa084e52d1852e4a2bd0685c315d2, 0x13b03af0fed4cd2cafadeed8fdf4a7, 0x97
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2EndoU() {
    signal output out[2];
    component c = Fp2Const(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2EndoV() {
    signal output out[2];
    component c = Fp2Const(
        0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c,
        0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius1Power1() {
    signal output out[2];
    component c = Fp2Const(
        0x521e08292f2176d60b35dadcc9e470, 0xb71c2865a7dfe8b99fdd76e68b605c, 0x1284,
        0x7992778eeec7e5ca5cf05f80f362ac, 0x96f3b4fae7e6a6327cfe12150b8e74, 0x2469
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius1Power2() {
    signal output out[2];
    component c = Fp2Const(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius1Power3() {
    signal output out[2];
    component c = Fp2Const(
        0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c,
        0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius1Power4() {
    signal output out[2];
    component c = Fp2Const(
        0x3365f7be94ec72848a1f55921ea762, 0x4f5e64eea80180f3c0b75a181e84d3, 0x5b5,
        0x85d2ea1bdec763c13b4711cd2b8126, 0x5edbe7fd8aee9f3a80b03b0b1c9236, 0x2c14
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius1Power5() {
    signal output out[2];
    component c = Fp2Const(
        0x5c459b55aa1bd32ea2c810eab7692f, 0xc1e74f798649e93a3661a4353ff442, 0x183,
        0x80cb99678e2ac024c6b8ee6e0c2c4b, 0xf2ca76fd0675a27fb246c7729f7db0, 0x12ac
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius2Power1() {
    signal output out;
    component c = FpConst(0x8f069fbb966e3de4bd44e5607cfd49, 0x4e72e131a0295e6dd9e7e0acccb0c2, 0x3064);
    out <== c.out;
}

template Fp2Frobenius2Power2() {
    signal output out;
    component c = FpConst(0x8f069fbb966e3de4bd44e5607cfd48, 0x4e72e131a0295e6dd9e7e0acccb0c2, 0x3064);
    out <== c.out;
}

template Fp2Frobenius2Power3() {
    signal output out;
    component c = FpConst(0x816a916871ca8d3c208c16d87cfd46, 0x4e72e131a029b85045b68181585d97, 0x3064);
    out <== c.out;
}

template Fp2Frobenius2Power4() {
    signal output out;
    component c = FpConst(0xf263f1acdb5c4f5763473177fffffe, 0x59e26bcea0d48bacd4, 0x0);
    out <== c.out;
}

template Fp2Frobenius2Power5() {
    signal output out;
    component c = FpConst(0xf263f1acdb5c4f5763473177ffffff, 0x59e26bcea0d48bacd4, 0x0);
    out <== c.out;
}

template Fp2Frobenius3Power1() {
    signal output out[2];
    component c = Fp2Const(
        0x4cb38dbe55d24ae86f7d391ed4a67f, 0x81cfcc82e4bbefe9608cd0acaa9089, 0x19dc,
        0x3a5e397d439ec7694aa2bf4c0c101, 0xf8b60be77d7306cbeee33576139d7f, 0xab
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius3Power2() {
    signal output out[2];
    component c = Fp2Const(
        0x5ffd3d5d6942d37b746ee87bdcfb6d, 0xe078b755ef0abaff1c77959f25ac80, 0x856,
        0xdf31bf98ff2631380cab2baaa586de, 0xde41b3d1766fa9f30e6dec26094f0f, 0x4f1
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius3Power3() {
    signal output out[2];
    component c = Fp2Const(
        0xd689a3bea870f45fcc8ad066dce9ed, 0x5b6d9896aa4cdbf17f1dca9e5ea3bb, 0x2a27,
        0xecc7d8cf6ebab94d0cb3b2594c64, 0x11b634f09b8fb14b900e9507e93276, 0x28a4
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius3Power4() {
    signal output out[2];
    component c = Fp2Const(
        0x33094575b06bcb0e1a92bc3ccbf066, 0x8c6611c08dab19bee0f7b5b2444ee6, 0xbc5,
        0x4a9e08737f96e55fe3ed9d730c239f, 0xe999e1910a12feb0f6ef0cd21d04a4, 0x23d5
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius3Power5() {
    signal output out[2];
    component c = Fp2Const(
        0xd68098967c84a5ebde847076261b43, 0x9044952c0905711699fa3b4d3f692e, 0x13c4,
        0x2ddaea200280211f25041384282499, 0x366a59b1dd0b9fb1b2282a48633d3e, 0x16db
    );
    for (var i = 0; i < 2; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Add() {
    signal input a[2];
    signal input b[2];
    signal output out[2];

    component add0 = FpAdd();
    component add1 = FpAdd();
    add0.a <== a[0];
    add0.b <== b[0];
    add1.a <== a[1];
    add1.b <== b[1];
    out[0] <== add0.out;
    out[1] <== add1.out;
}

template Fp2Sub() {
    signal input a[2];
    signal input b[2];
    signal output out[2];

    component sub0 = FpSub();
    component sub1 = FpSub();
    sub0.a <== a[0];
    sub0.b <== b[0];
    sub1.a <== a[1];
    sub1.b <== b[1];
    out[0] <== sub0.out;
    out[1] <== sub1.out;
}

template Fp2Neg() {
    signal input a[2];
    signal output out[2];

    component neg0 = FpNeg();
    component neg1 = FpNeg();
    neg0.a <== a[0];
    neg1.a <== a[1];
    out[0] <== neg0.out;
    out[1] <== neg1.out;
}

template Fp2Double() {
    signal input a[2];
    signal output out[2];

    component dbl0 = FpDouble();
    component dbl1 = FpDouble();
    dbl0.a <== a[0];
    dbl1.a <== a[1];
    out[0] <== dbl0.out;
    out[1] <== dbl1.out;
}

template Fp2Halve() {
    signal input a[2];
    signal output out[2];

    component invTwo = FpConst(
        0xc0b548b438e5469e10460b6c3e7ea4,
        0x27397098d014dc2822db40c0ac2ecb,
        0x1832
    );

    component mul = Fp2MulByElement();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.element <== invTwo.out;
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2Conjugate() {
    signal input a[2];
    signal output out[2];

    component neg1 = FpNeg();
    neg1.a <== a[1];
    out[0] <== a[0];
    out[1] <== neg1.out;
}

template Fp2Mul() {
    signal input a[2];
    signal input b[2];
    signal output out[2];

    component a0_plus_a1 = FpAdd();
    component b0_plus_b1 = FpAdd();
    a0_plus_a1.a <== a[0];
    a0_plus_a1.b <== a[1];
    b0_plus_b1.a <== b[0];
    b0_plus_b1.b <== b[1];

    component a_mul = FpMul();
    a_mul.a <== a0_plus_a1.out;
    a_mul.b <== b0_plus_b1.out;

    component b_mul = FpMul();
    component c_mul = FpMul();
    b_mul.a <== a[0];
    b_mul.b <== b[0];
    c_mul.a <== a[1];
    c_mul.b <== b[1];

    component c0 = FpSub();
    c0.a <== b_mul.out;
    c0.b <== c_mul.out;

    component tmp = FpSub();
    tmp.a <== a_mul.out;
    tmp.b <== b_mul.out;

    component c1 = FpSub();
    c1.a <== tmp.out;
    c1.b <== c_mul.out;

    out[0] <== c0.out;
    out[1] <== c1.out;
}

template Fp2Square() {
    signal input a[2];
    signal output out[2];

    component a0_plus_a1 = FpAdd();
    component a0_minus_a1 = FpSub();
    a0_plus_a1.a <== a[0];
    a0_plus_a1.b <== a[1];
    a0_minus_a1.a <== a[0];
    a0_minus_a1.b <== a[1];

    component a_mul = FpMul();
    a_mul.a <== a0_plus_a1.out;
    a_mul.b <== a0_minus_a1.out;

    component b_mul = FpMul();
    b_mul.a <== a[0];
    b_mul.b <== a[1];

    component b_dbl = FpDouble();
    b_dbl.a <== b_mul.out;

    out[0] <== a_mul.out;
    out[1] <== b_dbl.out;
}

template Fp2Inverse() {
    signal input a[2];
    signal input inv[2];
    signal output out[2];

    component mul = Fp2Mul();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.b[0] <== inv[0];
    mul.b[1] <== inv[1];

    component one = Fp2One();
    mul.out[0] === one.out[0];
    mul.out[1] === one.out[1];
    out[0] <== inv[0];
    out[1] <== inv[1];
}

template Fp2MulByNonResidue() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(9, 0, 0, 1, 0, 0);
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByElement() {
    signal input a[2];
    signal input element;
    signal output out[2];

    component mul0 = FpMul();
    component mul1 = FpMul();
    mul0.a <== a[0];
    mul0.b <== element;
    mul1.a <== a[1];
    mul1.b <== element;
    out[0] <== mul0.out;
    out[1] <== mul1.out;
}

template Fp2MulByConst(c0_l0, c0_l1, c0_l2, c1_l0, c1_l1, c1_l2) {
    signal input a[2];
    signal output out[2];

    component c = Fp2Const(c0_l0, c0_l1, c0_l2, c1_l0, c1_l1, c1_l2);
    component mul = Fp2Mul();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.b[0] <== c.out[0];
    mul.b[1] <== c.out[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByBTwistCoeff() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0xb4c5e559dbefa33267e6dc24a138e5, 0x9d40ceb8aaae81be18991be06ac3b5, 0x2b14,
        0x4fa084e52d1852e4a2bd0685c315d2, 0x13b03af0fed4cd2cafadeed8fdf4a7, 0x97
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue1Power1() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0x521e08292f2176d60b35dadcc9e470, 0xb71c2865a7dfe8b99fdd76e68b605c, 0x1284,
        0x7992778eeec7e5ca5cf05f80f362ac, 0x96f3b4fae7e6a6327cfe12150b8e74, 0x2469
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue1Power2() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue1Power3() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c,
        0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue1Power4() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0x3365f7be94ec72848a1f55921ea762, 0x4f5e64eea80180f3c0b75a181e84d3, 0x5b5,
        0x85d2ea1bdec763c13b4711cd2b8126, 0x5edbe7fd8aee9f3a80b03b0b1c9236, 0x2c14
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue1Power5() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0x5c459b55aa1bd32ea2c810eab7692f, 0xc1e74f798649e93a3661a4353ff442, 0x183,
        0x80cb99678e2ac024c6b8ee6e0c2c4b, 0xf2ca76fd0675a27fb246c7729f7db0, 0x12ac
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue2Power1() {
    signal input a[2];
    signal output out[2];

    component coeff = Fp2Frobenius2Power1();
    component mul = Fp2MulByElement();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.element <== coeff.out;
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue2Power2() {
    signal input a[2];
    signal output out[2];

    component coeff = Fp2Frobenius2Power2();
    component mul = Fp2MulByElement();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.element <== coeff.out;
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue2Power3() {
    signal input a[2];
    signal output out[2];

    component coeff = Fp2Frobenius2Power3();
    component mul = Fp2MulByElement();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.element <== coeff.out;
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue2Power4() {
    signal input a[2];
    signal output out[2];

    component coeff = Fp2Frobenius2Power4();
    component mul = Fp2MulByElement();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.element <== coeff.out;
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue2Power5() {
    signal input a[2];
    signal output out[2];

    component coeff = Fp2Frobenius2Power5();
    component mul = Fp2MulByElement();
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    mul.element <== coeff.out;
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue3Power1() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0x4cb38dbe55d24ae86f7d391ed4a67f, 0x81cfcc82e4bbefe9608cd0acaa9089, 0x19dc,
        0x3a5e397d439ec7694aa2bf4c0c101, 0xf8b60be77d7306cbeee33576139d7f, 0xab
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue3Power2() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0x5ffd3d5d6942d37b746ee87bdcfb6d, 0xe078b755ef0abaff1c77959f25ac80, 0x856,
        0xdf31bf98ff2631380cab2baaa586de, 0xde41b3d1766fa9f30e6dec26094f0f, 0x4f1
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue3Power3() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0xd689a3bea870f45fcc8ad066dce9ed, 0x5b6d9896aa4cdbf17f1dca9e5ea3bb, 0x2a27,
        0xecc7d8cf6ebab94d0cb3b2594c64, 0x11b634f09b8fb14b900e9507e93276, 0x28a4
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue3Power4() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0x33094575b06bcb0e1a92bc3ccbf066, 0x8c6611c08dab19bee0f7b5b2444ee6, 0xbc5,
        0x4a9e08737f96e55fe3ed9d730c239f, 0xe999e1910a12feb0f6ef0cd21d04a4, 0x23d5
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}

template Fp2MulByNonResidue3Power5() {
    signal input a[2];
    signal output out[2];

    component mul = Fp2MulByConst(
        0xd68098967c84a5ebde847076261b43, 0x9044952c0905711699fa3b4d3f692e, 0x13c4,
        0x2ddaea200280211f25041384282499, 0x366a59b1dd0b9fb1b2282a48633d3e, 0x16db
    );
    mul.a[0] <== a[0];
    mul.a[1] <== a[1];
    out[0] <== mul.out[0];
    out[1] <== mul.out[1];
}
