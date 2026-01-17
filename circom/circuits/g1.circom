pragma circom 2.0.0;

include "./fp.circom";

template G1AffineInfinity() {
    signal output out[2];

    component zero = FpZero();
    out[0] <== zero.out;
    out[1] <== zero.out;
}

template G1JacobianInfinity() {
    signal output out[3];

    component one = FpOne();
    component zero = FpZero();
    out[0] <== one.out;
    out[1] <== one.out;
    out[2] <== zero.out;
}

template G1AffineIsInfinity() {
    signal input p[2];
    signal output out;

    component xZero = FpIsZero();
    component yZero = FpIsZero();
    xZero.a <== p[0];
    yZero.a <== p[1];
    out <== xZero.out * yZero.out;
    out * (out - 1) === 0;
}

template G1JacIsInfinity() {
    signal input p[3];
    signal output out;

    component zZero = FpIsZero();
    zZero.a <== p[2];
    out <== zZero.out;
    out * (out - 1) === 0;
}

template G1IsOnCurveAffine() {
    signal input p[2];
    signal output out;

    component ySq = FpSquare();
    component xSq = FpSquare();
    component xCub = FpMul();
    component b = CurveB();
    component rhs = FpAdd();
    component eq = FpEq();
    component isInf = G1AffineIsInfinity();

    ySq.a <== p[1];
    xSq.a <== p[0];
    isInf.p[0] <== p[0];
    isInf.p[1] <== p[1];
    xCub.a <== xSq.out;
    xCub.b <== p[0];
    rhs.a <== xCub.out;
    rhs.b <== b.out;
    eq.a <== ySq.out;
    eq.b <== rhs.out;

    out <== isInf.out + (1 - isInf.out) * eq.out;
    out * (out - 1) === 0;
}

template G1NegAffine() {
    signal input p[2];
    signal output out[2];

    component neg = FpNeg();
    neg.a <== p[1];
    out[0] <== p[0];
    out[1] <== neg.out;
}

template G1DoubleMixed() {
    signal input a[2];
    signal output out[3];

    component xx = FpSquare();
    component yy = FpSquare();
    component yyyy = FpSquare();
    component a0_plus_yy = FpAdd();
    component a0_plus_yy_sq = FpSquare();
    component s_tmp = FpSub();
    component s_tmp2 = FpSub();
    component s = FpMul();
    component m = FpMul();
    component m_sq = FpSquare();
    component s_dbl = FpMul();
    component t = FpSub();
    component s_minus_t = FpSub();
    component y3_mul = FpMul();
    component y3 = FpSub();
    component z3 = FpMul();
    component two = FpTwo();
    component three = FpThree();
    component eight = FpEight();
    component yyyy_mul = FpMul();

    xx.a <== a[0];
    yy.a <== a[1];
    yyyy.a <== yy.out;
    a0_plus_yy.a <== a[0];
    a0_plus_yy.b <== yy.out;
    a0_plus_yy_sq.a <== a0_plus_yy.out;
    s_tmp.a <== a0_plus_yy_sq.out;
    s_tmp.b <== xx.out;
    s_tmp2.a <== s_tmp.out;
    s_tmp2.b <== yyyy.out;
    s.a <== two.out;
    s.b <== s_tmp2.out;
    m.a <== three.out;
    m.b <== xx.out;
    m_sq.a <== m.out;
    s_dbl.a <== two.out;
    s_dbl.b <== s.out;
    t.a <== m_sq.out;
    t.b <== s_dbl.out;
    s_minus_t.a <== s.out;
    s_minus_t.b <== t.out;
    y3_mul.a <== m.out;
    y3_mul.b <== s_minus_t.out;
    z3.a <== two.out;
    z3.b <== a[1];
    yyyy_mul.a <== eight.out;
    yyyy_mul.b <== yyyy.out;
    y3.a <== y3_mul.out;
    y3.b <== yyyy_mul.out;

    out[0] <== t.out;
    out[1] <== y3.out;
    out[2] <== z3.out;
}

