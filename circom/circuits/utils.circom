pragma circom 2.0.0;

template Num2Bits(n) {
    signal input in;
    signal output out[n];

    var acc = 0;
    var exp = 1;
    for (var i = 0; i < n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] - 1) === 0;
        acc += out[i] * exp;
        exp = exp * 2;
    }
    acc === in;
}

template IsZero() {
    signal input in;
    signal output out;
    signal inv;

    inv <-- (in == 0) ? 0 : 1 / in;
    out <== 1 - in * inv;
    out * in === 0;
    out * (out - 1) === 0;
}

template IsEqual() {
    signal input a;
    signal input b;
    signal output out;

    component isZero = IsZero();
    isZero.in <== a - b;
    out <== isZero.out;
}

template Lt(n) {
    signal input a;
    signal input b;
    signal output out;

    component bits = Num2Bits(n + 1);
    bits.in <== a + (1 << n) - b;
    out <== 1 - bits.out[n];
}
