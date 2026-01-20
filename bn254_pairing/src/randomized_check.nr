use crate::fp::{Fp, assert_fp_limbs_in_range, fp_from_limbs_checked, fp_modulus_limbs, fp_to_limbs};

pub struct FpMulWitness {
    pub c: [u128; 3],
    pub q: [u128; 3],
}

pub struct RandomCheckState<let N: u32> {
    pub rho: Field,
    pub alpha: Field,
    pub alpha_pow: Field,
    pub acc: Field,
    pub fp_mul_witnesses: [FpMulWitness; N],
    pub idx: u32,
}

pub fn new_random_check_state<let N: u32>(
    rho: Field,
    alpha: Field,
    fp_mul_witnesses: [FpMulWitness; N],
) -> RandomCheckState<N> {
    RandomCheckState {
        rho,
        alpha,
        alpha_pow: 1,
        acc: 0,
        fp_mul_witnesses,
        idx: 0,
    }
}

pub fn eval_limbs(limbs: [u128; 3], rho: Field) -> Field {
    let l0 = limbs[0] as Field;
    let l1 = limbs[1] as Field;
    let l2 = limbs[2] as Field;
    let rho2 = rho * rho;
    l0 + l1 * rho + l2 * rho2
}

pub fn eval_fp(x: Fp, rho: Field) -> Field {
    eval_limbs(fp_to_limbs(x), rho)
}

pub fn accumulate_check<let N: u32>(
    state: RandomCheckState<N>,
    check: Field,
) -> RandomCheckState<N> {
    RandomCheckState {
        rho: state.rho,
        alpha: state.alpha,
        alpha_pow: state.alpha_pow * state.alpha,
        acc: state.acc + state.alpha_pow * check,
        fp_mul_witnesses: state.fp_mul_witnesses,
        idx: state.idx,
    }
}

pub fn check_fp_mul<let N: u32>(
    a: Fp,
    b: Fp,
    state: RandomCheckState<N>,
) -> (Fp, RandomCheckState<N>) {
    let witness = state.fp_mul_witnesses[state.idx];
    let idx = state.idx + 1;

    assert_fp_limbs_in_range(witness.c);
    let c = fp_from_limbs_checked(witness.c);

    let a_eval = eval_limbs(fp_to_limbs(a), state.rho);
    let b_eval = eval_limbs(fp_to_limbs(b), state.rho);
    let c_eval = eval_limbs(witness.c, state.rho);
    let q_eval = eval_limbs(witness.q, state.rho);
    let p_eval = eval_limbs(fp_modulus_limbs(), state.rho);

    let check = a_eval * b_eval - c_eval - q_eval * p_eval;
    let acc = state.acc + state.alpha_pow * check;
    let alpha_pow = state.alpha_pow * state.alpha;

    (
        c,
        RandomCheckState {
            rho: state.rho,
            alpha: state.alpha,
            alpha_pow,
            acc,
            fp_mul_witnesses: state.fp_mul_witnesses,
            idx,
        },
    )
}

pub fn finalize<let N: u32>(state: RandomCheckState<N>) -> bool {
    state.acc == 0
}