template G1DoubleJac() {
    signal input p[3];
    signal output out[3];

    component a = FpSquare();
    component b = FpSquare();
    component c = FpSquare();
    component x_plus_b = FpAdd();
    component x_plus_b_sq = FpSquare();
    component d_tmp = FpSub();
    component d_tmp2 = FpSub();
    component d = FpMul();
    component e = FpAdd();
    component e_plus = FpAdd();
    component f = FpSquare();
    component t = FpMul();
    component x3 = FpSub();
    component d_minus_x3 = FpSub();
    component y3_mul = FpMul();
    component c_mul = FpMul();
    component y3 = FpSub();
    component z3 = FpMul();
    component z3_mul = FpMul();
    component two = FpTwo();
    component three = FpThree();
    component eight = FpEight();

    a.a <== p[0];
    b.a <== p[1];
    c.a <== b.out;
    x_plus_b.a <== p[0];
    x_plus_b.b <== b.out;
    e.a <== a.out;
    e.b <== a.out;
    x_plus_b_sq.a <== x_plus_b.out;
    d_tmp.a <== x_plus_b_sq.out;
    d_tmp.b <== a.out;
    d_tmp2.a <== d_tmp.out;
    d_tmp2.b <== c.out;
    d.a <== two.out;
    d.b <== d_tmp2.out;
    e_plus.a <== e.out;
    e_plus.b <== a.out;
    f.a <== e_plus.out;
    t.a <== two.out;
    t.b <== d.out;
    x3.a <== f.out;
    x3.b <== t.out;
    d_minus_x3.a <== d.out;
    d_minus_x3.b <== x3.out;
    y3_mul.a <== e_plus.out;
    y3_mul.b <== d_minus_x3.out;
    c_mul.a <== eight.out;
    c_mul.b <== c.out;
    y3.a <== y3_mul.out;
    y3.b <== c_mul.out;
    z3.a <== two.out;
    z3.b <== p[1];
    z3_mul.a <== z3.out;
    z3_mul.b <== p[2];

    out[0] <== x3.out;
    out[1] <== y3.out;
    out[2] <== z3_mul.out;
}

template G1AddJac() {
    signal input p[3];
    signal input q[3];
    signal output out[3];

    component pInf = G1JacIsInfinity();
    component qInf = G1JacIsInfinity();
    pInf.p[0] <== p[0];
    pInf.p[1] <== p[1];
    pInf.p[2] <== p[2];
    qInf.p[0] <== q[0];
    qInf.p[1] <== q[1];
    qInf.p[2] <== q[2];

    component z1z1 = FpSquare();
    component z2z2 = FpSquare();
    z1z1.a <== q[2];
    z2z2.a <== p[2];

    component u1 = FpMul();
    component u2 = FpMul();
    u1.a <== q[0];
    u1.b <== z2z2.out;
    u2.a <== p[0];
    u2.b <== z1z1.out;

    component s1 = FpMul();
    component s2 = FpMul();
    component pz_mul = FpMul();
    component qz_mul = FpMul();
    pz_mul.a <== q[1];
    pz_mul.b <== p[2];
    qz_mul.a <== p[1];
    qz_mul.b <== q[2];
    s1.a <== pz_mul.out;
    s1.b <== z2z2.out;
    s2.a <== qz_mul.out;
    s2.b <== z1z1.out;

    component sameU = FpEq();
    component sameS = FpEq();
    sameU.a <== u1.out;
    sameU.b <== u2.out;
    sameS.a <== s1.out;
    sameS.b <== s2.out;
    signal same;
    same <== sameU.out * sameS.out;
    same * (same - 1) === 0;

    component h = FpSub();
    h.a <== u2.out;
    h.b <== u1.out;
    component i_mul = FpMul();
    component two = FpTwo();
    i_mul.a <== two.out;
    i_mul.b <== h.out;
    component i_sq = FpSquare();
    i_sq.a <== i_mul.out;
    component j = FpMul();
    j.a <== h.out;
    j.b <== i_sq.out;
    component r = FpSub();
    r.a <== s2.out;
    r.b <== s1.out;
    component r2 = FpMul();
    r2.a <== two.out;
    r2.b <== r.out;
    component v = FpMul();
    v.a <== u1.out;
    v.b <== i_sq.out;
    component r_sq = FpSquare();
    r_sq.a <== r2.out;
    component x3_tmp = FpSub();
    x3_tmp.a <== r_sq.out;
    x3_tmp.b <== j.out;
    component v2 = FpMul();
    v2.a <== two.out;
    v2.b <== v.out;
    component x3 = FpSub();
    x3.a <== x3_tmp.out;
    x3.b <== v2.out;
    component v_minus_x3 = FpSub();
    v_minus_x3.a <== v.out;
    v_minus_x3.b <== x3.out;
    component y3_mul = FpMul();
    y3_mul.a <== r2.out;
    y3_mul.b <== v_minus_x3.out;
    component s1j = FpMul();
    s1j.a <== s1.out;
    s1j.b <== j.out;
    component s1j2 = FpMul();
    s1j2.a <== two.out;
    s1j2.b <== s1j.out;
    component y3 = FpSub();
    y3.a <== y3_mul.out;
    y3.b <== s1j2.out;
    component z3_sum = FpAdd();
    z3_sum.a <== p[2];
    z3_sum.b <== q[2];
    component z3_sum_sq = FpSquare();
    z3_sum_sq.a <== z3_sum.out;
    component z3_tmp = FpSub();
    z3_tmp.a <== z3_sum_sq.out;
    z3_tmp.b <== z1z1.out;
    component z3_tmp2 = FpSub();
    z3_tmp2.a <== z3_tmp.out;
    z3_tmp2.b <== z2z2.out;
    component z3 = FpMul();
    z3.a <== z3_tmp2.out;
    z3.b <== h.out;

    component dbl = G1DoubleJac();
    dbl.p[0] <== p[0];
    dbl.p[1] <== p[1];
    dbl.p[2] <== p[2];

    signal caseP;
    signal caseQ;
    signal caseDbl;
    signal caseAdd;
    caseP <== pInf.out;
    signal notP;
    signal notQ;
    signal nonInf;
    notP <== 1 - caseP;
    notQ <== 1 - qInf.out;
    nonInf <== notP * notQ;
    caseQ <== notP * qInf.out;
    caseDbl <== nonInf * same;
    caseAdd <== nonInf * (1 - same);
    caseP * (caseP - 1) === 0;
    caseQ * (caseQ - 1) === 0;
    caseDbl * (caseDbl - 1) === 0;
    caseAdd * (caseAdd - 1) === 0;
    caseP + caseQ + caseDbl + caseAdd === 1;

    signal sel0[3];
    signal sel1[3];
    sel0[0] <== p[0] + caseP * (q[0] - p[0]);
    sel0[1] <== p[1] + caseP * (q[1] - p[1]);
    sel0[2] <== p[2] + caseP * (q[2] - p[2]);
    sel1[0] <== sel0[0] + caseDbl * (dbl.out[0] - sel0[0]);
    sel1[1] <== sel0[1] + caseDbl * (dbl.out[1] - sel0[1]);
    sel1[2] <== sel0[2] + caseDbl * (dbl.out[2] - sel0[2]);
    out[0] <== sel1[0] + caseAdd * (x3.out - sel1[0]);
    out[1] <== sel1[1] + caseAdd * (y3.out - sel1[1]);
    out[2] <== sel1[2] + caseAdd * (z3.out - sel1[2]);
}

