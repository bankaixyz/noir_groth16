use crate::fp2::{Fp2, fp2_one, fp2_zero};

// Fp6 = Fp2[v] / (v^3 - xi), xi = 9 + u
/// Cubic extension field element b0 + b1 * v + b2 * v^2.
pub struct Fp6 {
    pub b0: Fp2,
    pub b1: Fp2,
    pub b2: Fp2,
}

pub fn fp6_zero() -> Fp6 {
    Fp6 { b0: fp2_zero(), b1: fp2_zero(), b2: fp2_zero() }
}

pub fn fp6_one() -> Fp6 {
    Fp6 { b0: fp2_one(), b1: fp2_zero(), b2: fp2_zero() }
}

impl Fp6 {
    pub fn add(self, other: Fp6) -> Fp6 {
        Fp6 {
            b0: self.b0.add(other.b0),
            b1: self.b1.add(other.b1),
            b2: self.b2.add(other.b2),
        }
    }

    pub fn sub(self, other: Fp6) -> Fp6 {
        Fp6 {
            b0: self.b0.sub(other.b0),
            b1: self.b1.sub(other.b1),
            b2: self.b2.sub(other.b2),
        }
    }

    pub fn neg(self) -> Fp6 {
        Fp6 { b0: self.b0.neg(), b1: self.b1.neg(), b2: self.b2.neg() }
    }

    pub fn double(self) -> Fp6 {
        Fp6 {
            b0: self.b0.double(),
            b1: self.b1.double(),
            b2: self.b2.double(),
        }
    }

    /// Multiply by v (the non-residue) via component rotation.
    pub fn mul_by_non_residue(self) -> Fp6 {
        Fp6 {
            b0: self.b2.mul_by_non_residue(),
            b1: self.b0,
            b2: self.b1,
        }
    }

    pub fn mul_by_e2(self, c0: Fp2) -> Fp6 {
        Fp6 {
            b0: self.b0.mul(c0),
            b1: self.b1.mul(c0),
            b2: self.b2.mul(c0),
        }
    }

    /// Karatsuba multiplication in Fp6 (3 Fp2 muls + non-residue).
    pub fn mul(self, other: Fp6) -> Fp6 {
        let t0 = self.b0.mul(other.b0);
        let t1 = self.b1.mul(other.b1);
        let t2 = self.b2.mul(other.b2);

        let mut c0 = (self.b1.add(self.b2)).mul(other.b1.add(other.b2));
        c0 = c0.sub(t1).sub(t2);
        c0 = c0.mul_by_non_residue().add(t0);

        let mut c1 = (self.b0.add(self.b1)).mul(other.b0.add(other.b1));
        c1 = c1.sub(t0).sub(t1);
        let tmp = t2.mul_by_non_residue();
        c1 = c1.add(tmp);

        let mut c2 = (self.b0.add(self.b2)).mul(other.b0.add(other.b2));
        c2 = c2.sub(t0).sub(t2).add(t1);

        Fp6 { b0: c0, b1: c1, b2: c2 }
    }

    /// Squaring optimized for Fp6 (symmetric Karatsuba).
    pub fn square(self) -> Fp6 {
        let c4 = self.b0.mul(self.b1).double();
        let c5 = self.b2.square();
        let c1 = c5.mul_by_non_residue().add(c4);
        let c2 = c4.sub(c5);
        let c3 = self.b0.square();
        let mut c4 = self.b0.sub(self.b1).add(self.b2);
        let c5 = self.b1.mul(self.b2).double();
        c4 = c4.square();
        let c0 = c5.mul_by_non_residue().add(c3);

        let b2 = c2.add(c4).add(c5).sub(c3);
        Fp6 { b0: c0, b1: c1, b2 }
    }

    /// Inversion via norm and Fp2 inversion.
    pub fn inverse(self) -> Fp6 {
        let t0 = self.b0.square();
        let t1 = self.b1.square();
        let t2 = self.b2.square();
        let t3 = self.b0.mul(self.b1);
        let t4 = self.b0.mul(self.b2);
        let t5 = self.b1.mul(self.b2);

        let c0 = t0.sub(t5.mul_by_non_residue());
        let c1 = t2.mul_by_non_residue().sub(t3);
        let c2 = t1.sub(t4);

        let t6 = self.b0.mul(c0);
        let d1 = self.b2.mul(c1);
        let d2 = self.b1.mul(c2);
        let d1 = d1.add(d2).mul_by_non_residue();
        let t6 = t6.add(d1);
        let t6 = t6.inverse();

        Fp6 { b0: c0.mul(t6), b1: c1.mul(t6), b2: c2.mul(t6) }
    }

    /// Multiply by sparse element (c0 + c1 * v).
    pub fn mul_by_01(self, c0: Fp2, c1: Fp2) -> Fp6 {
        let a = self.b0.mul(c0);
        let b = self.b1.mul(c1);

        let mut t0 = c1.mul(self.b1.add(self.b2));
        t0 = t0.sub(b).mul_by_non_residue();
        t0 = t0.add(a);

        let mut t2 = c0.mul(self.b0.add(self.b2));
        t2 = t2.sub(a).add(b);

        let mut t1 = c0.add(c1);
        t1 = t1.mul(self.b0.add(self.b1));
        t1 = t1.sub(a).sub(b);

        Fp6 { b0: t0, b1: t1, b2: t2 }
    }

    /// Multiply by sparse element (c1 * v).
    pub fn mul_by_1(self, c1: Fp2) -> Fp6 {
        let b = self.b1.mul(c1);

        let mut t0 = c1.mul(self.b1.add(self.b2));
        t0 = t0.sub(b).mul_by_non_residue();

        let mut t1 = c1.mul(self.b0.add(self.b1));
        t1 = t1.sub(b);

        Fp6 { b0: t0, b1: t1, b2: b }
    }

    /// Multiply by sparse element (b1 * v + b2 * v^2).
    pub fn mul_by_12(self, b1: Fp2, b2: Fp2) -> Fp6 {
        let t1 = self.b1.mul(b1);
        let t2 = self.b2.mul(b2);

        let mut c0 = (self.b1.add(self.b2)).mul(b1.add(b2));
        c0 = c0.sub(t1).sub(t2);
        c0 = c0.mul_by_non_residue();

        let mut c1 = (self.b0.add(self.b1)).mul(b1);
        c1 = c1.sub(t1);
        let tmp = t2.mul_by_non_residue();
        c1 = c1.add(tmp);

        let mut c2 = b2.mul(self.b0.add(self.b2));
        c2 = c2.sub(t2).add(t1);

        Fp6 { b0: c0, b1: c1, b2: c2 }
    }
}
