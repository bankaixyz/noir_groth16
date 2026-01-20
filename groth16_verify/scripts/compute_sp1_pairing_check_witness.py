#!/usr/bin/env python3
"""
Compute t_preimage and PairingCheck witnesses (c, w) for SP1.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import sys
from dataclasses import dataclass
from typing import Iterable, List, Tuple


P = 21888242871839275222246405745257275088696311157297823662689037894645226208583
R = 21888242871839275222246405745257275088548364400416034343698204186575808495617
X = 4965661367192848881

LIMB_BITS = 120
LIMB_MASK = (1 << LIMB_BITS) - 1
INV_TWO = (P + 1) // 2


def fp_from_limbs(l0: int, l1: int, l2: int) -> int:
    return (l0 & LIMB_MASK) + ((l1 & LIMB_MASK) << LIMB_BITS) + (l2 << (2 * LIMB_BITS))


def fp_to_limbs(x: int) -> Tuple[int, int, int]:
    x %= P
    return (x & LIMB_MASK, (x >> LIMB_BITS) & LIMB_MASK, x >> (2 * LIMB_BITS))


def fp_add(a: int, b: int) -> int:
    return (a + b) % P


def fp_sub(a: int, b: int) -> int:
    return (a - b) % P


def fp_mul(a: int, b: int) -> int:
    return (a * b) % P


def fp_inv(a: int) -> int:
    return pow(a, P - 2, P)


@dataclass(frozen=True)
class Fp2:
    c0: int
    c1: int

    def add(self, other: "Fp2") -> "Fp2":
        return Fp2(fp_add(self.c0, other.c0), fp_add(self.c1, other.c1))

    def sub(self, other: "Fp2") -> "Fp2":
        return Fp2(fp_sub(self.c0, other.c0), fp_sub(self.c1, other.c1))

    def neg(self) -> "Fp2":
        return Fp2((-self.c0) % P, (-self.c1) % P)

    def double(self) -> "Fp2":
        return Fp2(fp_add(self.c0, self.c0), fp_add(self.c1, self.c1))

    def halve(self) -> "Fp2":
        return self.mul_by_element(INV_TWO)

    def conjugate(self) -> "Fp2":
        return Fp2(self.c0, (-self.c1) % P)

    def mul(self, other: "Fp2") -> "Fp2":
        a = fp_mul(fp_add(self.c0, self.c1), fp_add(other.c0, other.c1))
        b = fp_mul(self.c0, other.c0)
        c = fp_mul(self.c1, other.c1)
        return Fp2(fp_sub(b, c), fp_sub(fp_sub(a, b), c))

    def square(self) -> "Fp2":
        a = fp_mul(fp_add(self.c0, self.c1), fp_sub(self.c0, self.c1))
        b = fp_mul(self.c0, self.c1)
        b = fp_add(b, b)
        return Fp2(a, b)

    def inverse(self) -> "Fp2":
        t0 = fp_mul(self.c0, self.c0)
        t1 = fp_mul(self.c1, self.c1)
        t0 = fp_add(t0, t1)
        t1 = fp_inv(t0)
        return Fp2(fp_mul(self.c0, t1), (-fp_mul(self.c1, t1)) % P)

    def mul_by_non_residue(self) -> "Fp2":
        two_a0 = fp_add(self.c0, self.c0)
        four_a0 = fp_add(two_a0, two_a0)
        eight_a0 = fp_add(four_a0, four_a0)
        nine_a0 = fp_add(eight_a0, self.c0)

        two_a1 = fp_add(self.c1, self.c1)
        four_a1 = fp_add(two_a1, two_a1)
        eight_a1 = fp_add(four_a1, four_a1)
        nine_a1 = fp_add(eight_a1, self.c1)

        return Fp2(fp_sub(nine_a0, self.c1), fp_add(self.c0, nine_a1))

    def mul_by_element(self, element: int) -> "Fp2":
        return Fp2(fp_mul(self.c0, element), fp_mul(self.c1, element))

    def mul_by_b_twist_coeff(self) -> "Fp2":
        return self.mul(B_TWIST)

    def mul_by_non_residue_1_power_2(self) -> "Fp2":
        return self.mul(FROB_1_2)

    def mul_by_non_residue_1_power_1(self) -> "Fp2":
        return self.mul(FROB_1_1)

    def mul_by_non_residue_1_power_3(self) -> "Fp2":
        return self.mul(FROB_1_3)

    def mul_by_non_residue_1_power_4(self) -> "Fp2":
        return self.mul(FROB_1_4)

    def mul_by_non_residue_1_power_5(self) -> "Fp2":
        return self.mul(FROB_1_5)

    def mul_by_non_residue_2_power_2(self) -> "Fp2":
        return self.mul_by_element(FROB_2_2)

    def mul_by_non_residue_2_power_1(self) -> "Fp2":
        return self.mul_by_element(FROB_2_1)

    def mul_by_non_residue_2_power_3(self) -> "Fp2":
        return self.mul_by_element(FROB_2_3)

    def mul_by_non_residue_2_power_4(self) -> "Fp2":
        return self.mul_by_element(FROB_2_4)

    def mul_by_non_residue_2_power_5(self) -> "Fp2":
        return self.mul_by_element(FROB_2_5)

    def mul_by_non_residue_3_power_1(self) -> "Fp2":
        return self.mul(FROB_3_1)

    def mul_by_non_residue_3_power_2(self) -> "Fp2":
        return self.mul(FROB_3_2)

    def mul_by_non_residue_3_power_3(self) -> "Fp2":
        return self.mul(FROB_3_3)

    def mul_by_non_residue_3_power_4(self) -> "Fp2":
        return self.mul(FROB_3_4)

    def mul_by_non_residue_3_power_5(self) -> "Fp2":
        return self.mul(FROB_3_5)

    def is_zero(self) -> bool:
        return self.c0 == 0 and self.c1 == 0

    def is_one(self) -> bool:
        return self.c0 == 1 and self.c1 == 0


def fp2_zero() -> Fp2:
    return Fp2(0, 0)


def fp2_one() -> Fp2:
    return Fp2(1, 0)


@dataclass(frozen=True)
class Fp6:
    b0: Fp2
    b1: Fp2
    b2: Fp2

    def add(self, other: "Fp6") -> "Fp6":
        return Fp6(self.b0.add(other.b0), self.b1.add(other.b1), self.b2.add(other.b2))

    def sub(self, other: "Fp6") -> "Fp6":
        return Fp6(self.b0.sub(other.b0), self.b1.sub(other.b1), self.b2.sub(other.b2))

    def neg(self) -> "Fp6":
        return Fp6(self.b0.neg(), self.b1.neg(), self.b2.neg())

    def double(self) -> "Fp6":
        return Fp6(self.b0.double(), self.b1.double(), self.b2.double())

    def mul_by_non_residue(self) -> "Fp6":
        return Fp6(self.b2.mul_by_non_residue(), self.b0, self.b1)

    def mul_by_e2(self, c0: Fp2) -> "Fp6":
        return Fp6(self.b0.mul(c0), self.b1.mul(c0), self.b2.mul(c0))

    def mul(self, other: "Fp6") -> "Fp6":
        t0 = self.b0.mul(other.b0)
        t1 = self.b1.mul(other.b1)
        t2 = self.b2.mul(other.b2)

        c0 = self.b1.add(self.b2).mul(other.b1.add(other.b2))
        c0 = c0.sub(t1).sub(t2)
        c0 = c0.mul_by_non_residue().add(t0)

        c1 = self.b0.add(self.b1).mul(other.b0.add(other.b1))
        c1 = c1.sub(t0).sub(t1)
        c1 = c1.add(t2.mul_by_non_residue())

        c2 = self.b0.add(self.b2).mul(other.b0.add(other.b2))
        c2 = c2.sub(t0).sub(t2).add(t1)

        return Fp6(c0, c1, c2)

    def square(self) -> "Fp6":
        c4 = self.b0.mul(self.b1).double()
        c5 = self.b2.square()
        c1 = c5.mul_by_non_residue().add(c4)
        c2 = c4.sub(c5)
        c3 = self.b0.square()
        c4 = self.b0.sub(self.b1).add(self.b2).square()
        c5 = self.b1.mul(self.b2).double()
        c0 = c5.mul_by_non_residue().add(c3)

        b2 = c2.add(c4).add(c5).sub(c3)
        return Fp6(c0, c1, b2)

    def inverse(self) -> "Fp6":
        t0 = self.b0.square()
        t1 = self.b1.square()
        t2 = self.b2.square()
        t3 = self.b0.mul(self.b1)
        t4 = self.b0.mul(self.b2)
        t5 = self.b1.mul(self.b2)

        c0 = t0.sub(t5.mul_by_non_residue())
        c1 = t2.mul_by_non_residue().sub(t3)
        c2 = t1.sub(t4)

        t6 = self.b0.mul(c0)
        d1 = self.b2.mul(c1)
        d2 = self.b1.mul(c2)
        d1 = d1.add(d2).mul_by_non_residue()
        t6 = t6.add(d1)
        t6 = t6.inverse()

        return Fp6(c0.mul(t6), c1.mul(t6), c2.mul(t6))

    def mul_by_01(self, c0: Fp2, c1: Fp2) -> "Fp6":
        a = self.b0.mul(c0)
        b = self.b1.mul(c1)

        t0 = c1.mul(self.b1.add(self.b2))
        t0 = t0.sub(b).mul_by_non_residue().add(a)

        t2 = c0.mul(self.b0.add(self.b2))
        t2 = t2.sub(a).add(b)

        t1 = c0.add(c1).mul(self.b0.add(self.b1))
        t1 = t1.sub(a).sub(b)

        return Fp6(t0, t1, t2)

    def mul_by_12(self, b1: Fp2, b2: Fp2) -> "Fp6":
        t1 = self.b1.mul(b1)
        t2 = self.b2.mul(b2)

        c0 = self.b1.add(self.b2).mul(b1.add(b2))
        c0 = c0.sub(t1).sub(t2).mul_by_non_residue()

        c1 = self.b0.add(self.b1).mul(b1)
        c1 = c1.sub(t1).add(t2.mul_by_non_residue())

        c2 = b2.mul(self.b0.add(self.b2))
        c2 = c2.sub(t2).add(t1)

        return Fp6(c0, c1, c2)

    def is_zero(self) -> bool:
        return self.b0.is_zero() and self.b1.is_zero() and self.b2.is_zero()

    def is_one(self) -> bool:
        return self.b0.is_one() and self.b1.is_zero() and self.b2.is_zero()

    def pow(self, exponent: int) -> "Fp6":
        result = fp6_one()
        base = self
        exp = exponent
        while exp > 0:
            if exp & 1:
                result = result.mul(base)
            base = base.square()
            exp >>= 1
        return result


def fp6_zero() -> Fp6:
    return Fp6(fp2_zero(), fp2_zero(), fp2_zero())


def fp6_one() -> Fp6:
    return Fp6(fp2_one(), fp2_zero(), fp2_zero())


@dataclass(frozen=True)
class Fp12:
    c0: Fp6
    c1: Fp6

    @staticmethod
    def zero() -> "Fp12":
        return Fp12(fp6_zero(), fp6_zero())

    @staticmethod
    def one() -> "Fp12":
        return Fp12(fp6_one(), fp6_zero())

    def is_one(self) -> bool:
        return self.c0.is_one() and self.c1.is_zero()

    def add(self, other: "Fp12") -> "Fp12":
        return Fp12(self.c0.add(other.c0), self.c1.add(other.c1))

    def sub(self, other: "Fp12") -> "Fp12":
        return Fp12(self.c0.sub(other.c0), self.c1.sub(other.c1))

    def neg(self) -> "Fp12":
        return Fp12(self.c0.neg(), self.c1.neg())

    def conjugate(self) -> "Fp12":
        return Fp12(self.c0, self.c1.neg())

    def mul(self, other: "Fp12") -> "Fp12":
        a = self.c0.add(self.c1).mul(other.c0.add(other.c1))
        b = self.c0.mul(other.c0)
        c = self.c1.mul(other.c1)
        c1 = a.sub(b).sub(c)
        c0 = c.mul_by_non_residue().add(b)
        return Fp12(c0, c1)

    def square(self) -> "Fp12":
        a = self.c0
        b = self.c1
        ab = a.mul(b)
        c0 = a.square().add(b.square().mul_by_non_residue())
        c1 = ab.double()
        return Fp12(c0, c1)

    def cyclotomic_square(self) -> "Fp12":
        t0 = self.c1.b1.square()
        t1 = self.c0.b0.square()
        t6 = (self.c1.b1.add(self.c0.b0)).square().sub(t0).sub(t1)
        t2 = self.c0.b2.square()
        t3 = self.c1.b0.square()
        t7 = (self.c0.b2.add(self.c1.b0)).square().sub(t2).sub(t3)
        t4 = self.c1.b2.square()
        t5 = self.c0.b1.square()
        t8 = (self.c1.b2.add(self.c0.b1)).square().sub(t4).sub(t5).mul_by_non_residue()

        t0 = t0.mul_by_non_residue().add(t1)
        t2 = t2.mul_by_non_residue().add(t3)
        t4 = t4.mul_by_non_residue().add(t5)

        z0 = t0.sub(self.c0.b0).double().add(t0)
        z1 = t2.sub(self.c0.b1).double().add(t2)
        z2 = t4.sub(self.c0.b2).double().add(t4)

        z3 = t8.add(self.c1.b0).double().add(t8)
        z4 = t6.add(self.c1.b1).double().add(t6)
        z5 = t7.add(self.c1.b2).double().add(t7)

        return Fp12(Fp6(z0, z1, z2), Fp6(z3, z4, z5))

    def n_square(self, n: int) -> "Fp12":
        result = self
        for _ in range(n):
            result = result.cyclotomic_square()
        return result

    def expt(self) -> "Fp12":
        x = self
        t3 = x.cyclotomic_square()
        t5 = t3.cyclotomic_square()
        result = t5.cyclotomic_square()
        t0 = result.cyclotomic_square()
        t2 = x.mul(t0)
        t0 = t3.mul(t2)
        t1 = x.mul(t0)
        t4 = result.mul(t2)
        t6 = t2.cyclotomic_square()
        t1 = t0.mul(t1)
        t0 = t3.mul(t1)
        t6 = t6.n_square(6)
        t5 = t5.mul(t6)
        t5 = t4.mul(t5)
        t5 = t5.n_square(7)
        t4 = t4.mul(t5)
        t4 = t4.n_square(8)
        t4 = t4.mul(t0)
        t3 = t3.mul(t4)
        t3 = t3.n_square(6)
        t2 = t2.mul(t3)
        t2 = t2.n_square(8)
        t2 = t2.mul(t0)
        t2 = t2.n_square(6)
        t2 = t2.mul(t0)
        t2 = t2.n_square(10)
        t1 = t1.mul(t2)
        t1 = t1.n_square(6)
        t0 = t0.mul(t1)
        result = result.mul(t0)
        return result
    def inverse(self) -> "Fp12":
        t0 = self.c0.square()
        t1 = self.c1.square()
        t0 = t0.sub(t1.mul_by_non_residue())
        t1 = t0.inverse()
        return Fp12(self.c0.mul(t1), self.c1.mul(t1).neg())

    def mul_by_034(self, c0: Fp2, c3: Fp2, c4: Fp2) -> "Fp12":
        a = self.c0.mul_by_e2(c0)
        b = self.c1.mul_by_01(c3, c4)
        d0 = c0.add(c3)
        d = self.c0.add(self.c1).mul_by_01(d0, c4)
        c1 = d.sub(a).sub(b)
        c0 = b.mul_by_non_residue().add(a)
        return Fp12(c0, c1)

    def mul_by_01234(self, x: List[Fp2]) -> "Fp12":
        c0 = Fp6(x[0], x[1], x[2])
        c1 = Fp6(x[3], x[4], fp2_zero())

        a = self.c0.add(self.c1).mul(c0.add(c1))
        b = self.c0.mul(c0)
        c = self.c1.mul_by_01(x[3], x[4])

        c1 = a.sub(b).sub(c)
        c0 = c.mul_by_non_residue().add(b)
        return Fp12(c0, c1)

    def pow(self, exponent: int) -> "Fp12":
        result = Fp12.one()
        base = self
        exp = exponent
        while exp > 0:
            if exp & 1:
                result = result.mul(base)
            base = base.square()
            exp >>= 1
        return result

    def frobenius(self) -> "Fp12":
        t0 = self.c0.b0.conjugate()
        t1 = self.c0.b1.conjugate().mul_by_non_residue_1_power_2()
        t2 = self.c0.b2.conjugate().mul_by_non_residue_1_power_4()
        t3 = self.c1.b0.conjugate().mul_by_non_residue_1_power_1()
        t4 = self.c1.b1.conjugate().mul_by_non_residue_1_power_3()
        t5 = self.c1.b2.conjugate().mul_by_non_residue_1_power_5()
        return Fp12(Fp6(t0, t1, t2), Fp6(t3, t4, t5))

    def frobenius_square(self) -> "Fp12":
        t0 = self.c0.b0
        t1 = self.c0.b1.mul_by_non_residue_2_power_2()
        t2 = self.c0.b2.mul_by_non_residue_2_power_4()
        t3 = self.c1.b0.mul_by_non_residue_2_power_1()
        t4 = self.c1.b1.mul_by_non_residue_2_power_3()
        t5 = self.c1.b2.mul_by_non_residue_2_power_5()
        return Fp12(Fp6(t0, t1, t2), Fp6(t3, t4, t5))

    def frobenius_cube(self) -> "Fp12":
        t0 = self.c0.b0.conjugate()
        t1 = self.c0.b1.conjugate().mul_by_non_residue_3_power_2()
        t2 = self.c0.b2.conjugate().mul_by_non_residue_3_power_4()
        t3 = self.c1.b0.conjugate().mul_by_non_residue_3_power_1()
        t4 = self.c1.b1.conjugate().mul_by_non_residue_3_power_3()
        t5 = self.c1.b2.conjugate().mul_by_non_residue_3_power_5()
        return Fp12(Fp6(t0, t1, t2), Fp6(t3, t4, t5))


@dataclass(frozen=True)
class Mul034Witness:
    x0: Fp2
    x3: Fp2
    x4: Fp2
    x04: Fp2
    x03: Fp2
    x34: Fp2


def mul_034_by_034_with_witness(
    d0: Fp2, d3: Fp2, d4: Fp2, c0: Fp2, c3: Fp2, c4: Fp2
) -> Tuple[List[Fp2], Mul034Witness]:
    x0 = c0.mul(d0)
    x3 = c3.mul(d3)
    x4 = c4.mul(d4)

    x04 = c0.add(c4).mul(d0.add(d4)).sub(x0).sub(x4)
    x03 = c0.add(c3).mul(d0.add(d3)).sub(x0).sub(x3)
    x34 = c3.add(c4).mul(d3.add(d4)).sub(x3).sub(x4)

    z00 = x4.mul_by_non_residue().add(x0)
    witness = Mul034Witness(x0=x0, x3=x3, x4=x4, x04=x04, x03=x03, x34=x34)
    return [z00, x3, x34, x03, x04], witness


def mul_034_by_034(d0: Fp2, d3: Fp2, d4: Fp2, c0: Fp2, c3: Fp2, c4: Fp2) -> List[Fp2]:
    result, _ = mul_034_by_034_with_witness(d0, d3, d4, c0, c3, c4)
    return result


@dataclass(frozen=True)
class G1Affine:
    x: int
    y: int

    def is_infinity(self) -> bool:
        return self.x == 0 and self.y == 0


@dataclass(frozen=True)
class G1Jac:
    x: int
    y: int
    z: int

    def is_infinity(self) -> bool:
        return self.z == 0


def g1_affine_infinity() -> G1Affine:
    return G1Affine(0, 0)


def g1_jacobian_infinity() -> G1Jac:
    return G1Jac(1, 1, 0)


def g1_affine_to_jac(p: G1Affine) -> G1Jac:
    if p.is_infinity():
        return g1_jacobian_infinity()
    return G1Jac(p.x, p.y, 1)


def jacobian_to_affine_g1(p: G1Jac) -> G1Affine:
    if p.is_infinity():
        return g1_affine_infinity()
    a = fp_inv(p.z)
    b = fp_mul(a, a)
    x = fp_mul(p.x, b)
    y = fp_mul(fp_mul(p.y, b), a)
    return G1Affine(x, y)


def add_g1_jac(p: G1Jac, q: G1Jac) -> G1Jac:
    if p.is_infinity():
        return q
    if q.is_infinity():
        return p

    z1z1 = fp_mul(q.z, q.z)
    z2z2 = fp_mul(p.z, p.z)
    u1 = fp_mul(q.x, z2z2)
    u2 = fp_mul(p.x, z1z1)
    s1 = fp_mul(fp_mul(q.y, p.z), z2z2)
    s2 = fp_mul(fp_mul(p.y, q.z), z1z1)

    if u1 == u2 and s1 == s2:
        return double_g1_jac(p)

    h = fp_sub(u2, u1)
    i = fp_mul(fp_add(h, h), fp_add(h, h))
    j = fp_mul(h, i)
    r = fp_mul(2, fp_sub(s2, s1))
    v = fp_mul(u1, i)

    x3 = fp_sub(fp_sub(fp_mul(r, r), j), fp_add(v, v))
    y3 = fp_sub(fp_mul(r, fp_sub(v, x3)), fp_mul(fp_add(s1, s1), j))
    z3 = fp_mul(fp_sub(fp_sub(fp_mul(fp_add(p.z, q.z), fp_add(p.z, q.z)), z1z1), z2z2), h)
    return G1Jac(x3, y3, z3)


def double_g1_jac(p: G1Jac) -> G1Jac:
    a = fp_mul(p.x, p.x)
    b = fp_mul(p.y, p.y)
    c = fp_mul(b, b)
    d = fp_mul(2, fp_sub(fp_sub(fp_mul(fp_add(p.x, b), fp_add(p.x, b)), a), c))
    e = fp_mul(3, a)
    f = fp_mul(e, e)
    t = fp_add(d, d)

    z3 = fp_mul(fp_mul(2, p.y), p.z)
    x3 = fp_sub(f, t)
    y3 = fp_sub(fp_mul(e, fp_sub(d, x3)), fp_mul(8, c))
    return G1Jac(x3, y3, z3)


def scalar_mul_g1(p: G1Affine, scalar: int) -> G1Affine:
    acc = g1_jacobian_infinity()
    base = g1_affine_to_jac(p)
    k = scalar
    for _ in range(254):
        if k & 1:
            acc = add_g1_jac(acc, base)
        base = double_g1_jac(base)
        k >>= 1
    return jacobian_to_affine_g1(acc)


@dataclass(frozen=True)
class G2Affine:
    x: Fp2
    y: Fp2

    def is_infinity(self) -> bool:
        return self.x.is_zero() and self.y.is_zero()

    def neg(self) -> "G2Affine":
        return G2Affine(self.x, self.y.neg())


@dataclass(frozen=True)
class G2Proj:
    x: Fp2
    y: Fp2
    z: Fp2

    def double_step(self) -> Tuple["G2Proj", "LineEvaluation"]:
        a = self.x.mul(self.y).halve()
        b = self.y.square()
        c = self.z.square()
        d = c.mul_by_element(3)
        e = d.mul_by_b_twist_coeff()
        f = e.mul_by_element(3)
        g = b.add(f).halve()
        h = self.y.add(self.z).square().sub(b).sub(c)
        i = e.sub(b)
        j = self.x.square()
        ee = e.square()
        k = ee.mul_by_element(3)

        x = b.sub(f).mul(a)
        y = g.square().sub(k)
        z = b.mul(h)

        line = LineEvaluation(
            r0=h.neg(),
            r1=j.mul_by_element(3),
            r2=i,
        )
        return G2Proj(x, y, z), line

    def add_mixed_step(self, a: "G2Affine") -> Tuple["G2Proj", "LineEvaluation"]:
        y2z1 = a.y.mul(self.z)
        o = self.y.sub(y2z1)
        x2z1 = a.x.mul(self.z)
        l = self.x.sub(x2z1)
        c = o.square()
        d = l.square()
        e = l.mul(d)
        f = self.z.mul(c)
        g = self.x.mul(d)
        t0 = g.double()
        h = e.add(f).sub(t0)
        t1 = self.y.mul(e)

        x = l.mul(h)
        y = g.sub(h).mul(o).sub(t1)
        z = e.mul(self.z)

        t2 = l.mul(a.y)
        j = a.x.mul(o).sub(t2)
        line = LineEvaluation(r0=l, r1=o.neg(), r2=j)

        return G2Proj(x, y, z), line

    def line_compute(self, a: "G2Affine") -> Tuple["G2Proj", "LineEvaluation"]:
        y2z1 = a.y.mul(self.z)
        o = self.y.sub(y2z1)
        x2z1 = a.x.mul(self.z)
        l = self.x.sub(x2z1)
        t2 = l.mul(a.y)
        j = a.x.mul(o).sub(t2)
        line = LineEvaluation(r0=l, r1=o.neg(), r2=j)
        return self, line


@dataclass(frozen=True)
class LineEvaluation:
    r0: Fp2
    r1: Fp2
    r2: Fp2


def projective_from_affine_g2(a: G2Affine) -> G2Proj:
    if a.is_infinity():
        return G2Proj(fp2_one(), fp2_one(), fp2_zero())
    return G2Proj(a.x, a.y, fp2_one())


def frobenius_g2(q: G2Affine) -> G2Affine:
    x = q.x.conjugate().mul_by_non_residue_1_power_2()
    y = q.y.conjugate().mul_by_non_residue_1_power_3()
    return G2Affine(x, y)


def frobenius_square_g2(q: G2Affine) -> G2Affine:
    x = q.x.mul_by_non_residue_2_power_2()
    y = q.y.mul_by_non_residue_2_power_3().neg()
    return G2Affine(x, y)


def line_eval_at_point(line: LineEvaluation, p: G1Affine) -> LineEvaluation:
    return LineEvaluation(
        r0=line.r0.mul_by_element(p.y),
        r1=line.r1.mul_by_element(p.x),
        r2=line.r2,
    )


def loop_counter() -> List[int]:
    value = 6 * X + 2
    naf: List[int] = []
    while value > 0:
        if value & 1:
            z = 2 - (value & 3)
            if z == 2:
                z = -1
            naf.append(z)
            value -= z
        else:
            naf.append(0)
        value >>= 1
    return naf


def compute_fixed_lines(q: G2Affine) -> List[LineEvaluation]:
    q_proj = projective_from_affine_g2(q)
    q_neg = q.neg()
    lines: List[LineEvaluation] = []

    q_proj, line = q_proj.double_step()
    lines.append(line)

    q_proj, l2 = q_proj.line_compute(q_neg)
    lines.append(l2)
    q_proj, l1 = q_proj.add_mixed_step(q)
    lines.append(l1)

    digits = loop_counter()
    for idx in range(63):
        i = 62 - idx
        q_proj, l1 = q_proj.double_step()
        lines.append(l1)
        if digits[i] == 1:
            q_proj, l2 = q_proj.add_mixed_step(q)
            lines.append(l2)
        elif digits[i] == -1:
            q_proj, l2 = q_proj.add_mixed_step(q_neg)
            lines.append(l2)

    q1 = frobenius_g2(q)
    q2 = frobenius_square_g2(q)
    q_proj, l2 = q_proj.add_mixed_step(q1)
    lines.append(l2)
    q_proj, l1 = q_proj.line_compute(q2)
    lines.append(l1)

    if len(lines) != 88:
        raise RuntimeError(f"unexpected line count: {len(lines)}")
    return lines


def mul_034_by_034_record(
    d0: Fp2,
    d3: Fp2,
    d4: Fp2,
    c0: Fp2,
    c3: Fp2,
    c4: Fp2,
    witnesses: List[Mul034Witness] | None,
) -> List[Fp2]:
    if witnesses is None:
        return mul_034_by_034(d0, d3, d4, c0, c3, c4)
    result, witness = mul_034_by_034_with_witness(d0, d3, d4, c0, c3, c4)
    witnesses.append(witness)
    return result


def miller_loop(
    p_list: List[G1Affine],
    q_list: List[G2Affine],
    mul_witnesses: List[Mul034Witness] | None = None,
) -> Fp12:
    pairs = [(p, q) for p, q in zip(p_list, q_list) if not p.is_infinity() and not q.is_infinity()]
    n = len(pairs)
    if n == 0:
        return Fp12.one()

    p = [pair[0] for pair in pairs]
    q = [pair[1] for pair in pairs]
    q_proj = [projective_from_affine_g2(qi) for qi in q]
    q_neg = [qi.neg() for qi in q]

    result = Fp12.one()

    if n >= 1:
        q0, line = q_proj[0].double_step()
        q_proj[0] = q0
        line = line_eval_at_point(line, p[0])
        result = Fp12(
            Fp6(line.r0, fp2_zero(), fp2_zero()),
            Fp6(line.r1, line.r2, fp2_zero()),
        )

    if n >= 2:
        q1, line = q_proj[1].double_step()
        q_proj[1] = q1
        line = line_eval_at_point(line, p[1])
        prod_lines = mul_034_by_034_record(
            line.r0,
            line.r1,
            line.r2,
            result.c0.b0,
            result.c1.b0,
            result.c1.b1,
            mul_witnesses,
        )
        result = Fp12(Fp6(prod_lines[0], prod_lines[1], prod_lines[2]), Fp6(prod_lines[3], prod_lines[4], fp2_zero()))

    for k in range(2, n):
        qk, line = q_proj[k].double_step()
        q_proj[k] = qk
        line = line_eval_at_point(line, p[k])
        result = result.mul_by_034(line.r0, line.r1, line.r2)

    result = result.square()
    for k in range(n):
        qk, l2 = q_proj[k].line_compute(q_neg[k])
        q_proj[k] = qk
        l2 = line_eval_at_point(l2, p[k])

        qk, l1 = q_proj[k].add_mixed_step(q[k])
        q_proj[k] = qk
        l1 = line_eval_at_point(l1, p[k])

        prod_lines = mul_034_by_034_record(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2, mul_witnesses)
        result = result.mul_by_01234(prod_lines)

    digits = loop_counter()
    for idx in range(63):
        i = 62 - idx
        result = result.square()
        for k in range(n):
            qk, l1 = q_proj[k].double_step()
            q_proj[k] = qk
            l1 = line_eval_at_point(l1, p[k])

            if digits[i] == 1:
                qk, l2 = q_proj[k].add_mixed_step(q[k])
                q_proj[k] = qk
                l2 = line_eval_at_point(l2, p[k])
                prod_lines = mul_034_by_034_record(
                    l1.r0,
                    l1.r1,
                    l1.r2,
                    l2.r0,
                    l2.r1,
                    l2.r2,
                    mul_witnesses,
                )
                result = result.mul_by_01234(prod_lines)
            elif digits[i] == -1:
                qk, l2 = q_proj[k].add_mixed_step(q_neg[k])
                q_proj[k] = qk
                l2 = line_eval_at_point(l2, p[k])
                prod_lines = mul_034_by_034_record(
                    l1.r0,
                    l1.r1,
                    l1.r2,
                    l2.r0,
                    l2.r1,
                    l2.r2,
                    mul_witnesses,
                )
                result = result.mul_by_01234(prod_lines)
            else:
                result = result.mul_by_034(l1.r0, l1.r1, l1.r2)

    for k in range(n):
        q1 = frobenius_g2(q[k])
        q2 = frobenius_square_g2(q[k])

        qk, l2 = q_proj[k].add_mixed_step(q1)
        q_proj[k] = qk
        l2 = line_eval_at_point(l2, p[k])

        qk, l1 = q_proj[k].line_compute(q2)
        q_proj[k] = qk
        l1 = line_eval_at_point(l1, p[k])

        prod_lines = mul_034_by_034_record(l1.r0, l1.r1, l1.r2, l2.r0, l2.r1, l2.r2, mul_witnesses)
        result = result.mul_by_01234(prod_lines)

    return result


def final_exponentiation(z: Fp12) -> Fp12:
    result = final_exp_easy_part(z)
    if result.is_one():
        return result
    return final_exp_hard_part(result)


def final_exp_easy_part(z: Fp12) -> Fp12:
    t0 = z.conjugate()
    result = z.inverse()
    t0 = t0.mul(result)
    result = t0.frobenius_square().mul(t0)
    return result


def final_exp_hard_part(result: Fp12) -> Fp12:
    if result.is_one():
        return result
    t0 = result.expt()
    t0 = t0.conjugate()
    t0 = t0.cyclotomic_square()
    t1 = t0.cyclotomic_square()
    t1 = t0.mul(t1)

    t2 = t1.expt()
    t2 = t2.conjugate()

    t3 = t1.conjugate()
    t1 = t2.mul(t3)

    t3 = t2.cyclotomic_square()
    t4 = t3.expt()
    t4 = t1.mul(t4)

    t3 = t0.mul(t4)
    t0 = t2.mul(t4)
    t0 = result.mul(t0)

    t2 = t3.frobenius()
    t0 = t2.mul(t0)

    t2 = t4.frobenius_square()
    t0 = t2.mul(t0)

    t2 = result.conjugate()
    t2 = t2.mul(t3)
    t2 = t2.frobenius_cube()
    t0 = t2.mul(t0)

    return t0


def modinv(a: int, m: int) -> int:
    return pow(a, -1, m)


def find_root_27th(rng: random.Random) -> Fp12:
    exp = (P**6 - 1) // 27
    for _ in range(512):
        g = Fp6(
            Fp2(rng.randrange(P), rng.randrange(P)),
            Fp2(rng.randrange(P), rng.randrange(P)),
            Fp2(rng.randrange(P), rng.randrange(P)),
        )
        if g.is_zero():
            continue
        root = g.pow(exp)
        if root.pow(27).is_one() and not root.pow(9).is_one():
            return Fp12(root, fp6_zero())
    raise RuntimeError("failed to find 27th root")


def ord_3(z: Fp12) -> int:
    if z.is_one():
        return 0
    t = 0
    cur = z
    while True:
        cur = cur.pow(3)
        t += 1
        if cur.is_one():
            return t


def cube_root(a: Fp12, root_27th: Fp12) -> Fp12:
    q12m1 = P**12 - 1
    k = 0
    s = q12m1
    while s % 3 == 0:
        s //= 3
        k += 1
    exp = (s + 1) // 3
    x = a.pow(exp)
    a_inv = a.inverse()
    t = ord_3(x.pow(3).mul(a_inv))
    w_exp = root_27th.pow(exp)
    while t != 0:
        x = x.mul(w_exp)
        t = ord_3(x.pow(3).mul(a_inv))
    return x


def fp12_from_fp6(c0: Fp6) -> Fp12:
    return Fp12(c0, fp6_zero())


def fp12_to_coeffs(z: Fp12) -> List[int]:
    return [
        z.c0.b0.c0,
        z.c0.b0.c1,
        z.c0.b1.c0,
        z.c0.b1.c1,
        z.c0.b2.c0,
        z.c0.b2.c1,
        z.c1.b0.c0,
        z.c1.b0.c1,
        z.c1.b1.c0,
        z.c1.b1.c1,
        z.c1.b2.c0,
        z.c1.b2.c1,
    ]


def gt_pow(x: Fp12, exponent: int) -> Fp12:
    result = Fp12.one()
    base = x
    exp = exponent
    while exp > 0:
        if exp & 1:
            result = result.mul(base)
        base = base.cyclotomic_square()
        exp >>= 1
    return result


def final_exp_exponent_on_gt() -> int:
    p_mod_r = P % R
    p2_mod_r = (P * P) % R
    p3_mod_r = (P * P * P) % R

    def conj(e: int) -> int:
        return (-e) % R

    def mul(e1: int, e2: int) -> int:
        return (e1 + e2) % R

    def sq(e: int) -> int:
        return (2 * e) % R

    def frob(e: int) -> int:
        return (e * p_mod_r) % R

    def frob2(e: int) -> int:
        return (e * p2_mod_r) % R

    def frob3(e: int) -> int:
        return (e * p3_mod_r) % R

    def expt(e: int) -> int:
        return (e * X) % R

    def easy_part(e: int) -> int:
        t0 = conj(e)
        result = conj(e)
        t0 = mul(t0, result)
        result = mul(frob2(t0), t0)
        return result

    def hard_part(e: int) -> int:
        if e == 0:
            return 0
        t0 = expt(e)
        t0 = conj(t0)
        t0 = sq(t0)
        t1 = sq(t0)
        t1 = mul(t0, t1)

        t2 = expt(t1)
        t2 = conj(t2)

        t3 = conj(t1)
        t1 = mul(t2, t3)

        t3 = sq(t2)
        t4 = expt(t3)
        t4 = mul(t1, t4)

        t3 = mul(t0, t4)
        t0 = mul(t2, t4)
        t0 = mul(e, t0)

        t2 = frob(t3)
        t0 = mul(t2, t0)

        t2 = frob2(t4)
        t0 = mul(t2, t0)

        t2 = conj(e)
        t2 = mul(t2, t3)
        t2 = frob3(t2)
        t0 = mul(t2, t0)

        return t0

    return hard_part(easy_part(1))


def compute_t_preimage(alpha_beta: Fp12) -> Fp12:
    alpha_beta_inv = alpha_beta.inverse()
    e = final_exp_exponent_on_gt()
    k = modinv(e, R)
    t_preimage = gt_pow(alpha_beta_inv, k)
    if fp12_to_coeffs(final_exponentiation(t_preimage)) != fp12_to_coeffs(alpha_beta_inv):
        raise RuntimeError("t_preimage failed FE check")
    return t_preimage


def compute_sp1_public_inputs(vkey: int, public_values: bytes) -> Tuple[int, int]:
    digest = hashlib.sha256(public_values).digest()
    masked = bytearray(digest)
    masked[0] &= 0x1F
    return vkey, int.from_bytes(masked, "big")


def parse_proof_bytes(proof_hex: str) -> Tuple[G1Affine, G2Affine, G1Affine]:
    s = proof_hex[2:] if proof_hex.startswith("0x") else proof_hex
    proof_bytes = bytes.fromhex(s)
    if len(proof_bytes) < 4 + 8 * 32:
        raise ValueError("proof hex too short")

    offset = 4

    def read_field() -> int:
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

    a = G1Affine(a_x, a_y)
    b = G2Affine(Fp2(b_x_c0, b_x_c1), Fp2(b_y_c0, b_y_c1))
    c = G1Affine(c_x, c_y)
    return a, b, c


def compute_linear_combination(input0: int, input1: int) -> G1Affine:
    term1 = scalar_mul_g1(SP1_IC1, input0)
    term2 = scalar_mul_g1(SP1_IC2, input1)
    acc = add_g1_jac(g1_affine_to_jac(SP1_IC0), g1_affine_to_jac(term1))
    acc = add_g1_jac(acc, g1_affine_to_jac(term2))
    return jacobian_to_affine_g1(acc)


def compute_witness(
    a: G1Affine,
    b: G2Affine,
    c: G1Affine,
    input0: int,
    input1: int,
    mul_witnesses: List[Mul034Witness] | None = None,
) -> Tuple[Fp12, Fp12]:
    l = compute_linear_combination(input0, input1)
    f = miller_loop([a, c, l], [b, SP1_DELTA_NEG, SP1_GAMMA_NEG], mul_witnesses)
    f_t = f.mul(sp1_t_preimage())

    rng = random.Random(0)
    root_27th = find_root_27th(rng)
    exp = (P**12 - 1) // 3
    w = None
    for s in range(3):
        w_candidate = root_27th.pow(s)
        if f_t.mul(w_candidate).pow(exp).is_one():
            w = w_candidate
            break
    if w is None:
        raise RuntimeError("failed to find cube residue adjustment")

    u = f_t.mul(w)
    h = (P**12 - 1) // R
    r_inv = modinv(R, h)
    u1 = u.pow(r_inv)
    lambda_val = 6 * X + 2 + P - P**2 + P**3
    m = lambda_val // R
    d = math.gcd(m, h)
    m_prime = m // d
    m_inv = modinv(m_prime, h)
    u2 = u1.pow(m_inv)
    c_wit = cube_root(u2, root_27th)

    return c_wit, w


def limbs_as_strings(values: Iterable[int]) -> List[str]:
    return [str(v) for v in values]


def fp12_to_limb_list(z: Fp12) -> List[List[str]]:
    return [limbs_as_strings(fp_to_limbs(coeff)) for coeff in fp12_to_coeffs(z)]


def fp2_to_limb_list(z: Fp2) -> List[List[str]]:
    l0, l1, l2 = fp_to_limbs(z.c0)
    r0, r1, r2 = fp_to_limbs(z.c1)
    return [limbs_as_strings([l0, l1, l2]), limbs_as_strings([r0, r1, r2])]


def mul_witness_to_limb_list(wit: Mul034Witness) -> List[List[str]]:
    out: List[List[str]] = []
    for fp2 in [wit.x0, wit.x3, wit.x4, wit.x04, wit.x03, wit.x34]:
        out.extend(fp2_to_limb_list(fp2))
    return out


def emit_fp12_noir(z: Fp12) -> str:
    coeffs = fp12_to_coeffs(z)
    fp2s = [
        Fp2(coeffs[0], coeffs[1]),
        Fp2(coeffs[2], coeffs[3]),
        Fp2(coeffs[4], coeffs[5]),
        Fp2(coeffs[6], coeffs[7]),
        Fp2(coeffs[8], coeffs[9]),
        Fp2(coeffs[10], coeffs[11]),
    ]
    names = ["c0_b0", "c0_b1", "c0_b2", "c1_b0", "c1_b1", "c1_b2"]
    lines = []
    for name, fp2 in zip(names, fp2s):
        l0, l1, l2 = fp_to_limbs(fp2.c0)
        r0, r1, r2 = fp_to_limbs(fp2.c1)
        lines.append(
            f"    let {name} = fp2_from_limbs([{hex(l0)}, {hex(l1)}, {hex(l2)}], "
            f"[{hex(r0)}, {hex(r1)}, {hex(r2)}]);"
        )
    lines.append("    fp12_from(fp6_from(c0_b0, c0_b1, c0_b2), fp6_from(c1_b0, c1_b1, c1_b2))")
    return "\n".join(lines)


def emit_fp2_noir(z: Fp2) -> str:
    l0, l1, l2 = fp_to_limbs(z.c0)
    r0, r1, r2 = fp_to_limbs(z.c1)
    return (
        f"fp2_from_limbs([{hex(l0)}, {hex(l1)}, {hex(l2)}], "
        f"[{hex(r0)}, {hex(r1)}, {hex(r2)}])"
    )


def emit_line_evals_noir(name: str, lines: List[LineEvaluation]) -> str:
    entries = []
    for line in lines:
        entries.append(
            "        LineEvaluation {\n"
            f"            r0: {emit_fp2_noir(line.r0)},\n"
            f"            r1: {emit_fp2_noir(line.r1)},\n"
            f"            r2: {emit_fp2_noir(line.r2)},\n"
            "        },"
        )
    body = "\n".join(entries)
    return f"pub fn {name}() -> [LineEvaluation; {len(lines)}] {{\n    [\n{body}\n    ]\n}}"


def main() -> None:
    parser = argparse.ArgumentParser(description="SP1 PairingCheck witness generator")
    parser.add_argument("--proof-json", help="SP1 proof JSON (proof/publicValues/vkey)")
    parser.add_argument("--format", choices=["json", "toml"], default="json")
    parser.add_argument("--no-validate", action="store_true")
    parser.add_argument("--print-t-preimage", action="store_true")
    parser.add_argument("--print-fixed-lines", action="store_true")
    parser.add_argument("--include-mul-witnesses", action="store_true")
    parser.add_argument("--output", help="Write output to file")
    args = parser.parse_args()

    outputs: List[str] = []

    if args.print_t_preimage:
        outputs.append("fn sp1_t_preimage() -> Fp12 {")
        outputs.append(emit_fp12_noir(sp1_t_preimage()))
        outputs.append("}")

    if args.print_fixed_lines:
        outputs.append(emit_line_evals_noir("sp1_gamma_lines", compute_fixed_lines(SP1_GAMMA_NEG)))
        outputs.append(emit_line_evals_noir("sp1_delta_lines", compute_fixed_lines(SP1_DELTA_NEG)))

    if args.proof_json:
        with open(args.proof_json, "r", encoding="utf-8") as f:
            data = json.load(f)
        a, b, c = parse_proof_bytes(data["proof"])
        public_values = bytes.fromhex(data["publicValues"][2:] if data["publicValues"].startswith("0x") else data["publicValues"])
        vkey = int.from_bytes(bytes.fromhex(data["vkey"][2:] if data["vkey"].startswith("0x") else data["vkey"]), "big")
        input0, input1 = compute_sp1_public_inputs(vkey, public_values)
        mul_witnesses: List[Mul034Witness] | None = [] if args.include_mul_witnesses else None
        c_wit, w_wit = compute_witness(a, b, c, input0, input1, mul_witnesses)
        if mul_witnesses is not None and len(mul_witnesses) != 67:
            raise SystemExit(f"unexpected mul witness count: {len(mul_witnesses)}")

        if not args.no_validate:
            f = miller_loop([a, c, compute_linear_combination(input0, input1)], [b, SP1_DELTA_NEG, SP1_GAMMA_NEG])
            f_t = f.mul(sp1_t_preimage())
            if not final_exponentiation(f_t).is_one():
                raise SystemExit("final exponentiation check failed")
            if not f_t.mul(w_wit) == c_wit.pow(6 * X + 2 + P - P**2 + P**3):
                raise SystemExit("f_t * w != c^lambda")
            if not w_wit.c1.is_zero():
                raise SystemExit("w not in Fp6")

        payload = {
            "c": fp12_to_limb_list(c_wit),
            "w": fp12_to_limb_list(w_wit),
        }
        if mul_witnesses is not None:
            payload["mul_witnesses"] = [mul_witness_to_limb_list(wit) for wit in mul_witnesses]

        if args.format == "json":
            outputs.append(json.dumps(payload, indent=2))
        else:
            lines = ["c = ["]
            for row in payload["c"]:
                lines.append(f'  ["{row[0]}", "{row[1]}", "{row[2]}"],')
            lines.append("]")
            lines.append("w = [")
            for row in payload["w"]:
                lines.append(f'  ["{row[0]}", "{row[1]}", "{row[2]}"],')
            lines.append("]")
            if "mul_witnesses" in payload:
                lines.append("mul_witnesses = [")
                for entry in payload["mul_witnesses"]:
                    lines.append("  [")
                    for row in entry:
                        lines.append(f'    ["{row[0]}", "{row[1]}", "{row[2]}"],')
                    lines.append("  ],")
                lines.append("]")
            outputs.append("\n".join(lines))

    if not outputs:
        parser.error("no action requested")

    content = "\n\n".join(outputs)
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(content)
    else:
        print(content)


FROB_1_1 = Fp2(
    fp_from_limbs(0x521E08292F2176D60B35DADCC9E470, 0xB71C2865A7DFE8B99FDD76E68B605C, 0x1284),
    fp_from_limbs(0x7992778EEEC7E5CA5CF05F80F362AC, 0x96F3B4FAE7E6A6327CFE12150B8E74, 0x2469),
)
FROB_1_2 = Fp2(
    fp_from_limbs(0x8CC310C2C3330C99E39557176F553D, 0x47984F7911F74C0BEC3CF559B143B7, 0x2FB3),
    fp_from_limbs(0xAE2A1D0B7C9DCE1665D51C640FCBA2, 0xE55061EBAE204BA4CC8BD75A079432, 0x16C9),
)
FROB_1_3 = Fp2(
    fp_from_limbs(0xAAE0EDA9C95998DC54014671A0135A, 0xF305489AF5DCDC5EC698B6E2F9B9DB, 0x63C),
    fp_from_limbs(0x807DC98FA25BD282D37F632623B0E3, 0x3CBCAC41049A0704B5A7EC796F2B21, 0x7C0),
)
FROB_1_4 = Fp2(
    fp_from_limbs(0x3365F7BE94EC72848A1F55921EA762, 0x4F5E64EEA80180F3C0B75A181E84D3, 0x5B5),
    fp_from_limbs(0x85D2EA1BDEC763C13B4711CD2B8126, 0x5EDBE7FD8AEE9F3A80B03B0B1C9236, 0x2C14),
)
FROB_1_5 = Fp2(
    fp_from_limbs(0x5C459B55AA1BD32EA2C810EAB7692F, 0xC1E74F798649E93A3661A4353FF442, 0x183),
    fp_from_limbs(0x80CB99678E2AC024C6B8EE6E0C2C4B, 0xF2CA76FD0675A27FB246C7729F7DB0, 0x12AC),
)
FROB_2_1 = fp_from_limbs(0x8F069FBB966E3DE4BD44E5607CFD49, 0x4E72E131A0295E6DD9E7E0ACCCB0C2, 0x3064)
FROB_2_2 = fp_from_limbs(0x8F069FBB966E3DE4BD44E5607CFD48, 0x4E72E131A0295E6DD9E7E0ACCCB0C2, 0x3064)
FROB_2_3 = fp_from_limbs(0x816A916871CA8D3C208C16D87CFD46, 0x4E72E131A029B85045B68181585D97, 0x3064)
FROB_2_4 = fp_from_limbs(0xF263F1ACDB5C4F5763473177FFFFFE, 0x59E26BCEA0D48BACD4, 0x0)
FROB_2_5 = fp_from_limbs(0xF263F1ACDB5C4F5763473177FFFFFF, 0x59E26BCEA0D48BACD4, 0x0)
FROB_3_1 = Fp2(
    fp_from_limbs(0x4CB38DBE55D24AE86F7D391ED4A67F, 0x81CFCC82E4BBEFE9608CD0ACAA9089, 0x19DC),
    fp_from_limbs(0x3A5E397D439EC7694AA2BF4C0C101, 0xF8B60BE77D7306CBEEE33576139D7F, 0xAB),
)
FROB_3_2 = Fp2(
    fp_from_limbs(0x5FFD3D5D6942D37B746EE87BDCFB6D, 0xE078B755EF0ABAFF1C77959F25AC80, 0x856),
    fp_from_limbs(0xDF31BF98FF2631380CAB2BAAA586DE, 0xDE41B3D1766FA9F30E6DEC26094F0F, 0x4F1),
)
FROB_3_3 = Fp2(
    fp_from_limbs(0xD689A3BEA870F45FCC8AD066DCE9ED, 0x5B6D9896AA4CDBF17F1DCA9E5EA3BB, 0x2A27),
    fp_from_limbs(0xECC7D8CF6EBAB94D0CB3B2594C64, 0x11B634F09B8FB14B900E9507E93276, 0x28A4),
)
FROB_3_4 = Fp2(
    fp_from_limbs(0x33094575B06BCB0E1A92BC3CCBF066, 0x8C6611C08DAB19BEE0F7B5B2444EE6, 0xBC5),
    fp_from_limbs(0x4A9E08737F96E55FE3ED9D730C239F, 0xE999E1910A12FEB0F6EF0CD21D04A4, 0x23D5),
)
FROB_3_5 = Fp2(
    fp_from_limbs(0xD68098967C84A5EBDE847076261B43, 0x9044952C0905711699FA3B4D3F692E, 0x13C4),
    fp_from_limbs(0x2DDAEA200280211F25041384282499, 0x366A59B1DD0B9FB1B2282A48633D3E, 0x16DB),
)

B_TWIST = Fp2(
    fp_from_limbs(0xB4C5E559DBEFA33267E6DC24A138E5, 0x9D40CEB8AAAE81BE18991BE06AC3B5, 0x2B14),
    fp_from_limbs(0x4FA084E52D1852E4A2BD0685C315D2, 0x13B03AF0FED4CD2CAFADEED8FDF4A7, 0x97),
)

SP1_GAMMA_NEG = G2Affine(
    x=Fp2(
        fp_from_limbs(0x4322D4F75EDADD46DEBD5CD992F6ED, 0xDEEF121F1E76426A00665E5C447967, 0x1800),
        fp_from_limbs(0xAA493335A9E71297E485B7AEF312C2, 0x9393920D483A7260BFB731FB5D25F1, 0x198E),
    ),
    y=Fp2(
        fp_from_limbs(0xAF83285C2DF711EF39C01571827F9D, 0xEFCD05A5323E6DA4D435F3B617CDB3, 0x1D9B),
        fp_from_limbs(0x36395DF7BE3B99E673B13A075A65EC, 0xC4A288D1AFB3CBB1AC09187524C7DB, 0x275D),
    ),
)
SP1_DELTA_NEG = G2Affine(
    x=Fp2(
        fp_from_limbs(0x3D3B76777A63B327D736BFFB0122ED, 0x41F4BA0C37FE2CAF27354D28E4B8F8, 0x3FF),
        fp_from_limbs(0x865E0CC020024521998269845F74E6, 0xCB8DE715675F21F01ECC9B46D236E0, 0x1CC7),
    ),
    y=Fp2(
        fp_from_limbs(0x266E474227C6439CA25CA8E1EC1FC2, 0xD3274441670227B4F69A44005B8711, 0x192B),
        fp_from_limbs(0xD7F8B2725CD5902A6B20DA7A2938FB, 0x9CD7827E0278E6B60843A4ABC7B111, 0x190),
    ),
)

SP1_IC0 = G1Affine(
    fp_from_limbs(0x24779233DB734C451D28B58AA9758E, 0x1E1CAFB0AD8A4EA0A694CD3743EBF5, 0x2609),
    fp_from_limbs(0x25489FEFA65A3E782E7BA70B66690E, 0xF50A6B8B11C3CA6FDB2690A124F8CE, 0x9F),
)
SP1_IC1 = G1Affine(
    fp_from_limbs(0xED36C6EC878755E537C1C48951FB4C, 0x3FD0FD3DA25D2607C227D090CCA750, 0x61C),
    fp_from_limbs(0x5E9A273E6119A212DD09EB51707219, 0x7AE9C2033379DF7B5C65EFF0E10705, 0xFA1),
)
SP1_IC2 = G1Affine(
    fp_from_limbs(0xFDEC51A16028DEE020634FD129E71C, 0xB241388A79817FE0E0E2EAD0B2EC4F, 0x4EA),
    fp_from_limbs(0xA9E16FCA56B18D5544B0889A65C1F5, 0x6256D21C60D02F0BDBF95CFF83E03E, 0x723),
)

SP1_ALPHA_BETA = Fp12(
    Fp6(
        Fp2(
            fp_from_limbs(0xA1ADE8B03E8B987D3578B630DC140D, 0x9B812ACB2275E21F0CCFD2B5B2C71B, 0x47C),
            fp_from_limbs(0xAABE2EF7A97706A8942A30D91B604A, 0xB9BE47B538F0C82106A3FB9B1E13DA, 0x2E96),
        ),
        Fp2(
            fp_from_limbs(0x99AFC69013773684381D2C74892018, 0x1F1D74C43656EE464741E6399C7237, 0xD22),
            fp_from_limbs(0x941C208B4FBC53D65AEDCDA7805CF4, 0x69ECD427A0CE90DCE160E1DE184905, 0x1AE0),
        ),
        Fp2(
            fp_from_limbs(0xCF123696B3BA61A91D739D7F8F06D, 0x3910F5F590D5910FFE4610DE63E7DC, 0x1176),
            fp_from_limbs(0x997FE53031CCD822922FACDAC67AC5, 0xDDA5649D0D0C861BD1E1B3ECEDD2DC, 0xFA3),
        ),
    ),
    Fp6(
        Fp2(
            fp_from_limbs(0x12CD3E2C33863498D5C913E5A8B842, 0xB627BC5985831858C16686982B1936, 0xFA5),
            fp_from_limbs(0x51D4BF1954E7C38DC83AD48FE8FE49, 0xB58BD40A46BDFC4B5B84C4B8254E37, 0x1650),
        ),
        Fp2(
            fp_from_limbs(0x6CFEEF5F8A6CB7436A6993F2EDE1E4, 0xF2EFD31E0684176C24C07BCD59DBFD, 0xA28),
            fp_from_limbs(0x80D70A0AE1724DD8935BBCCA6FE574, 0x2257E8E26C9335E43A8CCC062DB079, 0x2BD8),
        ),
        Fp2(
            fp_from_limbs(0x61029C66CAF40CA88899036FA48094, 0x7A5D05D208EC0D189852BC3FCEF800, 0x1A62),
            fp_from_limbs(0x38B4D32805C8D7862A2499DD4FCCD3, 0x11FA3287536B8AB776BC5889266C4, 0x11C5),
        ),
    ),
)

SP1_T_PREIMAGE: Fp12 | None = None


def sp1_t_preimage() -> Fp12:
    global SP1_T_PREIMAGE
    if SP1_T_PREIMAGE is None:
        SP1_T_PREIMAGE = compute_t_preimage(SP1_ALPHA_BETA)
    return SP1_T_PREIMAGE


if __name__ == "__main__":
    main()
