use crate::fp::{Fp, fp_from_limbs_checked, fp_to_limbs};
use crate::fp2::Fp2;
use crate::fp6::Fp6;
use crate::fp12::Fp12;
use crate::randomized_check::{FpMulWitness, finalize, new_random_check_state, RandomCheckState};

struct Fp2Int {
    c0: u128,
    c1: u128,
}

struct Fp6Int {
    b0: Fp2Int,
    b1: Fp2Int,
    b2: Fp2Int,
}

struct Fp12Int {
    c0: Fp6Int,
    c1: Fp6Int,
}

fn limbs_from_u128(value: u128) -> [u128; 3] {
    [value, 0, 0]
}

fn fp_from_u128(value: u128) -> Fp {
    fp_from_limbs_checked(limbs_from_u128(value))
}

fn fp2_from_ints(a: Fp2Int) -> Fp2 {
    Fp2 { c0: fp_from_u128(a.c0), c1: fp_from_u128(a.c1) }
}

fn fp6_from_ints(a: Fp6Int) -> Fp6 {
    Fp6 { b0: fp2_from_ints(a.b0), b1: fp2_from_ints(a.b1), b2: fp2_from_ints(a.b2) }
}

fn fp12_from_ints(a: Fp12Int) -> Fp12 {
    Fp12 { c0: fp6_from_ints(a.c0), c1: fp6_from_ints(a.c1) }
}

fn fp2_int_add(a: Fp2Int, b: Fp2Int) -> Fp2Int {
    Fp2Int { c0: a.c0 + b.c0, c1: a.c1 + b.c1 }
}

fn fp2_int_sub(a: Fp2Int, b: Fp2Int) -> Fp2Int {
    Fp2Int { c0: a.c0 - b.c0, c1: a.c1 - b.c1 }
}

fn fp6_int_add(a: Fp6Int, b: Fp6Int) -> Fp6Int {
    Fp6Int {
        b0: fp2_int_add(a.b0, b.b0),
        b1: fp2_int_add(a.b1, b.b1),
        b2: fp2_int_add(a.b2, b.b2),
    }
}

fn fp_mul_witness_from_int(a: u128, b: u128) -> FpMulWitness {
    let c = fp_from_u128(a * b);
    FpMulWitness {
        c: fp_to_limbs(c),
        q: [0, 0, 0],
    }
}

fn fp2_mul_witnesses_int(a: Fp2Int, b: Fp2Int) -> [FpMulWitness; 3] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 3];
    let a0 = a.c0 + a.c1;
    let b0 = b.c0 + b.c1;
    out[0] = fp_mul_witness_from_int(a0, b0);
    out[1] = fp_mul_witness_from_int(a.c0, b.c0);
    out[2] = fp_mul_witness_from_int(a.c1, b.c1);
    out
}

fn fp2_square_witnesses_int(a: Fp2Int) -> [FpMulWitness; 2] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 2];
    let a0 = a.c0 + a.c1;
    let b0 = a.c0 - a.c1;
    out[0] = fp_mul_witness_from_int(a0, b0);
    out[1] = fp_mul_witness_from_int(a.c0, a.c1);
    out
}

fn copy3_into18(mut out: [FpMulWitness; 18], start: u32, src: [FpMulWitness; 3]) -> [FpMulWitness; 18] {
    for i in 0..3 {
        out[start + i] = src[i];
    }
    out
}

fn copy18_into54(mut out: [FpMulWitness; 54], start: u32, src: [FpMulWitness; 18]) -> [FpMulWitness; 54] {
    for i in 0..18 {
        out[start + i] = src[i];
    }
    out
}

fn copy2_into12(mut out: [FpMulWitness; 12], start: u32, src: [FpMulWitness; 2]) -> [FpMulWitness; 12] {
    for i in 0..2 {
        out[start + i] = src[i];
    }
    out
}

fn copy3_into12(mut out: [FpMulWitness; 12], start: u32, src: [FpMulWitness; 3]) -> [FpMulWitness; 12] {
    for i in 0..3 {
        out[start + i] = src[i];
    }
    out
}

fn copy18_into42(mut out: [FpMulWitness; 42], start: u32, src: [FpMulWitness; 18]) -> [FpMulWitness; 42] {
    for i in 0..18 {
        out[start + i] = src[i];
    }
    out
}

fn copy12_into42(mut out: [FpMulWitness; 42], start: u32, src: [FpMulWitness; 12]) -> [FpMulWitness; 42] {
    for i in 0..12 {
        out[start + i] = src[i];
    }
    out
}

fn fp6_mul_witnesses_int(a: Fp6Int, b: Fp6Int) -> [FpMulWitness; 18] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 18];
    out = copy3_into18(out, 0, fp2_mul_witnesses_int(a.b0, b.b0));
    out = copy3_into18(out, 3, fp2_mul_witnesses_int(a.b1, b.b1));
    out = copy3_into18(out, 6, fp2_mul_witnesses_int(a.b2, b.b2));
    out = copy3_into18(out, 9, fp2_mul_witnesses_int(fp2_int_add(a.b1, a.b2), fp2_int_add(b.b1, b.b2)));
    out = copy3_into18(out, 12, fp2_mul_witnesses_int(fp2_int_add(a.b0, a.b1), fp2_int_add(b.b0, b.b1)));
    out = copy3_into18(out, 15, fp2_mul_witnesses_int(fp2_int_add(a.b0, a.b2), fp2_int_add(b.b0, b.b2)));
    out
}

