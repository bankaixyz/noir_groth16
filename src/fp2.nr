use crate::fp::{Fp, fp_nine, fp_one, fp_zero};
use bignum::BigNum;


// Fp2 = Fp[u] / (u^2 + 1)
pub struct Fp2 {
    pub c0: Fp,
    pub c1: Fp,
}

pub fn fp2_zero() -> Fp2 {
    Fp2 { c0: fp_zero(), c1: fp_zero() }
}

pub fn fp2_one() -> Fp2 {
    Fp2 { c0: fp_one(), c1: fp_zero() }
}

pub fn non_residue() -> Fp2 {
    Fp2 { c0: fp_nine(), c1: fp_one() } // 9 + u
}

pub fn non_residue_inv() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3]),
        c1: Fp::from_limbs([0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9]),
    }
}

pub fn b_twist() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x4fa084e52d1852e4a2bd0685c315d2, 0x13b03af0fed4cd2cafadeed8fdf4a7, 0x97]),
        c1: Fp::from_limbs([0xb4c5e559dbefa33267e6dc24a138e5, 0x9d40ceb8aaae81be18991be06ac3b5, 0x2b14]),
    }
}

pub fn endo_u() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3]),
        c1: Fp::from_limbs([0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9]),
    }
}

pub fn endo_v() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c]),
        c1: Fp::from_limbs([0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0]),
    }
}

pub fn frobenius_1_power_1() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x521e08292f2176d60b35dadcc9e470, 0xb71c2865a7dfe8b99fdd76e68b605c, 0x1284]),
        c1: Fp::from_limbs([0x7992778eeec7e5ca5cf05f80f362ac, 0x96f3b4fae7e6a6327cfe12150b8e74, 0x2469]),
    }
}

pub fn frobenius_1_power_2() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x8cc310c2c3330c99e39557176f553d, 0x47984f7911f74c0bec3cf559b143b7, 0x2fb3]),
        c1: Fp::from_limbs([0xae2a1d0b7c9dce1665d51c640fcba2, 0xe55061ebae204ba4cc8bd75a079432, 0x16c9]),
    }
}

pub fn frobenius_1_power_3() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0xaae0eda9c95998dc54014671a0135a, 0xf305489af5dcdc5ec698b6e2f9b9db, 0x63c]),
        c1: Fp::from_limbs([0x807dc98fa25bd282d37f632623b0e3, 0x3cbcac41049a0704b5a7ec796f2b21, 0x7c0]),
    }
}

pub fn frobenius_1_power_4() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x3365f7be94ec72848a1f55921ea762, 0x4f5e64eea80180f3c0b75a181e84d3, 0x5b5]),
        c1: Fp::from_limbs([0x85d2ea1bdec763c13b4711cd2b8126, 0x5edbe7fd8aee9f3a80b03b0b1c9236, 0x2c14]),
    }
}

pub fn frobenius_1_power_5() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x5c459b55aa1bd32ea2c810eab7692f, 0xc1e74f798649e93a3661a4353ff442, 0x183]),
        c1: Fp::from_limbs([0x80cb99678e2ac024c6b8ee6e0c2c4b, 0xf2ca76fd0675a27fb246c7729f7db0, 0x12ac]),
    }
}

pub fn frobenius_2_power_1() -> Fp {
    Fp::from_limbs([0x8f069fbb966e3de4bd44e5607cfd49, 0x4e72e131a0295e6dd9e7e0acccb0c2, 0x3064])
}

pub fn frobenius_2_power_2() -> Fp {
    Fp::from_limbs([0x8f069fbb966e3de4bd44e5607cfd48, 0x4e72e131a0295e6dd9e7e0acccb0c2, 0x3064])
}

pub fn frobenius_2_power_3() -> Fp {
    Fp::from_limbs([0x816a916871ca8d3c208c16d87cfd46, 0x4e72e131a029b85045b68181585d97, 0x3064])
}

pub fn frobenius_2_power_4() -> Fp {
    Fp::from_limbs([0xf263f1acdb5c4f5763473177fffffe, 0x59e26bcea0d48bacd4, 0x0])
}

pub fn frobenius_2_power_5() -> Fp {
    Fp::from_limbs([0xf263f1acdb5c4f5763473177ffffff, 0x59e26bcea0d48bacd4, 0x0])
}

pub fn frobenius_3_power_1() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x4cb38dbe55d24ae86f7d391ed4a67f, 0x81cfcc82e4bbefe9608cd0acaa9089, 0x19dc]),
        c1: Fp::from_limbs([0x3a5e397d439ec7694aa2bf4c0c101, 0xf8b60be77d7306cbeee33576139d7f, 0xab]),
    }
}

pub fn frobenius_3_power_2() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x5ffd3d5d6942d37b746ee87bdcfb6d, 0xe078b755ef0abaff1c77959f25ac80, 0x856]),
        c1: Fp::from_limbs([0xdf31bf98ff2631380cab2baaa586de, 0xde41b3d1766fa9f30e6dec26094f0f, 0x4f1]),
    }
}

pub fn frobenius_3_power_3() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0xd689a3bea870f45fcc8ad066dce9ed, 0x5b6d9896aa4cdbf17f1dca9e5ea3bb, 0x2a27]),
        c1: Fp::from_limbs([0xecc7d8cf6ebab94d0cb3b2594c64, 0x11b634f09b8fb14b900e9507e93276, 0x28a4]),
    }
}

