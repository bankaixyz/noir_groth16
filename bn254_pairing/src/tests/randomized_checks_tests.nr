use crate::fp::{Fp, fp_from_limbs_checked, fp_to_limbs};
use crate::fp2::Fp2;
use crate::fp6::Fp6;
use crate::fp12::Fp12;
use crate::randomized_check::{FpMulWitness, MulTrace, finalize, new_random_check_context};

fn fp_small(value: u128) -> Fp {
    fp_from_limbs_checked([value, 0, 0])
}

fn fp_mul_witness(a: Fp, b: Fp) -> FpMulWitness {
    let c = a * b;
    FpMulWitness { c: fp_to_limbs(c), q: [0, 0, 0] }
}

fn fp2_mul_witnesses(a: Fp2, b: Fp2) -> [FpMulWitness; 3] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 3];
    let a0 = a.c0 + a.c1;
    let b0 = b.c0 + b.c1;
    out[0] = fp_mul_witness(a0, b0);
    out[1] = fp_mul_witness(a.c0, b.c0);
    out[2] = fp_mul_witness(a.c1, b.c1);
    out
}

fn fp2_square_witnesses(a: Fp2) -> [FpMulWitness; 2] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 2];
    let a0 = a.c0 + a.c1;
    let b0 = a.c0 - a.c1;
    out[0] = fp_mul_witness(a0, b0);
    out[1] = fp_mul_witness(a.c0, a.c1);
    out
}

fn copy3_into18(out: &mut [FpMulWitness; 18], start: u32, src: [FpMulWitness; 3]) {
    for i in 0..3 {
        out[start + i] = src[i];
    }
}

fn copy18_into54(out: &mut [FpMulWitness; 54], start: u32, src: [FpMulWitness; 18]) {
    for i in 0..18 {
        out[start + i] = src[i];
    }
}

fn copy2_into12(out: &mut [FpMulWitness; 12], start: u32, src: [FpMulWitness; 2]) {
    for i in 0..2 {
        out[start + i] = src[i];
    }
}

fn copy3_into12(out: &mut [FpMulWitness; 12], start: u32, src: [FpMulWitness; 3]) {
    for i in 0..3 {
        out[start + i] = src[i];
    }
}

fn copy18_into42(out: &mut [FpMulWitness; 42], start: u32, src: [FpMulWitness; 18]) {
    for i in 0..18 {
        out[start + i] = src[i];
    }
}

fn copy12_into42(out: &mut [FpMulWitness; 42], start: u32, src: [FpMulWitness; 12]) {
    for i in 0..12 {
        out[start + i] = src[i];
    }
}

fn fp6_mul_witnesses(a: Fp6, b: Fp6) -> [FpMulWitness; 18] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 18];
    copy3_into18(&mut out, 0, fp2_mul_witnesses(a.b0, b.b0));
    copy3_into18(&mut out, 3, fp2_mul_witnesses(a.b1, b.b1));
    copy3_into18(&mut out, 6, fp2_mul_witnesses(a.b2, b.b2));
    copy3_into18(&mut out, 9, fp2_mul_witnesses(a.b1.add(a.b2), b.b1.add(b.b2)));
    copy3_into18(&mut out, 12, fp2_mul_witnesses(a.b0.add(a.b1), b.b0.add(b.b1)));
    copy3_into18(&mut out, 15, fp2_mul_witnesses(a.b0.add(a.b2), b.b0.add(b.b2)));
    out
}

fn fp6_square_witnesses(a: Fp6) -> [FpMulWitness; 12] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 12];
    copy3_into12(&mut out, 0, fp2_mul_witnesses(a.b0, a.b1));
    copy2_into12(&mut out, 3, fp2_square_witnesses(a.b2));
    copy2_into12(&mut out, 5, fp2_square_witnesses(a.b0));
    copy3_into12(&mut out, 7, fp2_mul_witnesses(a.b1, a.b2));
    copy2_into12(&mut out, 10, fp2_square_witnesses(a.b0.sub(a.b1).add(a.b2)));
    out
}

fn fp12_mul_witnesses(a: Fp12, b: Fp12) -> [FpMulWitness; 54] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 54];
    let a0 = a.c0.add(a.c1);
    let b0 = b.c0.add(b.c1);
    copy18_into54(&mut out, 0, fp6_mul_witnesses(a0, b0));
    copy18_into54(&mut out, 18, fp6_mul_witnesses(a.c0, b.c0));
    copy18_into54(&mut out, 36, fp6_mul_witnesses(a.c1, b.c1));
    out
}

fn fp12_square_witnesses(a: Fp12) -> [FpMulWitness; 42] {
    let mut out = [FpMulWitness { c: [0, 0, 0], q: [0, 0, 0] }; 42];
    copy18_into42(&mut out, 0, fp6_mul_witnesses(a.c0, a.c1));
    copy12_into42(&mut out, 18, fp6_square_witnesses(a.c0));
    copy12_into42(&mut out, 30, fp6_square_witnesses(a.c1));
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

fn fixture_fp12() -> Fp12 {
    let a = Fp2 { c0: fp_small(3), c1: fp_small(4) };
    let b = Fp2 { c0: fp_small(5), c1: fp_small(6) };
    let c = Fp2 { c0: fp_small(7), c1: fp_small(8) };
    let d = Fp2 { c0: fp_small(9), c1: fp_small(10) };
    let e = Fp2 { c0: fp_small(11), c1: fp_small(12) };
    let f = Fp2 { c0: fp_small(13), c1: fp_small(14) };

    let c0 = Fp6 { b0: a, b1: b, b2: c };
    let c1 = Fp6 { b0: d, b1: e, b2: f };
    Fp12 { c0, c1 }
}

fn fixture_fp12_other() -> Fp12 {
    let a = Fp2 { c0: fp_small(2), c1: fp_small(3) };
    let b = Fp2 { c0: fp_small(4), c1: fp_small(5) };
    let c = Fp2 { c0: fp_small(6), c1: fp_small(7) };
    let d = Fp2 { c0: fp_small(8), c1: fp_small(9) };
    let e = Fp2 { c0: fp_small(10), c1: fp_small(11) };
    let f = Fp2 { c0: fp_small(12), c1: fp_small(13) };

    let c0 = Fp6 { b0: a, b1: b, b2: c };
    let c1 = Fp6 { b0: d, b1: e, b2: f };
    Fp12 { c0, c1 }
}

#[test]
fn fp12_mul_checked_matches() {
    let a = fixture_fp12();
    let b = fixture_fp12_other();
    let expected = a.mul(b);
    let witnesses = fp12_mul_witnesses(a, b);
    let mut trace = MulTrace::new(witnesses);
    let mut ctx = new_random_check_context(7, 11);
    let result = a.mul_checked(b, expected, &mut trace, &mut ctx);
    assert_fp12_eq(result, expected);
    assert(finalize(ctx));
}

#[test]
fn fp12_square_checked_matches() {
    let a = fixture_fp12();
    let expected = a.square();
    let witnesses = fp12_square_witnesses(a);
    let mut trace = MulTrace::new(witnesses);
    let mut ctx = new_random_check_context(5, 9);
    let result = a.square_checked(expected, &mut trace, &mut ctx);
    assert_fp12_eq(result, expected);
    assert(finalize(ctx));
}
