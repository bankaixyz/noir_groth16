use crate::fp::Fp;
use crate::fp2::{Fp2, fp2_zero};
use crate::fp6::Fp6;
use crate::fp12::Fp12;
use crate::g1::G1Affine;
use crate::g2::{
    G2Affine,
    LineEvaluation,
    LineEvalAtP,
    LineScheduleSp1,
    frobenius_g2,
    frobenius_square_g2,
    neg_g2_affine,
    projective_from_affine_g2,
};
use crate::pairing::{miller_loop, miller_loop_with_lines_sp1, pairing, pairing_multi};
use bignum::BigNum;

fn fp_from_limbs(l0: u128, l1: u128, l2: u128) -> Fp {
    Fp::from_limbs([l0, l1, l2])
}

fn fp2_from_limbs(a0: [u128; 3], a1: [u128; 3]) -> Fp2 {
    Fp2 { c0: fp_from_limbs(a0[0], a0[1], a0[2]), c1: fp_from_limbs(a1[0], a1[1], a1[2]) }
}

fn fp6_from(b0: Fp2, b1: Fp2, b2: Fp2) -> Fp6 {
    Fp6 { b0, b1, b2 }
}

fn fp12_from(c0: Fp6, c1: Fp6) -> Fp12 {
    Fp12 { c0, c1 }
}

fn fp2_eq(a: Fp2, b: Fp2) -> bool {
    let c0 = a.c0 == b.c0;
    let c1 = a.c1 == b.c1;
    c0 & c1
}

fn fp12_eq(a: Fp12, b: Fp12) -> bool {
    let c0 = fp2_eq(a.c0.b0, b.c0.b0);
    let c1 = fp2_eq(a.c0.b1, b.c0.b1);
    let c2 = fp2_eq(a.c0.b2, b.c0.b2);
    let c3 = fp2_eq(a.c1.b0, b.c1.b0);
    let c4 = fp2_eq(a.c1.b1, b.c1.b1);
    let c5 = fp2_eq(a.c1.b2, b.c1.b2);
    c0 & c1 & c2 & c3 & c4 & c5
}

fn zero_line_eval() -> LineEvalAtP {
    let z = fp2_zero();
    LineEvalAtP { r0: z, r1: z, r2: z }
}

fn line_eval_at_point(line: LineEvaluation, p: G1Affine) -> LineEvalAtP {
    LineEvalAtP {
        r0: line.r0.mul_by_element(p.y),
        r1: line.r1.mul_by_element(p.x),
        r2: line.r2,
    }
}

fn sp1_loop_digits() -> [i8; 66] {
    [
        0, 0, 0, 1, 0, 1, 0, -1, 0, 0, -1, 0, 0, 0, 1, 0,
        0, -1, 0, -1, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, -1, 0,
        0, 1, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, -1,
        0, 1, 0, -1, 0, 0, 0, -1, 0, -1, 0, 0, 0, 1, 0, -1,
        0, 1,
    ]
}

