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

const fpAdd = (a, b) => mod(a + b);
const fpSub = (a, b) => mod(a - b);
const fpMul = (a, b) => mod(a * b);
const fpNeg = (a) => mod(-a);

const fp2ToBigInts = (fp2) => [limbsToBigInt(fp2[0]), limbsToBigInt(fp2[1])];
const fp2FromBigInts = (fp2) => [bigIntToLimbs(fp2[0]), bigIntToLimbs(fp2[1])];
const fp2AddBI = (a, b) => [fpAdd(a[0], b[0]), fpAdd(a[1], b[1])];
const fp2SubBI = (a, b) => [fpSub(a[0], b[0]), fpSub(a[1], b[1])];
const fp2NegBI = (a) => [fpNeg(a[0]), fpNeg(a[1])];
const fp2MulBI = (a, b) => [
    fpSub(fpMul(a[0], b[0]), fpMul(a[1], b[1])),
    fpAdd(fpMul(a[0], b[1]), fpMul(a[1], b[0])),
];
const fp2SquareBI = (a) => [
    fpSub(fpMul(a[0], a[0]), fpMul(a[1], a[1])),
    fpMul(fpAdd(a[0], a[0]), a[1]),
];
const fp2DoubleBI = (a) => [fpAdd(a[0], a[0]), fpAdd(a[1], a[1])];
const fp2MulByElementBI = (a, elem) => [fpMul(a[0], elem), fpMul(a[1], elem)];
const fp2InvBI = (a) => {
    const t0 = fpAdd(fpMul(a[0], a[0]), fpMul(a[1], a[1]));
    const t1 = fpInv(t0);
    return [fpMul(a[0], t1), fpNeg(fpMul(a[1], t1))];
};

const fp2Add = (a, b) => fp2FromBigInts(fp2AddBI(fp2ToBigInts(a), fp2ToBigInts(b)));
const fp2Sub = (a, b) => fp2FromBigInts(fp2SubBI(fp2ToBigInts(a), fp2ToBigInts(b)));
const fp2Neg = (a) => fp2FromBigInts(fp2NegBI(fp2ToBigInts(a)));
const fp2Mul = (a, b) => fp2FromBigInts(fp2MulBI(fp2ToBigInts(a), fp2ToBigInts(b)));
const fp2Square = (a) => fp2FromBigInts(fp2SquareBI(fp2ToBigInts(a)));
const fp2Double = (a) => fp2FromBigInts(fp2DoubleBI(fp2ToBigInts(a)));
const fp2MulByElement = (a, elem) => fp2FromBigInts(fp2MulByElementBI(fp2ToBigInts(a), elem));

const fp2Inv = (fp2) => {
    return fp2FromBigInts(fp2InvBI(fp2ToBigInts(fp2)));
};

module.exports = {
    MODULUS,
    BASE,
    mod,
    modPow,
    limbsToBigInt,
    bigIntToLimbs,
    fpInv,
    fpAdd,
    fpSub,
    fpMul,
    fpNeg,
    fp2ToBigInts,
    fp2FromBigInts,
    fp2AddBI,
    fp2SubBI,
    fp2NegBI,
    fp2MulBI,
    fp2SquareBI,
    fp2DoubleBI,
    fp2MulByElementBI,
    fp2InvBI,
    fp2Add,
    fp2Sub,
    fp2Neg,
    fp2Mul,
    fp2Square,
    fp2Double,
    fp2MulByElement,
    fp2Inv,
};
