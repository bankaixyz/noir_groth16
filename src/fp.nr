use bignum::BN254_Fq;
use bignum::BigNum;

pub type Fp = BN254_Fq;

pub fn seed_x0() -> u128 {
    4965661367192848881
}

pub fn fp_zero() -> Fp {
    Fp::from_limbs([0x0, 0x0, 0x0])
}

pub fn fp_one() -> Fp {
    Fp::from_limbs([0x1, 0x0, 0x0])
}

pub fn fp_two() -> Fp {
    Fp::from_limbs([0x2, 0x0, 0x0])
}

pub fn fp_three() -> Fp {
    Fp::from_limbs([0x3, 0x0, 0x0])
}

pub fn fp_four() -> Fp {
    Fp::from_limbs([0x4, 0x0, 0x0])
}

pub fn fp_eight() -> Fp {
    Fp::from_limbs([0x8, 0x0, 0x0])
}

pub fn fp_nine() -> Fp {
    Fp::from_limbs([0x9, 0x0, 0x0])
}

pub fn g1_generator_x() -> Fp {
    fp_one()
}

pub fn g1_generator_y() -> Fp {
    fp_two()
}

pub fn curve_b() -> Fp {
    fp_three()
}