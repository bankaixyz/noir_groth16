#!/usr/bin/env python3
"""
Compute ic1 + ic2 for the SP1 Groth16 verifying key (G1 over BN254 Fq).

This is an offline helper so we can hardcode `sp1_ic1_plus_ic2()` in
`groth16_verify/src/config/sp1.nr` and avoid paying constraints to compute it.

Limb format matches the existing tooling in this repo:
- 3 limbs of 120 bits: [low_120, mid_120, high_bits]
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


def main() -> None:
    # These are copied from `groth16_verify/src/config/sp1.nr`
    ic1_x = from_limbs(0xED36C6EC878755E537C1C48951FB4C, 0x3FD0FD3DA25D2607C227D090CCA750, 0x61C)
    ic1_y = from_limbs(0x5E9A273E6119A212DD09EB51707219, 0x7AE9C2033379DF7B5C65EFF0E10705, 0xFA1)

    ic2_x = from_limbs(0xFDEC51A16028DEE020634FD129E71C, 0xB241388A79817FE0E0E2EAD0B2EC4F, 0x4EA)
    ic2_y = from_limbs(0xA9E16FCA56B18D5544B0889A65C1F5, 0x6256D21C60D02F0BDBF95CFF83E03E, 0x723)

    if not is_on_curve(ic1_x, ic1_y):
        raise SystemExit("ic1 is not on curve (check limb packing)")
    if not is_on_curve(ic2_x, ic2_y):
        raise SystemExit("ic2 is not on curve (check limb packing)")

    r = add_affine((ic1_x, ic1_y), (ic2_x, ic2_y))
    if r is None:
        raise SystemExit("ic1 + ic2 is infinity (unexpected)")
    rx, ry = r

    if not is_on_curve(rx, ry):
        raise SystemExit("ic1 + ic2 result is not on curve (unexpected)")

    x0, x1, x2 = to_limbs(rx)
    y0, y1, y2 = to_limbs(ry)

    print("sp1_ic1_plus_ic2.x limbs (hex):", hex(x0), hex(x1), hex(x2))
    print("sp1_ic1_plus_ic2.y limbs (hex):", hex(y0), hex(y1), hex(y2))
    print()
    print("Paste into Noir:")
    print(
        f"x: fp_from_limbs({hex(x0)}, {hex(x1)}, {hex(x2)}),\\n"
        f"y: fp_from_limbs({hex(y0)}, {hex(y1)}, {hex(y2)}),"
    )


if __name__ == \"__main__\":
    main()

