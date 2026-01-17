const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const { expect } = require("chai");
const { mod, limbsToBigInt, bigIntToLimbs, fpInv } = require("./field");

const fp = (arr) => arr.map((v) => BigInt(v));
const g1 = (x, y) => [fp(x), fp(y)];

const generator = g1(["0x1", "0x0", "0x0"], ["0x2", "0x0", "0x0"]);
const pointA = g1(
    ["0x5577586de4c517537d17882f9b3f34", "0xf35db6971fd77c8f9afdae27f7fb35", "0x988"],
    ["0xb4a8ae95f49905d52cdb2c3b4cb203", "0xffa63fafc8c67007390a6e6dd52860", "0x23ba"]
);
const pointB = g1(
    ["0xf471f19fab22085f30251b3084cb7a", "0xa1741e8a505306a40614881a5b3506", "0x1cbc"],
    ["0xdf15071d3961bf6535a388c2b804d0", "0xfc14bee57a2dababc23e2510bd69bc", "0x168d"]
);
const pointAPlusB = g1(
    ["0x7e05587f149e1850a75e2cf76095d6", "0x3fbe7d5abdaabf807439706b07477b", "0x20ef"],
    ["0xdefcc453f6364c43b2d3a1e6114e90", "0x5c9cf4c0f268b4a9bc74fcef3b1fbd", "0xeb9"]
);
const pointADoubled = g1(
    ["0xf5c32a365156b25e5b0641c11a9f49", "0x6cba5a32a9297a9c6c094f352c94a9", "0x1887"],
    ["0x5b8343359cf4ce7e6721f6ed6db7fa", "0x58ec05617f5d75bc9de862f0ca7c1d", "0x23a"]
);
const pointANegated = g1(
    ["0x5577586de4c517537d17882f9b3f34", "0xf35db6971fd77c8f9afdae27f7fb35", "0x988"],
    ["0xccc1e2d27d318766f3b0ea9d304b44", "0x4ecca181d76348490cac1313833536", "0xca9"]
);
const infinity = g1(["0x0", "0x0", "0x0"], ["0x0", "0x0", "0x0"]);

const generatorJac = [
    fp(["0x1", "0x0", "0x0"]),
    fp(["0x2", "0x0", "0x0"]),
    fp(["0x1", "0x0", "0x0"]),
];
const generatorJacFuzzed = [
    fp(["0x121", "0x0", "0x0"]),
    fp(["0x2662", "0x0", "0x0"]),
    fp(["0x11", "0x0", "0x0"]),
];
const infinityJac = [
    fp(["0x1", "0x0", "0x0"]),
    fp(["0x1", "0x0", "0x0"]),
    fp(["0x0", "0x0", "0x0"]),
];

const fpInvLimbs = (limbs) => bigIntToLimbs(fpInv(limbsToBigInt(limbs)));

const jacobianToAffine = (p) => {
    const z = limbsToBigInt(p[2]);
    if (z === 0n) {
        return infinity;
    }
    const inv = fpInv(z);
    const invSq = mod(inv * inv);
    const x = mod(limbsToBigInt(p[0]) * invSq);
    const y = mod(limbsToBigInt(p[1]) * invSq * inv);
    return [bigIntToLimbs(x), bigIntToLimbs(y)];
};

describe("G1 operations", function () {
    this.timeout(60000);

    let circuit;
    let witness;

    before(async function () {
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/test/g1_ops.circom")
        );

        const h = mod(limbsToBigInt(pointB[0]) - limbsToBigInt(pointA[0]));
        const zAdd = mod(2n * h);
        const zDouble = mod(2n * limbsToBigInt(pointA[1]));

        witness = await circuit.calculateWitness(
            {
                a: pointA,
                b: pointB,
                neg_a: pointANegated,
                gen: generator,
                bad: [
                    generator[0],
                    bigIntToLimbs(mod(limbsToBigInt(generator[1]) * 2n)),
                ],
                inv_add_ab: bigIntToLimbs(fpInv(zAdd)),
                inv_double_a: bigIntToLimbs(fpInv(zDouble)),
                inv_jac_fuzzed: fpInvLimbs(generatorJacFuzzed[2]),
                inv_jac_inf: [0n, 0n, 0n],
                jac_p: generatorJac,
                jac_q: generatorJacFuzzed,
                jac_inf: infinityJac,
            },
            true
        );
    });

    it("checks curve membership", async function () {
        await circuit.assertOut(witness, {
            is_on_curve_gen: 1,
            is_on_curve_bad: 0,
        });
    });

    it("matches affine arithmetic fixtures", async function () {
        await circuit.assertOut(witness, {
            add_ab: pointAPlusB,
            add_a_inf: pointA,
            add_inf_a: pointA,
            add_a_neg: infinity,
            double_mixed_a: pointADoubled,
            add_a_a: pointADoubled,
        });
    });

    it("matches jacobian arithmetic expectations", async function () {
        const outputs = await circuit.getOutput(witness, {
            jac_sum: [3, [3, 1]],
            jac_dbl: [3, [3, 1]],
            jac_sum_neg: [3, [3, 1]],
            jac_add_inf1: [3, [3, 1]],
            jac_add_inf2: [3, [3, 1]],
            jac_fuzzed_affine: [2, [3, 1]],
            jac_inf_affine: [2, [3, 1]],
        });

        const sumAff = jacobianToAffine(outputs.jac_sum);
        const dblAff = jacobianToAffine(outputs.jac_dbl);
        expect(sumAff).to.deep.equal(dblAff);

        const sumNeg = jacobianToAffine(outputs.jac_sum_neg);
        expect(sumNeg).to.deep.equal(infinity);

        const addInf1 = jacobianToAffine(outputs.jac_add_inf1);
        const addInf2 = jacobianToAffine(outputs.jac_add_inf2);
        expect(addInf1).to.deep.equal(jacobianToAffine(generatorJacFuzzed));
        expect(addInf2).to.deep.equal(jacobianToAffine(generatorJacFuzzed));

        expect(outputs.jac_fuzzed_affine).to.deep.equal(generator);
        expect(outputs.jac_inf_affine).to.deep.equal(infinity);
    });
});
