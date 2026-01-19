#!/usr/bin/env python3
"""
Compute the inverse of a BN254 Miller loop result in Fp12.

The script reads `src/tests/bn254_miller_loop_vectors.json` by default and
selects a test case by name. It can also accept a JSON file with a
`miller_loop_result` object or a flat object with the same fields.
"""

from __future__ import annotations

import argparse
import json
import pathlib
from typing import Any, Dict, Tuple


P = int(
    "0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47",
    16,
)
LIMB_BITS = 120
LIMB_MASK = (1 << LIMB_BITS) - 1

Fp = int
Fp2 = Tuple[Fp, Fp]
Fp6 = Tuple[Fp2, Fp2, Fp2]
Fp12 = Tuple[Fp6, Fp6]

FP12_KEYS = (
    "c0_b0_a0",
    "c0_b0_a1",
    "c0_b1_a0",
    "c0_b1_a1",
    "c0_b2_a0",
    "c0_b2_a1",
    "c1_b0_a0",
    "c1_b0_a1",
    "c1_b1_a0",
    "c1_b1_a1",
    "c1_b2_a0",
    "c1_b2_a1",
)


def mod(x: int) -> int:
    return x % P


def fp_neg(a: Fp) -> Fp:
    return (-a) % P


def fp_add(a: Fp, b: Fp) -> Fp:
    return (a + b) % P


def fp_sub(a: Fp, b: Fp) -> Fp:
    return (a - b) % P


def fp_mul(a: Fp, b: Fp) -> Fp:
    return (a * b) % P


def fp_inv(a: Fp) -> Fp:
    return pow(a, P - 2, P)


def fp2_add(a: Fp2, b: Fp2) -> Fp2:
    return (fp_add(a[0], b[0]), fp_add(a[1], b[1]))


def fp2_sub(a: Fp2, b: Fp2) -> Fp2:
    return (fp_sub(a[0], b[0]), fp_sub(a[1], b[1]))


def fp2_neg(a: Fp2) -> Fp2:
    return (fp_neg(a[0]), fp_neg(a[1]))


def fp2_double(a: Fp2) -> Fp2:
    return (fp_add(a[0], a[0]), fp_add(a[1], a[1]))


def fp2_mul(a: Fp2, b: Fp2) -> Fp2:
    a0, a1 = a
    b0, b1 = b
    t0 = fp_mul(fp_add(a0, a1), fp_add(b0, b1))
    t1 = fp_mul(a0, b0)
    t2 = fp_mul(a1, b1)
    return (fp_sub(t1, t2), fp_sub(fp_sub(t0, t1), t2))


def fp2_square(a: Fp2) -> Fp2:
    a0, a1 = a
    t0 = fp_mul(fp_add(a0, a1), fp_sub(a0, a1))
    t1 = fp_mul(a0, a1)
    return (t0, fp_add(t1, t1))


def fp2_inv(a: Fp2) -> Fp2:
    a0, a1 = a
    t0 = fp_mul(a0, a0)
    t1 = fp_mul(a1, a1)
    inv = fp_inv(fp_add(t0, t1))
    return (fp_mul(a0, inv), fp_neg(fp_mul(a1, inv)))


def fp2_mul_by_non_residue(a: Fp2) -> Fp2:
    a0, a1 = a
    return (fp_sub(fp_mul(9, a0), a1), fp_add(a0, fp_mul(9, a1)))


def fp6_add(a: Fp6, b: Fp6) -> Fp6:
    return (fp2_add(a[0], b[0]), fp2_add(a[1], b[1]), fp2_add(a[2], b[2]))


def fp6_sub(a: Fp6, b: Fp6) -> Fp6:
    return (fp2_sub(a[0], b[0]), fp2_sub(a[1], b[1]), fp2_sub(a[2], b[2]))


def fp6_neg(a: Fp6) -> Fp6:
    return (fp2_neg(a[0]), fp2_neg(a[1]), fp2_neg(a[2]))


def fp6_mul_by_non_residue(a: Fp6) -> Fp6:
    b0, b1, b2 = a
    return (fp2_mul_by_non_residue(b2), b0, b1)


