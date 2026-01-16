use crate::fp::{
    Fp, curve_b, fp_eight, fp_four, fp_one, fp_three, fp_two, fp_zero,
};

pub struct G1Affine {
    pub x: Fp,
    pub y: Fp,
}

pub struct G1Jac {
    pub x: Fp,
    pub y: Fp,
    pub z: Fp,
}

pub fn g1_affine_infinity() -> G1Affine {
    G1Affine { x: fp_zero(), y: fp_zero() }
}

pub fn g1_jacobian_infinity() -> G1Jac {
    G1Jac { x: fp_one(), y: fp_one(), z: fp_zero() }
}

impl G1Affine {
    pub fn is_infinity(self) -> bool {
        let x_zero = self.x == fp_zero();
        let y_zero = self.y == fp_zero();
        x_zero & y_zero
    }
}

impl G1Jac {
    pub fn is_infinity(self) -> bool {
        self.z == fp_zero()
    }
}

pub fn is_on_curve_g1_affine(p: G1Affine) -> bool {
    let left = p.y * p.y;
    let right = (p.x * p.x * p.x) + curve_b();
    if p.is_infinity() { true } else { left == right }
}

pub fn neg_g1_affine(p: G1Affine) -> G1Affine {
    G1Affine { x: p.x, y: -p.y }
}

pub fn jacobian_to_affine_g1(p: G1Jac) -> G1Affine {
    if p.is_infinity() {
        g1_affine_infinity()
    } else {
        let a = fp_one() / p.z;
        let b = a * a;
        let x = p.x * b;
        let y = p.y * b * a;
        G1Affine { x, y }
    }
}

pub fn add_g1_affine(a: G1Affine, b: G1Affine) -> G1Affine {
    if a.is_infinity() {
        b
    } else if b.is_infinity() {
        a
    } else if a.x == b.x {
        if a.y == b.y {
            jacobian_to_affine_g1(double_mixed_g1(a))
        } else {
            g1_affine_infinity()
        }
    } else {
        let h = b.x - a.x;
        let hh = h * h;
        let i = fp_four() * hh;
        let j = h * i;
        let r = fp_two() * (b.y - a.y);
        let v = a.x * i;

        let x3 = r * r - j - fp_two() * v;
        let y3 = r * (v - x3) - fp_two() * a.y * j;
        let z3 = fp_two() * h;

        jacobian_to_affine_g1(G1Jac { x: x3, y: y3, z: z3 })
    }
}

pub fn double_mixed_g1(a: G1Affine) -> G1Jac {
    let xx = a.x * a.x;
    let yy = a.y * a.y;
    let yyyy = yy * yy;
    let s = fp_two() * ((a.x + yy) * (a.x + yy) - xx - yyyy);
    let m = fp_three() * xx;
    let t = m * m - fp_two() * s;

    let x3 = t;
    let y3 = m * (s - t) - fp_eight() * yyyy;
    let z3 = fp_two() * a.y;
    G1Jac { x: x3, y: y3, z: z3 }
}

pub fn add_g1_jac(p: G1Jac, q: G1Jac) -> G1Jac {
    if p.is_infinity() {
        q
    } else if q.is_infinity() {
        p
    } else {
        let z1z1 = q.z * q.z;
        let z2z2 = p.z * p.z;
        let u1 = q.x * z2z2;
        let u2 = p.x * z1z1;
        let s1 = q.y * p.z * z2z2;
        let s2 = p.y * q.z * z1z1;
        let same_u = u1 == u2;
        let same_s = s1 == s2;

        if same_u & same_s {
            double_g1_jac(p)
        } else {
            let h = u2 - u1;
            let i = fp_two() * h;
            let i = i * i;
            let j = h * i;
            let r = fp_two() * (s2 - s1);
            let v = u1 * i;

            let x3 = r * r - j - fp_two() * v;
            let y3 = r * (v - x3) - fp_two() * s1 * j;
            let z3 = ((p.z + q.z) * (p.z + q.z) - z1z1 - z2z2) * h;
            G1Jac { x: x3, y: y3, z: z3 }
        }
    }
}

pub fn double_g1_jac(p: G1Jac) -> G1Jac {
    let a = p.x * p.x;
    let b = p.y * p.y;
    let c = b * b;
    let d = fp_two() * ((p.x + b) * (p.x + b) - a - c);
    let e = fp_three() * a;
    let f = e * e;
    let t = fp_two() * d;

    let z3 = fp_two() * p.y * p.z;
    let x3 = f - t;
    let y3 = e * (d - x3) - fp_eight() * c;
    G1Jac { x: x3, y: y3, z: z3 }
}
