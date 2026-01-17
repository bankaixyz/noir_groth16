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

template FpFromLimbs() {
    signal input in[3];
    signal output out;

    component limb0 = Num2Bits(120);
    component limb1 = Num2Bits(120);
    component limb2 = Num2Bits(120);

    limb0.in <== in[0];
    limb1.in <== in[1];
    limb2.in <== in[2];

    var shift1 = 2**120;
    var shift2 = 2**240;
    out <== in[0] + in[1] * shift1 + in[2] * shift2;
}

template FpToLimbs() {
    signal input in;
    signal output out[3];

    component bits = Num2Bits(254);
    bits.in <== in;

    var limb0 = 0;
    var exp0 = 1;
    for (var i = 0; i < 120; i++) {
        limb0 += bits.out[i] * exp0;
        exp0 = exp0 * 2;
    }

    var limb1 = 0;
    var exp1 = 1;
    for (var i = 120; i < 240; i++) {
        limb1 += bits.out[i] * exp1;
        exp1 = exp1 * 2;
    }

    var limb2 = 0;
    var exp2 = 1;
    for (var i = 240; i < 254; i++) {
        limb2 += bits.out[i] * exp2;
        exp2 = exp2 * 2;
    }

    out[0] <== limb0;
    out[1] <== limb1;
    out[2] <== limb2;
}

template FpAdd() {
    signal input a[3];
    signal input b[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    component bVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
        bVal.in[i] <== b[i];
    }

    signal sum;
    sum <== aVal.out + bVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== sum;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}

template FpSub() {
    signal input a[3];
    signal input b[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    component bVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
        bVal.in[i] <== b[i];
    }

    signal diff;
    diff <== aVal.out - bVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== diff;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}

template FpNeg() {
    signal input a[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
    }

    signal neg;
    neg <== 0 - aVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== neg;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}

template FpDouble() {
    signal input a[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
    }

    signal dbl;
    dbl <== aVal.out + aVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== dbl;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}

template FpMul() {
    signal input a[3];
    signal input b[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    component bVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
        bVal.in[i] <== b[i];
    }

    signal prod;
    prod <== aVal.out * bVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== prod;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}

template FpSquare() {
    signal input a[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
    }

    signal sq;
    sq <== aVal.out * aVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== sq;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}

template FpInv() {
    signal input a[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
    }

    signal inv;
    inv <== 1 / aVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== inv;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}

template FpDiv() {
    signal input a[3];
    signal input b[3];
    signal output out[3];

    component aVal = FpFromLimbs();
    component bVal = FpFromLimbs();
    for (var i = 0; i < 3; i++) {
        aVal.in[i] <== a[i];
        bVal.in[i] <== b[i];
    }

    signal quot;
    quot <== aVal.out / bVal.out;

    component outLimbs = FpToLimbs();
    outLimbs.in <== quot;
    for (var i = 0; i < 3; i++) {
        out[i] <== outLimbs.out[i];
    }
}