fn build_line_schedule_sp1(p_list: [G1Affine; 3], q_list: [G2Affine; 3]) -> LineScheduleSp1 {
    let mut q_proj = [projective_from_affine_g2(q_list[0]); 3];
    let mut q_neg = [neg_g2_affine(q_list[0]); 3];
    for i in 0..3 {
        q_proj[i] = projective_from_affine_g2(q_list[i]);
        q_neg[i] = neg_g2_affine(q_list[i]);
    }

    let mut initial_doubles = [zero_line_eval(); 3];
    for i in 0..3 {
        let (qk, line) = q_proj[i].double_step();
        q_proj[i] = qk;
        initial_doubles[i] = line_eval_at_point(line, p_list[i]);
    }

    let mut pre_loop_lines = [zero_line_eval(); 3];
    let mut pre_loop_adds = [zero_line_eval(); 3];
    for i in 0..3 {
        let (qk, line) = q_proj[i].line_compute(q_neg[i]);
        q_proj[i] = qk;
        pre_loop_lines[i] = line_eval_at_point(line, p_list[i]);
        let (qk, line) = q_proj[i].add_mixed_step(q_list[i]);
        q_proj[i] = qk;
        pre_loop_adds[i] = line_eval_at_point(line, p_list[i]);
    }

    let mut loop_doubles = [[zero_line_eval(); 3]; 63];
    let mut loop_adds_pos = [[zero_line_eval(); 3]; 63];
    let mut loop_adds_neg = [[zero_line_eval(); 3]; 63];

    let digits = sp1_loop_digits();
    for idx in 0..63 {
        let digit = digits[62 - idx];
        for i in 0..3 {
            let (qk, line) = q_proj[i].double_step();
            q_proj[i] = qk;
            loop_doubles[idx][i] = line_eval_at_point(line, p_list[i]);

            if digit == 1i8 {
                let (qk, line_add) = q_proj[i].add_mixed_step(q_list[i]);
                q_proj[i] = qk;
                loop_adds_pos[idx][i] = line_eval_at_point(line_add, p_list[i]);
            } else if digit == -1i8 {
                let (qk, line_add) = q_proj[i].add_mixed_step(q_neg[i]);
                q_proj[i] = qk;
                loop_adds_neg[idx][i] = line_eval_at_point(line_add, p_list[i]);
            }
        }
    }

    let mut final_adds = [zero_line_eval(); 3];
    let mut final_lines = [zero_line_eval(); 3];
    for i in 0..3 {
        let q1 = frobenius_g2(q_list[i]);
        let q2 = frobenius_square_g2(q_list[i]);
        let (qk, line_add) = q_proj[i].add_mixed_step(q1);
        q_proj[i] = qk;
        final_adds[i] = line_eval_at_point(line_add, p_list[i]);
        let (qk, line) = q_proj[i].line_compute(q2);
        q_proj[i] = qk;
        final_lines[i] = line_eval_at_point(line, p_list[i]);
    }

    LineScheduleSp1 {
        initial_doubles,
        pre_loop_lines,
        pre_loop_adds,
        loop_doubles,
        loop_adds_pos,
        loop_adds_neg,
        final_adds,
        final_lines,
    }
}

fn g1_vector_single_generators() -> G1Affine {
    G1Affine { x: fp_from_limbs(0x1, 0x0, 0x0), y: fp_from_limbs(0x2, 0x0, 0x0) }
}

fn g2_vector_single_generators() -> G2Affine {
    G2Affine {
        x: fp2_from_limbs(
            [0x4322d4f75edadd46debd5cd992f6ed, 0xdeef121f1e76426a00665e5c447967, 0x1800],
            [0xaa493335a9e71297e485b7aef312c2, 0x9393920d483a7260bfb731fb5d25f1, 0x198e],
        ),
        y: fp2_from_limbs(
            [0xd1e7690c43d37b4ce6cc0166fa7daa, 0x5ea5db8c6deb4aab71808dcb408fe3, 0x12c8],
            [0x4b313370b38ef355acdadcd122975b, 0x89d0585ff075ec9e99ad690c3395bc, 0x906],
        ),
    }
}

fn g1_vector_single_2g1_g2() -> G1Affine {
    G1Affine {
        x: fp_from_limbs(0x7816a916871ca8d3c208c16d87cfd3, 0x44e72e131a029b85045b68181585d9, 0x306),
        y: fp_from_limbs(0xa6a449e3538fc7ff3ebf7a5a18a2c4, 0x738c0e0a7c92e7845f96b2ae9c0a68, 0x15ed),
    }
}


