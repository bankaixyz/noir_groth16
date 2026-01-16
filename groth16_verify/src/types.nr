use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::fp12::Fp12;

/// Groth16 Verification Key
/// Generic over L, the number of IC points (= num_public_inputs + 1)
pub struct VerifyingKey<let L: u32> {
    pub ic: [G1Affine; L],
    pub gamma_neg: G2Affine,
    pub delta_neg: G2Affine,
    pub alpha_beta: Fp12,
}

/// Groth16 Proof
pub struct Proof {
    pub a: G1Affine,
    pub b: G2Affine,
    pub c: G1Affine,
}
