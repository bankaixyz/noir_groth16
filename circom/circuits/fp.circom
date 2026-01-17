pragma circom 2.0.0;

include "./utils.circom";

template FpConst(l0, l1, l2) {
    signal output out;

    var base = 1 << 120;
    out <== l0 + l1 * base + l2 * base * base;
}

template FpZero() {
    signal output out;
    out <== 0;
}

template FpOne() {
    signal output out;
    out <== 1;
}

template FpTwo() {
    signal output out;
    out <== 2;
}

template FpThree() {
    signal output out;
    out <== 3;
}

template FpFour() {
    signal output out;
    out <== 4;
}

template FpEight() {
    signal output out;
    out <== 8;
}

template FpNine() {
    signal output out;
    out <== 9;
}

template SeedX0() {
    signal output out;
    out <== 4965661367192848881;
}

template G1GeneratorX() {
    signal output out;
    out <== 1;
}

template G1GeneratorY() {
    signal output out;
    out <== 2;
}

template CurveB() {
    signal output out;
    out <== 3;
}

template FpSelect() {
    signal input a;
    signal input b;
    signal input sel;
    signal output out;

    sel * (sel - 1) === 0;
    out <== b + sel * (a - b);
}

template FpAdd() {
    signal input a;
    signal input b;
    signal output out;

    out <== a + b;
}

template FpSub() {
    signal input a;
    signal input b;
    signal output out;

    out <== a - b;
}

template FpNeg() {
    signal input a;
    signal output out;

    out <== -a;
}

template FpDouble() {
    signal input a;
    signal output out;

    out <== a + a;
}

template FpMul() {
    signal input a;
    signal input b;
    signal output out;

    out <== a * b;
}

template FpSquare() {
    signal input a;
    signal output out;

    out <== a * a;
}

template FpInv() {
    signal input a;
    signal input inv;
    signal output out;

    a * inv === 1;
    out <== inv;
}

template FpDiv() {
    signal input a;
    signal input b;
    signal input inv_b;
    signal output out;

    component inv = FpInv();
    inv.a <== b;
    inv.inv <== inv_b;

    out <== a * inv_b;
}

template FpEq() {
    signal input a;
    signal input b;
    signal output out;

    component eq = IsEqual();
    eq.a <== a;
    eq.b <== b;
    out <== eq.out;
    out * (out - 1) === 0;
}

template FpIsZero() {
    signal input a;
    signal output out;

    component isZero = IsZero();
    isZero.in <== a;
    out <== isZero.out;
    out * (out - 1) === 0;
}
