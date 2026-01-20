# Randomized Fp12 Checks Review Report
Date: 2026-01-20

Scope: Compare `RANDOMIZED_FP12_CHECKS_SPEC.md` to current implementation
(`bn254_pairing`, `groth16_verify`, `sp1_verify_example`) and evaluate
spec correctness vs. observed constraints.

## Summary
- The randomized check machinery exists, but several spec requirements are
  not met (public seed, limb range checks, full coverage of Fp2 multiplies).
- Those gaps are both soundness risks and likely reasons constraints do not
  drop in practice.
- The spec is directionally correct, but expected savings appear optimistic
  unless you also address the remaining non-native multiplications outside
  the Fp12 mul/square path.

## Spec deviations (root spec vs implementation)

1) Seed is private, not public
- Spec: `RANDOMIZED_FP12_CHECKS_SPEC.md` (Soundness Requirements) requires a
  public seed used to derive `rho` and `alpha`.
- Implementation: `sp1_verify_example/src/main.nr` `main_randomized` takes
  `seed: Field` without `pub`, so it is a private witness input.
- Impact: prover can choose `rho`/`alpha`, breaking soundness.

2) Limb range checks for `c` and `q` are missing
- Spec: `RANDOMIZED_FP12_CHECKS_SPEC.md` (Randomized Check Design) requires
  range checks on limb triples for `c` and `q`.
- Implementation: `bn254_pairing/src/randomized_check.nr` uses
  `fp_from_limbs_unchecked` and never calls `assert_fp_limbs_in_range`.
- Note: `groth16_verify/SP1_NOIR_SPEC.md` explicitly says limbs are not
  range-checked, which conflicts with the root spec.
- Impact: the polynomial check can be satisfied with unconstrained limb
  choices, weakening soundness.

3) Fp2 multiplications in the pairing path are still non-randomized
- Spec: replace Fp2/Fp6/Fp12 multiplications and squarings used in the pairing
  path.
- Implementation:
  - `bn254_pairing/src/fp12.nr::mul_034_by_034` uses `Fp2.mul` (non-randomized).
  - `bn254_pairing/src/pairing.nr::line_eval_at_point` uses
    `Fp2.mul_by_element` (non-randomized).
- These operations are used throughout the Miller loop even in
  `pairing_check_with_preimage_randomized`.
- Impact: a large fraction of non-native multiplications remains.

4) Randomized entrypoint is not the default circuit entry
- `sp1_verify_example` defaults to `main` (non-randomized) and
  `Prover.toml` does not include `seed` or `trace`.
- Unless you switch to `main_randomized` and provide the randomized trace,
  constraint measurements will reflect the old circuit.

5) Extra linear checks for each Fp12 output (not in spec)
- `bn254_pairing/src/fp12.nr::check_fp12_linear` adds 12 accumulator checks
  per Fp12 output.
- Impact: small but reduces net savings vs. the spec assumptions.

6) `c.inverse()` still uses full non-native arithmetic
- `pairing_check_with_preimage_randomized` computes `c_inv = c.inverse()`
  using standard Fp12 operations (non-randomized).
- Impact: some large multiplications are still present.

## Likely causes for "no constraint drop"
- Measurements taken on the non-randomized entrypoint (`main`) instead of
  `main_randomized`.
- Remaining non-randomized Fp2/Fp operations (`mul_034_by_034`,
  `line_eval_at_point`, and G2 arithmetic) dominate the constraint count.
- Poseidon + extra linear checks offset part of the gains.
- If `get_limbs()` in the bignum library introduces range/decomposition
  constraints, per-multiplication checks may be more expensive than expected.

## Spec correctness evaluation

What is correct:
- Using randomized limb polynomial checks with `rho`/`alpha` derived from a
  verifier-controlled seed is standard and sound.
- The need for limb range checks is real; without them the check can be
  satisfied by unconstrained witnesses.

What is incomplete/optimistic:
- Expected constraint reductions assume Fp12 muls dominate, but in this code
  path many non-native multiplications occur outside Fp12 mul/square
  (line evaluation, `mul_034_by_034`, G2 arithmetic).
- The spec does not account for Poseidon overhead and the extra linear checks
  currently used to bind Fp12 outputs.

## Recommendations
- Make `seed` a public input at the entrypoint (e.g., `seed: pub Field`).
- Add limb range checks for `c` and `q` (or document why they are already
  range constrained elsewhere).
- Randomize or precompute the remaining Fp2 multiplications in the Miller
  loop (`mul_034_by_034`, `line_eval_at_point`) if the goal is a measurable
  constraint reduction.
- Update the example/prover inputs to use `main_randomized` plus a trace so
  constraint measurements reflect the randomized path.
- Re-estimate expected savings after removing Fp12 muls to validate the
  spec's reduction target.
