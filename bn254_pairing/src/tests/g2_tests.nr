use crate::fp::Fp;
use crate::fp2::{Fp2, fp2_one};
use crate::g2::{
    G2Affine, G2Jac, add_g2_jac, double_g2_jac, g2_affine_infinity,
    g2_jacobian_infinity, is_on_curve_g2_affine, jacobian_to_affine_g2,
    is_in_correct_subgroup_g2, psi_g2,
};
use bignum::BigNum;

fn fp_from_limbs(l0: u128, l1: u128, l2: u128) -> Fp {
    Fp::from_limbs([l0, l1, l2])
}

fn fp2_from_limbs(a0: [u128; 3], a1: [u128; 3]) -> Fp2 {
    Fp2 { c0: fp_from_limbs(a0[0], a0[1], a0[2]), c1: fp_from_limbs(a1[0], a1[1], a1[2]) }
}

fn g2_affine(x_a0: [u128; 3], x_a1: [u128; 3], y_a0: [u128; 3], y_a1: [u128; 3]) -> G2Affine {
    G2Affine {
        x: fp2_from_limbs(x_a0, x_a1),
        y: fp2_from_limbs(y_a0, y_a1),
    }
}

fn g2_jac(
    x_a0: [u128; 3],
    x_a1: [u128; 3],
    y_a0: [u128; 3],
    y_a1: [u128; 3],
    z_a0: [u128; 3],
    z_a1: [u128; 3],
) -> G2Jac {
    G2Jac {
        x: fp2_from_limbs(x_a0, x_a1),
        y: fp2_from_limbs(y_a0, y_a1),
        z: fp2_from_limbs(z_a0, z_a1),
    }
}

fn g2_jac_from_affine(a: G2Affine) -> G2Jac {
    if a.is_infinity() {
        g2_jacobian_infinity()
    } else {
        G2Jac { x: a.x, y: a.y, z: fp2_one() }
    }
}

fn fp2_eq(a: Fp2, b: Fp2) -> bool {
    let c0_eq = a.c0 == b.c0;
    let c1_eq = a.c1 == b.c1;
    c0_eq & c1_eq
}

fn assert_fp2_eq(a: Fp2, b: Fp2) {
    assert(fp2_eq(a, b));
}

fn assert_g2_affine_eq(a: G2Affine, b: G2Affine) {
    assert_fp2_eq(a.x, b.x);
    assert_fp2_eq(a.y, b.y);
}

fn generator() -> G2Affine {
    g2_affine(
        [0x4322d4f75edadd46debd5cd992f6ed, 0xdeef121f1e76426a00665e5c447967, 0x1800],
        [0xaa493335a9e71297e485b7aef312c2, 0x9393920d483a7260bfb731fb5d25f1, 0x198e],
        [0xd1e7690c43d37b4ce6cc0166fa7daa, 0x5ea5db8c6deb4aab71808dcb408fe3, 0x12c8],
        [0x4b313370b38ef355acdadcd122975b, 0x89d0585ff075ec9e99ad690c3395bc, 0x906],
    )
}

fn point_a() -> G2Affine {
    g2_affine(
        [0x13ba7204aeca62d66d931b99afe6e7, 0xa8c89a0d090f3d8644ada33a5f1c80, 0x116d],
        [0xd67b1d0e2a530069e3a7306569a91, 0x934ba9615b77b6a49b06fcce83ce9, 0x1274],
        [0xbefc72ac8a6157d30924e58dc4c172, 0x41042e77b6309644b56251f059cf14, 0x764],
        [0x79c18bd22b834ea8c6d07c0ba441db, 0x2d9816e5f86b4a7dedd00d04acc5c9, 0x2522],
    )
}

