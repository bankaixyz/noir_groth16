const path = require("path");
const wasm_tester = require("circom_tester").wasm;
const { expect } = require("chai");

const fp = (arr) => arr.map((v) => BigInt(v));
const fp2 = (a0, a1) => [fp(a0), fp(a1)];
const fp6 = (b0, b1, b2) => [b0, b1, b2];
const fp12 = (c0, c1) => [c0, c1];

const fp2Zero = fp2(["0x0", "0x0", "0x0"], ["0x0", "0x0", "0x0"]);
const fp2One = fp2(["0x1", "0x0", "0x0"], ["0x0", "0x0", "0x0"]);
const fp6Zero = fp6(fp2Zero, fp2Zero, fp2Zero);
const fp6One = fp6(fp2One, fp2Zero, fp2Zero);
const fp12One = fp12(fp6One, fp6Zero);

const fixtureA = fp12(
    fp6(
        fp2(
            ["0x52be749e51c8b8b3b5c86f9b40e41", "0x9012f00314e3994a44f526d28ec9b6", "0x1da3"],
            ["0x504f88248d15e2f4e74178a3b46c2", "0xe46df0668292bf362565dadeb633f4", "0x1771"]
        ),
        fp2(
            ["0x41fcfc078a9f50e28b5ff67dc31b2b", "0x34c87faa5ebcb8529dafd7a96adfbf", "0x190c"],
            ["0x982c399c33000927f343cbf2d1769c", "0xa432c056de7612bc4c136e184dce79", "0xc19"]
        ),
        fp2(
            ["0xd45ddd7f18f8e1518598d86166c194", "0x6c3f1fbde86150dadd11ae22362438", "0x70d"],
            ["0x569a119f42993a672560d94037673d", "0xf3338422c8ebf7204b71b5ab3b2be2", "0x1d45"]
        )
    ),
    fp6(
        fp2(
            ["0xec658c728e28d8c1791ee3658eae0", "0xa57adcf4569cbcd6223a4266176a8a", "0x2a69"],
            ["0x179b3f82b7193c212e4049501cbadc", "0x8f550f548860509e32a36b9e712afd", "0x414"]
        ),
        fp2(
            ["0xe67d98e9b222b5a7211d3ebb5c882b", "0x5a1f7018bbadbcc54e3e8de636fff0", "0x15c"],
            ["0x530f8f7d9bb9703c5dd92bf59b13d", "0x4f84761108f826542c423796e0a676", "0x27b7"]
        ),
        fp2(
            ["0xd9f9590a5dec7a32f53e625565f2e2", "0x1eca807cb31ec964c2891dc4ba4982", "0x82d"],
            ["0x21a25679c55158d1a0d741715403cb", "0x518beba94e851f3c797bb62ffcdd13", "0x106e"]
        )
    )
);

const fixtureB = fp12(
    fp6(
        fp2(
            ["0x84a3045dbbbbe73c01a659dce5f6a1", "0xbd294029245e4a44da27ba53d822a0", "0x130c"],
            ["0xe17e5dd9811497a796b49c708296", "0xa50eb0cd31c68f4e18a6cf9c397cd7", "0x11cf"]
        ),
        fp2(
            ["0x9efde40338ca532183c519cc2f767b", "0xa6cc3d10c332cfcb688ef0cba33943", "0x2959"],
            ["0x14406bfb0dbf1905ac7c136df1b78", "0xe111b1637fb4b8622df556b9acfda", "0x278d"]
        ),
        fp2(
            ["0xda242c3412548aa010f2fcb1cf641c", "0xb04def761c7387e3da482a297c1344", "0xd62"],
            ["0xb6261f9bccdd7263858a80f491c42f", "0x903534ddb6ea621db63264794311e2", "0x5ea"]
        )
    ),
    fp6(
        fp2(
            ["0xbf83f8f5a11fbba0f1a8bc02cc144e", "0x513b30ec71309984bb4bf16304359f", "0x159"],
            ["0x259c0448047f83c3f88276ebc7e7bb", "0xc93f1dc3afa76cae896d57f542ace8", "0x1e64"]
        ),
        fp2(
            ["0x3172ecb7d642ddc45576c0bd4e61b", "0x3de2fc782387c0ad16090f80967a7b", "0x1627"],
            ["0xce7d90376f45e31c5978ec9dcf0965", "0x2ab436a9ce54b60108f370d9d5405d", "0xb2e"]
        ),
        fp2(
            ["0xef2336c9a0a47da324a0d6e16e1a0d", "0x8c80d1f31ca088198f4a23a71fab5", "0x2054"],
            ["0x7c4db76e44d5727492ebd7b95fff01", "0xe6abcbcedb7abbfff1b4b255833f65", "0x1171"]
        )
    )
);

