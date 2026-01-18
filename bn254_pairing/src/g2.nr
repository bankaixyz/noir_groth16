use crate::fp::fp_three;
use crate::fp2::{Fp2, b_twist, endo_u, endo_v, fp2_one, fp2_zero};

/// G2 affine point over Fp2.
pub struct G2Affine {
    pub x: Fp2,
    pub y: Fp2,
}

/// G2 Jacobian point (X:Y:Z) representing (X/Z^2, Y/Z^3).
pub struct G2Jac {
    pub x: Fp2,
    pub y: Fp2,
    pub z: Fp2,
}

/// G2 projective point used for Miller loop steps.
pub struct G2Proj {
    pub x: Fp2,
    pub y: Fp2,
    pub z: Fp2,
}

/// Line function l_{R,P}(Q) coefficients for Miller loop evaluation.
pub struct LineEvaluation {
    pub r0: Fp2,
    pub r1: Fp2,
    pub r2: Fp2,
}

/// Affine point at infinity (0, 0).
pub fn g2_affine_infinity() -> G2Affine {
    G2Affine { x: fp2_zero(), y: fp2_zero() }
}

/// Jacobian point at infinity (1, 1, 0).
pub fn g2_jacobian_infinity() -> G2Jac {
    G2Jac { x: fp2_one(), y: fp2_one(), z: fp2_zero() }
}

impl G2Affine {
    pub fn is_infinity(self) -> bool {
        let x_zero = fp2_is_zero(self.x);
        let y_zero = fp2_is_zero(self.y);
        x_zero & y_zero
    }
}

impl G2Jac {
    pub fn is_infinity(self) -> bool {
        fp2_is_zero(self.z)
    }
}

/// Check y^2 = x^3 + b' for affine points, treating infinity as valid.
pub fn is_on_curve_g2_affine(p: G2Affine) -> bool {
    let left = p.y.square();
    let right = p.x.square().mul(p.x).add(b_twist());
    if p.is_infinity() { true } else { fp2_eq(left, right) }
}

/// Affine negation: (x, y) -> (x, -y).
pub fn neg_g2_affine(p: G2Affine) -> G2Affine {
    G2Affine { x: p.x, y: p.y.neg() }
}

/// Convert Jacobian to affine with a single inversion.
pub fn jacobian_to_affine_g2(p: G2Jac) -> G2Affine {
    if p.is_infinity() {
        g2_affine_infinity()
    } else {
        let a = p.z.inverse();
        let b = a.square();
        let x = p.x.mul(b);
        let y = p.y.mul(b).mul(a);
        G2Affine { x, y }
    }
}

/// Jacobian addition with no inversions (complete with special cases).
pub fn add_g2_jac(p: G2Jac, q: G2Jac) -> G2Jac {
    if p.is_infinity() {
        q
    } else if q.is_infinity() {
        p
    } else {
        let z1z1 = q.z.square();
        let z2z2 = p.z.square();
        let u1 = q.x.mul(z2z2);
        let u2 = p.x.mul(z1z1);
        let s1 = q.y.mul(p.z).mul(z2z2);
        let s2 = p.y.mul(q.z).mul(z1z1);
        let same_u = fp2_eq(u1, u2);
        let same_s = fp2_eq(s1, s2);

        if same_u & same_s {
            double_g2_jac(p)
        } else {
            let h = u2.sub(u1);
            let i = h.double().square();
            let j = h.mul(i);
            let r = s2.sub(s1).double();
            let v = u1.mul(i);

            let x3 = r.square().sub(j).sub(v.double());
            let y3 = r.mul(v.sub(x3)).sub(s1.double().mul(j));
            let z3 = p.z.add(q.z).square().sub(z1z1).sub(z2z2).mul(h);
            G2Jac { x: x3, y: y3, z: z3 }
        }
    }
}

/// Jacobian point doubling (used in scalar multiplication).
pub fn double_g2_jac(p: G2Jac) -> G2Jac {
    let a = p.x.square();
    let b = p.y.square();
    let c = b.square();
    let d = (p.x.add(b)).square().sub(a).sub(c).double();
    let e = a.double().add(a);
    let f = e.square();
    let t = d.double();

    let z3 = p.y.mul(p.z).double();
    let x3 = f.sub(t);
    let y3 = e.mul(d.sub(x3)).sub(c.double().double().double());
    G2Jac { x: x3, y: y3, z: z3 }
}