fn point_b() -> G2Affine {
    g2_affine(
        [0xf6168947698d7905591d550d0996a7, 0x89f73b921870a13c3bcffc688fe7e0, 0x23d0],
        [0x162db0496e99558b2ead49acdbd1ba, 0xefa13f2b80e64ae14f70b423898908, 0x2e0d],
        [0x36a089125b1a3f8df3a8c34dc447aa, 0x4a32636bd0c0d18bff662cd0c235ed, 0x1e27],
        [0x392d759ba9e1e6bb3300eb0f580a68, 0xc76db66c0ad94d6c61471a21887c49, 0x260d],
    )
}

fn point_a_plus_b() -> G2Affine {
    g2_affine(
        [0xcbb06e263c232e39d3be00b9d35951, 0xb7b85a2d4a976f777f99dc549687ff, 0x6f3],
        [0xd4e2b2437533ebf89b0f69845cd306, 0x53859e1cca25f2158e41826ae57672, 0x2f1b],
        [0xf26eb8d41e672888f84c702bd12044, 0x4cf2d5c6d887dd299b6e2d8357d429, 0x953],
        [0x6528b6a70234e839424ae707b263eb, 0xcbb0d0fa75b9ad0e176ecfd9ddb4d2, 0x2987],
    )
}

fn point_a_doubled() -> G2Affine {
    g2_affine(
        [0x8473fc86f3a81756dd0a3e9dc559fd, 0x8796dc8200e078a79a056f6770ffcc, 0x1036],
        [0xce30e6fc24eb998c805468f83a054c, 0xcb54e1ef69fa1f26277210d0796470, 0x2bdc],
        [0x516706967740a78ca26fbea6e05865, 0xbe8d96bfac4b10f1cbefe464c86b64, 0xe42],
        [0xc895cfefa2360f83cbf9a69f52dc94, 0xb7c4ddbe4c1c2b586a1f0541d22b12, 0x1512],
    )
}

fn point_a_negated() -> G2Affine {
    g2_affine(
        [0x13ba7204aeca62d66d931b99afe6e7, 0xa8c89a0d090f3d8644ada33a5f1c80, 0x116d],
        [0xd67b1d0e2a530069e3a7306569a91, 0x934ba9615b77b6a49b06fcce83ce9, 0x1274],
        [0xc26e1ebbe76935691767314ab83bd5, 0xd6eb2b9e9f9220b90542f90fe8e82, 0x2900],
        [0x7a9059646473e9359bb9accd8bb6c, 0x20daca4ba7be6dd257e6747cab97ce, 0xb42],
    )
}

fn infinity() -> G2Affine {
    g2_affine(
        [0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0],
    )
}

fn generator_jacobian() -> G2Jac {
    g2_jac(
        [0x4322d4f75edadd46debd5cd992f6ed, 0xdeef121f1e76426a00665e5c447967, 0x1800],
        [0xaa493335a9e71297e485b7aef312c2, 0x9393920d483a7260bfb731fb5d25f1, 0x198e],
        [0xd1e7690c43d37b4ce6cc0166fa7daa, 0x5ea5db8c6deb4aab71808dcb408fe3, 0x12c8],
        [0x4b313370b38ef355acdadcd122975b, 0x89d0585ff075ec9e99ad690c3395bc, 0x906],
        [0x1, 0x0, 0x0],
        [0x0, 0x0, 0x0],
    )
}

fn generator_jacobian_fuzzed() -> G2Jac {
    g2_jac(
        [0x7fcb31ea84eee86b45850eb11746e4, 0xd9b7aa68ec3304d3829e2ee8f0c5f1, 0x10f3],
        [0x655c79913d9821c5a7c6cbf631cada, 0x5622b877135af8f097287f7b043dc, 0x1e66],
        [0xcea868c27791c52efe24d17aaff0ec, 0x59b9ce8f09f5be963b5104ae20a12d, 0x2c90],
        [0xf9ebec2ed1aa9415df060af9a0775f, 0x246243a4b1da9089d7f5a059cdc083, 0xf92],
        [0x11, 0x0, 0x0],
        [0x0, 0x0, 0x0],
    )
}

fn infinity_jacobian() -> G2Jac {
    g2_jac(
        [0x1, 0x0, 0x0],
        [0x0, 0x0, 0x0],
        [0x1, 0x0, 0x0],
        [0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0],
        [0x0, 0x0, 0x0],
    )
}

