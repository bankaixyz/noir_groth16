# Groth16 SP1 Verify Example

This example circuit verifies a Groth16 proof produced by SP1. The inputs are
the SP1-encoded proof bytes, verification key bytes, and the 32-byte public
values.

## Running the example

```bash
nargo compile
nargo execute
bb write_vk -b ./target/sp1_verify_example.json -o target
bb prove -b ./target/sp1_verify_example.json -w ./target/sp1_verify_example.gz -k target/vk -o target
```

## Inputs and files

- `Prover.toml`: circuit inputs consumed by `nargo execute`
- `bankai_1.json`: example SP1 proof bundle used as the source input
- `proof.json`: the raw SP1 proof JSON that you can convert into `Prover.toml`

### SP1 proof bundle format (`bankai_1.json`)

This file matches SP1's encoding exactly and contains:

- `proof`: hex-encoded Groth16 proof bytes as emitted by SP1. The byte stream
  starts with a 4-byte header; the first 3 bytes are the ASCII `SP1` prefix and
  the remaining header byte is skipped by the converter. After the header, the
  proof is the concatenation of proof points `A` (G1), `B` (G2), and `C` (G1) in
  EIP-197 ordering. The converter unpacks these into `a_x`, `a_y`, `b_x_c0`,
  `b_x_c1`, `b_y_c0`, `b_y_c1`, `c_x`, `c_y` (each 32-byte, big-endian field
  elements).
- `publicValues`: 32-byte hex-encoded public values (exactly 32 bytes).
- `vkey`: hex-encoded SP1 program verification key bytes (converted to a
  single big-endian integer in `Prover.toml`).

## Generating inputs

If you already have an SP1 proof JSON, convert it to the circuit inputs like
this:

```bash
python3 scripts/convert_sp1_proof.py proof.json > Prover.toml
```

## Performance

Current constraint count: 1.65 constraints.