const fixtureAPlusB = fp12(
    fp6(
        fp2(
            ["0x8645a3f2f0de58b1c76c9fe1d079b", "0xfec94efa99182b3ed9665fa50e8ebf", "0x4b"],
            ["0x5e676e0225272c6f60acc26abc958", "0x897ca133b4594e843e0caa7aefb0cb", "0x2941"]
        ),
        fp2(
            ["0x5f904ea2519f16c7ee98f97175945f", "0x8d21db8981c5cfcdc08846f3b5bb6b", "0x1201"],
            ["0x1805aef372116d7c2d7f76513394cd", "0x63d0fa3b7647a5f2293c42029040bc", "0x342"]
        ),
        fp2(
            ["0xae8209b32b4d6bf1968bd5133625b0", "0x1c8d0f3404d4d8beb759d84bb2377d", "0x1470"],
            ["0xcc0313b0f76accaaaeb5a34c92b6c", "0x8368b9007fd6593e01a41a247e3dc5", "0x2330"]
        )
    ),
    fp6(
        fp2(
            ["0xce4a51bcca02492d093aaa3924ff2e", "0xf6b60de0c7cd565add8633c91ba029", "0x2bc2"],
            ["0x3d3743cabb98bfe526c2c03be4a297", "0x58942d183807bd4cbc10c393b3d7e5", "0x2279"]
        ),
        fp2(
            ["0xe994c7b52f86e3836674aac7316e46", "0x98026c90df357d7264479d66cd7a6b", "0x1783"],
            ["0x5243f7c6d736ece3feca6884abbd5b", "0x2bc5cb8937232404ef7f26ef5d893c", "0x281"]
        ),
        fp2(
            ["0xc91c8fd3fe90f7d619df3936d40cef", "0x27928d9be4e8d1e65b7dbfff2c4438", "0x2881"],
            ["0x9df00de80a26cb4633c3192ab402cc", "0x3837b77829ffdb3c6b306885801c78", "0x21e0"]
        )
    )
);

const fixtureAMinusB = fp12(
    fp6(
        fp2(
            ["0x8088e2ec2960a44f39b62d1cce17a0", "0xd2e9afd9f0854f056acd6c7eb6a715", "0xa96"],
            ["0x4237a246f504997a6dd62edcac42c", "0x3f5f3f9950cc2fe80cbf0b427cb71d", "0x5a2"]
        ),
        fp2(
            ["0x2469a96cc39f8afd2826f38a10a1f7", "0xdc6f23cb3bb3a0d77ad7685f200413", "0x2016"],
            ["0x1852c444f3eea4d3b90821946f586b", "0xe494867246a47f866eea9a2e0b5c37", "0x14f0"]
        ),
        fp2(
            ["0x7ba442b3786ee3ed9531f288145abf", "0xa6411796c1781474880057a126e8b", "0x2a0f"],
            ["0xa073f20375bbc8039fd6584ba5a30e", "0x62fe4f4512019502953f5131f819ff", "0x175b"]
        )
    ),
    fp6(
        fp2(
            ["0x4f425fd187c2d1eb25e932338cd692", "0x543fac07e56c235166ee51031334ea", "0x2910"],
            ["0x7369cca3246445995649e93cd1d068", "0x1488d2c278e29c3feeec952a86dbac", "0x1614"]
        ),
        fp2(
            ["0x64d0fb86a6891506fc51e988049f57", "0x6aaf54d2384fb4687debffe6f8e30d", "0x1b99"],
            ["0x36b368c06a75b3e76c64a6218aa7d8", "0x24d03f673aa37053234ec6bd0b6618", "0x1c89"]
        ),
        fp2(
            ["0x6c40b3a92f1289cbf129a24c74d61c", "0x6475548f217e79336f4afd0ba0ac64", "0x183d"],
            ["0x26bf3073f24673992e778090710211", "0xb953010c13341b8ccd7d855bd1fb45", "0x2f60"]
        )
    )
);

