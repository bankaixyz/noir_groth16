#!/usr/bin/env python3
import json
import sys

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


def main():
    if len(sys.argv) != 2:
        print("Usage: convert_sp1_proof.py <input.json>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1], "r", encoding="utf-8") as f:
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


if __name__ == "__main__":
    main()
