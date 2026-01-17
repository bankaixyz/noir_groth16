const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const { expect } = require("chai");
const { fp2Inv } = require("./field");

const fp = (arr) => arr.map((v) => BigInt(v));
const fp2 = (a0, a1) => [fp(a0), fp(a1)];
const fp6 = (b0, b1, b2) => [b0, b1, b2];

const fpZero = fp(["0x0", "0x0", "0x0"]);
const fp2Zero = fp2(["0x0", "0x0", "0x0"], ["0x0", "0x0", "0x0"]);
const fp2One = fp2(["0x1", "0x0", "0x0"], ["0x0", "0x0", "0x0"]);
const fp6One = fp6(fp2One, fp2Zero, fp2Zero);

const fixtureA = fp6(
    fp2(
        ["0xf6d12224380d148557d9fa87e8dd33", "0xc6be37ba553f2961099dab6c60c658", "0x293a"],
        ["0x44018f3ab94785b1c18539c2c800cf", "0xc9dbeb7b7672bc9dbb8fa318856c53", "0xd93"]
    ),
    fp2(
        ["0x4dc584675dbc5b92237da232d9271e", "0x4ac8482b805993eff0916900f565b8", "0x387"],
        ["0xecdf8c452fc7f46c32ec5aa264e3af", "0xc8fce7c114ee9b895e35ce6e46b8b2", "0x876"]
    ),
    fp2(
        ["0x8f7c1d14b796cf82d26d33f8aefef1", "0xa8135fb1ed4b9edbc927197abc6550", "0x10c5"],
        ["0xb75b3501d4c202042434b5f723a079", "0xaf9b1555603099d74e3da088380cd9", "0x256e"]
    )
);
const fixtureB = fp6(
    fp2(
        ["0x31d5a433ec3a65229ac76e08e8e362", "0xc9cbd0f5a284e2e05f9e86a8186fdb", "0x164a"],
        ["0x3c9cdeede8002828d0ecb61f10ecd9", "0xf25302e3050ca89143abaaa822a0e2", "0x2644"]
    ),
    fp2(
        ["0x672e166195732de2e6cad83344daaa", "0x91de36e3b1d72a97ca135ce6b14ff0", "0x2ae3"],
        ["0x1c176b5c327e202798dfe5404a5f3a", "0x4fa16fb359968b2efc32fef52a836", "0x229b"]
    ),
    fp2(
        ["0x9a0cd4cf95a3ce96888e54562ff28e", "0xbf821d02e4f0a36704de924ebd74e9", "0x1511"],
        ["0x3b23bc1e7d2e5f91cc3f76b6406ab7", "0x6193963db69357c84a95d6a625e2f2", "0xfcf"]
    )
);
const fixtureAPlusB = fp6(
    fp2(
        ["0xa73c34efb27cec6bd21551b854c34e", "0x4217277e579a53f12385b09320d89c", "0xf21"],
        ["0xff33dcc02f7d209e71e5d9095bf061", "0x6dbc0d2cdb55acdeb984cc3f4faf9d", "0x374"]
    ),
    fp2(
        ["0xb4f39ac8f32f89750a487a661e01c8", "0xdca67f0f3230be87baa4c5e7a6b5a8", "0x2e6a"],
        ["0x8f6f7a162461493cbcc3fe2af42e9", "0xcdf6febc4a88043c4df8fe5d9960e9", "0x2b11"]
    ),
    fp2(
        ["0x2988f1e44d3a9e195afb884edef17f", "0x67957cb4d23c4242ce05abc979da3a", "0x25d7"],
        ["0x71145fb7e025d459cfe815d4e70de9", "0xc2bbca61769a394f531cf5ad059234", "0x4d9"]
    )
);
const fixtureAMinusB = fp6(
    fp2(
        ["0xc4fb7df04bd2af62bd128c7efff9d1", "0xfcf266c4b2ba4680a9ff24c448567d", "0x12ef"],
        ["0x88cf41b54311eac511249a7c34113d", "0x25fbc9ca118fcc5cbd9a79f1bb2908", "0x17b3"]
    ),
    fp2(
        ["0x6801ff6e3a13baeb5d3ee0d81149bb", "0x75cf2796eac21a86c348d9b9c735f", "0x908"],
        ["0x5232b2516f146180ba988c3a9781bc", "0x1275b1f77f7eeb26b42920004c6e14", "0x1640"]
    ),
    fp2(
        ["0x76d9d9ad93bd8e286a6af67afc09aa", "0x370423e0a884b3c509ff08ad574dfe", "0x2c18"],
        ["0x7c3778e35793a27257f53f40e335c2", "0x4e077f17a99d420f03a7c9e21229e7", "0x159f"]
    )
);
const fixtureAMulB = fp6(
    fp2(
        ["0x65461139b385890b0a0e0546d846e1", "0x7fed50f1af0a8aea4754d5c8565c1e", "0x494"],
        ["0xe3ea59ce3923c3d7c6a29520394d13", "0xa1d0d96ccfc0897699f6dbdd653872", "0x15a5"]
    ),
    fp2(
        ["0xfac86b2ad937248d10a87780812e00", "0xf311bac40b4b1ee1c13172e0427792", "0x1ddc"],
        ["0x8f927fc166df0f3ab8c03c6f53bb0", "0xfae069d006f9fa373b59cf3254b440", "0xe85"]
    ),
    fp2(
        ["0x8445c8593f176e7e69f186a8bdd16a", "0x296e7baf9fad31d3a1451fd8bd97b0", "0x2618"],
        ["0xa8601c123ba1269832a079ab8e2eff", "0xc65775fccac432851c0bcb615aec48", "0xad7"]
    )
);
const fixtureASquared = fp6(
    fp2(
        ["0x815ca2706b17ae0b4fc2c817a230be", "0x24c6883bd742d61b042151c44b82b1", "0xb89"],
        ["0xdccaa5e4e26d35a70649e225c5fca7", "0x4b504cd1516c440bd812e3f85927f9", "0x199a"]
    ),
    fp2(
        ["0xcac28683e963b2fddb3b431daa0e04", "0x38c26686a1f42db6f2864c0c8b821c", "0x2504"],
        ["0xaa9048740b3969688bdb335b1920fb", "0xdf343ab84f6c29d80f2272e2f4323f", "0x552"]
    ),
    fp2(
        ["0x8acfaf6278867a136343f3f73faa9a", "0x761f36287b3ce7182de1374529ad27", "0xbfe"],
        ["0x4bfa9945a9c21fd5ae5c84acaf03ad", "0x219fa8ec5b4fdd121ce4a868776a88", "0x26b3"]
    )
);
const fixtureAInverse = fp6(
    fp2(
        ["0xe7346af700c2f204548385e21c097b", "0xd3ca0687fbaed935deea9993403e39", "0x2ad0"],
        ["0xb23ffd9d6af448b97dc9dbc17a2dc", "0xe2176812dd59c4460187a9f62b60cd", "0x1b7f"]
    ),
    fp2(
        ["0x5847ff073f0fae103be465701b74d4", "0x4ab6014be05cc1b4954ca9ceede01b", "0x5e5"],
        ["0x23eaf7ab8232caa57dab616667f0f2", "0x2008cba1367a3556d9b07db7bdfde7", "0xb22"]
    ),
    fp2(
        ["0x5bf713d411a4d5c870f0164c72dfac", "0x9a3a7d251fc3d3b859ea136532611c", "0x1fc7"],
        ["0x93881802b1169bbe326991f4e9bd58", "0xa08c23dff5d1071b535403f48d9eea", "0x149f"]
    )
);
const fixtureANegated = fp6(
    fp2(
        ["0x8a996f4439bd78b6c8b21c50942014", "0x87b4a9774aea8eef3c18d614f7973e", "0x729"],
        ["0x3d69022db883078a5f06dd15b4fc78", "0x8496f5b629b6fbb28a26de68d2f144", "0x22d0"]
    ),
    fp2(
        ["0x33a50d01140e31a9fd0e74a5a3d629", "0x3aa99061fd024605525188062f7df", "0x2cdd"],
        ["0x948b0523420298cfed9fbc36181998", "0x8575f9708b3b1cc6e780b31311a4e4", "0x27ed"]
    ),
    fp2(
        ["0xf1ee7453ba33bdb94e1ee2dfcdfe56", "0xa65f817fb2de19747c8f68069bf846", "0x1f9e"],
        ["0xca0f5c669d088b37fc5760e1595cce", "0x9ed7cbdc3ff91e78f778e0f92050bd", "0xaf5"]
    )
);
const fixtureADoubled = fp6(
    fp2(
        ["0x6c37b2dffe4f9bce8f27de3754bd1f", "0x3f098e430a549a71cd84d557692f1a", "0x2211"],
        ["0x88031e75728f0b63830a738590019e", "0x93b7d6f6ece5793b771f46310ad8a6", "0x1b27"]
    ),
    fp2(
        ["0x9b8b08cebb78b72446fb4465b24e3c", "0x9590905700b327dfe122d201eacb70", "0x70e"],
        ["0xd9bf188a5f8fe8d865d8b544c9c75e", "0x91f9cf8229dd3712bc6b9cdc8d7165", "0x10ed"]
    ),
    fp2(
        ["0x1ef83a296f2d9f05a4da67f15dfde2", "0x5026bf63da973db7924e32f578caa1", "0x218b"],
        ["0xed4bd89b37b976cc27dd5515ca43ab", "0x10c3497920377b5e56c4bf8f17bc1b", "0x1a79"]
    )
);
const fixtureAMulByNonResidue = fp6(
    fp2(
        ["0x512cade7bbf62f1d0089f016095b72", "0x9c2d8588b7248b4238b541c5b6c7cc", "0x10bb"],
        ["0x77c7004a15df05033472f9bd84b641", "0xaf62f756eddcfd3ba15433bb4a49d3", "0xeeb"]
    ),
    fp2(
        ["0xf6d12224380d148557d9fa87e8dd33", "0xc6be37ba553f2961099dab6c60c658", "0x293a"],
        ["0x44018f3ab94785b1c18539c2c800cf", "0xc9dbeb7b7672bc9dbb8fa318856c53", "0xd93"]
    ),
    fp2(
        ["0x4dc584675dbc5b92237da232d9271e", "0x4ac8482b805993eff0916900f565b8", "0x387"],
        ["0xecdf8c452fc7f46c32ec5aa264e3af", "0xc8fce7c114ee9b895e35ce6e46b8b2", "0x876"]
    )
);
const fixtureSparseC0 = fp2(
    ["0xa1f4e347126975aecc1ed1a1dbe83d", "0x62166cfda650097340e6472b0208f5", "0x2d9d"],
    ["0xe352eabd48965d35eb97de369c5878", "0x713a87c10b3d23ef926a941459c426", "0x84b"]
);
const fixtureSparseC1 = fp2(
    ["0x81a9b18a41534b4f4422755fa4f85", "0x27e308acf8a1f7df99fb2c08c84f70", "0x19bc"],
    ["0xf3dbf8efb3dc6943c09d1b5980afde", "0x6b40f8a1788f529e3f9c498e1021eb", "0x1036"]
);
const fixtureAMulBy01 = fp6(
    fp2(
        ["0x870270b763390168463577c693411c", "0x17bb70eb3bffece66e7dd7fa71c963", "0x19b4"],
        ["0x7d088d4a36787c1088011263c1d7a1", "0x623b69a7ce6439727e3c6ee91bde66", "0x1002"]
    ),
    fp2(
        ["0x855d5dd955b6e1f40cda8b13e6f814", "0x5d3e32572a2f6359ac8bfaa3687792", "0x1c14"],
        ["0x729e221acd3d1a66e937f2793a02b1", "0xfa4246ccf91011cbdcc85b365d71fe", "0x3c4"]
    ),
    fp2(
        ["0xaf6914e514be6b56ebed28df77ebc6", "0xc01bc584046c78216f8aa85583e3bf", "0xc99"],
        ["0x31c8b87cdf5d56360f65fe8eb44432", "0x1f22a31ee6f5947202c1b2fb1584c0", "0xb1a"]
    )
);