def fp6_mul(a: Fp6, b: Fp6) -> Fp6:
    a0, a1, a2 = a
    b0, b1, b2 = b
    t0 = fp2_mul(a0, b0)
    t1 = fp2_mul(a1, b1)
    t2 = fp2_mul(a2, b2)

    c0 = fp2_mul(fp2_add(a1, a2), fp2_add(b1, b2))
    c0 = fp2_sub(c0, t1)
    c0 = fp2_sub(c0, t2)
    c0 = fp2_add(fp2_mul_by_non_residue(c0), t0)

    c1 = fp2_mul(fp2_add(a0, a1), fp2_add(b0, b1))
    c1 = fp2_sub(c1, t0)
    c1 = fp2_sub(c1, t1)
    c1 = fp2_add(c1, fp2_mul_by_non_residue(t2))

    c2 = fp2_mul(fp2_add(a0, a2), fp2_add(b0, b2))
    c2 = fp2_sub(c2, t0)
    c2 = fp2_sub(c2, t2)
    c2 = fp2_add(c2, t1)

    return (c0, c1, c2)


def fp6_square(a: Fp6) -> Fp6:
    a0, a1, a2 = a
    c4 = fp2_double(fp2_mul(a0, a1))
    c5 = fp2_square(a2)
    c1 = fp2_add(fp2_mul_by_non_residue(c5), c4)
    c2 = fp2_sub(c4, c5)
    c3 = fp2_square(a0)
    c4 = fp2_square(fp2_add(fp2_sub(a0, a1), a2))
    c5 = fp2_double(fp2_mul(a1, a2))
    c0 = fp2_add(fp2_mul_by_non_residue(c5), c3)
    b2 = fp2_sub(fp2_add(fp2_add(c2, c4), c5), c3)
    return (c0, c1, b2)


def fp6_inv(a: Fp6) -> Fp6:
    b0, b1, b2 = a
    t0 = fp2_square(b0)
    t1 = fp2_square(b1)
    t2 = fp2_square(b2)
    t3 = fp2_mul(b0, b1)
    t4 = fp2_mul(b0, b2)
    t5 = fp2_mul(b1, b2)

    c0 = fp2_sub(t0, fp2_mul_by_non_residue(t5))
    c1 = fp2_sub(fp2_mul_by_non_residue(t2), t3)
    c2 = fp2_sub(t1, t4)

    t6 = fp2_mul(b0, c0)
    d1 = fp2_mul(b2, c1)
    d2 = fp2_mul(b1, c2)
    d1 = fp2_mul_by_non_residue(fp2_add(d1, d2))
    t6 = fp2_add(t6, d1)
    t6 = fp2_inv(t6)

    return (fp2_mul(c0, t6), fp2_mul(c1, t6), fp2_mul(c2, t6))


def fp12_mul(a: Fp12, b: Fp12) -> Fp12:
    a0, a1 = a
    b0, b1 = b
    t0 = fp6_mul(fp6_add(a0, a1), fp6_add(b0, b1))
    t1 = fp6_mul(a0, b0)
    t2 = fp6_mul(a1, b1)
    c1 = fp6_sub(fp6_sub(t0, t1), t2)
    c0 = fp6_add(fp6_mul_by_non_residue(t2), t1)
    return (c0, c1)


def fp12_inv(a: Fp12) -> Fp12:
    c0, c1 = a
    t0 = fp6_square(c0)
    t1 = fp6_square(c1)
    t0 = fp6_sub(t0, fp6_mul_by_non_residue(t1))
    t1 = fp6_inv(t0)
    return (fp6_mul(c0, t1), fp6_neg(fp6_mul(c1, t1)))


def fp12_one() -> Fp12:
    fp2_zero: Fp2 = (0, 0)
    fp2_one: Fp2 = (1, 0)
    fp6_zero: Fp6 = (fp2_zero, fp2_zero, fp2_zero)
    fp6_one: Fp6 = (fp2_one, fp2_zero, fp2_zero)
    return (fp6_one, fp6_zero)


def parse_hex(value: Any) -> int:
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        return int(value, 16)
    raise TypeError(f"Unsupported value type: {type(value)}")


def fp12_from_dict(data: Dict[str, Any]) -> Fp12:
    def get(name: str) -> Fp:
        return mod(parse_hex(data[name]))

    c0_b0 = (get("c0_b0_a0"), get("c0_b0_a1"))
    c0_b1 = (get("c0_b1_a0"), get("c0_b1_a1"))
    c0_b2 = (get("c0_b2_a0"), get("c0_b2_a1"))
    c1_b0 = (get("c1_b0_a0"), get("c1_b0_a1"))
    c1_b1 = (get("c1_b1_a0"), get("c1_b1_a1"))
    c1_b2 = (get("c1_b2_a0"), get("c1_b2_a1"))
    return ((c0_b0, c0_b1, c0_b2), (c1_b0, c1_b1, c1_b2))