pub fn frobenius_3_power_4() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0x33094575b06bcb0e1a92bc3ccbf066, 0x8c6611c08dab19bee0f7b5b2444ee6, 0xbc5]),
        c1: Fp::from_limbs([0x4a9e08737f96e55fe3ed9d730c239f, 0xe999e1910a12feb0f6ef0cd21d04a4, 0x23d5]),
    }
}

pub fn frobenius_3_power_5() -> Fp2 {
    Fp2 {
        c0: Fp::from_limbs([0xd68098967c84a5ebde847076261b43, 0x9044952c0905711699fa3b4d3f692e, 0x13c4]),
        c1: Fp::from_limbs([0x2ddaea200280211f25041384282499, 0x366a59b1dd0b9fb1b2282a48633d3e, 0x16db]),
    }
}

impl Fp2 {
    pub fn add(self, other: Fp2) -> Fp2 {
        Fp2 { c0: self.c0 + other.c0, c1: self.c1 + other.c1 }
    }

    pub fn sub(self, other: Fp2) -> Fp2 {
        Fp2 { c0: self.c0 - other.c0, c1: self.c1 - other.c1 }
    }

    pub fn neg(self) -> Fp2 {
        Fp2 { c0: -self.c0, c1: -self.c1 }
    }

    pub fn double(self) -> Fp2 {
        Fp2 { c0: self.c0 + self.c0, c1: self.c1 + self.c1 }
    }

    pub fn conjugate(self) -> Fp2 {
        Fp2 { c0: self.c0, c1: -self.c1 }
    }

    pub fn mul(self, other: Fp2) -> Fp2 {
        let a = (self.c0 + self.c1) * (other.c0 + other.c1);
        let b = self.c0 * other.c0;
        let c = self.c1 * other.c1;
        Fp2 { c0: b - c, c1: a - b - c }
    }

    pub fn square(self) -> Fp2 {
        let a = (self.c0 + self.c1) * (self.c0 - self.c1);
        let b = self.c0 * self.c1;
        let b = b + b;
        Fp2 { c0: a, c1: b }
    }

    pub fn inverse(self) -> Fp2 {
        let t0 = self.c0 * self.c0;
        let t1 = self.c1 * self.c1;
        let t0 = t0 + t1;
        let t1 = fp_one() / t0;
        Fp2 { c0: self.c0 * t1, c1: -(self.c1 * t1) }
    }

    pub fn mul_by_non_residue(self) -> Fp2 {
        let two_a0 = self.c0 + self.c0;
        let four_a0 = two_a0 + two_a0;
        let eight_a0 = four_a0 + four_a0;
        let nine_a0 = eight_a0 + self.c0;

        let two_a1 = self.c1 + self.c1;
        let four_a1 = two_a1 + two_a1;
        let eight_a1 = four_a1 + four_a1;
        let nine_a1 = eight_a1 + self.c1;
        Fp2 { c0: nine_a0 - self.c1, c1: self.c0 + nine_a1 }
    }

    pub fn mul_by_element(self, element: Fp) -> Fp2 {
        Fp2 { c0: self.c0 * element, c1: self.c1 * element }
    }

    pub fn mul_by_non_residue_1_power_1(self) -> Fp2 {
        self.mul(frobenius_1_power_1())
    }

    pub fn mul_by_non_residue_1_power_2(self) -> Fp2 {
        self.mul(frobenius_1_power_2())
    }

    pub fn mul_by_non_residue_1_power_3(self) -> Fp2 {
        self.mul(frobenius_1_power_3())
    }

    pub fn mul_by_non_residue_1_power_4(self) -> Fp2 {
        self.mul(frobenius_1_power_4())
    }

    pub fn mul_by_non_residue_1_power_5(self) -> Fp2 {
        self.mul(frobenius_1_power_5())
    }

    pub fn mul_by_non_residue_2_power_1(self) -> Fp2 {
        self.mul_by_element(frobenius_2_power_1())
    }

    pub fn mul_by_non_residue_2_power_2(self) -> Fp2 {
        self.mul_by_element(frobenius_2_power_2())
    }

    pub fn mul_by_non_residue_2_power_3(self) -> Fp2 {
        self.mul_by_element(frobenius_2_power_3())
    }

    pub fn mul_by_non_residue_2_power_4(self) -> Fp2 {
        self.mul_by_element(frobenius_2_power_4())
    }

    pub fn mul_by_non_residue_2_power_5(self) -> Fp2 {
        self.mul_by_element(frobenius_2_power_5())
    }

    pub fn mul_by_non_residue_3_power_1(self) -> Fp2 {
        self.mul(frobenius_3_power_1())
    }

    pub fn mul_by_non_residue_3_power_2(self) -> Fp2 {
        self.mul(frobenius_3_power_2())
    }

    pub fn mul_by_non_residue_3_power_3(self) -> Fp2 {
        self.mul(frobenius_3_power_3())
    }

    pub fn mul_by_non_residue_3_power_4(self) -> Fp2 {
        self.mul(frobenius_3_power_4())
    }

    pub fn mul_by_non_residue_3_power_5(self) -> Fp2 {
        self.mul(frobenius_3_power_5())
    }
}