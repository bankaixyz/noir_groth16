use crate::fp::{Fp, assert_fp_limbs_in_range, fp_from_limbs_checked, fp_modulus_limbs, fp_to_limbs};

pub struct FpMulWitness {
    pub c: [u128; 3],
    pub q: [u128; 3],
}

pub struct MulTrace<let N: u32> {
    pub data: [FpMulWitness; N],
    pub idx: u32,
}

impl<let N: u32> MulTrace<N> {
    pub fn new(data: [FpMulWitness; N]) -> MulTrace<N> {
        MulTrace { data, idx: 0 }
    }

    pub fn next(&mut self) -> FpMulWitness {
        let witness = self.data[self.idx];
        self.idx = self.idx + 1;
        witness
    }
}

pub struct RandomCheckContext {
    pub rho: Field,
    pub alpha: Field,
    pub alpha_pow: Field,
    pub acc: Field,
}

pub fn new_random_check_context(rho: Field, alpha: Field) -> RandomCheckContext {
    RandomCheckContext { rho, alpha, alpha_pow: 1, acc: 0 }
}

pub fn eval_limbs(limbs: [u128; 3], rho: Field) -> Field {
    let l0 = limbs[0] as Field;
    let l1 = limbs[1] as Field;
    let l2 = limbs[2] as Field;
    let rho2 = rho * rho;
    l0 + l1 * rho + l2 * rho2
}

pub fn check_fp_mul(
    a: Fp,
    b: Fp,
    witness: FpMulWitness,
    ctx: &mut RandomCheckContext,
) -> Fp {
    assert_fp_limbs_in_range(witness.c);
    assert_fp_limbs_in_range(witness.q);
    let c = fp_from_limbs_checked(witness.c);

    let a_eval = eval_limbs(fp_to_limbs(a), ctx.rho);
    let b_eval = eval_limbs(fp_to_limbs(b), ctx.rho);
    let c_eval = eval_limbs(witness.c, ctx.rho);
    let q_eval = eval_limbs(witness.q, ctx.rho);
    let p_eval = eval_limbs(fp_modulus_limbs(), ctx.rho);

    let check = a_eval * b_eval - c_eval - q_eval * p_eval;
    ctx.acc = ctx.acc + ctx.alpha_pow * check;
    ctx.alpha_pow = ctx.alpha_pow * ctx.alpha;
    c
}

pub fn finalize(ctx: RandomCheckContext) -> bool {
    ctx.acc == 0
}