fn g2_vector_single_3g2() -> G2Affine {
    G2Affine {
        x: fp2_from_limbs(
            [0x7e478cb09a5e0012defa0694fbc7f5, 0x4e784db10e9051e52826e192715e8d, 0x606],
            [0x4156b6878a0a7c9824f32ffb66e85, 0x772f57bb9742735191cd5dcfe4ebbc, 0x1014],
        ),
        y: fp2_from_limbs(
            [0xb920d74521e79765036d57666c5597, 0x1d5681b5b9e0074b0f9c8d2c68a069, 0x58e],
            [0x9453ac49b55441452aeaca147711b2, 0x2335f3354bb7922ffcc2f38d3323dd, 0x21e],
        ),
    }
}

fn expected_miller_loop_g1_g2() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0x8b8434a96f775cd2ea6fbf7d1de6fc, 0xce0988952737c7f3406a2aca6de60f, 0xdcb],
        [0x49146e410326ded265c56d03f0fe9b, 0x9668206b49f92a48b8f202006d8db, 0x589],
    );
    let c0_b1 = fp2_from_limbs(
        [0xd485c7be55827bab3892a0ab26c948, 0xd94f083b27955ba1ab5f1a8d9c1a10, 0x28f0],
        [0x8612f7bb8db8f4fe819f27af88b811, 0x95199dba7a89b741d33317700024cd, 0x157c],
    );
    let c0_b2 = fp2_from_limbs(
        [0xbe39e74ee3c6ebfb88fa1ce44837d4, 0x17cf7e1eef31e332e03d40761f8bf3, 0x2d5b],
        [0x6ab4175009cf99191a3e5e5e6e65d5, 0xa8334192684a51a009e93db7238a2, 0xf66],
    );
    let c1_b0 = fp2_from_limbs(
        [0xf1cdd5bb12113208c5606889d06c8f, 0x2c1570d84d3b274ab68e7bdb866ac6, 0x18bf],
        [0xf9a69f27d21dac07ff00c3c8f617cd, 0x3d2e4e1b5b860c5a584c8e64f26660, 0x119f],
    );
    let c1_b1 = fp2_from_limbs(
        [0xea5fa11ac5279c5ddff21eed23ac4f, 0x1537226892f3f27b18930ff99b59a3, 0xcca],
        [0x40a06b7dc66d5e7dc64baaa475274b, 0xdd8c8524f697fd19f8d157f829d935, 0x20c0],
    );
    let c1_b2 = fp2_from_limbs(
        [0x11b3dddfb65884e6c0ff5b57c5c448, 0x187276058befac0c129781f60e748f, 0x2458],
        [0xef318415303900331ef0d2e7c80ac1, 0x17d4f8dc98a169510fb5bccade38fc, 0x2dec],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}

fn expected_miller_loop_2g1_g2() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0xc48ceb87e94e284e8e0b11a1f2a750, 0xf2a48a5f198703aa3a42779a4c61a0, 0x230e],
        [0xf85f304bc5d5f5edd46a355dba1b7d, 0x6c107d6d6d30bcb73d8dfab7030581, 0x15d5],
    );
    let c0_b1 = fp2_from_limbs(
        [0xa8edb34f803756877c0082ed9b2562, 0xf7fd305acd95ee541a34f66b3bb6c0, 0xd38],
        [0xa069a3a159600e8edb4ded92bb0a4c, 0x3b5204efe772c4930976935946e6fb, 0x2bc8],
    );
    let c0_b2 = fp2_from_limbs(
        [0x1a1c83926df25a7e568afff43a738b, 0xf17bee6b265dc2cb97c3e34971442e, 0x12f6],
        [0x7bdd7c39b40959f34d96958254233a, 0x6da1b1c19c4e46031edca1ce431dbb, 0x1e71],
    );
    let c1_b0 = fp2_from_limbs(
        [0xf988166d4337dacc782ab109ed7cf3, 0xa7ba5ddfdb886dc9f164c4ec2464d6, 0x1a11],
        [0x878dc3f5f90bccc2abf06669ffcb2a, 0xe305258bf1ef19912ef6d72b6b547e, 0x1b4e],
    );
    let c1_b1 = fp2_from_limbs(
        [0xe941d807b8ad9ab52963042bedaf28, 0x79fea69d28a32d34338a5b1c419d8e, 0x20f6],
        [0x7bca791c8064d850566e80413ce3d2, 0xc368f0d14a90ec0945e66ce24debe7, 0x1dd3],
    );
    let c1_b2 = fp2_from_limbs(
        [0xe65a116e77e3fdba66fa6e1850a1e1, 0xb6bf133f82cf635a7161c2c91e6ab4, 0x86f],
        [0x35ad6b69d68cdee18e4efe6b0ed7f0, 0xc9f5813a1bded4e09b4ad3d7f0a41b, 0xd8b],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}


