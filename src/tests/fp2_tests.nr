use crate::fp::{Fp, fp_one, fp_zero};
use crate::fp2::{Fp2, fp2_one};
use bignum::BigNum;

fn fp_from_limbs(l0: u128, l1: u128, l2: u128) -> Fp {
    Fp::from_limbs([l0, l1, l2])
}

fn fp2(a0: [u128; 3], a1: [u128; 3]) -> Fp2 {
    Fp2 { c0: fp_from_limbs(a0[0], a0[1], a0[2]), c1: fp_from_limbs(a1[0], a1[1], a1[2]) }
}

fn assert_fp2_eq(a: Fp2, b: Fp2) {
    assert(a.c0 == b.c0);
    assert(a.c1 == b.c1);
}

fn fixture_a() -> Fp2 {
    fp2(
        [0x8fb963ec9acdeb921e94bec973154e, 0xb05e7ef12a97ed0b7deacb789da82e, 0x1672],
        [0x1d557c31a563f1a88397bffd5f9464, 0x5fa03764ea6a871224878ea00c1bd6, 0x168c],
    )
}

fn fixture_b() -> Fp2 {
    fp2(
        [0xc819fe8c2f7ec1e183c5de4c76cab4, 0x2f3df37748c8ec29f577c0f81391, 0x658],
        [0xf95fa7d75eeaa5c437d5e7a822db0e, 0x84d68a7e740995d33d66ff4e33b59e, 0x2123],
    )
}

fn fixture_a_plus_b() -> Fp2 {
    fp2(
        [0x57d36278ca4cad73a25a9d15e9e002, 0xb08dbce4a1e0b5f7a7e0433995bbc0, 0x1cca],
        [0x954a92a092840a309ae190cd05722b, 0x9603e0b1be4a64951c380c6ce773dd, 0x74b],
    )
}

fn fixture_a_minus_b() -> Fp2 {
    fp2(
        [0xc79f65606b4f29b09acee07cfc4a9a, 0xb02f40fdb34f241f53f553b7a5949c, 0x101a],
        [0xa56065c2b843d9206c4def2db9b69d, 0x293c8e18168aa98f2cd710d330c3ce, 0x25cd],
    )
}

fn fixture_a_mul_b() -> Fp2 {
    fp2(
        [0xb7d9af6ee9ad0db2f53808f68e9680, 0x54733ccc4262cb6728d948286934ae, 0xfc8],
        [0x2cf6c898b15ae6e65f2f632ab744f6, 0x2c400b41bb9e868fba9b251dbf6c67, 0x2ad],
    )
}

fn fixture_a_squared() -> Fp2 {
    fp2(
        [0x3654d6f2a1a71187851897ff18aae8, 0x58749ec4d124030b21de49809b4236, 0x301f],
        [0x1d694ea25bdfc5d7a315fb9a762763, 0x1536e6efb2039a32ecbbcb000ab238, 0x163d],
    )
}

fn fixture_a_inverse() -> Fp2 {
    fp2(
        [0x8a243c36e3da37b7fe8c95b2f8d88f, 0x41f27e85c9e524a276536b8716b0e1, 0x338],
        [0xa5e13e64c7092959ecc7c70195063f, 0x16d17bc691c20ecb48676cb53e8417, 0x27a3],
    )
}

fn fixture_a_negated() -> Fp2 {
    fp2(
        [0xf1b12d7bd6fca1aa01f7580f09e7f9, 0x9e1462407591cb44c7cbb608bab568, 0x19f1],
        [0x64151536cc669b939cf456db1d68e3, 0xeed2a9ccb5bf313e212ef2e14c41c1, 0x19d7],
    )
}

fn fixture_a_doubled() -> Fp2 {
    fp2(
        [0x1f72c7d9359bd7243d297d92e62a9c, 0x60bcfde2552fda16fbd596f13b505d, 0x2ce5],
        [0x3aaaf8634ac7e351072f7ffabf28c8, 0xbf406ec9d4d50e24490f1d401837ac, 0x2d18],
    )
}

fn fixture_a_conjugate() -> Fp2 {
    fp2(
        [0x8fb963ec9acdeb921e94bec973154e, 0xb05e7ef12a97ed0b7deacb789da82e, 0x1672],
        [0x64151536cc669b939cf456db1d68e3, 0xeed2a9ccb5bf313e212ef2e14c41c1, 0x19d7],
    )
}

fn fixture_a_mul_by_nonresidue() -> Fp2 {
    fp2(
        [0x6bef52e67679aec62dfeb08e353385, 0xe8599b80b46fa5647796141975b506, 0x224e],
        [0x92107c09a427358e3cba234fdb57b6, 0xd334ecb6e7afcb6dafd4c913a92c57, 0x1fd0],
    )
}

#[test]
fn fp2_add_sub_identity() {
    let a = fixture_a();
    let b = fixture_b();
    assert_fp2_eq(a.add(b), fixture_a_plus_b());
    assert_fp2_eq(a.sub(b), fixture_a_minus_b());
    assert_fp2_eq(a.add(b).sub(b), a);
}

#[test]
fn fp2_mul_inverse_identity() {
    let a = fixture_a();
    let inv = fixture_a_inverse();
    assert_fp2_eq(a.mul(inv), fp2_one());
    assert_fp2_eq(inv.inverse(), a);
}

#[test]
fn fp2_square_mul_consistency() {
    let a = fixture_a();
    assert_fp2_eq(a.square(), fixture_a_squared());
    assert_fp2_eq(a.square(), a.mul(a));
}

#[test]
fn fp2_mul_fixture() {
    let a = fixture_a();
    let b = fixture_b();
    assert_fp2_eq(a.mul(b), fixture_a_mul_b());
}

#[test]
fn fp2_neg_double_consistency() {
    let a = fixture_a();
    assert_fp2_eq(a.neg(), fixture_a_negated());
    assert_fp2_eq(a.double(), fixture_a_doubled());
    assert_fp2_eq(a.neg().neg(), a);
}

#[test]
fn fp2_mul_by_non_residue_consistency() {
    let a = fixture_a();
    assert_fp2_eq(a.mul_by_non_residue(), fixture_a_mul_by_nonresidue());
}

#[test]
fn fp2_mul_by_element_inverse() {
    let a = fixture_a();
    let elem = a.c0;
    let inv = fp_one() / elem;
    let res = a.mul_by_element(elem).mul_by_element(inv);
    assert_fp2_eq(res, a);
}

#[test]
fn fp2_conjugate_properties() {
    let a = fixture_a();
    let conj = a.conjugate();
    assert_fp2_eq(conj, fixture_a_conjugate());

    let sum = a.add(conj);
    assert(sum.c1 == fp_zero());
    assert(sum.c0 == a.c0 + a.c0);

    let diff = a.sub(conj);
    assert(diff.c0 == fp_zero());
    assert(diff.c1 == a.c1 + a.c1);
}
