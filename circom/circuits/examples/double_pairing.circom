pragma circom 2.0.0;

include "../pairing.circom";

template DoublePairingExample() {
    signal input p[2][2];
    signal input q[2][2][2];
    signal input inv_miller[2][3][2];
    signal output out[2][3][2];

    component pairing = PairingMulti(2);
    for (var k = 0; k < 2; k++) {
        for (var j = 0; j < 2; j++) {
            pairing.p[k][j] <== p[k][j];
        }
        for (var i2 = 0; i2 < 2; i2++) {
            pairing.q[k][0][i2] <== q[k][0][i2];
            pairing.q[k][1][i2] <== q[k][1][i2];
        }
    }
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i3 = 0; i3 < 2; i3++) {
                pairing.inv_miller[c][b][i3] <== inv_miller[c][b][i3];
            }
        }
    }

    for (var c2 = 0; c2 < 2; c2++) {
        for (var b2 = 0; b2 < 3; b2++) {
            for (var i4 = 0; i4 < 2; i4++) {
                out[c2][b2][i4] <== pairing.out[c2][b2][i4];
            }
        }
    }
}

component main = DoublePairingExample();