fn expected_miller_loop_multi_2_pairs() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0x834351749130a29c412bc5bc75729c, 0x3bf54dc4a2e3ec1d91d90d5e721dc5, 0x1ab9],
        [0xc28091b6d6fa563f819a3d8fc92a42, 0xd8f7f45553b84c025ff72df9b7382a, 0xf9d],
    );
    let c0_b1 = fp2_from_limbs(
        [0xe932f91cef84aaeb684a2bea6488ed, 0xb17afd86ce4d61f9964d6337375a21, 0x1d45],
        [0xe5da8b03373b4fa73d3d15ceecb01a, 0x14963e088d936391441f7dad590dd, 0x1380],
    );
    let c0_b2 = fp2_from_limbs(
        [0xaf4409966a9cd04eb17c5a23687613, 0x7783471dd2a8d4c087a08dd48ae940, 0x214d],
        [0xa3136c2a5e8a26390a2cf28aa94b58, 0x4b9e9c86f0f8e60ba6fe1d0103c61a, 0x2c6b],
    );
    let c1_b0 = fp2_from_limbs(
        [0x14d09e5f3f08077d0e36e53f4db890, 0x958ff680cfdf938c2e7b40254ef630, 0x21eb],
        [0xdd164d6df60832c43779cd663ef45e, 0xd9270a07cad72df584b7bc60904727, 0x1028],
    );
    let c1_b1 = fp2_from_limbs(
        [0xdd4457a17369b4e3ee362315a8ba20, 0x713bfce2f48207d2f0ba8f781a8367, 0x1a80],
        [0x13b6683ec5cfb17426fe8875b61ed3, 0x80b39b38fab4c1dc33e81ca1e37781, 0x1794],
    );
    let c1_b2 = fp2_from_limbs(
        [0x5e2dbcef867c8e2e3252f4c50f137f, 0x10e12eb4c39982277bbaf139ba4dc9, 0x2817],
        [0x7b0b844b2d6394f63098943ddbe710, 0x7a3e508120f687a06d4785a712de00, 0x6e9],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}


fn expected_pairing_g1_g2() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0x7e5feb898578b55e1f63739d870e95, 0x253feda94cfe0da01bde280a3ed6f8, 0x262b],
        [0x7c4dea0918ed66b49d34b48efb8a4a, 0x2d2cc795a2000a1b1f823879abbd39, 0x2e0],
    );
    let c0_b1 = fp2_from_limbs(
        [0xd2957387ecb1fc4e135402fdbd1de0, 0xf2d6e29b128da5b1ad44b31977935f, 0x13a9],
        [0xb420bd699ce630b130b08a6ea1162b, 0xa9fa500f1a5c4b31984a74e68659c4, 0x40b],
    );
    let c0_b2 = fp2_from_limbs(
        [0x8f590b211ce30bf5e3eeaef89eafdb, 0x2f3fd870678fbe359d7f9873f05247, 0xafc],
        [0xa9a712cc5a8243f9cddbd2d98dd1f0, 0xa530398c9064bdc662d929e645cadd, 0x1c54],
    );
    let c1_b0 = fp2_from_limbs(
        [0xa990ecfd4b7aef5c0d58c5dc2429fe, 0xfbf5d5a1ac023794a0d856f92591b, 0x95c],
        [0xad9ebb590cb4a60f8215d4b99f2b4a, 0xd6ca72d8a950a31dc10f7b4053c9e9, 0x14d3],
    );
    let c1_b1 = fp2_from_limbs(
        [0xdc1a23043c585fdfaf545838ca7429, 0xe7bbc3d70e6689dc206b4b91c85759, 0x1dc0],
        [0xb90d61ac16cc1b7ab2cd3ed5e22b97, 0x320e5a6488cb98a855ffc837d2a75a, 0xb53],
    );
    let c1_b2 = fp2_from_limbs(
        [0xce07bac42a9c0f9bd7fddaf5ebd723, 0xafd3085dae4c6c91476ef36cd1d318, 0x13a8],
        [0xeee1b343940c383e5314859e762c97, 0x7b5221474526b601f3730a3afa965c, 0xf9],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}

