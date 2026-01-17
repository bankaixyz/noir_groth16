pragma circom 2.0.0;

include "./fp.circom";

template Fp2Const(c0_l0, c0_l1, c0_l2, c1_l0, c1_l1, c1_l2) {
    signal output out[2][3];

    out[0][0] <== c0_l0;
    out[0][1] <== c0_l1;
    out[0][2] <== c0_l2;
    out[1][0] <== c1_l0;
    out[1][1] <== c1_l1;
    out[1][2] <== c1_l2;
}

template Fp2Zero() {
    signal output out[2][3];
    component c = Fp2Const(0, 0, 0, 0, 0, 0);
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2One() {
    signal output out[2][3];
    component c = Fp2Const(1, 0, 0, 0, 0, 0);
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2NonResidue() {
    signal output out[2][3];
    component c = Fp2Const(9, 0, 0, 1, 0, 0);
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2NonResidueInv() {
    signal output out[2][3];
    component c = Fp2Const(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2BTwist() {
    signal output out[2][3];
    component c = Fp2Const(
        0xb4c5e559dbefa33267e6dc24a138e5, 0x9d40ceb8aaae81be18991be06ac3b5, 0x2b14,
        0x4fa084e52d1852e4a2bd0685c315d2, 0x13b03af0fed4cd2cafadeed8fdf4a7, 0x97
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2EndoU() {
    signal output out[2][3];
    component c = Fp2Const(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2EndoV() {
    signal output out[2][3];
    component c = Fp2Const(
        0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c,
        0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius1Power1() {
    signal output out[2][3];
    component c = Fp2Const(
        0x521e08292f2176d60b35dadcc9e470, 0xb71c2865a7dfe8b99fdd76e68b605c, 0x1284,
        0x7992778eeec7e5ca5cf05f80f362ac, 0x96f3b4fae7e6a6327cfe12150b8e74, 0x2469
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius1Power2() {
    signal output out[2][3];
    component c = Fp2Const(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius1Power3() {
    signal output out[2][3];
    component c = Fp2Const(
        0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c,
        0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius1Power4() {
    signal output out[2][3];
    component c = Fp2Const(
        0x3365f7be94ec72848a1f55921ea762, 0x4f5e64eea80180f3c0b75a181e84d3, 0x5b5,
        0x85d2ea1bdec763c13b4711cd2b8126, 0x5edbe7fd8aee9f3a80b03b0b1c9236, 0x2c14
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius1Power5() {
    signal output out[2][3];
    component c = Fp2Const(
        0x5c459b55aa1bd32ea2c810eab7692f, 0xc1e74f798649e93a3661a4353ff442, 0x183,
        0x80cb99678e2ac024c6b8ee6e0c2c4b, 0xf2ca76fd0675a27fb246c7729f7db0, 0x12ac
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius2Power1() {
    signal output out[3];
    component c = FpConst(0x8f069fbb966e3de4bd44e5607cfd49, 0x4e72e131a0295e6dd9e7e0acccb0c2, 0x3064);
    for (var i = 0; i < 3; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius2Power2() {
    signal output out[3];
    component c = FpConst(0x8f069fbb966e3de4bd44e5607cfd48, 0x4e72e131a0295e6dd9e7e0acccb0c2, 0x3064);
    for (var i = 0; i < 3; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius2Power3() {
    signal output out[3];
    component c = FpConst(0x816a916871ca8d3c208c16d87cfd46, 0x4e72e131a029b85045b68181585d97, 0x3064);
    for (var i = 0; i < 3; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius2Power4() {
    signal output out[3];
    component c = FpConst(0xf263f1acdb5c4f5763473177fffffe, 0x59e26bcea0d48bacd4, 0x0);
    for (var i = 0; i < 3; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius2Power5() {
    signal output out[3];
    component c = FpConst(0xf263f1acdb5c4f5763473177ffffff, 0x59e26bcea0d48bacd4, 0x0);
    for (var i = 0; i < 3; i++) {
        out[i] <== c.out[i];
    }
}

template Fp2Frobenius3Power1() {
    signal output out[2][3];
    component c = Fp2Const(
        0x4cb38dbe55d24ae86f7d391ed4a67f, 0x81cfcc82e4bbefe9608cd0acaa9089, 0x19dc,
        0x3a5e397d439ec7694aa2bf4c0c101, 0xf8b60be77d7306cbeee33576139d7f, 0xab
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius3Power2() {
    signal output out[2][3];
    component c = Fp2Const(
        0x5ffd3d5d6942d37b746ee87bdcfb6d, 0xe078b755ef0abaff1c77959f25ac80, 0x856,
        0xdf31bf98ff2631380cab2baaa586de, 0xde41b3d1766fa9f30e6dec26094f0f, 0x4f1
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius3Power3() {
    signal output out[2][3];
    component c = Fp2Const(
        0xd689a3bea870f45fcc8ad066dce9ed, 0x5b6d9896aa4cdbf17f1dca9e5ea3bb, 0x2a27,
        0xecc7d8cf6ebab94d0cb3b2594c64, 0x11b634f09b8fb14b900e9507e93276, 0x28a4
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius3Power4() {
    signal output out[2][3];
    component c = Fp2Const(
        0x33094575b06bcb0e1a92bc3ccbf066, 0x8c6611c08dab19bee0f7b5b2444ee6, 0xbc5,
        0x4a9e08737f96e55fe3ed9d730c239f, 0xe999e1910a12feb0f6ef0cd21d04a4, 0x23d5
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Frobenius3Power5() {
    signal output out[2][3];
    component c = Fp2Const(
        0xd68098967c84a5ebde847076261b43, 0x9044952c0905711699fa3b4d3f692e, 0x13c4,
        0x2ddaea200280211f25041384282499, 0x366a59b1dd0b9fb1b2282a48633d3e, 0x16db
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== c.out[i][j];
        }
    }
}

template Fp2Add() {
    signal input a[2][3];
    signal input b[2][3];
    signal output out[2][3];

    component add0 = FpAdd();
    component add1 = FpAdd();
    for (var i = 0; i < 3; i++) {
        add0.a[i] <== a[0][i];
        add0.b[i] <== b[0][i];
        add1.a[i] <== a[1][i];
        add1.b[i] <== b[1][i];
    }
    for (var i = 0; i < 3; i++) {
        out[0][i] <== add0.out[i];
        out[1][i] <== add1.out[i];
    }
}

template Fp2Sub() {
    signal input a[2][3];
    signal input b[2][3];
    signal output out[2][3];

    component sub0 = FpSub();
    component sub1 = FpSub();
    for (var i = 0; i < 3; i++) {
        sub0.a[i] <== a[0][i];
        sub0.b[i] <== b[0][i];
        sub1.a[i] <== a[1][i];
        sub1.b[i] <== b[1][i];
    }
    for (var i = 0; i < 3; i++) {
        out[0][i] <== sub0.out[i];
        out[1][i] <== sub1.out[i];
    }
}

template Fp2Neg() {
    signal input a[2][3];
    signal output out[2][3];

    component neg0 = FpNeg();
    component neg1 = FpNeg();
    for (var i = 0; i < 3; i++) {
        neg0.a[i] <== a[0][i];
        neg1.a[i] <== a[1][i];
    }
    for (var i = 0; i < 3; i++) {
        out[0][i] <== neg0.out[i];
        out[1][i] <== neg1.out[i];
    }
}

template Fp2Double() {
    signal input a[2][3];
    signal output out[2][3];

    component dbl0 = FpDouble();
    component dbl1 = FpDouble();
    for (var i = 0; i < 3; i++) {
        dbl0.a[i] <== a[0][i];
        dbl1.a[i] <== a[1][i];
    }
    for (var i = 0; i < 3; i++) {
        out[0][i] <== dbl0.out[i];
        out[1][i] <== dbl1.out[i];
    }
}

template Fp2Halve() {
    signal input a[2][3];
    signal output out[2][3];

    component one = FpConst(1, 0, 0);
    component two = FpConst(2, 0, 0);
    component invTwo = FpDiv();
    for (var i = 0; i < 3; i++) {
        invTwo.a[i] <== one.out[i];
        invTwo.b[i] <== two.out[i];
    }

    component mul = Fp2MulByElement();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
        }
    }
    for (var i = 0; i < 3; i++) {
        mul.element[i] <== invTwo.out[i];
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2Conjugate() {
    signal input a[2][3];
    signal output out[2][3];

    component neg1 = FpNeg();
    for (var i = 0; i < 3; i++) {
        out[0][i] <== a[0][i];
        neg1.a[i] <== a[1][i];
    }
    for (var i = 0; i < 3; i++) {
        out[1][i] <== neg1.out[i];
    }
}

template Fp2Mul() {
    signal input a[2][3];
    signal input b[2][3];
    signal output out[2][3];

    component a0_plus_a1 = FpAdd();
    component b0_plus_b1 = FpAdd();
    for (var i = 0; i < 3; i++) {
        a0_plus_a1.a[i] <== a[0][i];
        a0_plus_a1.b[i] <== a[1][i];
        b0_plus_b1.a[i] <== b[0][i];
        b0_plus_b1.b[i] <== b[1][i];
    }

    component a_mul = FpMul();
    for (var i = 0; i < 3; i++) {
        a_mul.a[i] <== a0_plus_a1.out[i];
        a_mul.b[i] <== b0_plus_b1.out[i];
    }

    component b_mul = FpMul();
    component c_mul = FpMul();
    for (var i = 0; i < 3; i++) {
        b_mul.a[i] <== a[0][i];
        b_mul.b[i] <== b[0][i];
        c_mul.a[i] <== a[1][i];
        c_mul.b[i] <== b[1][i];
    }

    component c0 = FpSub();
    for (var i = 0; i < 3; i++) {
        c0.a[i] <== b_mul.out[i];
        c0.b[i] <== c_mul.out[i];
    }

    component tmp = FpSub();
    for (var i = 0; i < 3; i++) {
        tmp.a[i] <== a_mul.out[i];
        tmp.b[i] <== b_mul.out[i];
    }

    component c1 = FpSub();
    for (var i = 0; i < 3; i++) {
        c1.a[i] <== tmp.out[i];
        c1.b[i] <== c_mul.out[i];
    }

    for (var i = 0; i < 3; i++) {
        out[0][i] <== c0.out[i];
        out[1][i] <== c1.out[i];
    }
}

template Fp2Square() {
    signal input a[2][3];
    signal output out[2][3];

    component a0_plus_a1 = FpAdd();
    component a0_minus_a1 = FpSub();
    for (var i = 0; i < 3; i++) {
        a0_plus_a1.a[i] <== a[0][i];
        a0_plus_a1.b[i] <== a[1][i];
        a0_minus_a1.a[i] <== a[0][i];
        a0_minus_a1.b[i] <== a[1][i];
    }

    component a_mul = FpMul();
    for (var i = 0; i < 3; i++) {
        a_mul.a[i] <== a0_plus_a1.out[i];
        a_mul.b[i] <== a0_minus_a1.out[i];
    }

    component b_mul = FpMul();
    for (var i = 0; i < 3; i++) {
        b_mul.a[i] <== a[0][i];
        b_mul.b[i] <== a[1][i];
    }

    component b_dbl = FpDouble();
    for (var i = 0; i < 3; i++) {
        b_dbl.a[i] <== b_mul.out[i];
    }

    for (var i = 0; i < 3; i++) {
        out[0][i] <== a_mul.out[i];
        out[1][i] <== b_dbl.out[i];
    }
}

template Fp2Inverse() {
    signal input a[2][3];
    signal output out[2][3];

    component t0 = FpSquare();
    component t1 = FpSquare();
    for (var i = 0; i < 3; i++) {
        t0.a[i] <== a[0][i];
        t1.a[i] <== a[1][i];
    }

    component sum = FpAdd();
    for (var i = 0; i < 3; i++) {
        sum.a[i] <== t0.out[i];
        sum.b[i] <== t1.out[i];
    }

    component inv = FpInv();
    for (var i = 0; i < 3; i++) {
        inv.a[i] <== sum.out[i];
    }

    component c0 = FpMul();
    component c1 = FpMul();
    for (var i = 0; i < 3; i++) {
        c0.a[i] <== a[0][i];
        c0.b[i] <== inv.out[i];
        c1.a[i] <== a[1][i];
        c1.b[i] <== inv.out[i];
    }

    component c1_neg = FpNeg();
    for (var i = 0; i < 3; i++) {
        c1_neg.a[i] <== c1.out[i];
    }

    for (var i = 0; i < 3; i++) {
        out[0][i] <== c0.out[i];
        out[1][i] <== c1_neg.out[i];
    }
}

template Fp2MulByNonResidue() {
    signal input a[2][3];
    signal output out[2][3];

    component two_a0 = FpDouble();
    component four_a0 = FpDouble();
    component eight_a0 = FpDouble();
    component nine_a0 = FpAdd();
    for (var i = 0; i < 3; i++) {
        two_a0.a[i] <== a[0][i];
        four_a0.a[i] <== two_a0.out[i];
        eight_a0.a[i] <== four_a0.out[i];
        nine_a0.a[i] <== eight_a0.out[i];
        nine_a0.b[i] <== a[0][i];
    }

    component two_a1 = FpDouble();
    component four_a1 = FpDouble();
    component eight_a1 = FpDouble();
    component nine_a1 = FpAdd();
    for (var i = 0; i < 3; i++) {
        two_a1.a[i] <== a[1][i];
        four_a1.a[i] <== two_a1.out[i];
        eight_a1.a[i] <== four_a1.out[i];
        nine_a1.a[i] <== eight_a1.out[i];
        nine_a1.b[i] <== a[1][i];
    }

    component c0 = FpSub();
    component c1 = FpAdd();
    for (var i = 0; i < 3; i++) {
        c0.a[i] <== nine_a0.out[i];
        c0.b[i] <== a[1][i];
        c1.a[i] <== a[0][i];
        c1.b[i] <== nine_a1.out[i];
    }

    for (var i = 0; i < 3; i++) {
        out[0][i] <== c0.out[i];
        out[1][i] <== c1.out[i];
    }
}

template Fp2MulByElement() {
    signal input a[2][3];
    signal input element[3];
    signal output out[2][3];

    component mul0 = FpMul();
    component mul1 = FpMul();
    for (var i = 0; i < 3; i++) {
        mul0.a[i] <== a[0][i];
        mul0.b[i] <== element[i];
        mul1.a[i] <== a[1][i];
        mul1.b[i] <== element[i];
    }
    for (var i = 0; i < 3; i++) {
        out[0][i] <== mul0.out[i];
        out[1][i] <== mul1.out[i];
    }
}

template Fp2MulByConst(c0_l0, c0_l1, c0_l2, c1_l0, c1_l1, c1_l2) {
    signal input a[2][3];
    signal output out[2][3];

    component c = Fp2Const(c0_l0, c0_l1, c0_l2, c1_l0, c1_l1, c1_l2);
    component mul = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            mul.b[i][j] <== c.out[i][j];
        }
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByBTwistCoeff() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0xb4c5e559dbefa33267e6dc24a138e5, 0x9d40ceb8aaae81be18991be06ac3b5, 0x2b14,
        0x4fa084e52d1852e4a2bd0685c315d2, 0x13b03af0fed4cd2cafadeed8fdf4a7, 0x97
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue1Power1() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0x521e08292f2176d60b35dadcc9e470, 0xb71c2865a7dfe8b99fdd76e68b605c, 0x1284,
        0x7992778eeec7e5ca5cf05f80f362ac, 0x96f3b4fae7e6a6327cfe12150b8e74, 0x2469
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue1Power2() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3,
        0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue1Power3() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c,
        0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue1Power4() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0x3365f7be94ec72848a1f55921ea762, 0x4f5e64eea80180f3c0b75a181e84d3, 0x5b5,
        0x85d2ea1bdec763c13b4711cd2b8126, 0x5edbe7fd8aee9f3a80b03b0b1c9236, 0x2c14
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue1Power5() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0x5c459b55aa1bd32ea2c810eab7692f, 0xc1e74f798649e93a3661a4353ff442, 0x183,
        0x80cb99678e2ac024c6b8ee6e0c2c4b, 0xf2ca76fd0675a27fb246c7729f7db0, 0x12ac
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue2Power1() {
    signal input a[2][3];
    signal output out[2][3];

    component coeff = Fp2Frobenius2Power1();
    component mul = Fp2MulByElement();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
        }
    }
    for (var i = 0; i < 3; i++) {
        mul.element[i] <== coeff.out[i];
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue2Power2() {
    signal input a[2][3];
    signal output out[2][3];

    component coeff = Fp2Frobenius2Power2();
    component mul = Fp2MulByElement();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
        }
    }
    for (var i = 0; i < 3; i++) {
        mul.element[i] <== coeff.out[i];
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue2Power3() {
    signal input a[2][3];
    signal output out[2][3];

    component coeff = Fp2Frobenius2Power3();
    component mul = Fp2MulByElement();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
        }
    }
    for (var i = 0; i < 3; i++) {
        mul.element[i] <== coeff.out[i];
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue2Power4() {
    signal input a[2][3];
    signal output out[2][3];

    component coeff = Fp2Frobenius2Power4();
    component mul = Fp2MulByElement();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
        }
    }
    for (var i = 0; i < 3; i++) {
        mul.element[i] <== coeff.out[i];
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue2Power5() {
    signal input a[2][3];
    signal output out[2][3];

    component coeff = Fp2Frobenius2Power5();
    component mul = Fp2MulByElement();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
        }
    }
    for (var i = 0; i < 3; i++) {
        mul.element[i] <== coeff.out[i];
    }
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue3Power1() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0x4cb38dbe55d24ae86f7d391ed4a67f, 0x81cfcc82e4bbefe9608cd0acaa9089, 0x19dc,
        0x3a5e397d439ec7694aa2bf4c0c101, 0xf8b60be77d7306cbeee33576139d7f, 0xab
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue3Power2() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0x5ffd3d5d6942d37b746ee87bdcfb6d, 0xe078b755ef0abaff1c77959f25ac80, 0x856,
        0xdf31bf98ff2631380cab2baaa586de, 0xde41b3d1766fa9f30e6dec26094f0f, 0x4f1
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue3Power3() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0xd689a3bea870f45fcc8ad066dce9ed, 0x5b6d9896aa4cdbf17f1dca9e5ea3bb, 0x2a27,
        0xecc7d8cf6ebab94d0cb3b2594c64, 0x11b634f09b8fb14b900e9507e93276, 0x28a4
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue3Power4() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0x33094575b06bcb0e1a92bc3ccbf066, 0x8c6611c08dab19bee0f7b5b2444ee6, 0xbc5,
        0x4a9e08737f96e55fe3ed9d730c239f, 0xe999e1910a12feb0f6ef0cd21d04a4, 0x23d5
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}

template Fp2MulByNonResidue3Power5() {
    signal input a[2][3];
    signal output out[2][3];

    component mul = Fp2MulByConst(
        0xd68098967c84a5ebde847076261b43, 0x9044952c0905711699fa3b4d3f692e, 0x13c4,
        0x2ddaea200280211f25041384282499, 0x366a59b1dd0b9fb1b2282a48633d3e, 0x16db
    );
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul.a[i][j] <== a[i][j];
            out[i][j] <== mul.out[i][j];
        }
    }
}