fn fp6_square_witnesses_int(a: Fp6Int) -> [FpMulWitness; 12] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 12];
    out = copy3_into12(out, 0, fp2_mul_witnesses_int(a.b0, a.b1));
    out = copy2_into12(out, 3, fp2_square_witnesses_int(a.b2));
    out = copy2_into12(out, 5, fp2_square_witnesses_int(a.b0));
    out = copy3_into12(out, 7, fp2_mul_witnesses_int(a.b1, a.b2));
    let tmp = fp2_int_add(fp2_int_sub(a.b0, a.b1), a.b2);
    out = copy2_into12(out, 10, fp2_square_witnesses_int(tmp));
    out
}

fn fp12_mul_witnesses_int(a: Fp12Int, b: Fp12Int) -> [FpMulWitness; 54] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 54];
    let a0 = fp6_int_add(a.c0, a.c1);
    let b0 = fp6_int_add(b.c0, b.c1);
    out = copy18_into54(out, 0, fp6_mul_witnesses_int(a0, b0));
    out = copy18_into54(out, 18, fp6_mul_witnesses_int(a.c0, b.c0));
    out = copy18_into54(out, 36, fp6_mul_witnesses_int(a.c1, b.c1));
    out
}

fn fp12_square_witnesses_int(a: Fp12Int) -> [FpMulWitness; 42] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 42];
    out = copy18_into42(out, 0, fp6_mul_witnesses_int(a.c0, a.c1));
    out = copy12_into42(out, 18, fp6_square_witnesses_int(a.c0));
    out = copy12_into42(out, 30, fp6_square_witnesses_int(a.c1));
    out
}

fn assert_fp12_eq(a: Fp12, b: Fp12) {
    assert(a.c0.b0.c0 == b.c0.b0.c0);
    assert(a.c0.b0.c1 == b.c0.b0.c1);
    assert(a.c0.b1.c0 == b.c0.b1.c0);
    assert(a.c0.b1.c1 == b.c0.b1.c1);
    assert(a.c0.b2.c0 == b.c0.b2.c0);
    assert(a.c0.b2.c1 == b.c0.b2.c1);
    assert(a.c1.b0.c0 == b.c1.b0.c0);
    assert(a.c1.b0.c1 == b.c1.b0.c1);
    assert(a.c1.b1.c0 == b.c1.b1.c0);
    assert(a.c1.b1.c1 == b.c1.b1.c1);
    assert(a.c1.b2.c0 == b.c1.b2.c0);
    assert(a.c1.b2.c1 == b.c1.b2.c1);
}

fn fixture_fp12_int() -> Fp12Int {
    let c0 = Fp6Int {
        b0: Fp2Int { c0: 3, c1: 4 },
        b1: Fp2Int { c0: 5, c1: 6 },
        b2: Fp2Int { c0: 7, c1: 8 },
    };
    let c1 = Fp6Int {
        b0: Fp2Int { c0: 9, c1: 10 },
        b1: Fp2Int { c0: 11, c1: 12 },
        b2: Fp2Int { c0: 13, c1: 14 },
    };
    Fp12Int { c0, c1 }
}

fn fixture_fp12_other_int() -> Fp12Int {
    let c0 = Fp6Int {
        b0: Fp2Int { c0: 2, c1: 3 },
        b1: Fp2Int { c0: 4, c1: 5 },
        b2: Fp2Int { c0: 6, c1: 7 },
    };
    let c1 = Fp6Int {
        b0: Fp2Int { c0: 8, c1: 9 },
        b1: Fp2Int { c0: 10, c1: 11 },
        b2: Fp2Int { c0: 12, c1: 13 },
    };
    Fp12Int { c0, c1 }
}

#[test]
fn fp12_mul_checked_matches() {
    let a_int = fixture_fp12_int();
    let b_int = fixture_fp12_other_int();
    let a = fp12_from_ints(a_int);
    let b = fp12_from_ints(b_int);
    let expected = a.mul(b);
    let witnesses = fp12_mul_witnesses_int(a_int, b_int);
    let state: RandomCheckState<54> = new_random_check_state(7, 11, witnesses);
    let (result, state) = a.mul_checked(b, expected, state);
    assert_fp12_eq(result, expected);
    assert(finalize(state));
}

#[test]
fn fp12_square_checked_matches() {
    let a_int = fixture_fp12_int();
    let a = fp12_from_ints(a_int);
    let expected = a.square();
    let witnesses = fp12_square_witnesses_int(a_int);
    let state: RandomCheckState<42> = new_random_check_state(5, 9, witnesses);
    let (result, state) = a.square_checked(expected, state);
    assert_fp12_eq(result, expected);
    assert(finalize(state));
}
