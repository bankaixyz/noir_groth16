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

/// Assert each limb fits in 120 bits (canonical limb size).
pub fn assert_fp_limbs_in_range(limbs: [u128; 3]) {
    let max: u128 = 1 << 120;
    assert(limbs[0] < max);
    assert(limbs[1] < max);
    assert(limbs[2] < max);
}

/// Build an Fp element from limbs with range checks.
pub fn fp_from_limbs_checked(limbs: [u128; 3]) -> Fp {
    assert_fp_limbs_in_range(limbs);
    Fp::from_limbs(limbs)
}

/// Build an Fp element from limbs without range checks.
pub fn fp_from_limbs_unchecked(limbs: [u128; 3]) -> Fp {
    Fp::from_limbs(limbs)
}

/// BN254 base field modulus as limbs.
pub fn fp_modulus_limbs() -> [u128; 3] {
    [0x816a916871ca8d3c208c16d87cfd47, 0x4e72e131a029b85045b68181585d97, 0x3064]
}

/// Convert an Fp element to 120-bit limbs.
pub fn fp_to_limbs(x: Fp) -> [u128; 3] {
    x.get_limbs()
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