fn expected_pairing_2g1_g2() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0xa22e45ed1493e5bc0a8fe1f729706c, 0xa2f59e28b738bcc03f4bf98397b7f1, 0x1169],
        [0x16deaf40367798d1e722f4cd2f8f5a, 0x14f9c0ae52c3a9e608ab8805ac85f9, 0x717],
    );
    let c0_b1 = fp2_from_limbs(
        [0xb2f8e484008e1913e95645aee21720, 0x3920a1fb10b90bb11b2564432f50f4, 0x1348],
        [0x9b859ca7245b67df3928ea83caa41e, 0x3aac7806c96c0a93a2cd8b2422c1db, 0x18],
    );
    let c0_b2 = fp2_from_limbs(
        [0x2bcf2078a9a3045239bebb0fb115d6, 0xf218919b4354f9893ec017c2ea747c, 0x16f1],
        [0x35d6aaab39b3eff5999f1e59393924, 0xee5d937044ca302f2b521a46c967d1, 0xf55],
    );
    let c1_b0 = fp2_from_limbs(
        [0x383b5629649025227ac3fad1883949, 0x10999b90e85c67a5f490085eb5493f, 0x179],
        [0x58c7b4a28fefc552a7c59da6cac5b7, 0xa10a405b40a15dc4838249728590a5, 0x15cf],
    );
    let c1_b1 = fp2_from_limbs(
        [0xac0f9e7430b7010227f81883851af3, 0xc22b19a80d4886d1eec286049da1bd, 0x498],
        [0xcc139b2c762a94d1094a90fd32f9c, 0xec7ea0669846457044046d90b93f55, 0x1b55],
    );
    let c1_b2 = fp2_from_limbs(
        [0x7b5c918a6366be657162727f683a82, 0x665a6ddcb3555c729e72d917800b26, 0x4ad],
        [0xf35c869412f8f6365ff589dc19d146, 0x11f71f828edd604643a804acedc91c, 0x227d],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}