describe("Fp6 operations", function () {
    this.timeout(60000);
    let circuit;
    let witnessAB;
    let witnessAA;
    let witnessNeg;

    before(async function () {
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/test/fp6_ops.circom")
        );
        const inputAB = {
            a: fixtureA,
            b: fixtureB,
            inv: fixtureAInverse,
            c0: fixtureSparseC0,
            c1: fixtureSparseC1,
            c0_inv_hint: fp2Inv(fixtureSparseC0),
        };
        witnessAB = await circuit.calculateWitness(inputAB, true);

        const inputAA = {
            a: fixtureA,
            b: fixtureA,
            inv: fixtureAInverse,
            c0: fixtureSparseC0,
            c1: fixtureSparseC1,
            c0_inv_hint: fp2Inv(fixtureSparseC0),
        };
        witnessAA = await circuit.calculateWitness(inputAA, true);

        const inputNeg = {
            a: fixtureANegated,
            b: fixtureB,
            inv: fixtureAInverse,
            c0: fixtureSparseC0,
            c1: fixtureSparseC1,
            c0_inv_hint: fp2Inv(fixtureSparseC0),
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
            mul: [3, [2, [3, 1]]],
            square: [3, [2, [3, 1]]],
        });
        expect(outputs.mul).to.deep.equal(outputs.square);
    });

    it("inverse fixtures are consistent", async function () {
        await circuit.assertOut(witnessAB, {
            inv_a: fixtureAInverse,
            mul_inv: fp6One,
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

    it("mul_by_e2 inverse round-trips", async function () {
        await circuit.assertOut(witnessAB, { mul_by_e2_chain: fixtureA });
    });

    it("mul_by_01 fixture matches", async function () {
        await circuit.assertOut(witnessAB, { mul_by_01: fixtureAMulBy01 });
    });

    it("mul_by_1 matches sparse mul", async function () {
        const outputs = await circuit.getOutput(witnessAB, {
            mul_by_1: [3, [2, [3, 1]]],
            mul_sparse: [3, [2, [3, 1]]],
        });
        expect(outputs.mul_by_1).to.deep.equal(outputs.mul_sparse);
    });
});