const fixtureAMulB = fp12(
    fp6(
        fp2(
            ["0xe05d54cb4805ffc802ac866316a851", "0x67a9930d3469a30751683065d0d7ea", "0xb40"],
            ["0x32135fb2722c9abd104aefa152de10", "0x3aa1c831ffb46cc6c242bf16d4ab63", "0x20dd"]
        ),
        fp2(
            ["0xe8801f0f07e1e18f7c1a235120f205", "0x22daebb0a0c04489e0c4877b297df8", "0x1b02"],
            ["0xb65b5e7750b1c207b2507392764135", "0x1ed7e5cc533c45b4d97e1c45651fae", "0x27e3"]
        ),
        fp2(
            ["0x5c770124c32dab1eb8e928f3fe0d16", "0x1bdd68f1bfd9143976a2747f9b77e9", "0x3ae"],
            ["0x9a419dc77c2167a3d5c140b1ecf1f6", "0xf1225b864e3b305c9baab6035777ed", "0xd84"]
        )
    ),
    fp6(
        fp2(
            ["0xa5e626401ba5f827cbbbd913f5a854", "0xe6d6f87113f514e70d89f773efcb93", "0x259d"],
            ["0x612e6bdda822e9af1757ee2088b04b", "0xed91f8ec37ac9f75e8b5d8caf96f58", "0x486"]
        ),
        fp2(
            ["0xb1970a1fe3d6bd85e4cdda45973b7f", "0xa67162ffa6a333093cc542900a484d", "0x1570"],
            ["0x128b6e24760f5e9116d373b591bbb6", "0xa0345086a70f34ace3974577ce9279", "0x2bc0"]
        ),
        fp2(
            ["0xbfce37289b240c5cb61d3861457ecd", "0x8f0619e404072422ea8b831267352e", "0x28ab"],
            ["0x73e2089461fc5330b01341fed3297", "0x390b59ac1d7321c8b1b530f0509e0b", "0x2b15"]
        )
    )
);

const fixtureASquared = fp12(
    fp6(
        fp2(
            ["0x3d335d926a63b582cd11ad073b4f39", "0x43ed8084ae4997232d130b7c103386", "0x1ad4"],
            ["0xebb4fa287b154ddd3cb9b9767ebcf", "0xfecb0fab70dfb0bbdd7230a66930c", "0xa06"]
        ),
        fp2(
            ["0x170f5b3c6b6ae63c4379ad50e9d3da", "0xc2606e98426c56c5e4ef94a2b4b803", "0x10f8"],
            ["0xabf8d7359489c07f82157a9d5276ab", "0x6949c40feaf465a03796fb0c06084c", "0x2b04"]
        ),
        fp2(
            ["0xdf55ef585f19d334fb0b55f7713776", "0x7b282a1eabfe2ba76fda6620813d4c", "0x1868"],
            ["0x6f6291c01492247ccb7cf9b901372b", "0x25efc143d975bc6f2849e77e24c222", "0x2233"]
        )
    ),
    fp6(
        fp2(
            ["0x4644e5933e8f2bd1857892da2af82", "0x913366f1a3a5c2bb71ee0fe2a25a06", "0x27d2"],
            ["0x60f89d3ce96d364c6a646c78ccad89", "0x6324a7c3a41976ed63ce8238d3e1d9", "0xe70"]
        ),
        fp2(
            ["0xea3db0bb49409684a007933c11138e", "0x637338cc8ffaaf23665f56b968456b", "0x26f9"],
            ["0x302611d3d7fac8d29525185ae0fbea", "0x2d88b4e5a5334eda128c1640a4d5b9", "0x171f"]
        ),
        fp2(
            ["0x67b5fc1205e7b0bd1689c491eec23", "0xd744cd1911ca695b9074f29ce21f1e", "0x27c0"],
            ["0xa4eca3507c70c89468b85ce933e90a", "0x96a48db5ca50264e1cd2142cdbb3c2", "0x2cb9"]
        )
    )
);