/// Convert affine to projective (Z = 1) for Miller loop steps.
pub fn projective_from_affine_g2(a: G2Affine) -> G2Proj {
    if a.is_infinity() {
        G2Proj { x: fp2_one(), y: fp2_one(), z: fp2_zero() }
    } else {
        G2Proj { x: a.x, y: a.y, z: fp2_one() }
    }
}

/// Frobenius map on the twist: Q -> Q^p with precomputed coefficients.
pub fn frobenius_g2(q: G2Affine) -> G2Affine {
    let x = q.x.conjugate().mul_by_non_residue_1_power_2();
    let y = q.y.conjugate().mul_by_non_residue_1_power_3();
    G2Affine { x, y }
}

/// Frobenius^2 map on the twist, used in final Miller steps.
pub fn frobenius_square_g2(q: G2Affine) -> G2Affine {
    let x = q.x.mul_by_non_residue_2_power_2();
    let y = q.y.mul_by_non_residue_2_power_3().neg();
    G2Affine { x, y }
}

/// Endomorphism psi: conjugation + constants (GLV-style on BN curves).
pub fn psi_g2(p: G2Jac) -> G2Jac {
    let x = p.x.conjugate().mul(endo_u());
    let y = p.y.conjugate().mul(endo_v());
    let z = p.z.conjugate();
    G2Jac { x, y, z }
}

impl G2Proj {
    /// Doubling step that also returns the tangent line evaluation.
    pub fn double_step(self) -> (G2Proj, LineEvaluation) {
        let a = self.x.mul(self.y).halve();
        let b = self.y.square();
        let c = self.z.square();
        let d = c.mul_by_element(fp_three());
        let e = d.mul_by_b_twist_coeff();
        let f = e.mul_by_element(fp_three());
        let g = b.add(f).halve();
        let h = self.y.add(self.z).square().sub(b).sub(c);
        let i = e.sub(b);
        let j = self.x.square();
        let ee = e.square();
        let k = ee.mul_by_element(fp_three());

        let x = b.sub(f).mul(a);
        let y = g.square().sub(k);
        let z = b.mul(h);

        let line = LineEvaluation {
            r0: h.neg(),
            r1: j.mul_by_element(fp_three()),
            r2: i,
        };
        (G2Proj { x, y, z }, line)
    }

    /// Mixed addition step (projective + affine) with line evaluation.
    pub fn add_mixed_step(self, a: G2Affine) -> (G2Proj, LineEvaluation) {
        let y2z1 = a.y.mul(self.z);
        let o = self.y.sub(y2z1);
        let x2z1 = a.x.mul(self.z);
        let l = self.x.sub(x2z1);
        let c = o.square();
        let d = l.square();
        let e = l.mul(d);
        let f = self.z.mul(c);
        let g = self.x.mul(d);
        let t0 = g.double();
        let h = e.add(f).sub(t0);
        let t1 = self.y.mul(e);

        let x = l.mul(h);
        let y = g.sub(h).mul(o).sub(t1);
        let z = e.mul(self.z);

        let t2 = l.mul(a.y);
        let j = a.x.mul(o).sub(t2);
        let line = LineEvaluation { r0: l, r1: o.neg(), r2: j };

        (G2Proj { x, y, z }, line)
    }

    /// Compute the line evaluation for adding affine a to self.
    pub fn line_compute(self, a: G2Affine) -> (G2Proj, LineEvaluation) {
        let y2z1 = a.y.mul(self.z);
        let o = self.y.sub(y2z1);
        let x2z1 = a.x.mul(self.z);
        let l = self.x.sub(x2z1);
        let t2 = l.mul(a.y);
        let j = a.x.mul(o).sub(t2);

        let line = LineEvaluation { r0: l, r1: o.neg(), r2: j };
        (self, line)
    }
}

fn fp2_is_zero(a: Fp2) -> bool {
    let z = fp2_zero();
    let c0_zero = a.c0 == z.c0;
    let c1_zero = a.c1 == z.c1;
    c0_zero & c1_zero
}

fn fp2_eq(a: Fp2, b: Fp2) -> bool {
    let c0_eq = a.c0 == b.c0;
    let c1_eq = a.c1 == b.c1;
    c0_eq & c1_eq
}