def fp12_to_hex_dict(z: Fp12) -> Dict[str, str]:
    (c0_b0, c0_b1, c0_b2), (c1_b0, c1_b1, c1_b2) = z
    return {
        "c0_b0_a0": hex(c0_b0[0]),
        "c0_b0_a1": hex(c0_b0[1]),
        "c0_b1_a0": hex(c0_b1[0]),
        "c0_b1_a1": hex(c0_b1[1]),
        "c0_b2_a0": hex(c0_b2[0]),
        "c0_b2_a1": hex(c0_b2[1]),
        "c1_b0_a0": hex(c1_b0[0]),
        "c1_b0_a1": hex(c1_b0[1]),
        "c1_b1_a0": hex(c1_b1[0]),
        "c1_b1_a1": hex(c1_b1[1]),
        "c1_b2_a0": hex(c1_b2[0]),
        "c1_b2_a1": hex(c1_b2[1]),
    }


def to_limbs(x: int) -> Tuple[int, int, int]:
    x = mod(x)
    l0 = x & LIMB_MASK
    l1 = (x >> LIMB_BITS) & LIMB_MASK
    l2 = x >> (2 * LIMB_BITS)
    return (l0, l1, l2)


def format_fp(x: int) -> str:
    l0, l1, l2 = to_limbs(x)
    return f"Fp::from_limbs([{hex(l0)}, {hex(l1)}, {hex(l2)}])"


def format_fp2(x: Fp2) -> str:
    return f"Fp2 {{ c0: {format_fp(x[0])}, c1: {format_fp(x[1])} }}"


def format_fp6(x: Fp6, indent: str) -> str:
    b0, b1, b2 = x
    inner = indent + "    "
    return (
        "Fp6 {\n"
        f"{inner}b0: {format_fp2(b0)},\n"
        f"{inner}b1: {format_fp2(b1)},\n"
        f"{inner}b2: {format_fp2(b2)},\n"
        f"{indent}}}"
    )


def format_fp12(x: Fp12) -> str:
    c0, c1 = x
    return (
        "Fp12 {\n"
        f"    c0: {format_fp6(c0, '    ')},\n"
        f"    c1: {format_fp6(c1, '    ')},\n"
        "}"
    )


def load_fp12_from_input(path: pathlib.Path, case_name: str | None) -> Fp12:
    data = json.loads(path.read_text())

    if isinstance(data, dict) and "test_cases" in data:
        if case_name is None:
            raise SystemExit("Provide --case when using a vector file.")
        for case in data["test_cases"]:
            if case.get("name") == case_name:
                return fp12_from_dict(case["miller_loop_result"])
        names = ", ".join(case["name"] for case in data["test_cases"])
        raise SystemExit(f"Case '{case_name}' not found. Available: {names}")

    if isinstance(data, dict) and "miller_loop_result" in data:
        return fp12_from_dict(data["miller_loop_result"])

    if isinstance(data, dict) and all(key in data for key in FP12_KEYS):
        return fp12_from_dict(data)

    raise SystemExit("Input JSON missing miller loop fields.")


def main() -> None:
    default_vectors = pathlib.Path(__file__).resolve().parents[1] / "src/tests/bn254_miller_loop_vectors.json"
    parser = argparse.ArgumentParser(description="Compute inverse of a Miller loop result.")
    parser.add_argument(
        "--input",
        type=pathlib.Path,
        default=default_vectors,
        help="Path to vector JSON or a file containing miller_loop_result fields.",
    )
    parser.add_argument(
        "--case",
        default="single_generators",
        help="Test case name (only used when --input is a vector file).",
    )
    parser.add_argument(
        "--format",
        choices=("json", "noir", "both"),
        default="both",
        help="Output format.",
    )
    args = parser.parse_args()

    fp12_val = load_fp12_from_input(args.input, args.case)
    fp12_inv_val = fp12_inv(fp12_val)
    if fp12_mul(fp12_val, fp12_inv_val) != fp12_one():
        raise SystemExit("Inverse check failed (z * z_inv != 1).")

    if args.format in ("json", "both"):
        print(json.dumps(fp12_to_hex_dict(fp12_inv_val), indent=2))
    if args.format in ("noir", "both"):
        if args.format == "both":
            print("")
        print(format_fp12(fp12_inv_val))


if __name__ == "__main__":
    main()