fn expected_pairing_multi_2_pairs() -> Fp12 {
    let c0_b0 = fp2_from_limbs(
        [0x72ac3e27fb2581561b643475583a53, 0xb3a2b74938dd5cf9fba7e349a783c, 0x2f78],
        [0x62fc5001c6b6338a4be00262bf1bd6, 0x8addb6dbd01f03799a74c99acb71a0, 0x2b1f],
    );
    let c0_b1 = fp2_from_limbs(
        [0x78f8aae0b224d1d38ff5bd50b41ecf, 0xd1b53005bfa44511635130af961ed1, 0x89d],
        [0x7b7f5826285b5259900b5315d5e2bf, 0xa8b7ab22771c41841ee9d0bf46f1f1, 0x18c4],
    );
    let c0_b2 = fp2_from_limbs(
        [0x363b3b293ffbe49691eb460160bb2, 0xfdd65979fd5bd85bab3533df0448e7, 0x131],
        [0x14f8b74d54c3a6c909b81e686fbfd0, 0xb52a8ae06a6120e9310addfbc4e544, 0x1ef5],
    );
    let c1_b0 = fp2_from_limbs(
        [0x8304d7a3fde82195b2c706494c06bf, 0xe7d05ff51692e05aa855d4f56e9a0a, 0xa4d],
        [0x9d4c18104902088f2150ba81ad83af, 0xba1ac6416c5579c71219f5282ab4da, 0x72d],
    );
    let c1_b1 = fp2_from_limbs(
        [0xbf05816f7c966938aa1610b02fc5c, 0x94a6fdb8a067f85c722969d89b3644, 0x13a7],
        [0x8717d5dfee72f9a1be9cf1eb90274a, 0xd5ebed13d50bff30f69508d8983f68, 0x17a2],
    );
    let c1_b2 = fp2_from_limbs(
        [0x3725017c7af41cd48b176918230ec0, 0x4274b9fb6d0678a510533e3526399a, 0x248],
        [0x46dc31409c8b9d7f8d33f6b4a842b9, 0xa1b59823649ba6ec03f58fc5593a16, 0x2b21],
    );
    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))
}

#[test]
fn miller_loop_single_generators_vectors_matches() {
    let p = g1_vector_single_generators();
    let q = g2_vector_single_generators();
    let result = miller_loop([p], [q]);
    let expected = expected_miller_loop_g1_g2();
    assert(fp12_eq(result, expected));
}

#[test]
fn miller_loop_single_2g1_g2_vectors_matches() {
    let p = g1_vector_single_2g1_g2();
    let q = g2_vector_single_generators();
    let result = miller_loop([p], [q]);
    let expected = expected_miller_loop_2g1_g2();
    assert(fp12_eq(result, expected));
}


#[test]
fn miller_loop_multi_2_pairs_vectors_matches() {
    let p0 = g1_vector_single_generators();
    let p1 = g1_vector_single_2g1_g2();
    let q0 = g2_vector_single_generators();
    let q1 = g2_vector_single_3g2();
    let result = miller_loop([p0, p1], [q0, q1]);
    let expected = expected_miller_loop_multi_2_pairs();
    assert(fp12_eq(result, expected));
}


#[test]
fn pairing_single_generators_vectors_matches() {
    let p = g1_vector_single_generators();
    let q = g2_vector_single_generators();
    let result = pairing(p, q);
    let expected = expected_pairing_g1_g2();
    assert(fp12_eq(result, expected));
}

#[test]
fn pairing_single_2g1_g2_vectors_matches() {
    let p = g1_vector_single_2g1_g2();
    let q = g2_vector_single_generators();
    let result = pairing(p, q);
    let expected = expected_pairing_2g1_g2();
    assert(fp12_eq(result, expected));
}

#[test]
fn pairing_multi_2_pairs_vectors_matches() {
    let p0 = g1_vector_single_generators();
    let p1 = g1_vector_single_2g1_g2();
    let q0 = g2_vector_single_generators();
    let q1 = g2_vector_single_3g2();
    let result = pairing_multi([p0, p1], [q0, q1]);
    let expected = expected_pairing_multi_2_pairs();
    assert(fp12_eq(result, expected));
}

#[test]
fn miller_loop_with_lines_sp1_matches_miller_loop() {
    let p0 = g1_vector_single_generators();
    let p1 = g1_vector_single_2g1_g2();
    let p2 = g1_vector_single_generators();
    let q0 = g2_vector_single_generators();
    let q1 = g2_vector_single_generators();
    let q2 = g2_vector_single_generators();
    let p_list = [p0, p1, p2];
    let q_list = [q0, q1, q2];
    let lines = build_line_schedule_sp1(p_list, q_list);
    let result = miller_loop(p_list, q_list);
    let result_lines = miller_loop_with_lines_sp1(p_list, lines);
    assert(fp12_eq(result, result_lines));
}
