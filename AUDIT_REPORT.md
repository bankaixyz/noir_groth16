# Audit Report: BN254 Pairing + Groth16 Verification (Noir)

## 1) Executive Summary
This repository provides Noir implementations of BN254 field arithmetic, curve operations, optimal Ate pairing, and a Groth16 verifier with an SP1-optimized path. The core arithmetic and pairing routines are well-structured and include comprehensive test vectors for field tower operations and pairings. The primary security gap is missing validation of proof points (on-curve and subgroup checks), which can allow invalid-curve or small-subgroup attacks in adversarial settings. Overall risk posture: **Medium**, with **High** severity impact if untrusted proof points are not validated.

## 2) System Overview
- `noir_bn254_pairing`: Implements Fp/Fp2/Fp6/Fp12 arithmetic, G1/G2 operations, and the optimal Ate pairing with final exponentiation. The Miller loop uses signed-NAF digits of the BN parameter and sparse line multiplication. The final exponentiation uses Frobenius maps and cyclotomic squaring.
- `noir_groth16_verify`: Implements Groth16 verification over BN254 using a 3-pairing check. A fast SP1 path uses a 2-scalar MSM with a precomputed 3-bit joint window table and SP1-specific public input hashing.
- Examples: `pairing_multi_example` and `sp1_verify_example` provide integration sanity checks.

## 3) Threat Model & Assumptions
### Adversaries
- Malicious prover who controls witness values and tries to satisfy constraints without a valid Groth16 proof.
- Malicious user supplying malformed proof points: off-curve points, points at infinity, non-subgroup points, or non-canonical limb encodings.
- Malicious user attempting to exploit non-native arithmetic (limb decomposition, range constraints, equality, inversions).

### Trust Boundaries
- Trusted constants: verifying keys embedded in `groth16_verify/src/config/sp1.nr`, precomputed MSM tables, and fixed pairing constants.
- Untrusted inputs: proof points `(A, B, C)`, public inputs, SP1 public values, and any externally provided verifying key or MSM table parameters.
- The pairing and verifier code assume inputs are valid curve points. On-curve and subgroup checks are not enforced in the verifier, so they must be enforced externally or added in-circuit.

### Assumptions
- The `bignum`/`BigNum` library enforces limb range constraints and canonical reduction for `Fp` elements; equality is assumed to be representation-correct.
- The SHA256 gadget (`sha256_var`) is collision-resistant and correctly constrains the hash output.
- Verifying keys and precomputed tables are used as constants in production circuits.

## 4) Methodology
### Review Approach
- Static review of Noir source for field arithmetic, curve ops, Miller loop, final exponentiation, and verifier logic.
- Checked test vectors and examples for coverage of core arithmetic and pairing behavior.
- Cross-referenced algorithms against known BN254 pairing and Groth16 verification formulas.

### Tests Executed
- No automated tests were executed in this audit environment.
- Existing tests include Fp2/Fp6/Fp12 arithmetic fixtures and pairing vectors, plus G1/G2 arithmetic checks and SP1 proof vectors.

### Limitations
- Did not execute `nargo test`; conclusions rely on static analysis and provided vector tests.
- `bignum` library internals are external to this repo; correctness and constraint-soundness are assumed but not proven here.

## 5) Findings Table
| ID | Severity | Component | Title | Impacted Files | Status |
| --- | --- | --- | --- | --- | --- |
| F-01 | High | Groth16 verifier | Missing on-curve and subgroup checks for proof points | `groth16_verify/src/verify.nr`, `bn254_pairing/src/g1.nr`, `bn254_pairing/src/g2.nr` | Open |
| F-02 | Low | SP1 fast path | MSM table and VK must be trusted constants | `groth16_verify/src/verify.nr`, `groth16_verify/src/config/sp1.nr` | Open |
| F-03 | Informational | Non-native arithmetic | Limb canonicalization relies on `bignum` constraints | `bn254_pairing/src/fp.nr`, `sp1_verify_example/src/main.nr` | Open |

## 6) Detailed Findings

### F-01: Missing on-curve and subgroup checks for proof points
**Severity:** High  
**Impact:** A malicious prover can supply invalid points (off-curve or not in the correct subgroup), potentially forging verification by exploiting invalid-curve or small-subgroup behavior in the pairing. In Groth16, the pairing check is only sound when proof points are on-curve and in the correct subgroup (especially for G2).  
**Root Cause:** `verify` and `verify_sp1_fast` accept proof points and pass them directly into `pairing_multi` without validating membership. The library exposes `is_on_curve_g1_affine` and `is_on_curve_g2_affine` but does not use them in the verifier.  
**Affected Code References:**  
- `verify` uses proof points directly in the pairing check without validation (`verify.nr`).  
- On-curve checks are available in `g1.nr` and `g2.nr` but are not invoked.  
**Suggested Fix:**  
- Enforce on-curve checks for `proof.a`, `proof.b`, and `proof.c` before the pairing.  
- For G2, add a subgroup check (cofactor clearing or a BN254-specific subgroup test using the endomorphism `psi`), and reject points not in the r-torsion subgroup.  
- Consider rejecting points at infinity unless explicitly allowed by the protocol.  
**Suggested Tests / PoCs:**  
- Provide a proof with `B` not in the correct G2 subgroup and show current verifier can be satisfied.  
- Add negative tests for off-curve points and infinity points that must fail verification.