const fixtureAInverse = fp12(
    fp6(
        fp2(
            ["0x2a8f962cd5d6d12fdc8ba0efb9fc7f", "0xc93ee8e2b844a0fd8b0c0c48d3fa27", "0x130a"],
            ["0xa610ae78f79bbb8305bc57d74e7733", "0xc7cc3426ddd45cf292455eb0a5903a", "0x108b"]
        ),
        fp2(
            ["0xa4af21a85011cfff36d30d19e07481", "0xe344e2fa872a8d710fcdfa51e76da4", "0xf89"],
            ["0x3567bb93020539f2a0810a497ead0d", "0x7e34abefd90892062bb9f01c0a6ca3", "0x32a"]
        ),
        fp2(
            ["0xc8c9bfd993d5fb99f44e1fbee9a11d", "0x142166d660ca42d71b67e2b209fcd9", "0x489"],
            ["0xd3b265ab47aa48305eff3e0057ad24", "0x2a556d8a30cc3d3243a6e9b93e76cf", "0x2958"]
        )
    ),
    fp6(
        fp2(
            ["0xaa28ef649cd4b8fe9af1c7a3b663aa", "0x3f86cebaac3fafadb12fc6113c77ff", "0x1260"],
            ["0x9af30ec7d4e93f967c218b40206889", "0xa5b245e750955d6b639a6d29832555", "0xa9b"]
        ),
        fp2(
            ["0xefa275ae65a5ac8ecf3ff43661d487", "0x26fcd6a11548ade08eec83362d7524", "0x2671"],
            ["0xc46a7c6a1a34f511a888e2ed367a3a", "0xd575aba978a651a3c03b3b042a0835", "0x1515"]
        ),
        fp2(
            ["0xf05df4ae927ba40821792336c2c4a0", "0xb9bf4f0eb503e91b60f6ba54efa2f5", "0x26e3"],
            ["0x79af9cab098af6f867f8652f46bf57", "0x146741a9aad340b5dc5e95152cea2e", "0xca4"]
        )
    )
);

const fixtureAConjugate = fp12(
    fp6(
        fp2(
            ["0x52be749e51c8b8b3b5c86f9b40e41", "0x9012f00314e3994a44f526d28ec9b6", "0x1da3"],
            ["0x504f88248d15e2f4e74178a3b46c2", "0xe46df0668292bf362565dadeb633f4", "0x1771"]
        ),
        fp2(
            ["0x41fcfc078a9f50e28b5ff67dc31b2b", "0x34c87faa5ebcb8529dafd7a96adfbf", "0x190c"],
            ["0x982c399c33000927f343cbf2d1769c", "0xa432c056de7612bc4c136e184dce79", "0xc19"]
        ),
        fp2(
            ["0xd45ddd7f18f8e1518598d86166c194", "0x6c3f1fbde86150dadd11ae22362438", "0x70d"],
            ["0x569a119f42993a672560d94037673d", "0xf3338422c8ebf7204b71b5ab3b2be2", "0x1d45"]
        )
    ),
    fp6(
        fp2(
            ["0x72a438a148e7ffb008fa28a2241267", "0xa8f8043d498cfb7a237c3f1b40f30d", "0x5fa"],
            ["0x69cf51e5bab1511af24bcd8860426b", "0xbf1dd1dd17c967b2131315e2e7329a", "0x2c4f"]
        ),
        fp2(
            ["0x9aecf87ebfa7d794ff6ed81d20751c", "0xf4537118e47bfb8af777f39b215da6", "0x2f07"],
            ["0x7c399870980ef6385aae8419234c0a", "0xfeee6b20973191fc197449ea77b721", "0x8ac"]
        ),
        fp2(
            ["0xa771385e13de13092b4db483170a65", "0x2fa860b4ed0aeeeb832d63bc9e1414", "0x2837"],
            ["0x5fc83aeeac79346a7fb4d56728f97c", "0xfce6f58851a49913cc3acb515b8084", "0x1ff5"]
        )
    )
);

