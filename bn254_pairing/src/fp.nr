use bignum::BN254_Fq;
use bignum::BigNum;

/// Base field Fp for BN254 (Fq).
pub type Fp = BN254_Fq;

/// BN254 parameter x for the optimal Ate pairing loop.
pub fn seed_x0() -> u128 {
    4965661367192848881
}

/// Field zero.
pub fn fp_zero() -> Fp {
    Fp::from_limbs([0x0, 0x0, 0x0])
}

/// Field one.
pub fn fp_one() -> Fp {
    Fp::from_limbs([0x1, 0x0, 0x0])
}

/// Field constant 2.
pub fn fp_two() -> Fp {
    Fp::from_limbs([0x2, 0x0, 0x0])
}

/// Field constant 3 (curve b parameter).
pub fn fp_three() -> Fp {
    Fp::from_limbs([0x3, 0x0, 0x0])
}

/// Field constant 4.
pub fn fp_four() -> Fp {
    Fp::from_limbs([0x4, 0x0, 0x0])
}

/// Field constant 8.
pub fn fp_eight() -> Fp {
    Fp::from_limbs([0x8, 0x0, 0x0])
}

/// Field constant 9 (quadratic non-residue seed).
pub fn fp_nine() -> Fp {
    Fp::from_limbs([0x9, 0x0, 0x0])
}

/// BN254 G1 generator x-coordinate.
pub fn g1_generator_x() -> Fp {
    fp_one()
}

/// BN254 G1 generator y-coordinate.
pub fn g1_generator_y() -> Fp {
    fp_two()
}

/// Curve parameter b for y^2 = x^3 + b over Fp.
pub fn curve_b() -> Fp {
    fp_three()
}