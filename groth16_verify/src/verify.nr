use crate::types::{Proof, VerifyingKey};
use noir_bn254_pairing::fp::{fp_one};
use noir_bn254_pairing::fp2::Fp2;
use noir_bn254_pairing::fp12::Fp12;
use noir_bn254_pairing::g1::{
    G1Affine,
    G1Jac,
    add_g1_jac,
    double_g1_jac,
    g1_jacobian_infinity,
    jacobian_to_affine_g1,
};
use noir_bn254_pairing::pairing::pairing_multi;

fn g1_affine_to_jac(p: G1Affine) -> G1Jac {
    if p.is_infinity() {
        g1_jacobian_infinity()
    } else {
        G1Jac { x: p.x, y: p.y, z: fp_one() }
    }
}

fn fp2_eq(a: Fp2, b: Fp2) -> bool {
    let c0 = a.c0 == b.c0;
    let c1 = a.c1 == b.c1;
    c0 & c1
}

fn fp12_eq(a: Fp12, b: Fp12) -> bool {
    let c0 = fp2_eq(a.c0.b0, b.c0.b0);
    let c1 = fp2_eq(a.c0.b1, b.c0.b1);
    let c2 = fp2_eq(a.c0.b2, b.c0.b2);
    let c3 = fp2_eq(a.c1.b0, b.c1.b0);
    let c4 = fp2_eq(a.c1.b1, b.c1.b1);
    let c5 = fp2_eq(a.c1.b2, b.c1.b2);
    c0 & c1 & c2 & c3 & c4 & c5
}

fn scalar_mul_g1(p: G1Affine, scalar: Field) -> G1Affine {
    let mut acc = g1_jacobian_infinity();
    if !p.is_infinity() {
        let bits: [u1; 254] = scalar.to_le_bits();
        let mut base = g1_affine_to_jac(p);

        for i in 0..254 {
            let bit: u8 = bits[i] as u8;
            if bit == 1 {
                acc = add_g1_jac(acc, base);
            }
            base = double_g1_jac(base);
        }
    }

    jacobian_to_affine_g1(acc)
}

pub fn verify<let N: u32, let L: u32>(
    vk: VerifyingKey<L>,
    proof: Proof,
    public_inputs: [Field; N],
) -> bool {
    assert(L == N + 1);

    let mut acc = g1_affine_to_jac(vk.ic[0]);
    for i in 0..N {
        let term = scalar_mul_g1(vk.ic[i + 1], public_inputs[i]);
        acc = add_g1_jac(acc, g1_affine_to_jac(term));
    }
    let l = jacobian_to_affine_g1(acc);

    let result = pairing_multi(
        [proof.a, proof.c, l],
        [proof.b, vk.delta_neg, vk.gamma_neg],
    );

    fp12_eq(result, vk.alpha_beta)
}
