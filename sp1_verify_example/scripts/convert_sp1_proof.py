#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from pathlib import Path

LIMB_BITS = 120
LIMB_MASK = (1 << LIMB_BITS) - 1


def to_limbs(value: int):
    l0 = value & LIMB_MASK
    l1 = (value >> LIMB_BITS) & LIMB_MASK
    l2 = value >> (2 * LIMB_BITS)
    return [l0, l1, l2]


def hex_to_bytes(hex_str: str) -> bytes:
    s = hex_str[2:] if hex_str.startswith("0x") else hex_str
    if len(s) % 2 != 0:
        s = "0" + s
    return bytes.fromhex(s)


def load_pairing_check_witness(input_path: str) -> dict:
    script_path = (
        Path(__file__).resolve().parents[2]
        / "groth16_verify"
        / "scripts"
        / "compute_sp1_pairing_check_witness.py"
    )
    output = subprocess.check_output(
        [sys.executable, str(script_path), "--proof-json", input_path, "--format", "json"]
    )
    return json.loads(output.decode("utf-8"))


def toml_inline_table(data: dict) -> str:
    parts = []
    for key, value in data.items():
        parts.append(f"{key} = {json.dumps(value)}")
    return "{ " + ", ".join(parts) + " }"


def main():
    parser = argparse.ArgumentParser(description="Convert SP1 proof JSON to Noir inputs")
    parser.add_argument("input_json", help="SP1 proof JSON (proof/publicValues/vkey)")
    parser.add_argument("--no-witness", action="store_true", help="Skip pairing-check witness generation")
    args = parser.parse_args()

    with open(args.input_json, "r", encoding="utf-8") as f:
        data = json.load(f)

    proof_hex = data["proof"]
    public_values_hex = data["publicValues"]
    vkey_hex = data["vkey"]

    proof_bytes = hex_to_bytes(proof_hex)
    if len(proof_bytes) < 4 + 8 * 32:
        raise ValueError("proof hex too short")

    offset = 4
    def read_field():
        nonlocal offset
        chunk = proof_bytes[offset:offset + 32]
        if len(chunk) != 32:
            raise ValueError("unexpected proof length")
        offset += 32
        return int.from_bytes(chunk, "big")

    a_x = read_field()
    a_y = read_field()
    b_x_c1 = read_field()
    b_x_c0 = read_field()
    b_y_c1 = read_field()
    b_y_c0 = read_field()
    c_x = read_field()
    c_y = read_field()

    vkey_int = int.from_bytes(hex_to_bytes(vkey_hex), "big")
    public_values_bytes = list(hex_to_bytes(public_values_hex))

    def fmt_limbs(name, value):
        limbs = to_limbs(value)
        return f'{name} = ["{limbs[0]}", "{limbs[1]}", "{limbs[2]}"]'

    print("# SP1 Groth16 Proof Test Data")
    print("# Limb format: [low_120bits, mid_120bits, high_bits] as decimal strings")
    print("")
    print("# Proof point A (G1)")
    print(fmt_limbs("a_x", a_x))
    print(fmt_limbs("a_y", a_y))
    print("")
    print("# Proof point B (G2) - EIP-197 ordering applies to proof bytes")
    print(fmt_limbs("b_x_c0", b_x_c0))
    print(fmt_limbs("b_x_c1", b_x_c1))
    print(fmt_limbs("b_y_c0", b_y_c0))
    print(fmt_limbs("b_y_c1", b_y_c1))
    print("")
    print("# Proof point C (G1)")
    print(fmt_limbs("c_x", c_x))
    print(fmt_limbs("c_y", c_y))
    print("")
    print("# SP1 program verification key")
    print(f'vkey = "{vkey_int}"')
    print("")
    print("# SP1 public values (32 bytes)")
    print(f"public_values = {public_values_bytes}")

    if not args.no_witness:
        witness = load_pairing_check_witness(args.input_json)
        print("")
        print("# PairingCheck witnesses (Fp12)")
        print("c = [")
        for row in witness["c"]:
            print(f'  ["{row[0]}", "{row[1]}", "{row[2]}"],')
        print("]")
        print("w = [")
        for row in witness["w"]:
            print(f'  ["{row[0]}", "{row[1]}", "{row[2]}"],')
        print("]")

        if "lines" in witness:
            print("")
            print("# Line schedule (evaluated at P)")
            print(f"lines = {toml_inline_table(witness['lines'])}")
            print("")
            print("# Raw line coefficients for B")
            print(f"b_lines_raw = {toml_inline_table(witness['b_lines_raw'])}")
            print("")
            print("# Line witness intermediates for B")
            print(f"b_line_witness = {toml_inline_table(witness['b_line_witness'])}")


if __name__ == "__main__":
    main()
