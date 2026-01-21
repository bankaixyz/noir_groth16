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


def toml_limbs(limbs) -> str:
    return f'["{limbs[0]}", "{limbs[1]}", "{limbs[2]}"]'


def toml_fp(limbs) -> str:
    return f"{{ limbs = {toml_limbs(limbs)} }}"


def toml_fp2(fp2) -> str:
    return f"{{ c0 = {toml_fp(fp2[0])}, c1 = {toml_fp(fp2[1])} }}"


def toml_line_eval(line) -> str:
    return f"{{ r0 = {toml_fp2(line[0])}, r1 = {toml_fp2(line[1])}, r2 = {toml_fp2(line[2])} }}"


def toml_line_triplet(triplet) -> str:
    items = ", ".join(toml_line_eval(line) for line in triplet)
    return f"[ {items} ]"


def toml_g2_proj(p) -> str:
    return f"{{ x = {toml_fp2(p[0])}, y = {toml_fp2(p[1])}, z = {toml_fp2(p[2])} }}"


def toml_double_witness(w) -> str:
    return f"{{ a = {toml_fp2(w[0])}, b = {toml_fp2(w[1])}, c = {toml_fp2(w[2])}, ee = {toml_fp2(w[3])} }}"


def toml_add_witness(w) -> str:
    names = ["c", "d", "e", "f", "g", "t1", "t2"]
    parts = [f"{name} = {toml_fp2(value)}" for name, value in zip(names, w)]
    return "{ " + ", ".join(parts) + " }"


def toml_line_compute_witness(w) -> str:
    return f"{{ t2 = {toml_fp2(w[0])} }}"


def print_array(name: str, values, formatter) -> None:
    print(f"{name} = [")
    for value in values:
        print(f"  {formatter(value)},")
    print("]")


def print_line_triplet_array(name: str, values) -> None:
    print(f"{name} = [")
    for value in values:
        print(f"  {toml_line_triplet(value)},")
    print("]")


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
            lines = witness["lines"]
            print("")
            print("# Line schedule (evaluated at P)")
            print("[lines]")
            print_array("initial_doubles", lines["initial_doubles"], toml_line_eval)
            print_array("pre_loop_lines", lines["pre_loop_lines"], toml_line_eval)
            print_array("pre_loop_adds", lines["pre_loop_adds"], toml_line_eval)
            print_line_triplet_array("loop_doubles", lines["loop_doubles"])
            print_line_triplet_array("loop_adds_pos", lines["loop_adds_pos"])
            print_line_triplet_array("loop_adds_neg", lines["loop_adds_neg"])
            print_array("final_adds", lines["final_adds"], toml_line_eval)
            print_array("final_lines", lines["final_lines"], toml_line_eval)

            raw = witness["b_lines_raw"]
            print("")
            print("# Raw line coefficients for B")
            print("[b_lines_raw]")
            print(f"initial_double = {toml_line_eval(raw['initial_double'])}")
            print(f"pre_loop_line = {toml_line_eval(raw['pre_loop_line'])}")
            print(f"pre_loop_add = {toml_line_eval(raw['pre_loop_add'])}")
            print_array("loop_doubles", raw["loop_doubles"], toml_line_eval)
            print_array("loop_adds_pos", raw["loop_adds_pos"], toml_line_eval)
            print_array("loop_adds_neg", raw["loop_adds_neg"], toml_line_eval)
            print(f"final_add = {toml_line_eval(raw['final_add'])}")
            print(f"final_line = {toml_line_eval(raw['final_line'])}")

            b_witness = witness["b_line_witness"]
            print("")
            print("# Line witness intermediates for B")
            print("[b_line_witness]")
            print_array("double_witnesses", b_witness["double_witnesses"], toml_double_witness)
            print_array("double_outputs", b_witness["double_outputs"], toml_g2_proj)
            print(f"pre_loop_line_witness = {toml_line_compute_witness(b_witness['pre_loop_line_witness'])}")
            print(f"pre_loop_add_witness = {toml_add_witness(b_witness['pre_loop_add_witness'])}")
            print(f"pre_loop_add_output = {toml_g2_proj(b_witness['pre_loop_add_output'])}")
            print_array("loop_add_witness_pos", b_witness["loop_add_witness_pos"], toml_add_witness)
            print_array("loop_add_witness_neg", b_witness["loop_add_witness_neg"], toml_add_witness)
            print_array("loop_add_outputs", b_witness["loop_add_outputs"], toml_g2_proj)
            print(f"final_add_witness = {toml_add_witness(b_witness['final_add_witness'])}")
            print(f"final_add_output = {toml_g2_proj(b_witness['final_add_output'])}")
            print(f"final_line_witness = {toml_line_compute_witness(b_witness['final_line_witness'])}")


if __name__ == "__main__":
    main()
