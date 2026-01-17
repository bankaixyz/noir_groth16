const MODULUS = BigInt(
    "0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47"
);
const BASE = 1n << 120n;

const mod = (value) => {
    const res = value % MODULUS;
    return res >= 0n ? res : res + MODULUS;
};

const limbsToBigInt = (limbs) =>
    BigInt(limbs[0]) + BigInt(limbs[1]) * BASE + BigInt(limbs[2]) * BASE * BASE;

const bigIntToLimbs = (value) => {
    const v = mod(value);
    const l0 = v % BASE;
    const l1 = (v / BASE) % BASE;
    const l2 = v / (BASE * BASE);
    return [l0, l1, l2];
};

const modPow = (base, exp) => {
    let result = 1n;
    let b = mod(base);
    let e = exp;
    while (e > 0n) {
        if (e & 1n) {
            result = mod(result * b);
        }
        b = mod(b * b);
        e >>= 1n;
    }
    return result;
};

const fpInv = (value) => modPow(value, MODULUS - 2n);

const fp2Inv = (fp2) => {
    const a = limbsToBigInt(fp2[0]);
    const b = limbsToBigInt(fp2[1]);
    const t0 = mod(a * a + b * b);
    const t1 = fpInv(t0);
    const c0 = mod(a * t1);
    const c1 = mod(-b * t1);
    return [bigIntToLimbs(c0), bigIntToLimbs(c1)];
};

module.exports = { MODULUS, BASE, mod, modPow, limbsToBigInt, bigIntToLimbs, fpInv, fp2Inv };
