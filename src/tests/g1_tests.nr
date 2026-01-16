use crate::fp::{Fp, fp_one, fp_two};
use crate::g1::{
    G1Affine, G1Jac, add_g1_affine, add_g1_jac, double_g1_jac, double_mixed_g1,
    g1_affine_infinity, g1_jacobian_infinity, is_on_curve_g1_affine,
    jacobian_to_affine_g1,
};
use bignum::BigNum;

fn fp_from_limbs(l0: u128, l1: u128, l2: u128) -> Fp {
    Fp::from_limbs([l0, l1, l2])
}

fn g1_affine(x: [u128; 3], y: [u128; 3]) -> G1Affine {
    G1Affine { x: fp_from_limbs(x[0], x[1], x[2]), y: fp_from_limbs(y[0], y[1], y[2]) }
}

fn g1_jac(x: [u128; 3], y: [u128; 3], z: [u128; 3]) -> G1Jac {
    G1Jac {
        x: fp_from_limbs(x[0], x[1], x[2]),
        y: fp_from_limbs(y[0], y[1], y[2]),
        z: fp_from_limbs(z[0], z[1], z[2]),
    }
}

fn g1_jac_from_affine(a: G1Affine) -> G1Jac {
    if a.is_infinity() {
        g1_jacobian_infinity()
    } else {
        G1Jac { x: a.x, y: a.y, z: fp_one() }
    }
}

fn assert_g1_affine_eq(a: G1Affine, b: G1Affine) {
    assert(a.x == b.x);
    assert(a.y == b.y);
}

fn generator() -> G1Affine {
    g1_affine([0x1, 0x0, 0x0], [0x2, 0x0, 0x0])
}

fn point_a() -> G1Affine {
    g1_affine(
        [0x5577586de4c517537d17882f9b3f34, 0xf35db6971fd77c8f9afdae27f7fb35, 0x988],
        [0xb4a8ae95f49905d52cdb2c3b4cb203, 0xffa63fafc8c67007390a6e6dd52860, 0x23ba],
    )
}

fn point_b() -> G1Affine {
    g1_affine(
        [0xf471f19fab22085f30251b3084cb7a, 0xa1741e8a505306a40614881a5b3506, 0x1cbc],
        [0xdf15071d3961bf6535a388c2b804d0, 0xfc14bee57a2dababc23e2510bd69bc, 0x168d],
    )
}

fn point_a_plus_b() -> G1Affine {
    g1_affine(
        [0x7e05587f149e1850a75e2cf76095d6, 0x3fbe7d5abdaabf807439706b07477b, 0x20ef],
        [0xdefcc453f6364c43b2d3a1e6114e90, 0x5c9cf4c0f268b4a9bc74fcef3b1fbd, 0xeb9],
    )
}

fn point_a_doubled() -> G1Affine {
    g1_affine(
        [0xf5c32a365156b25e5b0641c11a9f49, 0x6cba5a32a9297a9c6c094f352c94a9, 0x1887],
        [0x5b8343359cf4ce7e6721f6ed6db7fa, 0x58ec05617f5d75bc9de862f0ca7c1d, 0x23a],
    )
}

fn point_a_negated() -> G1Affine {
    g1_affine(
        [0x5577586de4c517537d17882f9b3f34, 0xf35db6971fd77c8f9afdae27f7fb35, 0x988],
        [0xccc1e2d27d318766f3b0ea9d304b44, 0x4ecca181d76348490cac1313833536, 0xca9],
    )
}

fn infinity() -> G1Affine {
    g1_affine([0x0, 0x0, 0x0], [0x0, 0x0, 0x0])
}

fn generator_jacobian() -> G1Jac {
    g1_jac([0x1, 0x0, 0x0], [0x2, 0x0, 0x0], [0x1, 0x0, 0x0])
}

fn generator_jacobian_fuzzed() -> G1Jac {
    g1_jac([0x121, 0x0, 0x0], [0x2662, 0x0, 0x0], [0x11, 0x0, 0x0])
}

fn infinity_jacobian() -> G1Jac {
    g1_jac([0x1, 0x0, 0x0], [0x1, 0x0, 0x0], [0x0, 0x0, 0x0])
}

#[test]
fn g1_curve_membership_affine() {
    let g = generator();
    assert(is_on_curve_g1_affine(g));

    let bad = G1Affine { x: g.x, y: g.y * fp_two() };
    assert(!is_on_curve_g1_affine(bad));
}

#[test]
fn g1_affine_arithmetic() {
    let a = point_a();
    let b = point_b();
    let inf = infinity();
    let neg = point_a_negated();

    assert_g1_affine_eq(add_g1_affine(a, b), point_a_plus_b());
    assert_g1_affine_eq(add_g1_affine(a, inf), a);
    assert_g1_affine_eq(add_g1_affine(inf, a), a);
    assert_g1_affine_eq(add_g1_affine(a, neg), g1_affine_infinity());
    assert_g1_affine_eq(jacobian_to_affine_g1(double_mixed_g1(a)), point_a_doubled());
    assert_g1_affine_eq(add_g1_affine(a, a), point_a_doubled());
}

#[test]
fn g1_jacobian_arithmetic() {
    let p = generator_jacobian();
    let q = generator_jacobian_fuzzed();
    let inf = infinity_jacobian();

    let sum = add_g1_jac(p, q);
    let dbl = double_g1_jac(q);
    assert_g1_affine_eq(jacobian_to_affine_g1(sum), jacobian_to_affine_g1(dbl));

    let neg_q = G1Jac { x: q.x, y: -q.y, z: q.z };
    let sum_neg = add_g1_jac(q, neg_q);
    assert_g1_affine_eq(jacobian_to_affine_g1(sum_neg), g1_affine_infinity());

    assert_g1_affine_eq(jacobian_to_affine_g1(add_g1_jac(q, inf)), jacobian_to_affine_g1(q));
    assert_g1_affine_eq(jacobian_to_affine_g1(add_g1_jac(inf, q)), jacobian_to_affine_g1(q));
}

#[test]
fn g1_jacobian_affine_conversion() {
    let g = generator();
    let fuzzed = generator_jacobian_fuzzed();
    let inf = g1_jacobian_infinity();

    assert_g1_affine_eq(jacobian_to_affine_g1(fuzzed), g);
    assert_g1_affine_eq(jacobian_to_affine_g1(inf), g1_affine_infinity());

    let from_affine = g1_jac_from_affine(g);
    assert(from_affine.z == fp_one());
    assert(from_affine.x == g.x);
    assert(from_affine.y == g.y);
}