const fixtureADoubled = fp12(
    fp6(
        fp2(
            ["0x88ed3d2b586e89da562cf71aeb1f3b", "0xd1b2fed4899d7a444433cc23c535d4", "0xae2"],
            ["0xa09f10491a2bc5e9ce82f14768d84", "0xc8dbe0cd05257e6c4acbb5bd6c67e8", "0x2ee3"]
        ),
        fp2(
            ["0x28f66a6a3741488f633d62309390f", "0x1b1e1e231d4fb854f5a92dd17d61e7", "0x1b4"],
            ["0x305873386600124fe68797e5a2ed38", "0x486580adbcec25789826dc309b9cf3", "0x1833"]
        ),
        fp2(
            ["0xa8bbbafe31f1c2a30b31b0c2cd8328", "0xd87e3f7bd0c2a1b5ba235c446c4871", "0xe1a"],
            ["0x2bc991d61367e7922a359ba7f1d133", "0x97f42713f1ae35f0512ce9d51dfa2d", "0xa27"]
        )
    ),
    fp6(
        fp2(
            ["0x9c222025dffa8ddc0e97c59434d879", "0xfc82d8b70d0fc15bfebe034ad6777c", "0x246e"],
            ["0x2f367f056e3278425c8092a03975b8", "0x1eaa1ea910c0a13c6546d73ce255fa", "0x829"]
        ),
        fp2(
            ["0xccfb31d364456b4e423a7d76b91056", "0xb43ee031775b798a9c7d1bcc6dffe1", "0x2b8"],
            ["0x88f7608741aca0cb6b2f0ea6366533", "0x50960af071c6945812cdedac68ef54", "0x1f0a"]
        ),
        fp2(
            ["0xb3f2b214bbd8f465ea7cc4aacbe5c4", "0x3d9500f9663d92c985123b89749305", "0x105a"],
            ["0x4344acf38aa2b1a341ae82e2a80796", "0xa317d7529d0a3e78f2f76c5ff9ba26", "0x20dc"]
        )
    )
);

const fixtureAFrobenius = fp12(
    fp6(
        fp2(
            ["0x52be749e51c8b8b3b5c86f9b40e41", "0x9012f00314e3994a44f526d28ec9b6", "0x1da3"],
            ["0x7c6598e628f92f0cd217ff4e41b685", "0x6a04f0cb1d96f91a2050a6a2a229a3", "0x18f2"]
        ),
        fp2(
            ["0xd061e019885706877c08e695697483", "0xca974c75ed68d6aa23ee19f9009393", "0x14e6"],
            ["0xaab3d9c8ba1fa388d0c3e0fcd00085", "0x567c02a91eaefc88f21530c7b325f0", "0x21ef"]
        ),
        fp2(
            ["0x386c04c24fd3cfacc12cc27ea02740", "0x6e99158eaddc0e241eb3ceef5ab0de", "0x2812"],
            ["0x55ee4833bf8885e6b668bf13d3f64b", "0xbfc8a682516b8c9ef21ba1dd84165d", "0x7f9"]
        )
    ),
    fp6(
        fp2(
            ["0xf4ef10993c4cb32cfc22d1ede91ad2", "0x953be03b7d2b0f5e20a62b1b4b42d7", "0x2703"],
            ["0xae1674f0aed7c05811e85d9b0bc61e", "0xae5715188a0c2ad3acf901557c4fe9", "0x2169"]
        ),
        fp2(
            ["0x8e16863a3d551394c576831d49a12f", "0x235adc08eb6afe1dfb7588ec5176b1", "0x2e85"],
            ["0x295ffcdf8bfa3037feca9497174c1c", "0x9f85d0745b29a8e2149b9daf1e985f", "0x16ce"]
        ),
        fp2(
            ["0x39173b0c78ff8d8d7a4261e9563fec", "0xc8904a864d74ff7ef1d86b4f017590", "0x76a"],
            ["0xd045f502770507c28a8fc73bca74ff", "0x2cd586f84c9daec294c88c056abda6", "0x21e4"]
        )
    )
);

const fixtureAFrobeniusSquare = fp12(
    fp6(
        fp2(
            ["0x52be749e51c8b8b3b5c86f9b40e41", "0x9012f00314e3994a44f526d28ec9b6", "0x1da3"],
            ["0x504f88248d15e2f4e74178a3b46c2", "0xe46df0668292bf362565dadeb633f4", "0x1771"]
        ),
        fp2(
            ["0x93be0768a83357fd29f8018ef78587", "0x9038487ec1f2a10dd884c65190348a", "0x172b"],
            ["0xb3d2bc21f7ea1fb479ffcebc4ea776", "0xf95232cb2b46aaddea58444f76c620", "0x948"]
        ),
        fp2(
            ["0xf7ca6b01fe81428b9048fe1d8fa691", "0xaf77d973656d861076f41503cb60e4", "0x1a44"],
            ["0x126ee80cc7a04f788a0e2eb8a1c534", "0xc267f35a8dde2ea591bd2c17564298", "0xe64"]
        )
    ),
    fp6(
        fp2(
            ["0xbae8844f2f9b6100713aff7b90573e", "0x78a5f64795b9d25972d71e9926f6e8", "0x1dd3"],
            ["0x9394ac217983a655ad8a3f2850ada6", "0xb34756ab51875f2535cea52e7feed8", "0x231e"]
        ),
        fp2(
            ["0x9aecf87ebfa7d794ff6ed81d20751c", "0xf4537118e47bfb8af777f39b215da6", "0x2f07"],
            ["0x7c399870980ef6385aae8419234c0a", "0xfeee6b20973191fc197449ea77b721", "0x8ac"]
        ),
        fp2(
            ["0x265d6ebe731f4719f5bc3a98e1e28", "0xeb1775e514321e0bd08da1772f5e71", "0x2130"],
            ["0x73228437a1a6d36368e136d768d97b", "0x7af8a0274c031b6b92a904b2757398", "0x129b"]
        )
    )
);