template G1AddJacMixed() {
    signal input p[3];
    signal input q[2];
    signal output out[3];

    component pInf = G1JacIsInfinity();
    component qInf = G1AffineIsInfinity();
    pInf.p[0] <== p[0];
    pInf.p[1] <== p[1];
    pInf.p[2] <== p[2];
    qInf.p[0] <== q[0];
    qInf.p[1] <== q[1];

    component z2z2 = FpSquare();
    z2z2.a <== p[2];
    component u1 = FpMul();
    u1.a <== q[0];
    u1.b <== z2z2.out;
    component s1 = FpMul();
    component pz_mul = FpMul();
    pz_mul.a <== q[1];
    pz_mul.b <== p[2];
    s1.a <== pz_mul.out;
    s1.b <== z2z2.out;
    component sameU = FpEq();
    component sameS = FpEq();
    sameU.a <== u1.out;
    sameU.b <== p[0];
    sameS.a <== s1.out;
    sameS.b <== p[1];
    signal same;
    same <== sameU.out * sameS.out;
    same * (same - 1) === 0;

    component h = FpSub();
    h.a <== p[0];
    h.b <== u1.out;
    component i_mul = FpMul();
    component two = FpTwo();
    i_mul.a <== two.out;
    i_mul.b <== h.out;
    component i_sq = FpSquare();
    i_sq.a <== i_mul.out;
    component j = FpMul();
    j.a <== h.out;
    j.b <== i_sq.out;
    component r = FpSub();
    r.a <== p[1];
    r.b <== s1.out;
    component r2 = FpMul();
    r2.a <== two.out;
    r2.b <== r.out;
    component v = FpMul();
    v.a <== u1.out;
    v.b <== i_sq.out;
    component r_sq = FpSquare();
    r_sq.a <== r2.out;
    component x3_tmp = FpSub();
    x3_tmp.a <== r_sq.out;
    x3_tmp.b <== j.out;
    component v2 = FpMul();
    v2.a <== two.out;
    v2.b <== v.out;
    component x3 = FpSub();
    x3.a <== x3_tmp.out;
    x3.b <== v2.out;
    component v_minus_x3 = FpSub();
    v_minus_x3.a <== v.out;
    v_minus_x3.b <== x3.out;
    component y3_mul = FpMul();
    y3_mul.a <== r2.out;
    y3_mul.b <== v_minus_x3.out;
    component s1j = FpMul();
    s1j.a <== s1.out;
    s1j.b <== j.out;
    component s1j2 = FpMul();
    s1j2.a <== two.out;
    s1j2.b <== s1j.out;
    component y3 = FpSub();
    y3.a <== y3_mul.out;
    y3.b <== s1j2.out;
    component z3_sum = FpAdd();
    z3_sum.a <== p[2];
    z3_sum.b <== h.out;
    component z3_sum_sq = FpSquare();
    z3_sum_sq.a <== z3_sum.out;
    component h_sq = FpSquare();
    h_sq.a <== h.out;
    component z3_tmp = FpSub();
    z3_tmp.a <== z3_sum_sq.out;
    z3_tmp.b <== z2z2.out;
    component z3 = FpSub();
    z3.a <== z3_tmp.out;
    z3.b <== h_sq.out;

    component dbl = G1DoubleJac();
    dbl.p[0] <== p[0];
    dbl.p[1] <== p[1];
    dbl.p[2] <== p[2];

    component one = FpOne();
    component zero = FpZero();
    signal qjac[3];
    qjac[0] <== q[0];
    qjac[1] <== q[1];
    qjac[2] <== one.out;

    component inf = G1JacobianInfinity();

    signal caseInf;
    signal caseQ;
    signal casePOnly;
    signal caseDbl;
    signal caseAdd;
    caseInf <== pInf.out * qInf.out;
    caseQ <== pInf.out * (1 - qInf.out);
    casePOnly <== (1 - pInf.out) * qInf.out;
    caseDbl <== (1 - pInf.out) * (1 - qInf.out) * same;
    caseAdd <== (1 - pInf.out) * (1 - qInf.out) * (1 - same);
    caseInf * (caseInf - 1) === 0;
    caseQ * (caseQ - 1) === 0;
    casePOnly * (casePOnly - 1) === 0;
    caseDbl * (caseDbl - 1) === 0;
    caseAdd * (caseAdd - 1) === 0;
    caseInf + caseQ + casePOnly + caseDbl + caseAdd === 1;

    out[0] <== caseInf * inf.out[0] + caseQ * qjac[0] + casePOnly * p[0] + caseDbl * dbl.out[0] + caseAdd * x3.out;
    out[1] <== caseInf * inf.out[1] + caseQ * qjac[1] + casePOnly * p[1] + caseDbl * dbl.out[1] + caseAdd * y3.out;
    out[2] <== caseInf * inf.out[2] + caseQ * qjac[2] + casePOnly * p[2] + caseDbl * dbl.out[2] + caseAdd * z3.out;
}

