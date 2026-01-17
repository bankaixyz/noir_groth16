pragma circom 2.0.0;

include "../pairing.circom";

template PairingOps() {
    signal input g1_gen[2];
    signal input g2_gen[2][2];
    signal input g1_2g1[2];
    signal input g2_3g2[2][2];

    signal input inv_miller_gen[2][3][2];
    signal input inv_miller_2g1[2][3][2];
    signal input inv_miller_multi[2][3][2];

    signal output miller_gen[2][3][2];
    signal output miller_2g1[2][3][2];
    signal output miller_multi[2][3][2];
    signal output pairing_gen[2][3][2];
    signal output pairing_2g1[2][3][2];
    signal output pairing_multi[2][3][2];

    component miller_single = PairingMillerLoop(1);
    miller_single.p[0][0] <== g1_gen[0];
    miller_single.p[0][1] <== g1_gen[1];
    for (var i2 = 0; i2 < 2; i2++) {
        miller_single.q[0][0][i2] <== g2_gen[0][i2];
        miller_single.q[0][1][i2] <== g2_gen[1][i2];
    }

    component miller_2g1_calc = PairingMillerLoop(1);
    miller_2g1_calc.p[0][0] <== g1_2g1[0];
    miller_2g1_calc.p[0][1] <== g1_2g1[1];
    for (var i3 = 0; i3 < 2; i3++) {
        miller_2g1_calc.q[0][0][i3] <== g2_gen[0][i3];
        miller_2g1_calc.q[0][1][i3] <== g2_gen[1][i3];
    }

    component miller_multi_2 = PairingMillerLoop(2);
    for (var j5 = 0; j5 < 2; j5++) {
        miller_multi_2.p[0][j5] <== g1_gen[j5];
        miller_multi_2.p[1][j5] <== g1_2g1[j5];
    }
    for (var i4 = 0; i4 < 2; i4++) {
        miller_multi_2.q[0][0][i4] <== g2_gen[0][i4];
        miller_multi_2.q[0][1][i4] <== g2_gen[1][i4];
        miller_multi_2.q[1][0][i4] <== g2_3g2[0][i4];
        miller_multi_2.q[1][1][i4] <== g2_3g2[1][i4];
    }

    component pairing_single = PairingFinalExponentiation();
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i6 = 0; i6 < 2; i6++) {
                pairing_single.z[c][b][i6] <== miller_single.out[c][b][i6];
                pairing_single.inv_z[c][b][i6] <== inv_miller_gen[c][b][i6];
            }
        }
    }

    component pairing_2g1_single = PairingFinalExponentiation();
    for (var c2 = 0; c2 < 2; c2++) {
        for (var b2 = 0; b2 < 3; b2++) {
            for (var i8 = 0; i8 < 2; i8++) {
                pairing_2g1_single.z[c2][b2][i8] <== miller_2g1_calc.out[c2][b2][i8];
                pairing_2g1_single.inv_z[c2][b2][i8] <== inv_miller_2g1[c2][b2][i8];
            }
        }
    }

    component pairing_multi_2 = PairingFinalExponentiation();
    for (var c3 = 0; c3 < 2; c3++) {
        for (var b3 = 0; b3 < 3; b3++) {
            for (var i10 = 0; i10 < 2; i10++) {
                pairing_multi_2.z[c3][b3][i10] <== miller_multi_2.out[c3][b3][i10];
                pairing_multi_2.inv_z[c3][b3][i10] <== inv_miller_multi[c3][b3][i10];
            }
        }
    }

    for (var c4 = 0; c4 < 2; c4++) {
        for (var b4 = 0; b4 < 3; b4++) {
            for (var i12 = 0; i12 < 2; i12++) {
                miller_gen[c4][b4][i12] <== miller_single.out[c4][b4][i12];
                miller_2g1[c4][b4][i12] <== miller_2g1_calc.out[c4][b4][i12];
                miller_multi[c4][b4][i12] <== miller_multi_2.out[c4][b4][i12];
                pairing_gen[c4][b4][i12] <== pairing_single.out[c4][b4][i12];
                pairing_2g1[c4][b4][i12] <== pairing_2g1_single.out[c4][b4][i12];
                pairing_multi[c4][b4][i12] <== pairing_multi_2.out[c4][b4][i12];
            }
        }
    }
}

component main = PairingOps();
