use crate::types::Proof;
use crate::verify::{
    verify_sp1_fast,
    verify_sp1_pairing_check as verify_sp1_pairing_check_impl,
    verify_sp1_pairing_check_with_lines as verify_sp1_pairing_check_with_lines_impl,
};
use noir_bn254_pairing::fp::{Fp, fp_from_limbs_checked};
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::{G2Affine, G2LineWitnessSp1, LineScheduleSp1, LineScheduleSp1Raw};
use noir_bn254_pairing::BigNum;
use poseidon::poseidon2::Poseidon2;
use sha256::sha256_var;

/// Convert 32 big-endian bytes to a Field element.
fn bytes32_to_field(bytes: [u8; 32]) -> Field {
    let mut result: Field = 0;
    for i in 0..32 {
        result = result * 256 + bytes[i] as Field;
    }
    result
}

fn fp_from_u128(value: u128) -> Fp {
    Fp::from_limbs([value, 0, 0])
}

fn bytes32_to_fp(bytes: [u8; 32]) -> Fp {
    let mut result = fp_from_u128(0);
    let base = fp_from_u128(256);
    for i in 0..32 {
        result = result * base + fp_from_u128(bytes[i] as u128);
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

fn field_to_le_bytes32(value: Field) -> [u8; 32] {
    let bits: [u1; 254] = value.to_le_bits();
    let mut out = [0u8; 32];
    for i in 0..32 {
        let mut byte: u8 = 0;
        for j in 0..8 {
            let idx = i * 8 + j;
            let bit: u32 = if idx < 254 { bits[idx] as u32 } else { 0 };
            byte = byte | ((bit << j) as u8);
        }
        out[i] = byte;
    }
    out
}

fn field_to_be_bytes32(value: Field) -> [u8; 32] {
    let le = field_to_le_bytes32(value);
    let mut be = [0u8; 32];
    for i in 0..32 {
        be[i] = le[31 - i];
    }
    be
}

fn limb_to_field(value: u128) -> Field {
    value as Field
}

fn derive_rho_sp1<let N: u32>(
    vkey: Field,
    public_values: [u8; N],
    a_x: [u128; 3],
    a_y: [u128; 3],
    b_x_c0: [u128; 3],
    b_x_c1: [u128; 3],
    b_y_c0: [u128; 3],
    b_y_c1: [u128; 3],
    c_x: [u128; 3],
    c_y: [u128; 3],
) -> Fp {
    let public_inputs = sp1_public_inputs(vkey, public_values);
    let mut inputs: [Field; 26] = [0; 26];
    inputs[0] = public_inputs[0];
    inputs[1] = public_inputs[1];

    let limb_sets = [a_x, a_y, b_x_c0, b_x_c1, b_y_c0, b_y_c1, c_x, c_y];
    let mut idx: u32 = 2;
    for s in 0..8 {
        let limbs = limb_sets[s];
        for l in 0..3 {
            inputs[idx] = limb_to_field(limbs[l]);
            idx = idx + 1;
        }
    }

    let rho_field = Poseidon2::hash(inputs, inputs.len());
    let rho_bytes = field_to_be_bytes32(rho_field);
    bytes32_to_fp(rho_bytes)
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

/// Verifies an SP1 Groth16 proof using PairingCheck with witnessed line schedule.
pub fn verify_sp1_pairing_check_with_lines<let N: u32>(
    vkey: Field,
    public_values: [u8; N],
    a_x: [u128; 3],
    a_y: [u128; 3],
    b_x_c0: [u128; 3],
    b_x_c1: [u128; 3],
    b_y_c0: [u128; 3],
    b_y_c1: [u128; 3],
    c_x: [u128; 3],
    c_y: [u128; 3],
    c: Fp12,
    w: Fp12,
    lines: LineScheduleSp1,
    b_lines_raw: LineScheduleSp1Raw,
    b_line_witness: G2LineWitnessSp1,
) -> bool {
    let proof = Proof {
        a: G1Affine { x: fp_from_limbs_checked(a_x), y: fp_from_limbs_checked(a_y) },
        b: G2Affine {
            x: Fp2 { c0: fp_from_limbs_checked(b_x_c0), c1: fp_from_limbs_checked(b_x_c1) },
            y: Fp2 { c0: fp_from_limbs_checked(b_y_c0), c1: fp_from_limbs_checked(b_y_c1) },
        },
        c: G1Affine { x: fp_from_limbs_checked(c_x), y: fp_from_limbs_checked(c_y) },
    };
    let public_inputs = sp1_public_inputs(vkey, public_values);
    let rho = derive_rho_sp1(
        vkey,
        public_values,
        a_x,
        a_y,
        b_x_c0,
        b_x_c1,
        b_y_c0,
        b_y_c1,
        c_x,
        c_y,
    );
    verify_sp1_pairing_check_with_lines_impl(
        proof,
        public_inputs,
        c,
        w,
        lines,
        b_lines_raw,
        b_line_witness,
        rho,
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
