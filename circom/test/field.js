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

const fp2ToBigInts = (fp2) => [BigInt(fp2[0]), BigInt(fp2[1])];
const fp2FromBigInts = (fp2) => [mod(fp2[0]), mod(fp2[1])];
const fp2AddBI = (a, b) => [fpAdd(a[0], b[0]), fpAdd(a[1], b[1])];
const fp2SubBI = (a, b) => [fpSub(a[0], b[0]), fpSub(a[1], b[1])];
const fp2NegBI = (a) => [fpNeg(a[0]), fpNeg(a[1])];
const fp2MulBI = (a, b) => [
    fpSub(fpMul(a[0], b[0]), fpMul(a[1], b[1])),
    fpAdd(fpMul(a[0], b[1]), fpMul(a[1], b[0])),
];
const fp2MulByNonResidueBI = (a) => {
    const nine = 9n;
    const c0 = fpSub(fpMul(nine, a[0]), a[1]);
    const c1 = fpAdd(a[0], fpMul(nine, a[1]));
    return [c0, c1];
};
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

const fp2Add = (a, b) => fp2FromBigInts(fp2AddBI(a, b));
const fp2Sub = (a, b) => fp2FromBigInts(fp2SubBI(a, b));
const fp2Neg = (a) => fp2FromBigInts(fp2NegBI(a));
const fp2Mul = (a, b) => fp2FromBigInts(fp2MulBI(a, b));
const fp2MulByNonResidue = (a) => fp2FromBigInts(fp2MulByNonResidueBI(a));
const fp2Square = (a) => fp2FromBigInts(fp2SquareBI(a));
const fp2Double = (a) => fp2FromBigInts(fp2DoubleBI(a));
const fp2MulByElement = (a, elem) => fp2FromBigInts(fp2MulByElementBI(a, elem));

const fp2Inv = (fp2) => fp2FromBigInts(fp2InvBI(fp2));

const fp6ToBigInts = (fp6) => [fp6[0], fp6[1], fp6[2]];
const fp6FromBigInts = (fp6) => [
    fp2FromBigInts(fp6[0]),
    fp2FromBigInts(fp6[1]),
    fp2FromBigInts(fp6[2]),
];
const fp6AddBI = (a, b) => [
    fp2AddBI(a[0], b[0]),
    fp2AddBI(a[1], b[1]),
    fp2AddBI(a[2], b[2]),
];
const fp6SubBI = (a, b) => [
    fp2SubBI(a[0], b[0]),
    fp2SubBI(a[1], b[1]),
    fp2SubBI(a[2], b[2]),
];
const fp6NegBI = (a) => [fp2NegBI(a[0]), fp2NegBI(a[1]), fp2NegBI(a[2])];
const fp6MulByNonResidueBI = (a) => [
    fp2MulByNonResidueBI(a[2]),
    a[0],
    a[1],
];
const fp6MulBI = (a, b) => {
    const t0 = fp2MulBI(a[0], b[0]);
    const t1 = fp2MulBI(a[1], b[1]);
    const t2 = fp2MulBI(a[2], b[2]);

    let c0 = fp2MulBI(fp2AddBI(a[1], a[2]), fp2AddBI(b[1], b[2]));
    c0 = fp2SubBI(fp2SubBI(c0, t1), t2);
    c0 = fp2AddBI(fp2MulByNonResidueBI(c0), t0);

    let c1 = fp2MulBI(fp2AddBI(a[0], a[1]), fp2AddBI(b[0], b[1]));
    c1 = fp2SubBI(fp2SubBI(c1, t0), t1);
    c1 = fp2AddBI(c1, fp2MulByNonResidueBI(t2));

    let c2 = fp2MulBI(fp2AddBI(a[0], a[2]), fp2AddBI(b[0], b[2]));
    c2 = fp2AddBI(fp2SubBI(fp2SubBI(c2, t0), t2), t1);

    return [c0, c1, c2];
};
const fp6SquareBI = (a) => {
    const c4 = fp2DoubleBI(fp2MulBI(a[0], a[1]));
    const c5 = fp2SquareBI(a[2]);
    const c1 = fp2AddBI(fp2MulByNonResidueBI(c5), c4);
    const c2 = fp2SubBI(c4, c5);
    const c3 = fp2SquareBI(a[0]);
    let c4b = fp2AddBI(fp2SubBI(a[0], a[1]), a[2]);
    const c5b = fp2DoubleBI(fp2MulBI(a[1], a[2]));
    c4b = fp2SquareBI(c4b);
    const c0 = fp2AddBI(fp2MulByNonResidueBI(c5b), c3);

    const b2 = fp2AddBI(fp2AddBI(fp2AddBI(c2, c4b), c5b), fp2NegBI(c3));
    return [c0, c1, b2];
};
const fp6InvBI = (a) => {
    const t0 = fp2SquareBI(a[0]);
    const t1 = fp2SquareBI(a[1]);
    const t2 = fp2SquareBI(a[2]);
    const t3 = fp2MulBI(a[0], a[1]);
    const t4 = fp2MulBI(a[0], a[2]);
    const t5 = fp2MulBI(a[1], a[2]);

    const c0 = fp2SubBI(t0, fp2MulByNonResidueBI(t5));
    const c1 = fp2SubBI(fp2MulByNonResidueBI(t2), t3);
    const c2 = fp2SubBI(t1, t4);

    const t6a = fp2MulBI(a[0], c0);
    const d1 = fp2MulBI(a[2], c1);
    const d2 = fp2MulBI(a[1], c2);
    const t6b = fp2MulByNonResidueBI(fp2AddBI(d1, d2));
    const t6 = fp2InvBI(fp2AddBI(t6a, t6b));

    return [
        fp2MulBI(c0, t6),
        fp2MulBI(c1, t6),
        fp2MulBI(c2, t6),
    ];
};

