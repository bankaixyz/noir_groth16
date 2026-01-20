use crate::types::Proof;
use crate::verify::{
    verify_sp1_fast,
    verify_sp1_pairing_check as verify_sp1_pairing_check_impl,
    verify_sp1_pairing_check_fixed_lines_randomized as verify_sp1_pairing_check_fixed_lines_randomized_impl,
};
use noir_bn254_pairing::fp::Fp;
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp12::{Fp12, Mul034Witness};
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::G2Affine;
use noir_bn254_pairing::BigNum;
use sha256::sha256_var;

/// Convert 32 big-endian bytes to a Field element.
fn bytes32_to_field(bytes: [u8; 32]) -> Field {
    let mut result: Field = 0;
    for i in 0..32 {
        result = result * 256 + bytes[i] as Field;
    }
    result
}

/// Convert a SHA256 hash to a BN254 scalar by masking to 253 bits.
/// Clears the top 3 bits so the value fits in the scalar field.
pub fn hash_to_field(hash: [u8; 32]) -> Field {
    let mut masked = hash;
    masked[0] = masked[0] & 0x1F;
    bytes32_to_field(masked)
}

/// Hash public values using SHA256 and mask to 253 bits.
fn hash_public_values<let N: u32>(public_values: [u8; N]) -> Field {
    let hash: [u8; 32] = sha256_var(public_values, N);
    hash_to_field(hash)
}

/// SP1 public inputs: [vkey, H(public_values)] where H is SHA256.
pub fn sp1_public_inputs<let N: u32>(vkey: Field, public_values: [u8; N]) -> [Field; 2] {
    let input0 = vkey;
    let input1 = hash_public_values(public_values);
    [input0, input1]
}

/// Verifies an SP1 Groth16 proof.
///
/// SP1 wraps its STARK proof in a Groth16 proof on BN254.
/// The verification uses two public inputs:
///   - input0: The SP1 program vkey (already a BN254 scalar)
///   - input1: sha256(publicValues) masked to 253 bits
///
/// Parameters:
/// - vkey: The SP1 program verification key as a Field
/// - public_values: The raw public values bytes from the SP1 proof
/// - proof: The parsed Groth16 proof (A, B, C points)
pub fn verify_sp1<let N: u32>(
    vkey: Field,
    public_values: [u8; N],
    proof: Proof,
) -> bool {
    let public_inputs = sp1_public_inputs(vkey, public_values);
    verify_sp1_fast(proof, public_inputs)
}

/// Verifies an SP1 Groth16 proof using the PairingCheck fast path.
pub fn verify_sp1_pairing_check<let N: u32>(
    vkey: Field,
    public_values: [u8; N],
    proof: Proof,
    c: Fp12,
    w: Fp12,
) -> bool {
    let public_inputs = sp1_public_inputs(vkey, public_values);
    verify_sp1_pairing_check_impl(proof, public_inputs, c, w)
}

/// Verifies an SP1 Groth16 proof with fixed-line tables and randomized checks.
pub fn verify_sp1_pairing_check_fixed_lines_randomized<let N: u32>(
    vkey: Field,
    public_values: [u8; N],
    proof: Proof,
    c: Fp12,
    w: Fp12,
    rho: Field,
    alpha: Field,
    mul_witnesses: [Mul034Witness; 67],
) -> bool {
    let public_inputs = sp1_public_inputs(vkey, public_values);
    verify_sp1_pairing_check_fixed_lines_randomized_impl(
        proof,
        public_inputs,
        c,
        w,
        rho,
        alpha,
        mul_witnesses,
    )
}

/// Build an Fp element from 3 u128 limbs (BN254 limb order).
fn fp_from_limbs(l0: u128, l1: u128, l2: u128) -> Fp {
    Fp::from_limbs([l0, l1, l2])
}

/// Build an Fp2 element from two Fp limb arrays.
fn fp2_from_limbs(a0: [u128; 3], a1: [u128; 3]) -> Fp2 {
    Fp2 { c0: fp_from_limbs(a0[0], a0[1], a0[2]), c1: fp_from_limbs(a1[0], a1[1], a1[2]) }
}

#[test]
fn sp1_verify_proof_vectors() {
    let proof = Proof {
        a: G1Affine {
            x: fp_from_limbs(
                307787076379487458571156906009180964,
                50751341420081675745548884269875970,
                6065,
            ),
            y: fp_from_limbs(
                302841750745344791179181479786202522,
                1294004320088991008988018350263061581,
                7814,
            ),
        },
        b: G2Affine {
            x: fp2_from_limbs(
                [
                    894254050534938276113179901188568010,
                    1171700586208065115867573360758492544,
                    3945,
                ],
                [
                    1223688730982776644053098029284500517,
                    895923234142781803864927689747099941,
                    9618,
                ],
            ),
            y: fp2_from_limbs(
                [
                    406582600782811713233430330757714549,
                    1318678159873813427242602707960382066,
                    1727,
                ],
                [
                    40303331300895208317235077209052673,
                    637515280078031819478564287027125089,
                    4594,
                ],
            ),
        },
        c: G1Affine {
            x: fp_from_limbs(
                583926555283738009014131359112148614,
                139345707890961960705811690317537466,
                1974,
            ),
            y: fp_from_limbs(
                627599278550929784918135029507933026,
                1059785295754105831700881546841708741,
                3409,
            ),
        },
    };

    let vkey: Field =
        123288693060355078070849777297038038443682877021812958790646459095157221042;
    let public_values: [u8; 32] = [
        45, 159, 62, 110, 230, 192, 251, 199, 27, 200, 89, 127, 61, 125, 225, 145,
        173, 173, 115, 160, 232, 42, 224, 231, 229, 46, 57, 136, 193, 117, 175, 212,
    ];

    let verified = verify_sp1(vkey, public_values, proof);
    assert(verified);
}