const fixtureAFrobeniusCube = fp12(
    fp6(
        fp2(
            ["0x52be749e51c8b8b3b5c86f9b40e41", "0x9012f00314e3994a44f526d28ec9b6", "0x1da3"],
            ["0x7c6598e628f92f0cd217ff4e41b685", "0x6a04f0cb1d96f91a2050a6a2a229a3", "0x18f2"]
        ),
        fp2(
            ["0xe6fd981c07a0bc04efbaa8725197fb", "0x5c85f13fc04dde11b355e6026feab3", "0x2f22"],
            ["0xf5d406329a378991bdde8d536c688", "0x1a0fd88b5bc5e6942f3095b6dc1e79", "0x2541"]
        ),
        fp2(
            ["0xae5949d455f6d6e4576f4afa670eac", "0x48a25451aa57c83688ef427fc14f8f", "0x621"],
            ["0xe0ade6f1925fd7ea9ed6caebb9f530", "0x5d26fb94c49236d7a8875f17011311", "0x1d11"]
        )
    ),
    fp6(
        fp2(
            ["0x3179d8dffee75011e6e8c17b1c312b", "0x55aaedde2c49bd2734a47bc92b331b", "0x2fdc"],
            ["0x621adf8a72fec4650dfa70953d154e", "0x19565be259dc05b086332740e156b1", "0x1c45"]
        ),
        fp2(
            ["0xf3540b2e347579a75b1593bb335c18", "0x2b180528b4beba324a40f89506e6e5", "0x1df"],
            ["0x580a9488e5d05d0421c1824165b12b", "0xaeed10bd45000f6e311ae3d239c538", "0x1995"]
        ),
        fp2(
            ["0xf991e04246d8d985732e9f17f684ae", "0x8c11b9f5d19852c697185fb0c6c121", "0x1ad0"],
            ["0x5c1e7ab1010a8984bf06f193429d3", "0x5327ca53befd53be5fa51a9101d2b6", "0x1406"]
        )
    )
);

const fixtureCyclotomicElement = fp12(
    fp6(
        fp2(
            ["0x8917821319602b91e1aeb00c4348cb", "0x41112080857313b150bdf608625e1a", "0x311"],
            ["0x249de6db409c4205fcebb920c8ccdb", "0x619990eec784bb80ed0e4e60520fb9", "0xc60"]
        ),
        fp2(
            ["0xb1e40e5c31ed7ac272bd9b66d0b815", "0xe617f66fc2672699a8b96c3f5efe44", "0x29b8"],
            ["0x4aa452560f7058f7b164759bf5b8f6", "0x4b4ec7e7b293c3c4992ef183cd5807", "0x1757"]
        ),
        fp2(
            ["0x371667be317ae31b2f951b282c9032", "0xb031edeee4fa66660c7ecc9f80b99e", "0x4ed"],
            ["0x65a422354f69667c80c299e4b812a2", "0xf8df9deb0b8898f11a0f1b796e296c", "0x1e34"]
        )
    ),
    fp6(
        fp2(
            ["0x1ec75a24f77360ee04468260d012b5", "0xfa04a576d7f4fc0b979fa7cd9b303", "0x8e8"],
            ["0x55f3569a6aaf0e21826b89cdab4e50", "0x1fb62c8e3ad46148aa657d1be5ea9f", "0xb75"]
        ),
        fp2(
            ["0x85a838e60c248bb6d4fce0212a2081", "0x9ff5782a986c3df099ee08e9dd3bb3", "0x1142"],
            ["0xdd0231431375203694434b916338e1", "0xdd3d6e150049d214cdf6f2f7dc4ca0", "0x6a7"]
        ),
        fp2(
            ["0x93d97c5e76703715879c7b3b4af451", "0xe53cd19abdaa3088e9d4d4c7e66cec", "0x20bc"],
            ["0x52100c3c27464b6d7f9b5874a90073", "0xcc1a90af9ebe7eedf57445748f8998", "0x1833"]
        )
    )
);

