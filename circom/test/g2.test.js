const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const { expect } = require("chai");
const {
    fp2Inv,
    fp2Double,
    fp2ToBigInts,
    fp2FromBigInts,
    fp2MulBI,
    fp2SquareBI,
    fp2InvBI,
    limbsToBigInt,
} = require("./field");

const fp = (arr) => limbsToBigInt(arr.map((v) => BigInt(v)));
const fp2 = (a0, a1) => [fp(a0), fp(a1)];
const g2 = (x0, x1, y0, y1) => [fp2(x0, x1), fp2(y0, y1)];

const fp2One = fp2(["0x1", "0x0", "0x0"], ["0x0", "0x0", "0x0"]);
const fp2Zero = fp2(["0x0", "0x0", "0x0"], ["0x0", "0x0", "0x0"]);
const g2Infinity = g2(
    ["0x0", "0x0", "0x0"],
    ["0x0", "0x0", "0x0"],
    ["0x0", "0x0", "0x0"],
    ["0x0", "0x0", "0x0"]
);

const generator = g2(
    ["0x4322d4f75edadd46debd5cd992f6ed", "0xdeef121f1e76426a00665e5c447967", "0x1800"],
    ["0xaa493335a9e71297e485b7aef312c2", "0x9393920d483a7260bfb731fb5d25f1", "0x198e"],
    ["0xd1e7690c43d37b4ce6cc0166fa7daa", "0x5ea5db8c6deb4aab71808dcb408fe3", "0x12c8"],
    ["0x4b313370b38ef355acdadcd122975b", "0x89d0585ff075ec9e99ad690c3395bc", "0x906"]
);
const pointA = g2(
    ["0x13ba7204aeca62d66d931b99afe6e7", "0xa8c89a0d090f3d8644ada33a5f1c80", "0x116d"],
    ["0xd67b1d0e2a530069e3a7306569a91", "0x934ba9615b77b6a49b06fcce83ce9", "0x1274"],
    ["0xbefc72ac8a6157d30924e58dc4c172", "0x41042e77b6309644b56251f059cf14", "0x764"],
    ["0x79c18bd22b834ea8c6d07c0ba441db", "0x2d9816e5f86b4a7dedd00d04acc5c9", "0x2522"]
);
const pointB = g2(
    ["0xf6168947698d7905591d550d0996a7", "0x89f73b921870a13c3bcffc688fe7e0", "0x23d0"],
    ["0x162db0496e99558b2ead49acdbd1ba", "0xefa13f2b80e64ae14f70b423898908", "0x2e0d"],
    ["0x36a089125b1a3f8df3a8c34dc447aa", "0x4a32636bd0c0d18bff662cd0c235ed", "0x1e27"],
    ["0x392d759ba9e1e6bb3300eb0f580a68", "0xc76db66c0ad94d6c61471a21887c49", "0x260d"]
);
const pointAPlusB = g2(
    ["0xcbb06e263c232e39d3be00b9d35951", "0xb7b85a2d4a976f777f99dc549687ff", "0x6f3"],
    ["0xd4e2b2437533ebf89b0f69845cd306", "0x53859e1cca25f2158e41826ae57672", "0x2f1b"],
    ["0xf26eb8d41e672888f84c702bd12044", "0x4cf2d5c6d887dd299b6e2d8357d429", "0x953"],
    ["0x6528b6a70234e839424ae707b263eb", "0xcbb0d0fa75b9ad0e176ecfd9ddb4d2", "0x2987"]
);
const pointADoubled = g2(
    ["0x8473fc86f3a81756dd0a3e9dc559fd", "0x8796dc8200e078a79a056f6770ffcc", "0x1036"],
    ["0xce30e6fc24eb998c805468f83a054c", "0xcb54e1ef69fa1f26277210d0796470", "0x2bdc"],
    ["0x516706967740a78ca26fbea6e05865", "0xbe8d96bfac4b10f1cbefe464c86b64", "0xe42"],
    ["0xc895cfefa2360f83cbf9a69f52dc94", "0xb7c4ddbe4c1c2b586a1f0541d22b12", "0x1512"]
);
const pointANegated = g2(
    ["0x13ba7204aeca62d66d931b99afe6e7", "0xa8c89a0d090f3d8644ada33a5f1c80", "0x116d"],
    ["0xd67b1d0e2a530069e3a7306569a91", "0x934ba9615b77b6a49b06fcce83ce9", "0x1274"],
    ["0xc26e1ebbe76935691767314ab83bd5", "0xd6eb2b9e9f9220b90542f90fe8e82", "0x2900"],
    ["0x7a9059646473e9359bb9accd8bb6c", "0x20daca4ba7be6dd257e6747cab97ce", "0xb42"]
);

