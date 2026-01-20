use poseidon::poseidon::bn254;

pub fn derive_rho_alpha(seed: Field, public_inputs: [Field; 2], vk_hash: Field) -> (Field, Field) {
    let domain_rho: Field = 1;
    let domain_alpha: Field = 2;
    let rho = bn254::hash_5([domain_rho, seed, public_inputs[0], public_inputs[1], vk_hash]);
    let alpha = bn254::hash_6([domain_alpha, seed, public_inputs[0], public_inputs[1], vk_hash, rho]);
    (rho, alpha)
}