const fixtureCyclotomicSquared = fp12(
    fp6(
        fp2(
            ["0x182de82e0ddae40e02cab7a7acf774", "0xea70296829bb866ec6ddc3b238bc25", "0x23cd"],
            ["0x71cf5abeb8071bc3e3929c74974136", "0x6dafdafe7b824e0a436b80be5a10e4", "0x87f"]
        ),
        fp2(
            ["0xc110c9c7a11364510aebd37f19f270", "0x56102825e5e112b7d1fbc1695fbfa0", "0x1804"],
            ["0xaf6eac350e8107a18fda3ad79a1345", "0x51482ae7f249f7db41bb00a20e0aae", "0x1602"]
        ),
        fp2(
            ["0x561ffd63955c7fb117754b1b790f53", "0x262d1f2313f4bb67d3585f71f1a9e", "0x1871"],
            ["0xa425a86be04add35be8ccba0dc5c54", "0x929e20ecdf6eae73a8eb59862ac33c", "0x1397"]
        )
    ),
    fp6(
        fp2(
            ["0x1ec00e165323a44f65345336c2b06b", "0x346211f7cdf90b0e16556c01db6573", "0x259b"],
            ["0x9d6f0dde0f6db41696668db72ea57", "0x7051523100fd79fbff358093fa44d5", "0xafc"]
        ),
        fp2(
            ["0x3e5e64b64181f862e0bef026c5367e", "0xce8e569fae2ce7537341dc7fce95c8", "0x210"],
            ["0xf6c2f0af8ccd963658b2170ef26e3e", "0x2386845458e889ffb21d442fd415ce", "0x11c9"]
        ),
        fp2(
            ["0xad55a89db9290f812858ff0fb1760f", "0xd33b0b8ebfe2f4ad86f8babd6652bf", "0x1d7b"],
            ["0x1ae686023f7ca108c22302ad2cfb2", "0x6b0c5f35d6885c52e13344041f58cf", "0x543"]
        )
    )
);

const fixtureSparseD0 = fp2(
    ["0xe816f2acdb2624b67746e5e1478ecb", "0x3a4aa00b5df006208b35738b34b65f", "0xa59"],
    ["0x4c50d3587ded53bd76de9ac2abd8e3", "0xd42e05dfa7821b8c1b562b91a2c0ef", "0x891"]
);
const fixtureSparseD3 = fp2(
    ["0x2e2a3f01f62df9cbddd01e8a066615", "0x790abbf630502e697902d004eef18e", "0x14bd"],
    ["0x45e40f50fec699b22a3a4ef143a30a", "0xae670e5aa05553d945f55b234b4963", "0xdcd"]
);
const fixtureSparseD4 = fp2(
    ["0x2a9ff015410dce297a4229fc001d6e", "0x10fc68e7ef37f53161093a7485b4a", "0x630"],
    ["0x6f1c395c576f415a0d09d8d9ca4bb5", "0xf450fb778f0b80117c12ecaf5f841c", "0x21d5"]
);

