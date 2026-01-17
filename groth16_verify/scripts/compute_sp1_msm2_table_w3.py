#!/usr/bin/env python3
"""
Compute the SP1 MSM2 w=3 joint-window table:

  T[a + 8*b] = a*ic1 + b*ic2  for a,b in 0..7

Limb format matches the repo's convention (3 limbs of 120 bits).
The output is intended to be pasted into `groth16_verify/src/config/sp1.nr`.
"""

from __future__ import annotations


P = 21888242871839275222246405745257275088696311157297823662689037894645226208583

LIMB_BITS = 120
LIMB_MASK = (1 << LIMB_BITS) - 1


def from_limbs(l0: int, l1: int, l2: int) -> int:
    return (l0 & LIMB_MASK) + ((l1 & LIMB_MASK) << LIMB_BITS) + (l2 << (2 * LIMB_BITS))


def to_limbs(x: int) -> tuple[int, int, int]:
    x %= P
    l0 = x & LIMB_MASK
    l1 = (x >> LIMB_BITS) & LIMB_MASK
    l2 = x >> (2 * LIMB_BITS)
    return (l0, l1, l2)


def inv(x: int) -> int:
    return pow(x, P - 2, P)


def is_on_curve(x: int, y: int) -> bool:
    return (y * y - (x * x * x + 3)) % P == 0


def add_affine(p1: tuple[int, int] | None, p2: tuple[int, int] | None) -> tuple[int, int] | None:
    if p1 is None:
        return p2
    if p2 is None:
        return p1

    x1, y1 = p1
    x2, y2 = p2

    if x1 == x2:
        if (y1 - y2) % P != 0:
            return None
        lam = (3 * x1 * x1) * inv((2 * y1) % P) % P
    else:
        lam = ((y2 - y1) % P) * inv((x2 - x1) % P) % P

    x3 = (lam * lam - x1 - x2) % P
    y3 = (lam * (x1 - x3) - y1) % P
    return (x3, y3)


def mul_small(p: tuple[int, int] | None, k: int) -> tuple[int, int] | None:
    acc: tuple[int, int] | None = None
    for _ in range(k):
        acc = add_affine(acc, p)
    return acc


def fmt_fp_from_limbs(x: int) -> str:
    l0, l1, l2 = to_limbs(x)
    return f"fp_from_limbs({hex(l0)}, {hex(l1)}, {hex(l2)})"


def main() -> None:
    # Copied from `groth16_verify/src/config/sp1.nr`
    ic1_x = from_limbs(0xED36C6EC878755E537C1C48951FB4C, 0x3FD0FD3DA25D2607C227D090CCA750, 0x61C)
    ic1_y = from_limbs(0x5E9A273E6119A212DD09EB51707219, 0x7AE9C2033379DF7B5C65EFF0E10705, 0xFA1)
    ic2_x = from_limbs(0xFDEC51A16028DEE020634FD129E71C, 0xB241388A79817FE0E0E2EAD0B2EC4F, 0x4EA)
    ic2_y = from_limbs(0xA9E16FCA56B18D5544B0889A65C1F5, 0x6256D21C60D02F0BDBF95CFF83E03E, 0x723)

    if not is_on_curve(ic1_x, ic1_y) or not is_on_curve(ic2_x, ic2_y):
        raise SystemExit("ic1/ic2 not on curve; limb packing mismatch")

    ic1 = (ic1_x, ic1_y)
    ic2 = (ic2_x, ic2_y)

    # Precompute small multiples 0..7
    ic1_mul = [mul_small(ic1, i) for i in range(8)]
    ic2_mul = [mul_small(ic2, j) for j in range(8)]

    table: list[tuple[int, int] | None] = []
    for b in range(8):
        for a in range(8):
            pt = add_affine(ic1_mul[a], ic2_mul[b])
            table.append(pt)

    if len(table) != 64:
        raise SystemExit("table size mismatch")

    # Verify table entries
    for idx, pt in enumerate(table):
        if idx == 0:
            if pt is not None:
                raise SystemExit("index 0 should be infinity")
            continue
        if pt is None:
            raise SystemExit(f"unexpected infinity at idx={idx}")
        x, y = pt
        if not is_on_curve(x, y):
            raise SystemExit(f"point off curve at idx={idx}")

    print("Paste into `sp1_msm2_w3_table()` as a literal array (index = a + 8*b):")
    print("")
    print("[")
    for idx, pt in enumerate(table):
        if pt is None:
            print("    g1_affine_infinity(),")
        else:
            x, y = pt
            print("    G1Affine {")
            print(f"        x: {fmt_fp_from_limbs(x)},")
            print(f"        y: {fmt_fp_from_limbs(y)},")
            print("    },")
    print("]")


if __name__ == "__main__":
    main()