template G1JacobianToAffine() {
    signal input p[3];
    signal input inv_z;
    signal input enable;
    signal output out[2];

    enable * (enable - 1) === 0;

    component zZero = FpIsZero();
    zZero.a <== p[2];
    component mul = FpMul();
    mul.a <== p[2];
    mul.b <== inv_z;
    component one = FpOne();
    component zero = FpZero();
    component expect = FpSelect();
    expect.a <== zero.out;
    expect.b <== one.out;
    expect.sel <== zZero.out;
    enable * (mul.out - expect.out) === 0;

    component invSq = FpSquare();
    invSq.a <== inv_z;
    component xMul = FpMul();
    xMul.a <== p[0];
    xMul.b <== invSq.out;
    component yMul = FpMul();
    yMul.a <== p[1];
    yMul.b <== invSq.out;
    component yMul2 = FpMul();
    yMul2.a <== yMul.out;
    yMul2.b <== inv_z;

    component selX = FpSelect();
    component selY = FpSelect();
    selX.a <== zero.out;
    selX.b <== xMul.out;
    selY.a <== zero.out;
    selY.b <== yMul2.out;
    selX.sel <== zZero.out;
    selY.sel <== zZero.out;
    out[0] <== selX.out;
    out[1] <== selY.out;
}

template G1AddAffine() {
    signal input a[2];
    signal input b[2];
    signal input inv_add_z;
    signal input inv_double_z;
    signal output out[2];

    component aInf = G1AffineIsInfinity();
    component bInf = G1AffineIsInfinity();
    aInf.p[0] <== a[0];
    aInf.p[1] <== a[1];
    bInf.p[0] <== b[0];
    bInf.p[1] <== b[1];

    component eqX = FpEq();
    component eqY = FpEq();
    eqX.a <== a[0];
    eqX.b <== b[0];
    eqY.a <== a[1];
    eqY.b <== b[1];
    signal same;
    signal diffY;
    signal notSameX;
    same <== eqX.out * eqY.out;
    same * (same - 1) === 0;
    diffY <== eqX.out * (1 - eqY.out);
    diffY * (diffY - 1) === 0;
    notSameX <== 1 - eqX.out;

    component h = FpSub();
    component hh = FpSquare();
    component i_mul = FpMul();
    component j = FpMul();
    component r_tmp = FpSub();
    component r = FpMul();
    component v = FpMul();
    component two = FpTwo();
    component four = FpFour();

    h.a <== b[0];
    h.b <== a[0];
    r_tmp.a <== b[1];
    r_tmp.b <== a[1];
    hh.a <== h.out;
    i_mul.a <== four.out;
    i_mul.b <== hh.out;
    j.a <== h.out;
    j.b <== i_mul.out;
    r.a <== two.out;
    r.b <== r_tmp.out;
    v.a <== a[0];
    v.b <== i_mul.out;
    component r_sq = FpSquare();
    r_sq.a <== r.out;
    component x3_tmp = FpSub();
    x3_tmp.a <== r_sq.out;
    x3_tmp.b <== j.out;
    component v2 = FpMul();
    v2.a <== two.out;
    v2.b <== v.out;
    component x3 = FpSub();
    x3.a <== x3_tmp.out;
    x3.b <== v2.out;
    component v_minus_x3 = FpSub();
    v_minus_x3.a <== v.out;
    v_minus_x3.b <== x3.out;
    component y3_mul = FpMul();
    y3_mul.a <== r.out;
    y3_mul.b <== v_minus_x3.out;
    component ayj = FpMul();
    ayj.a <== a[1];
    ayj.b <== j.out;
    component ayj2 = FpMul();
    ayj2.a <== two.out;
    ayj2.b <== ayj.out;
    component y3 = FpSub();
    y3.a <== y3_mul.out;
    y3.b <== ayj2.out;
    component z3 = FpMul();
    z3.a <== two.out;
    z3.b <== h.out;

    signal addJac[3];
    addJac[0] <== x3.out;
    addJac[1] <== y3.out;
    addJac[2] <== z3.out;

    signal notAInf;
    signal notBInf;
    notAInf <== 1 - aInf.out;
    notBInf <== 1 - bInf.out;
    signal addEnableTmp;
    signal dblEnableTmp;
    component addAff = G1JacobianToAffine();
    addEnableTmp <== notSameX * notAInf;
    addAff.enable <== addEnableTmp * notBInf;
    addAff.p[0] <== addJac[0];
    addAff.p[1] <== addJac[1];
    addAff.p[2] <== addJac[2];
    addAff.inv_z <== inv_add_z;

    component dblJac = G1DoubleMixed();
    dblJac.a[0] <== a[0];
    dblJac.a[1] <== a[1];
    component dblAff = G1JacobianToAffine();
    dblEnableTmp <== same * notAInf;
    dblAff.enable <== dblEnableTmp * notBInf;
    dblAff.p[0] <== dblJac.out[0];
    dblAff.p[1] <== dblJac.out[1];
    dblAff.p[2] <== dblJac.out[2];
    dblAff.inv_z <== inv_double_z;

    component inf = G1AffineInfinity();

    signal caseA;
    signal caseB;
    signal caseSame;
    signal caseInf;
    signal caseAdd;
    caseA <== aInf.out;
    signal nonInf;
    nonInf <== notAInf * notBInf;
    caseB <== notAInf * bInf.out;
    caseSame <== nonInf * same;
    caseInf <== nonInf * diffY;
    caseAdd <== nonInf * notSameX;
    caseA * (caseA - 1) === 0;
    caseB * (caseB - 1) === 0;
    caseSame * (caseSame - 1) === 0;
    caseInf * (caseInf - 1) === 0;
    caseAdd * (caseAdd - 1) === 0;
    caseA + caseB + caseSame + caseInf + caseAdd === 1;

    signal sel0[2];
    signal sel1[2];
    signal sel2[2];
    sel0[0] <== a[0] + caseA * (b[0] - a[0]);
    sel0[1] <== a[1] + caseA * (b[1] - a[1]);
    sel1[0] <== sel0[0] + caseSame * (dblAff.out[0] - sel0[0]);
    sel1[1] <== sel0[1] + caseSame * (dblAff.out[1] - sel0[1]);
    sel2[0] <== sel1[0] + caseInf * (inf.out[0] - sel1[0]);
    sel2[1] <== sel1[1] + caseInf * (inf.out[1] - sel1[1]);
    out[0] <== sel2[0] + caseAdd * (addAff.out[0] - sel2[0]);
    out[1] <== sel2[1] + caseAdd * (addAff.out[1] - sel2[1]);
}

