use crate::config::sp1::{sp1_msm2_w3_table, sp1_t_preimage, sp1_vk};
use crate::config::sp1_lines::{sp1_delta_lines, sp1_gamma_lines};
use crate::types::Proof;
use crate::verify::{verify as verify_groth16, verify_optimized as verify_groth16_optimized};
use noir_bn254_pairing::fp::{Fp, fp_from_limbs_checked};
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp12::{Fp12, Mul034Witness};
use noir_bn254_pairing::g1::G1Affine;
use noir_bn254_pairing::g2::{G2Affine, G2LineWitness, LineSchedule, LineScheduleRaw};
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
    rho_seed: Field,
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
    let mut inputs: [Field; 27] = [0; 27];
    inputs[0] = rho_seed;
    inputs[1] = public_inputs[0];
    inputs[2] = public_inputs[1];

    let limb_sets = [a_x, a_y, b_x_c0, b_x_c1, b_y_c0, b_y_c1, c_x, c_y];
    let mut idx: u32 = 3;
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
pub fn verify<let N: u32>(
    vkey: Field,
    public_values: [u8; N],
    proof: Proof,
) -> bool {
    let public_inputs = sp1_public_inputs(vkey, public_values);
    let vk = sp1_vk();
    verify_groth16::<2, 3>(vk, proof, public_inputs)
}

/// Verifies an SP1 Groth16 proof using the optimized pairing check.
pub fn verify_optimized<let N: u32>(
    vkey: Field,
    public_values: [u8; N],
    rho_seed: Field,
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
    lines: LineSchedule,
    b_lines_raw: LineScheduleRaw,
    b_line_witness: G2LineWitness,
    mul_034_witnesses: [Mul034Witness; 67],
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
        rho_seed,
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
    let vk = sp1_vk();
    let msm2_w3_table = sp1_msm2_w3_table();
    let t_preimage = sp1_t_preimage();
    let delta_lines = sp1_delta_lines();
    let gamma_lines = sp1_gamma_lines();
    verify_groth16_optimized(
        vk,
        proof,
        public_inputs,
        msm2_w3_table,
        t_preimage,
        delta_lines,
        gamma_lines,
        lines,
        b_lines_raw,
        b_line_witness,
        mul_034_witnesses,
        rho,
        c,
        w,
    )
}


