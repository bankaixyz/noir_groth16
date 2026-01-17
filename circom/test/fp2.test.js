const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const { expect } = require("chai");
const { fpInv, limbsToBigInt, mod } = require("./field");

const fp = (arr) => limbsToBigInt(arr.map((v) => BigInt(v)));
const fp2 = (a0, a1) => [fp(a0), fp(a1)];
const fpNeg = (value) => mod(-value);
const fp2Neg = (value) => [fpNeg(value[0]), fpNeg(value[1])];

const fpZero = 0n;
const fp2One = [1n, 0n];

const fixtureA = fp2(
    ["0x8fb963ec9acdeb921e94bec973154e", "0xb05e7ef12a97ed0b7deacb789da82e", "0x1672"],
    ["0x1d557c31a563f1a88397bffd5f9464", "0x5fa03764ea6a871224878ea00c1bd6", "0x168c"]
);
const fixtureB = fp2(
    ["0xc819fe8c2f7ec1e183c5de4c76cab4", "0x2f3df37748c8ec29f577c0f81391", "0x658"],
    ["0xf95fa7d75eeaa5c437d5e7a822db0e", "0x84d68a7e740995d33d66ff4e33b59e", "0x2123"]
);
const fixtureAPlusB = fp2(
    ["0x57d36278ca4cad73a25a9d15e9e002", "0xb08dbce4a1e0b5f7a7e0433995bbc0", "0x1cca"],
    ["0x954a92a092840a309ae190cd05722b", "0x9603e0b1be4a64951c380c6ce773dd", "0x74b"]
);
const fixtureAMinusB = fp2(
    ["0xc79f65606b4f29b09acee07cfc4a9a", "0xb02f40fdb34f241f53f553b7a5949c", "0x101a"],
    ["0xa56065c2b843d9206c4def2db9b69d", "0x293c8e18168aa98f2cd710d330c3ce", "0x25cd"]
);
const fixtureAMulB = fp2(
    ["0xb7d9af6ee9ad0db2f53808f68e9680", "0x54733ccc4262cb6728d948286934ae", "0xfc8"],
    ["0x2cf6c898b15ae6e65f2f632ab744f6", "0x2c400b41bb9e868fba9b251dbf6c67", "0x2ad"]
);
const fixtureASquared = fp2(
    ["0x3654d6f2a1a71187851897ff18aae8", "0x58749ec4d124030b21de49809b4236", "0x301f"],
    ["0x1d694ea25bdfc5d7a315fb9a762763", "0x1536e6efb2039a32ecbbcb000ab238", "0x163d"]
);
const fixtureAInverse = fp2(
    ["0x8a243c36e3da37b7fe8c95b2f8d88f", "0x41f27e85c9e524a276536b8716b0e1", "0x338"],
    ["0xa5e13e64c7092959ecc7c70195063f", "0x16d17bc691c20ecb48676cb53e8417", "0x27a3"]
);
const fixtureANegInverse = fp2Neg(fixtureAInverse);
const fixtureANegated = fp2(
    ["0xf1b12d7bd6fca1aa01f7580f09e7f9", "0x9e1462407591cb44c7cbb608bab568", "0x19f1"],
    ["0x64151536cc669b939cf456db1d68e3", "0xeed2a9ccb5bf313e212ef2e14c41c1", "0x19d7"]
);
const fixtureADoubled = fp2(
    ["0x1f72c7d9359bd7243d297d92e62a9c", "0x60bcfde2552fda16fbd596f13b505d", "0x2ce5"],
    ["0x3aaaf8634ac7e351072f7ffabf28c8", "0xbf406ec9d4d50e24490f1d401837ac", "0x2d18"]
);
const fixtureAConjugate = fp2(
    ["0x8fb963ec9acdeb921e94bec973154e", "0xb05e7ef12a97ed0b7deacb789da82e", "0x1672"],
    ["0x64151536cc669b939cf456db1d68e3", "0xeed2a9ccb5bf313e212ef2e14c41c1", "0x19d7"]
);
const fixtureAMulByNonResidue = fp2(
    ["0x6bef52e67679aec62dfeb08e353385", "0xe8599b80b46fa5647796141975b506", "0x224e"],
    ["0x92107c09a427358e3cba234fdb57b6", "0xd334ecb6e7afcb6dafd4c913a92c57", "0x1fd0"]
);

describe("Fp2 operations", function () {
    this.timeout(60000);
    let circuit;
    let witnessAB;
    let witnessAA;
    let witnessNeg;

    before(async function () {
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/test/fp2_ops.circom")
        );
        const inputAB = {
            a: fixtureA,
            b: fixtureB,
            inv: fixtureAInverse,
            inv_elem_hint: fpInv(fixtureA[0]),
        };
        witnessAB = await circuit.calculateWitness(inputAB, true);

        const inputAA = {
            a: fixtureA,
            b: fixtureA,
            inv: fixtureAInverse,
            inv_elem_hint: fpInv(fixtureA[0]),
        };
        witnessAA = await circuit.calculateWitness(inputAA, true);

        const inputNeg = {
            a: fixtureANegated,
            b: fixtureB,
            inv: fixtureANegInverse,
            inv_elem_hint: fpInv(fixtureANegated[0]),
        };
        witnessNeg = await circuit.calculateWitness(inputNeg, true);
    });

    it("adds and subtracts fixtures", async function () {
        await circuit.assertOut(witnessAB, {
            add: fixtureAPlusB,
            sub: fixtureAMinusB,
        });
    });

    it("multiplies and squares fixtures", async function () {
        await circuit.assertOut(witnessAB, { mul: fixtureAMulB });
        await circuit.assertOut(witnessAB, { square: fixtureASquared });
    });

    it("square equals mul(a, a)", async function () {
        const outputs = await circuit.getOutput(witnessAA, {
            mul: [2, 1],
            square: [2, 1],
        });
        expect(outputs.mul).to.deep.equal(outputs.square);
    });

    it("inverse fixtures are consistent", async function () {
        await circuit.assertOut(witnessAB, {
            inv_a: fixtureAInverse,
            mul_inv: fp2One,
            inv_inverse: fixtureA,
        });
    });

    it("negation and doubling fixtures are consistent", async function () {
        await circuit.assertOut(witnessAB, { neg: fixtureANegated, double: fixtureADoubled });
        await circuit.assertOut(witnessNeg, { neg: fixtureA });
    });

    it("mul_by_non_residue fixture matches", async function () {
        await circuit.assertOut(witnessAB, { mul_by_non_residue: fixtureAMulByNonResidue });
    });

    it("mul_by_element round-trips", async function () {
        await circuit.assertOut(witnessAB, { mul_by_element_chain: fixtureA });
    });

    it("conjugate properties match", async function () {
        await circuit.assertOut(witnessAB, { conjugate: fixtureAConjugate });
        const outputs = await circuit.getOutput(witnessAB, {
            sum_conj: [2, 1],
            diff_conj: [2, 1],
        });
        expect(outputs.sum_conj[1]).to.deep.equal(fpZero);
        expect(outputs.diff_conj[0]).to.deep.equal(fpZero);
    });
});