const generatorJac = [
    fp2(
        ["0x4322d4f75edadd46debd5cd992f6ed", "0xdeef121f1e76426a00665e5c447967", "0x1800"],
        ["0xaa493335a9e71297e485b7aef312c2", "0x9393920d483a7260bfb731fb5d25f1", "0x198e"]
    ),
    fp2(
        ["0xd1e7690c43d37b4ce6cc0166fa7daa", "0x5ea5db8c6deb4aab71808dcb408fe3", "0x12c8"],
        ["0x4b313370b38ef355acdadcd122975b", "0x89d0585ff075ec9e99ad690c3395bc", "0x906"]
    ),
    fp2(["0x1", "0x0", "0x0"], ["0x0", "0x0", "0x0"]),
];
const generatorJacFuzzed = [
    fp2(
        ["0x7fcb31ea84eee86b45850eb11746e4", "0xd9b7aa68ec3304d3829e2ee8f0c5f1", "0x10f3"],
        ["0x655c79913d9821c5a7c6cbf631cada", "0x5622b877135af8f097287f7b043dc", "0x1e66"]
    ),
    fp2(
        ["0xcea868c27791c52efe24d17aaff0ec", "0x59b9ce8f09f5be963b5104ae20a12d", "0x2c90"],
        ["0xf9ebec2ed1aa9415df060af9a0775f", "0x246243a4b1da9089d7f5a059cdc083", "0xf92"]
    ),
    fp2(["0x11", "0x0", "0x0"], ["0x0", "0x0", "0x0"]),
];
const infinityJac = [
    fp2(["0x1", "0x0", "0x0"], ["0x0", "0x0", "0x0"]),
    fp2(["0x1", "0x0", "0x0"], ["0x0", "0x0", "0x0"]),
    fp2(["0x0", "0x0", "0x0"], ["0x0", "0x0", "0x0"]),
];

const fp2IsZero = (a) => a[0] === 0n && a[1] === 0n;

const jacobianToAffine = (p) => {
    const z = fp2ToBigInts(p[2]);
    if (fp2IsZero(z)) {
        return g2Infinity;
    }
    const inv = fp2InvBI(z);
    const invSq = fp2SquareBI(inv);
    const x = fp2MulBI(fp2ToBigInts(p[0]), invSq);
    const y = fp2MulBI(fp2ToBigInts(p[1]), fp2MulBI(invSq, inv));
    return [fp2FromBigInts(x), fp2FromBigInts(y)];
};

describe("G2 operations", function () {
    this.timeout(60000);

    let circuit;
    let witness;

    before(async function () {
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/test/g2_ops.circom")
        );

        const bad = [generator[0], fp2Double(generator[1])];

        witness = await circuit.calculateWitness(
            {
                a: pointA,
                b: pointB,
                neg_a: pointANegated,
                gen: generator,
                bad,
                jac_p: generatorJac,
                jac_q: generatorJacFuzzed,
                jac_inf: infinityJac,
                inv_jac_fuzzed: fp2Inv(generatorJacFuzzed[2]),
                inv_jac_inf: fp2Zero,
                inv_psi: fp2One,
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

    it("matches affine arithmetic fixtures via jacobian", async function () {
        const outputs = await circuit.getOutput(witness, {
            jac_sum: [3, [2, 1]],
            jac_sum_inf1: [3, [2, 1]],
            jac_sum_inf2: [3, [2, 1]],
            jac_sum_neg: [3, [2, 1]],
            jac_dbl: [3, [2, 1]],
            jac_add_self: [3, [2, 1]],
        });

        expect(jacobianToAffine(outputs.jac_sum)).to.deep.equal(pointAPlusB);
        expect(jacobianToAffine(outputs.jac_sum_inf1)).to.deep.equal(pointA);
        expect(jacobianToAffine(outputs.jac_sum_inf2)).to.deep.equal(pointA);
        expect(jacobianToAffine(outputs.jac_sum_neg)).to.deep.equal(g2Infinity);
        expect(jacobianToAffine(outputs.jac_dbl)).to.deep.equal(pointADoubled);
        expect(jacobianToAffine(outputs.jac_add_self)).to.deep.equal(pointADoubled);
    });

    it("matches jacobian arithmetic expectations", async function () {
        const outputs = await circuit.getOutput(witness, {
            jac_sum_pq: [3, [2, 1]],
            jac_dbl_q: [3, [2, 1]],
            jac_sum_neg_q: [3, [2, 1]],
            jac_add_inf_q1: [3, [2, 1]],
            jac_add_inf_q2: [3, [2, 1]],
            jac_fuzzed_affine: [2, [2, 1]],
            jac_inf_affine: [2, [2, 1]],
        });

        const sumAff = jacobianToAffine(outputs.jac_sum_pq);
        const dblAff = jacobianToAffine(outputs.jac_dbl_q);
        expect(sumAff).to.deep.equal(dblAff);
        expect(jacobianToAffine(outputs.jac_sum_neg_q)).to.deep.equal(g2Infinity);
        expect(jacobianToAffine(outputs.jac_add_inf_q1)).to.deep.equal(jacobianToAffine(generatorJacFuzzed));
        expect(jacobianToAffine(outputs.jac_add_inf_q2)).to.deep.equal(jacobianToAffine(generatorJacFuzzed));
        expect(outputs.jac_fuzzed_affine).to.deep.equal(generator);
        expect(outputs.jac_inf_affine).to.deep.equal(g2Infinity);
    });

    it("psi maps to curve and differs from generator", async function () {
        await circuit.assertOut(witness, {
            psi_on_curve: 1,
            psi_eq_gen: 0,
        });
    });
});