#[test]
fn g2_curve_membership_affine() {
    let g = generator();
    assert(is_on_curve_g2_affine(g));

    let bad = G2Affine { x: g.x, y: g.y.double() };
    assert(!is_on_curve_g2_affine(bad));
}

#[test]
fn g2_affine_arithmetic_via_jacobian() {
    let a = point_a();
    let b = point_b();
    let inf = infinity();
    let neg = point_a_negated();

    let sum = add_g2_jac(g2_jac_from_affine(a), g2_jac_from_affine(b));
    assert_g2_affine_eq(jacobian_to_affine_g2(sum), point_a_plus_b());

    let sum_inf = add_g2_jac(g2_jac_from_affine(a), g2_jac_from_affine(inf));
    assert_g2_affine_eq(jacobian_to_affine_g2(sum_inf), a);

    let sum_inf2 = add_g2_jac(g2_jac_from_affine(inf), g2_jac_from_affine(a));
    assert_g2_affine_eq(jacobian_to_affine_g2(sum_inf2), a);

    let sum_neg = add_g2_jac(g2_jac_from_affine(a), g2_jac_from_affine(neg));
    assert_g2_affine_eq(jacobian_to_affine_g2(sum_neg), g2_affine_infinity());

    let dbl = double_g2_jac(g2_jac_from_affine(a));
    assert_g2_affine_eq(jacobian_to_affine_g2(dbl), point_a_doubled());

    let add_self = add_g2_jac(g2_jac_from_affine(a), g2_jac_from_affine(a));
    assert_g2_affine_eq(jacobian_to_affine_g2(add_self), point_a_doubled());
}

#[test]
fn g2_jacobian_arithmetic() {
    let p = generator_jacobian();
    let q = generator_jacobian_fuzzed();
    let inf = infinity_jacobian();

    let sum = add_g2_jac(p, q);
    let dbl = double_g2_jac(q);
    assert_g2_affine_eq(jacobian_to_affine_g2(sum), jacobian_to_affine_g2(dbl));

    let neg_q = G2Jac { x: q.x, y: q.y.neg(), z: q.z };
    let sum_neg = add_g2_jac(q, neg_q);
    assert_g2_affine_eq(jacobian_to_affine_g2(sum_neg), g2_affine_infinity());

    assert_g2_affine_eq(jacobian_to_affine_g2(add_g2_jac(q, inf)), jacobian_to_affine_g2(q));
    assert_g2_affine_eq(jacobian_to_affine_g2(add_g2_jac(inf, q)), jacobian_to_affine_g2(q));
}

#[test]
fn g2_jacobian_affine_conversion() {
    let g = generator();
    let fuzzed = generator_jacobian_fuzzed();
    let inf = g2_jacobian_infinity();

    assert_g2_affine_eq(jacobian_to_affine_g2(fuzzed), g);
    assert_g2_affine_eq(jacobian_to_affine_g2(inf), g2_affine_infinity());

    let from_affine = g2_jac_from_affine(g);
    assert_fp2_eq(from_affine.z, fp2_one());
    assert_fp2_eq(from_affine.x, g.x);
    assert_fp2_eq(from_affine.y, g.y);
}

#[test]
fn g2_psi_maps_to_curve() {
    let g = generator_jacobian();
    let psi = psi_g2(g);
    let psi_aff = jacobian_to_affine_g2(psi);
    assert(is_on_curve_g2_affine(psi_aff));

    let g_aff = jacobian_to_affine_g2(generator_jacobian());
    let x_eq = fp2_eq(psi_aff.x, g_aff.x);
    let y_eq = fp2_eq(psi_aff.y, g_aff.y);
    assert(!(x_eq & y_eq));
}

#[test]
fn g2_subgroup_check_generator() {
    let g = generator();
    assert(is_in_correct_subgroup_g2(g));
    assert(!is_in_correct_subgroup_g2(g2_affine_infinity()));
}