const fp6Add = (a, b) => fp6FromBigInts(fp6AddBI(a, b));
const fp6Sub = (a, b) => fp6FromBigInts(fp6SubBI(a, b));
const fp6Neg = (a) => fp6FromBigInts(fp6NegBI(a));
const fp6Mul = (a, b) => fp6FromBigInts(fp6MulBI(a, b));
const fp6Square = (a) => fp6FromBigInts(fp6SquareBI(a));
const fp6Inv = (a) => fp6FromBigInts(fp6InvBI(a));

const fp12ToBigInts = (fp12) => [fp12[0], fp12[1]];
const fp12FromBigInts = (fp12) => [fp6FromBigInts(fp12[0]), fp6FromBigInts(fp12[1])];
const fp12MulBI = (a, b) => {
    const aSum = fp6AddBI(a[0], a[1]);
    const bSum = fp6AddBI(b[0], b[1]);
    const t0 = fp6MulBI(aSum, bSum);
    const t1 = fp6MulBI(a[0], b[0]);
    const t2 = fp6MulBI(a[1], b[1]);
    const c1 = fp6SubBI(fp6SubBI(t0, t1), t2);
    const c0 = fp6AddBI(fp6MulByNonResidueBI(t2), t1);
    return [c0, c1];
};
const fp12SquareBI = (a) => {
    const ab = fp6MulBI(a[0], a[1]);
    const c0 = fp6AddBI(fp6SquareBI(a[0]), fp6MulByNonResidueBI(fp6SquareBI(a[1])));
    const c1 = fp6AddBI(ab, ab);
    return [c0, c1];
};
const fp12InvBI = (a) => {
    const t0 = fp6SquareBI(a[0]);
    const t1 = fp6SquareBI(a[1]);
    const t0b = fp6SubBI(t0, fp6MulByNonResidueBI(t1));
    const t1b = fp6InvBI(t0b);
    const c0 = fp6MulBI(a[0], t1b);
    const c1 = fp6NegBI(fp6MulBI(a[1], t1b));
    return [c0, c1];
};
const fp12Inv = (a) => fp12FromBigInts(fp12InvBI(a));

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
    fp2MulByNonResidueBI,
    fp2SquareBI,
    fp2DoubleBI,
    fp2MulByElementBI,
    fp2InvBI,
    fp2Add,
    fp2Sub,
    fp2Neg,
    fp2Mul,
    fp2MulByNonResidue,
    fp2Square,
    fp2Double,
    fp2MulByElement,
    fp2Inv,
    fp6ToBigInts,
    fp6FromBigInts,
    fp6AddBI,
    fp6SubBI,
    fp6NegBI,
    fp6MulByNonResidueBI,
    fp6MulBI,
    fp6SquareBI,
    fp6InvBI,
    fp6Add,
    fp6Sub,
    fp6Neg,
    fp6Mul,
    fp6Square,
    fp6Inv,
    fp12ToBigInts,
    fp12FromBigInts,
    fp12MulBI,
    fp12SquareBI,
    fp12InvBI,
    fp12Inv,
};
