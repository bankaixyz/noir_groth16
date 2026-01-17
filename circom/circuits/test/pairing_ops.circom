pragma circom 2.0.0;

include "../pairing.circom";

template PairingOps() {
    signal input g1_gen[2][3];
    signal input g2_gen[2][2][3];
    signal input g1_2g1[2][3];
    signal input g2_3g2[2][2][3];

    signal input inv_miller_gen[2][3][2][3];
    signal input inv_miller_2g1[2][3][2][3];
    signal input inv_miller_multi[2][3][2][3];

    signal output miller_gen[2][3][2][3];
    signal output miller_2g1[2][3][2][3];
    signal output miller_multi[2][3][2][3];
    signal output pairing_gen[2][3][2][3];
    signal output pairing_2g1[2][3][2][3];
    signal output pairing_multi[2][3][2][3];

    component miller_single = PairingMillerLoop(1);
    for (var j = 0; j < 3; j++) {
        miller_single.p[0][0][j] <== g1_gen[0][j];
        miller_single.p[0][1][j] <== g1_gen[1][j];
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            miller_single.q[0][0][i2][j2] <== g2_gen[0][i2][j2];
            miller_single.q[0][1][i2][j2] <== g2_gen[1][i2][j2];
        }
    }

    component miller_2g1_calc = PairingMillerLoop(1);
    for (var j3 = 0; j3 < 3; j3++) {
        miller_2g1_calc.p[0][0][j3] <== g1_2g1[0][j3];
        miller_2g1_calc.p[0][1][j3] <== g1_2g1[1][j3];
    }
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j4 = 0; j4 < 3; j4++) {
            miller_2g1_calc.q[0][0][i3][j4] <== g2_gen[0][i3][j4];
            miller_2g1_calc.q[0][1][i3][j4] <== g2_gen[1][i3][j4];
        }
    }

    component miller_multi_2 = PairingMillerLoop(2);
    for (var j5 = 0; j5 < 3; j5++) {
        miller_multi_2.p[0][0][j5] <== g1_gen[0][j5];
        miller_multi_2.p[0][1][j5] <== g1_gen[1][j5];
        miller_multi_2.p[1][0][j5] <== g1_2g1[0][j5];
        miller_multi_2.p[1][1][j5] <== g1_2g1[1][j5];
    }
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j6 = 0; j6 < 3; j6++) {
            miller_multi_2.q[0][0][i4][j6] <== g2_gen[0][i4][j6];
            miller_multi_2.q[0][1][i4][j6] <== g2_gen[1][i4][j6];
            miller_multi_2.q[1][0][i4][j6] <== g2_3g2[0][i4][j6];
            miller_multi_2.q[1][1][i4][j6] <== g2_3g2[1][i4][j6];
        }
    }

    component pairing_single = PairingFinalExponentiation();
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i6 = 0; i6 < 2; i6++) {
                for (var j9 = 0; j9 < 3; j9++) {
                    pairing_single.z[c][b][i6][j9] <== miller_single.out[c][b][i6][j9];
                    pairing_single.inv_z[c][b][i6][j9] <== inv_miller_gen[c][b][i6][j9];
                }
            }
        }
    }

    component pairing_2g1_single = PairingFinalExponentiation();
    for (var c2 = 0; c2 < 2; c2++) {
        for (var b2 = 0; b2 < 3; b2++) {
            for (var i8 = 0; i8 < 2; i8++) {
                for (var j12 = 0; j12 < 3; j12++) {
                    pairing_2g1_single.z[c2][b2][i8][j12] <== miller_2g1_calc.out[c2][b2][i8][j12];
                    pairing_2g1_single.inv_z[c2][b2][i8][j12] <== inv_miller_2g1[c2][b2][i8][j12];
                }
            }
        }
    }

    component pairing_multi_2 = PairingFinalExponentiation();
    for (var c3 = 0; c3 < 2; c3++) {
        for (var b3 = 0; b3 < 3; b3++) {
            for (var i10 = 0; i10 < 2; i10++) {
                for (var j15 = 0; j15 < 3; j15++) {
                    pairing_multi_2.z[c3][b3][i10][j15] <== miller_multi_2.out[c3][b3][i10][j15];
                    pairing_multi_2.inv_z[c3][b3][i10][j15] <== inv_miller_multi[c3][b3][i10][j15];
                }
            }
        }
    }

    for (var c4 = 0; c4 < 2; c4++) {
        for (var b4 = 0; b4 < 3; b4++) {
            for (var i11 = 0; i11 < 2; i11++) {
                for (var j16 = 0; j16 < 3; j16++) {
                    miller_gen[c4][b4][i11][j16] <== miller_single.out[c4][b4][i11][j16];
                    miller_2g1[c4][b4][i11][j16] <== miller_2g1_calc.out[c4][b4][i11][j16];
                    miller_multi[c4][b4][i11][j16] <== miller_multi_2.out[c4][b4][i11][j16];
                    pairing_gen[c4][b4][i11][j16] <== pairing_single.out[c4][b4][i11][j16];
                    pairing_2g1[c4][b4][i11][j16] <== pairing_2g1_single.out[c4][b4][i11][j16];
                    pairing_multi[c4][b4][i11][j16] <== pairing_multi_2.out[c4][b4][i11][j16];
                }
            }
        }
    }
}

component main = PairingOps();