### F-02: MSM table and VK must be trusted constants
**Severity:** Low  
**Impact:** If `verify_sp1_fast` is called with a witness-controlled MSM table or VK, the verifier can be trivially satisfied with arbitrary proofs because the linear combination `L` can be manipulated.  
**Root Cause:** The fast path accepts the MSM table and VK as parameters, but the function does not enforce them to be constants or consistent with the intended SP1 verifying key.  
**Affected Code References:**  
- `verify_sp1_fast` signature accepts `msm2_w3_table` and `vk` (`verify.nr`).  
**Suggested Fix:**  
- For production circuits, wrap `verify_sp1_fast` with a function that sources `vk` and `msm2_w3_table` from constants and does not expose them as inputs.  
- Optionally add a hash commitment to the table and VK if they must remain public inputs.  
**Suggested Tests / PoCs:**  
- Construct a circuit using `verify_sp1_fast` with a witness-controlled table and show the pairing check can be satisfied with an invalid proof.

### F-03: Limb canonicalization relies on `bignum` constraints
**Severity:** Informational  
**Impact:** If `Fp::from_limbs` or `BN254_Fq` construction does not enforce limb ranges and reduction, equality checks and arithmetic could become unsound (e.g., non-canonical encodings).  
**Root Cause:** This repo does not add explicit range checks around limb inputs; it relies on the external `bignum` library to constrain them.  
**Affected Code References:**  
- `Fp` is a type alias to `BN254_Fq` (`fp.nr`).  
- Example circuits construct points from raw limb arrays (`sp1_verify_example/src/main.nr`).  
**Suggested Fix:**  
- Confirm `bignum` enforces limb bounds and modular reduction.  
- If not guaranteed, add explicit limb range checks or canonicalization when constructing points from limbs.  
**Suggested Tests / PoCs:**  
- Feed limb values exceeding the modulus and verify the circuit rejects or normalizes them.

## 7) What Is Correct / Why It Is Secure

### Field Towers and Arithmetic
- Fp2 uses Karatsuba multiplication and complex squaring consistent with `u^2 = -1`. The `Fp2` inverse computes `(a0 - a1*u) / (a0^2 + a1^2)`, which is standard.
- Fp6 and Fp12 use known Karatsuba and sparse multiplication patterns to reduce the number of Fp2 multiplications. These match textbook constructions for BN curves.
- Test vectors for Fp2/Fp6/Fp12 operations validate add/sub/mul/square/inverse properties.

### Miller Loop and Line Evaluations
- The pairing uses an optimal Ate Miller loop with signed-NAF digits of the BN parameter. This reduces loop length and keeps line evaluations sparse.
- Line evaluation coefficients are represented in sparse Fp12 slots and combined using specialized multiplication (`mul_by_034`, `mul_by_01234`), preserving correctness while saving constraints.

### Final Exponentiation
- The easy part uses conjugation, inversion, and Frobenius squares to map into the cyclotomic subgroup.
- The hard part uses cyclotomic squaring and a fixed exponentiation chain (Fuentes-Castaneda et al. 2011), which is standard for BN254 and preserves correctness in GT.

### Groth16 Verification Logic
- The verifier computes the linear combination `L = IC_0 + sum_i IC_{i+1} * input_i` and checks the product of three pairings against `alpha_beta`.
- The pairing product is consistent with Groth16 when proof points and VK are valid and in the correct subgroups.

### SP1 Fast Path
- The SP1 public input derivation uses SHA256 and masks to 253 bits, matching the documented SP1 format.
- The 2-scalar MSM uses a 3-bit joint window (Straus/Shamir) and a precomputed table, which is correct when the table corresponds to `(a*IC1 + b*IC2)` for each window digit pair.

## 8) Recommendations & Hardening Checklist (Prioritized)
1. **Add on-curve checks** for `A`, `B`, `C` in Groth16 verification.
2. **Add G2 subgroup checks** for `B` (and any other G2 inputs) or perform cofactor clearing.
3. **Reject points at infinity** unless the protocol explicitly permits them.
4. **Document trust boundaries** for verifying keys and MSM tables; prefer constants in production circuits.
5. **Validate limb encoding constraints** for any external inputs constructed via `Fp::from_limbs`.
6. **Add negative tests** for off-curve and small-subgroup points.

## 9) Appendix

### Key Equations
- Pairing definition: `e: G1 x G2 -> GT`, bilinear and non-degenerate.
- Groth16 check: `e(A, B) * e(C, -delta) * e(L, -gamma) == e(alpha, beta)`.
- Linear combination: `L = IC_0 + sum_i input_i * IC_{i+1}`.
- SP1 input hashing: `input1 = SHA256(public_values) & ((1 << 253) - 1)` (big-endian).

### References
- Barreto and Naehrig (2006): BN curves.
- Aranha et al. (2010): Optimal Ate pairing.
- Karabina (2010): Cyclotomic squaring.
- Fuentes-Castaneda, Knapp, Rodriguez-Henriquez (2011): Final exponentiation chains.
- Groth (2016): Groth16 zkSNARK.
- SP1 Noir spec: `groth16_verify/SP1_NOIR_SPEC.md`.