const fixtureAMulBy034 = fp12(
    fp6(
        fp2(
            ["0x956b5c90fe404419fad8558374158a", "0x6c8ac8c370b9eabbe5ceadbc907277", "0xf4e"],
            ["0x6831720f6941c88988292f8dae204e", "0x76cfd646e8cf30134b8e3052b3e87c", "0x2933"]
        ),
        fp2(
            ["0xb679da55e03c5e7697894a78779aa5", "0x99a0742608e2e242301b0651207863", "0x1ca7"],
            ["0x34d112a8c7ddd550c682c5169122e3", "0x5767545d82edc5620d57c55856d59", "0x11de"]
        ),
        fp2(
            ["0xf7ed076d0e49361654562304d30797", "0xc332ad1495eff5039454b1a0e42f22", "0x129b"],
            ["0x6ed2bbdeb819a9f0fb369a8d6772f2", "0xd1a829c6b8b33d93ab41a2336acce3", "0x2020"]
        )
    ),
    fp6(
        fp2(
            ["0xd33e3e636f58fcf44793414a5a7ea9", "0x88bfe7691265d642fa65b206afe827", "0x11e9"],
            ["0x7f8a49a06a8b73a12a0e2acdc1b74", "0x2fe8325bc072f1bba84e40e98d8287", "0x601"]
        ),
        fp2(
            ["0x903d8a774a54cbefe192fc8ecf0d81", "0xaba4efbe1326957d7fd731e1da5495", "0x157e"],
            ["0xdb1bcc6c196e8d1690378e170afc4", "0x475822d3e823c94f5340bfe413f13b", "0x232e"]
        ),
        fp2(
            ["0x1dd37aee7b2791804bab44baac06fd", "0xef684056358727c2c9fc9a109bd397", "0x1160"],
            ["0x784efb2fc9dc19ce5eefe88d2586cd", "0x8da291b801dd96c0c5c147decef699", "0x843"]
        )
    )
);

describe("Fp12 operations", function () {
    this.timeout(120000);
    let circuit;
    let witnessAB;
    let witnessAA;
    let witnessConj;

    before(async function () {
        circuit = await wasm_tester(
            path.join(__dirname, "../circuits/test/fp12_ops.circom")
        );
        const inputAB = {
            a: fixtureA,
            b: fixtureB,
            inv: fixtureAInverse,
            cyclo: fixtureCyclotomicElement,
            d0: fixtureSparseD0,
            d3: fixtureSparseD3,
            d4: fixtureSparseD4,
        };
        witnessAB = await circuit.calculateWitness(inputAB, true);

        const inputAA = {
            a: fixtureA,
            b: fixtureA,
            inv: fixtureAInverse,
            cyclo: fixtureCyclotomicElement,
            d0: fixtureSparseD0,
            d3: fixtureSparseD3,
            d4: fixtureSparseD4,
        };
        witnessAA = await circuit.calculateWitness(inputAA, true);

        const inputConj = {
            a: fixtureA,
            b: fixtureAConjugate,
            inv: fixtureAInverse,
            cyclo: fixtureCyclotomicElement,
            d0: fixtureSparseD0,
            d3: fixtureSparseD3,
            d4: fixtureSparseD4,
        };
        witnessConj = await circuit.calculateWitness(inputConj, true);
    });

    it("adds and subtracts fixtures", async function () {
        await circuit.assertOut(witnessAB, {
            add: fixtureAPlusB,
            sub: fixtureAMinusB,
        });
    });

    it("mul/inverse fixtures are consistent", async function () {
        await circuit.assertOut(witnessAB, {
            mul_inv: fp12One,
            inv_inverse: fixtureA,
            inv_a: fixtureAInverse,
        });
    });

    it("multiplies and squares fixtures", async function () {
        await circuit.assertOut(witnessAB, { mul: fixtureAMulB, square: fixtureASquared });
    });

    it("square equals mul(a, a)", async function () {
        const outputs = await circuit.getOutput(witnessAA, {
            mul: [2, [3, [2, [3, 1]]]],
            square: [2, [3, [2, [3, 1]]]],
        });
        expect(outputs.mul).to.deep.equal(outputs.square);
    });

    it("conjugate properties match", async function () {
        await circuit.assertOut(witnessAB, { conjugate: fixtureAConjugate });
        const outputs = await circuit.getOutput(witnessConj, {
            add: [2, [3, [2, [3, 1]]]],
        });
        expect(outputs.add[1]).to.deep.equal(fp6Zero);
    });

    it("double fixture matches", async function () {
        await circuit.assertOut(witnessAB, { double: fixtureADoubled });
    });

    it("frobenius fixtures match", async function () {
        await circuit.assertOut(witnessAB, {
            frob: fixtureAFrobenius,
            frob_square: fixtureAFrobeniusSquare,
            frob_cube: fixtureAFrobeniusCube,
        });
    });

    it("cyclotomic square fixture matches", async function () {
        await circuit.assertOut(witnessAB, { cyclotomic_square: fixtureCyclotomicSquared });
    });

    it("mul_by_034 fixture matches", async function () {
        await circuit.assertOut(witnessAB, { mul_by_034: fixtureAMulBy034 });
    });
});
