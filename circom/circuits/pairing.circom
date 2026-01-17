pragma circom 2.0.0;

include "./fp12.circom";
include "./fp2.circom";
include "./fp.circom";
include "./g1.circom";
include "./g2.circom";

template PairingLineEvalAtPoint() {
    signal input line[3][2][3];
    signal input p[2][3];
    signal output out[3][2][3];

    component mul0 = Fp2MulByElement();
    component mul1 = Fp2MulByElement();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            mul0.a[i][j] <== line[0][i][j];
            mul1.a[i][j] <== line[1][i][j];
        }
    }
    for (var j2 = 0; j2 < 3; j2++) {
        mul0.element[j2] <== p[1][j2];
        mul1.element[j2] <== p[0][j2];
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j3 = 0; j3 < 3; j3++) {
            out[0][i2][j3] <== mul0.out[i2][j3];
            out[1][i2][j3] <== mul1.out[i2][j3];
            out[2][i2][j3] <== line[2][i2][j3];
        }
    }
}

template PairingLineSelect() {
    signal input line[3][2][3];
    signal input sel;
    signal output out[3][2][3];

    component one = Fp2One();
    component zero = Fp2Zero();
    component sel0 = Fp2Select();
    component sel1 = Fp2Select();
    component sel2 = Fp2Select();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            sel0.a[i][j] <== one.out[i][j];
            sel0.b[i][j] <== line[0][i][j];
            sel1.a[i][j] <== zero.out[i][j];
            sel1.b[i][j] <== line[1][i][j];
            sel2.a[i][j] <== zero.out[i][j];
            sel2.b[i][j] <== line[2][i][j];
        }
    }
    sel0.sel <== sel;
    sel1.sel <== sel;
    sel2.sel <== sel;
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            out[0][i2][j2] <== sel0.out[i2][j2];
            out[1][i2][j2] <== sel1.out[i2][j2];
            out[2][i2][j2] <== sel2.out[i2][j2];
        }
    }
}

template PairingMul034By034() {
    signal input d0[2][3];
    signal input d3[2][3];
    signal input d4[2][3];
    signal input c0[2][3];
    signal input c3[2][3];
    signal input c4[2][3];
    signal output out[5][2][3];

    component x0 = Fp2Mul();
    component x3 = Fp2Mul();
    component x4 = Fp2Mul();
    for (var i = 0; i < 2; i++) {
        for (var j = 0; j < 3; j++) {
            x0.a[i][j] <== c0[i][j];
            x0.b[i][j] <== d0[i][j];
            x3.a[i][j] <== c3[i][j];
            x3.b[i][j] <== d3[i][j];
            x4.a[i][j] <== c4[i][j];
            x4.b[i][j] <== d4[i][j];
        }
    }

    component c0c4 = Fp2Add();
    component d0d4 = Fp2Add();
    component c0c3 = Fp2Add();
    component d0d3 = Fp2Add();
    component c3c4 = Fp2Add();
    component d3d4 = Fp2Add();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            c0c4.a[i2][j2] <== c0[i2][j2];
            c0c4.b[i2][j2] <== c4[i2][j2];
            d0d4.a[i2][j2] <== d0[i2][j2];
            d0d4.b[i2][j2] <== d4[i2][j2];
            c0c3.a[i2][j2] <== c0[i2][j2];
            c0c3.b[i2][j2] <== c3[i2][j2];
            d0d3.a[i2][j2] <== d0[i2][j2];
            d0d3.b[i2][j2] <== d3[i2][j2];
            c3c4.a[i2][j2] <== c3[i2][j2];
            c3c4.b[i2][j2] <== c4[i2][j2];
            d3d4.a[i2][j2] <== d3[i2][j2];
            d3d4.b[i2][j2] <== d4[i2][j2];
        }
    }

    component x04_mul = Fp2Mul();
    component x03_mul = Fp2Mul();
    component x34_mul = Fp2Mul();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            x04_mul.a[i3][j3] <== c0c4.out[i3][j3];
            x04_mul.b[i3][j3] <== d0d4.out[i3][j3];
            x03_mul.a[i3][j3] <== c0c3.out[i3][j3];
            x03_mul.b[i3][j3] <== d0d3.out[i3][j3];
            x34_mul.a[i3][j3] <== c3c4.out[i3][j3];
            x34_mul.b[i3][j3] <== d3d4.out[i3][j3];
        }
    }

    component x04_sub1 = Fp2Sub();
    component x04 = Fp2Sub();
    component x03_sub1 = Fp2Sub();
    component x03 = Fp2Sub();
    component x34_sub1 = Fp2Sub();
    component x34 = Fp2Sub();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j4 = 0; j4 < 3; j4++) {
            x04_sub1.a[i4][j4] <== x04_mul.out[i4][j4];
            x04_sub1.b[i4][j4] <== x0.out[i4][j4];

            x03_sub1.a[i4][j4] <== x03_mul.out[i4][j4];
            x03_sub1.b[i4][j4] <== x0.out[i4][j4];

            x34_sub1.a[i4][j4] <== x34_mul.out[i4][j4];
            x34_sub1.b[i4][j4] <== x3.out[i4][j4];
        }
    }
    for (var i4b = 0; i4b < 2; i4b++) {
        for (var j4b = 0; j4b < 3; j4b++) {
            x04.a[i4b][j4b] <== x04_sub1.out[i4b][j4b];
            x04.b[i4b][j4b] <== x4.out[i4b][j4b];

            x03.a[i4b][j4b] <== x03_sub1.out[i4b][j4b];
            x03.b[i4b][j4b] <== x3.out[i4b][j4b];

            x34.a[i4b][j4b] <== x34_sub1.out[i4b][j4b];
            x34.b[i4b][j4b] <== x4.out[i4b][j4b];
        }
    }

    component x4_nr = Fp2MulByNonResidue();
    for (var i5 = 0; i5 < 2; i5++) {
        for (var j5 = 0; j5 < 3; j5++) {
            x4_nr.a[i5][j5] <== x4.out[i5][j5];
        }
    }
    component z00 = Fp2Add();
    for (var i6 = 0; i6 < 2; i6++) {
        for (var j6 = 0; j6 < 3; j6++) {
            z00.a[i6][j6] <== x4_nr.out[i6][j6];
            z00.b[i6][j6] <== x0.out[i6][j6];
        }
    }

    for (var i7 = 0; i7 < 2; i7++) {
        for (var j7 = 0; j7 < 3; j7++) {
            out[0][i7][j7] <== z00.out[i7][j7];
            out[1][i7][j7] <== x3.out[i7][j7];
            out[2][i7][j7] <== x34.out[i7][j7];
            out[3][i7][j7] <== x03.out[i7][j7];
            out[4][i7][j7] <== x04.out[i7][j7];
        }
    }
}

template PairingG2DoubleStepAtPoint() {
    signal input q_proj[3][2][3];
    signal input p[2][3];
    signal input active;
    signal output q_proj_out[3][2][3];
    signal output line_out[3][2][3];

    component dbl = G2ProjDoubleStep();
    for (var c = 0; c < 3; c++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                dbl.p[c][i][j] <== q_proj[c][i][j];
            }
        }
    }

    component eval = PairingLineEvalAtPoint();
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            eval.line[0][i2][j2] <== dbl.line[0][i2][j2];
            eval.line[1][i2][j2] <== dbl.line[1][i2][j2];
            eval.line[2][i2][j2] <== dbl.line[2][i2][j2];
        }
    }
    for (var j3 = 0; j3 < 3; j3++) {
        eval.p[0][j3] <== p[0][j3];
        eval.p[1][j3] <== p[1][j3];
    }

    component sel = PairingLineSelect();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j4 = 0; j4 < 3; j4++) {
            sel.line[0][i3][j4] <== eval.out[0][i3][j4];
            sel.line[1][i3][j4] <== eval.out[1][i3][j4];
            sel.line[2][i3][j4] <== eval.out[2][i3][j4];
        }
    }
    sel.sel <== active;

    for (var c2 = 0; c2 < 3; c2++) {
        for (var i4 = 0; i4 < 2; i4++) {
            for (var j5 = 0; j5 < 3; j5++) {
                q_proj_out[c2][i4][j5] <== dbl.out[c2][i4][j5];
                line_out[c2][i4][j5] <== sel.out[c2][i4][j5];
            }
        }
    }
}

template PairingG2AddMixedStepAtPoint() {
    signal input q_proj[3][2][3];
    signal input q_aff[2][2][3];
    signal input p[2][3];
    signal input active;
    signal output q_proj_out[3][2][3];
    signal output line_out[3][2][3];

    component add = G2ProjAddMixedStep();
    for (var c = 0; c < 3; c++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                add.p[c][i][j] <== q_proj[c][i][j];
            }
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            add.a[0][i2][j2] <== q_aff[0][i2][j2];
            add.a[1][i2][j2] <== q_aff[1][i2][j2];
        }
    }

    component eval = PairingLineEvalAtPoint();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            eval.line[0][i3][j3] <== add.line[0][i3][j3];
            eval.line[1][i3][j3] <== add.line[1][i3][j3];
            eval.line[2][i3][j3] <== add.line[2][i3][j3];
        }
    }
    for (var j4 = 0; j4 < 3; j4++) {
        eval.p[0][j4] <== p[0][j4];
        eval.p[1][j4] <== p[1][j4];
    }

    component sel = PairingLineSelect();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j5 = 0; j5 < 3; j5++) {
            sel.line[0][i4][j5] <== eval.out[0][i4][j5];
            sel.line[1][i4][j5] <== eval.out[1][i4][j5];
            sel.line[2][i4][j5] <== eval.out[2][i4][j5];
        }
    }
    sel.sel <== active;

    for (var c2 = 0; c2 < 3; c2++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j6 = 0; j6 < 3; j6++) {
                q_proj_out[c2][i5][j6] <== add.out[c2][i5][j6];
                line_out[c2][i5][j6] <== sel.out[c2][i5][j6];
            }
        }
    }
}

template PairingG2LineComputeAtPoint() {
    signal input q_proj[3][2][3];
    signal input q_aff[2][2][3];
    signal input p[2][3];
    signal input active;
    signal output q_proj_out[3][2][3];
    signal output line_out[3][2][3];

    component line = G2ProjLineCompute();
    for (var c = 0; c < 3; c++) {
        for (var i = 0; i < 2; i++) {
            for (var j = 0; j < 3; j++) {
                line.p[c][i][j] <== q_proj[c][i][j];
            }
        }
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            line.a[0][i2][j2] <== q_aff[0][i2][j2];
            line.a[1][i2][j2] <== q_aff[1][i2][j2];
        }
    }

    component eval = PairingLineEvalAtPoint();
    for (var i3 = 0; i3 < 2; i3++) {
        for (var j3 = 0; j3 < 3; j3++) {
            eval.line[0][i3][j3] <== line.line[0][i3][j3];
            eval.line[1][i3][j3] <== line.line[1][i3][j3];
            eval.line[2][i3][j3] <== line.line[2][i3][j3];
        }
    }
    for (var j4 = 0; j4 < 3; j4++) {
        eval.p[0][j4] <== p[0][j4];
        eval.p[1][j4] <== p[1][j4];
    }

    component sel = PairingLineSelect();
    for (var i4 = 0; i4 < 2; i4++) {
        for (var j5 = 0; j5 < 3; j5++) {
            sel.line[0][i4][j5] <== eval.out[0][i4][j5];
            sel.line[1][i4][j5] <== eval.out[1][i4][j5];
            sel.line[2][i4][j5] <== eval.out[2][i4][j5];
        }
    }
    sel.sel <== active;

    for (var c2 = 0; c2 < 3; c2++) {
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j6 = 0; j6 < 3; j6++) {
                q_proj_out[c2][i5][j6] <== line.out[c2][i5][j6];
                line_out[c2][i5][j6] <== sel.out[c2][i5][j6];
            }
        }
    }
}

template PairingFinalExpEasyPart() {
    signal input z[2][3][2][3];
    signal input inv_z[2][3][2][3];
    signal output out[2][3][2][3];

    component conj = Fp12Conjugate();
    for (var c = 0; c < 2; c++) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    conj.a[c][k][i][j] <== z[c][k][i][j];
                }
            }
        }
    }

    component inv = Fp12Inverse();
    for (var c2 = 0; c2 < 2; c2++) {
        for (var k2 = 0; k2 < 3; k2++) {
            for (var i2 = 0; i2 < 2; i2++) {
                for (var j2 = 0; j2 < 3; j2++) {
                    inv.a[c2][k2][i2][j2] <== z[c2][k2][i2][j2];
                    inv.inv[c2][k2][i2][j2] <== inv_z[c2][k2][i2][j2];
                }
            }
        }
    }

    component t0 = Fp12Mul();
    for (var c3 = 0; c3 < 2; c3++) {
        for (var k3 = 0; k3 < 3; k3++) {
            for (var i3 = 0; i3 < 2; i3++) {
                for (var j3 = 0; j3 < 3; j3++) {
                    t0.a[c3][k3][i3][j3] <== conj.out[c3][k3][i3][j3];
                    t0.b[c3][k3][i3][j3] <== inv.out[c3][k3][i3][j3];
                }
            }
        }
    }

    component frob = Fp12FrobeniusSquare();
    for (var c4 = 0; c4 < 2; c4++) {
        for (var k4 = 0; k4 < 3; k4++) {
            for (var i4 = 0; i4 < 2; i4++) {
                for (var j4 = 0; j4 < 3; j4++) {
                    frob.a[c4][k4][i4][j4] <== t0.out[c4][k4][i4][j4];
                }
            }
        }
    }

    component mul = Fp12Mul();
    for (var c5 = 0; c5 < 2; c5++) {
        for (var k5 = 0; k5 < 3; k5++) {
            for (var i5 = 0; i5 < 2; i5++) {
                for (var j5 = 0; j5 < 3; j5++) {
                    mul.a[c5][k5][i5][j5] <== frob.out[c5][k5][i5][j5];
                    mul.b[c5][k5][i5][j5] <== t0.out[c5][k5][i5][j5];
                }
            }
        }
    }

    for (var c6 = 0; c6 < 2; c6++) {
        for (var k6 = 0; k6 < 3; k6++) {
            for (var i6 = 0; i6 < 2; i6++) {
                for (var j6 = 0; j6 < 3; j6++) {
                    out[c6][k6][i6][j6] <== mul.out[c6][k6][i6][j6];
                }
            }
        }
    }
}

template PairingFinalExpHardPart() {
    signal input a[2][3][2][3];
    signal output out[2][3][2][3];

    component t0 = Fp12Expt();
    for (var c = 0; c < 2; c++) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    t0.a[c][k][i][j] <== a[c][k][i][j];
                }
            }
        }
    }

    component t0_conj = Fp12Conjugate();
    for (var c2 = 0; c2 < 2; c2++) {
        for (var k2 = 0; k2 < 3; k2++) {
            for (var i2 = 0; i2 < 2; i2++) {
                for (var j2 = 0; j2 < 3; j2++) {
                    t0_conj.a[c2][k2][i2][j2] <== t0.out[c2][k2][i2][j2];
                }
            }
        }
    }

    component t0_sq = Fp12CyclotomicSquare();
    for (var c3 = 0; c3 < 2; c3++) {
        for (var k3 = 0; k3 < 3; k3++) {
            for (var i3 = 0; i3 < 2; i3++) {
                for (var j3 = 0; j3 < 3; j3++) {
                    t0_sq.a[c3][k3][i3][j3] <== t0_conj.out[c3][k3][i3][j3];
                }
            }
        }
    }

    component t1_sq = Fp12CyclotomicSquare();
    for (var c4 = 0; c4 < 2; c4++) {
        for (var k4 = 0; k4 < 3; k4++) {
            for (var i4 = 0; i4 < 2; i4++) {
                for (var j4 = 0; j4 < 3; j4++) {
                    t1_sq.a[c4][k4][i4][j4] <== t0_sq.out[c4][k4][i4][j4];
                }
            }
        }
    }

    component t1 = Fp12Mul();
    for (var c5 = 0; c5 < 2; c5++) {
        for (var k5 = 0; k5 < 3; k5++) {
            for (var i5 = 0; i5 < 2; i5++) {
                for (var j5 = 0; j5 < 3; j5++) {
                    t1.a[c5][k5][i5][j5] <== t0_sq.out[c5][k5][i5][j5];
                    t1.b[c5][k5][i5][j5] <== t1_sq.out[c5][k5][i5][j5];
                }
            }
        }
    }

    component t2 = Fp12Expt();
    for (var c6 = 0; c6 < 2; c6++) {
        for (var k6 = 0; k6 < 3; k6++) {
            for (var i6 = 0; i6 < 2; i6++) {
                for (var j6 = 0; j6 < 3; j6++) {
                    t2.a[c6][k6][i6][j6] <== t1.out[c6][k6][i6][j6];
                }
            }
        }
    }

    component t2_conj = Fp12Conjugate();
    for (var c7 = 0; c7 < 2; c7++) {
        for (var k7 = 0; k7 < 3; k7++) {
            for (var i7 = 0; i7 < 2; i7++) {
                for (var j7 = 0; j7 < 3; j7++) {
                    t2_conj.a[c7][k7][i7][j7] <== t2.out[c7][k7][i7][j7];
                }
            }
        }
    }

    component t3 = Fp12Conjugate();
    for (var c8 = 0; c8 < 2; c8++) {
        for (var k8 = 0; k8 < 3; k8++) {
            for (var i8 = 0; i8 < 2; i8++) {
                for (var j8 = 0; j8 < 3; j8++) {
                    t3.a[c8][k8][i8][j8] <== t1.out[c8][k8][i8][j8];
                }
            }
        }
    }

    component t1b = Fp12Mul();
    for (var c9 = 0; c9 < 2; c9++) {
        for (var k9 = 0; k9 < 3; k9++) {
            for (var i9 = 0; i9 < 2; i9++) {
                for (var j9 = 0; j9 < 3; j9++) {
                    t1b.a[c9][k9][i9][j9] <== t2_conj.out[c9][k9][i9][j9];
                    t1b.b[c9][k9][i9][j9] <== t3.out[c9][k9][i9][j9];
                }
            }
        }
    }

    component t3_sq = Fp12CyclotomicSquare();
    for (var c10 = 0; c10 < 2; c10++) {
        for (var k10 = 0; k10 < 3; k10++) {
            for (var i10 = 0; i10 < 2; i10++) {
                for (var j10 = 0; j10 < 3; j10++) {
                    t3_sq.a[c10][k10][i10][j10] <== t2_conj.out[c10][k10][i10][j10];
                }
            }
        }
    }

    component t4 = Fp12Expt();
    for (var c11 = 0; c11 < 2; c11++) {
        for (var k11 = 0; k11 < 3; k11++) {
            for (var i11 = 0; i11 < 2; i11++) {
                for (var j11 = 0; j11 < 3; j11++) {
                    t4.a[c11][k11][i11][j11] <== t3_sq.out[c11][k11][i11][j11];
                }
            }
        }
    }

    component t4b = Fp12Mul();
    for (var c12 = 0; c12 < 2; c12++) {
        for (var k12 = 0; k12 < 3; k12++) {
            for (var i12 = 0; i12 < 2; i12++) {
                for (var j12 = 0; j12 < 3; j12++) {
                    t4b.a[c12][k12][i12][j12] <== t1b.out[c12][k12][i12][j12];
                    t4b.b[c12][k12][i12][j12] <== t4.out[c12][k12][i12][j12];
                }
            }
        }
    }

    component t3b = Fp12Mul();
    for (var c13 = 0; c13 < 2; c13++) {
        for (var k13 = 0; k13 < 3; k13++) {
            for (var i13 = 0; i13 < 2; i13++) {
                for (var j13 = 0; j13 < 3; j13++) {
                    t3b.a[c13][k13][i13][j13] <== t0_sq.out[c13][k13][i13][j13];
                    t3b.b[c13][k13][i13][j13] <== t4b.out[c13][k13][i13][j13];
                }
            }
        }
    }

    component t0b = Fp12Mul();
    for (var c14 = 0; c14 < 2; c14++) {
        for (var k14 = 0; k14 < 3; k14++) {
            for (var i14 = 0; i14 < 2; i14++) {
                for (var j14 = 0; j14 < 3; j14++) {
                    t0b.a[c14][k14][i14][j14] <== t2_conj.out[c14][k14][i14][j14];
                    t0b.b[c14][k14][i14][j14] <== t4b.out[c14][k14][i14][j14];
                }
            }
        }
    }

    component t0c = Fp12Mul();
    for (var c15 = 0; c15 < 2; c15++) {
        for (var k15 = 0; k15 < 3; k15++) {
            for (var i15 = 0; i15 < 2; i15++) {
                for (var j15 = 0; j15 < 3; j15++) {
                    t0c.a[c15][k15][i15][j15] <== a[c15][k15][i15][j15];
                    t0c.b[c15][k15][i15][j15] <== t0b.out[c15][k15][i15][j15];
                }
            }
        }
    }

    component t2f = Fp12Frobenius();
    for (var c16 = 0; c16 < 2; c16++) {
        for (var k16 = 0; k16 < 3; k16++) {
            for (var i16 = 0; i16 < 2; i16++) {
                for (var j16 = 0; j16 < 3; j16++) {
                    t2f.a[c16][k16][i16][j16] <== t3b.out[c16][k16][i16][j16];
                }
            }
        }
    }

    component t0d = Fp12Mul();
    for (var c17 = 0; c17 < 2; c17++) {
        for (var k17 = 0; k17 < 3; k17++) {
            for (var i17 = 0; i17 < 2; i17++) {
                for (var j17 = 0; j17 < 3; j17++) {
                    t0d.a[c17][k17][i17][j17] <== t2f.out[c17][k17][i17][j17];
                    t0d.b[c17][k17][i17][j17] <== t0c.out[c17][k17][i17][j17];
                }
            }
        }
    }

    component t2fs = Fp12FrobeniusSquare();
    for (var c18 = 0; c18 < 2; c18++) {
        for (var k18 = 0; k18 < 3; k18++) {
            for (var i18 = 0; i18 < 2; i18++) {
                for (var j18 = 0; j18 < 3; j18++) {
                    t2fs.a[c18][k18][i18][j18] <== t4b.out[c18][k18][i18][j18];
                }
            }
        }
    }

    component t0e = Fp12Mul();
    for (var c19 = 0; c19 < 2; c19++) {
        for (var k19 = 0; k19 < 3; k19++) {
            for (var i19 = 0; i19 < 2; i19++) {
                for (var j19 = 0; j19 < 3; j19++) {
                    t0e.a[c19][k19][i19][j19] <== t2fs.out[c19][k19][i19][j19];
                    t0e.b[c19][k19][i19][j19] <== t0d.out[c19][k19][i19][j19];
                }
            }
        }
    }

    component t2c = Fp12Conjugate();
    for (var c20 = 0; c20 < 2; c20++) {
        for (var k20 = 0; k20 < 3; k20++) {
            for (var i20 = 0; i20 < 2; i20++) {
                for (var j20 = 0; j20 < 3; j20++) {
                    t2c.a[c20][k20][i20][j20] <== a[c20][k20][i20][j20];
                }
            }
        }
    }

    component t2d = Fp12Mul();
    for (var c21 = 0; c21 < 2; c21++) {
        for (var k21 = 0; k21 < 3; k21++) {
            for (var i21 = 0; i21 < 2; i21++) {
                for (var j21 = 0; j21 < 3; j21++) {
                    t2d.a[c21][k21][i21][j21] <== t2c.out[c21][k21][i21][j21];
                    t2d.b[c21][k21][i21][j21] <== t3b.out[c21][k21][i21][j21];
                }
            }
        }
    }

    component t2fc = Fp12FrobeniusCube();
    for (var c22 = 0; c22 < 2; c22++) {
        for (var k22 = 0; k22 < 3; k22++) {
            for (var i22 = 0; i22 < 2; i22++) {
                for (var j22 = 0; j22 < 3; j22++) {
                    t2fc.a[c22][k22][i22][j22] <== t2d.out[c22][k22][i22][j22];
                }
            }
        }
    }

    component t0f = Fp12Mul();
    for (var c23 = 0; c23 < 2; c23++) {
        for (var k23 = 0; k23 < 3; k23++) {
            for (var i23 = 0; i23 < 2; i23++) {
                for (var j23 = 0; j23 < 3; j23++) {
                    t0f.a[c23][k23][i23][j23] <== t2fc.out[c23][k23][i23][j23];
                    t0f.b[c23][k23][i23][j23] <== t0e.out[c23][k23][i23][j23];
                }
            }
        }
    }

    for (var c24 = 0; c24 < 2; c24++) {
        for (var k24 = 0; k24 < 3; k24++) {
            for (var i24 = 0; i24 < 2; i24++) {
                for (var j24 = 0; j24 < 3; j24++) {
                    out[c24][k24][i24][j24] <== t0f.out[c24][k24][i24][j24];
                }
            }
        }
    }
}

template PairingFinalExponentiation() {
    signal input z[2][3][2][3];
    signal input inv_z[2][3][2][3];
    signal output out[2][3][2][3];

    component easy = PairingFinalExpEasyPart();
    for (var c = 0; c < 2; c++) {
        for (var k = 0; k < 3; k++) {
            for (var i = 0; i < 2; i++) {
                for (var j = 0; j < 3; j++) {
                    easy.z[c][k][i][j] <== z[c][k][i][j];
                    easy.inv_z[c][k][i][j] <== inv_z[c][k][i][j];
                }
            }
        }
    }

    component is_one = Fp12IsOne();
    for (var c2 = 0; c2 < 2; c2++) {
        for (var k2 = 0; k2 < 3; k2++) {
            for (var i2 = 0; i2 < 2; i2++) {
                for (var j2 = 0; j2 < 3; j2++) {
                    is_one.a[c2][k2][i2][j2] <== easy.out[c2][k2][i2][j2];
                }
            }
        }
    }

    component hard = PairingFinalExpHardPart();
    for (var c3 = 0; c3 < 2; c3++) {
        for (var k3 = 0; k3 < 3; k3++) {
            for (var i3 = 0; i3 < 2; i3++) {
                for (var j3 = 0; j3 < 3; j3++) {
                    hard.a[c3][k3][i3][j3] <== easy.out[c3][k3][i3][j3];
                }
            }
        }
    }

    signal sel;
    sel <== 1 - is_one.out;
    for (var c4 = 0; c4 < 2; c4++) {
        for (var k4 = 0; k4 < 3; k4++) {
            for (var i4 = 0; i4 < 2; i4++) {
                for (var j4 = 0; j4 < 3; j4++) {
                    out[c4][k4][i4][j4] <== easy.out[c4][k4][i4][j4] + sel * (hard.out[c4][k4][i4][j4] - easy.out[c4][k4][i4][j4]);
                }
            }
        }
    }
}

template PairingMillerLoop(N) {
    signal input p[N][2][3];
    signal input q[N][2][2][3];
    signal output out[2][3][2][3];

    component pInf[N];
    component qInf[N];
    signal active[N];
    for (var k = 0; k < N; k++) {
        pInf[k] = G1AffineIsInfinity();
        qInf[k] = G2AffineIsInfinity();
        for (var j = 0; j < 3; j++) {
            pInf[k].p[0][j] <== p[k][0][j];
            pInf[k].p[1][j] <== p[k][1][j];
        }
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                qInf[k].p[0][i2][j2] <== q[k][0][i2][j2];
                qInf[k].p[1][i2][j2] <== q[k][1][i2][j2];
            }
        }
    }
    for (var k2 = 0; k2 < N; k2++) {
        active[k2] <== (1 - pInf[k2].out) * (1 - qInf[k2].out);
        active[k2] * (active[k2] - 1) === 0;
    }

    component proj[N];
    component neg[N];
    for (var k3 = 0; k3 < N; k3++) {
        proj[k3] = G2ProjectiveFromAffine();
        neg[k3] = G2NegAffine();
        for (var i3 = 0; i3 < 2; i3++) {
            for (var j3 = 0; j3 < 3; j3++) {
                proj[k3].a[0][i3][j3] <== q[k3][0][i3][j3];
                proj[k3].a[1][i3][j3] <== q[k3][1][i3][j3];
                neg[k3].p[0][i3][j3] <== q[k3][0][i3][j3];
                neg[k3].p[1][i3][j3] <== q[k3][1][i3][j3];
            }
        }
    }

    signal q_proj0[N][3][2][3];
    signal q_neg[N][2][2][3];
    for (var k4 = 0; k4 < N; k4++) {
        for (var c = 0; c < 3; c++) {
            for (var i4 = 0; i4 < 2; i4++) {
                for (var j4 = 0; j4 < 3; j4++) {
                    q_proj0[k4][c][i4][j4] <== proj[k4].out[c][i4][j4];
                }
            }
        }
        for (var i5 = 0; i5 < 2; i5++) {
            for (var j5 = 0; j5 < 3; j5++) {
                q_neg[k4][0][i5][j5] <== neg[k4].out[0][i5][j5];
                q_neg[k4][1][i5][j5] <== neg[k4].out[1][i5][j5];
            }
        }
    }

    component dbl_init[N];
    for (var k5 = 0; k5 < N; k5++) {
        dbl_init[k5] = PairingG2DoubleStepAtPoint();
        for (var c2 = 0; c2 < 3; c2++) {
            for (var i6 = 0; i6 < 2; i6++) {
                for (var j6 = 0; j6 < 3; j6++) {
                    dbl_init[k5].q_proj[c2][i6][j6] <== q_proj0[k5][c2][i6][j6];
                }
            }
        }
        for (var j7 = 0; j7 < 3; j7++) {
            dbl_init[k5].p[0][j7] <== p[k5][0][j7];
            dbl_init[k5].p[1][j7] <== p[k5][1][j7];
        }
        dbl_init[k5].active <== active[k5];
    }

    signal q_proj1[N][3][2][3];
    signal line_init[N][3][2][3];
    for (var k6 = 0; k6 < N; k6++) {
        for (var c3 = 0; c3 < 3; c3++) {
            for (var i7 = 0; i7 < 2; i7++) {
                for (var j8 = 0; j8 < 3; j8++) {
                    q_proj1[k6][c3][i7][j8] <== dbl_init[k6].q_proj_out[c3][i7][j8];
                    line_init[k6][c3][i7][j8] <== dbl_init[k6].line_out[c3][i7][j8];
                }
            }
        }
    }

    component one = Fp12One();
    component mul_init[N];
    for (var k7 = 0; k7 < N; k7++) {
        mul_init[k7] = Fp12MulBy034();
        if (k7 == 0) {
            for (var c4 = 0; c4 < 2; c4++) {
                for (var b4 = 0; b4 < 3; b4++) {
                    for (var i8 = 0; i8 < 2; i8++) {
                        for (var j9 = 0; j9 < 3; j9++) {
                            mul_init[k7].a[c4][b4][i8][j9] <== one.out[c4][b4][i8][j9];
                        }
                    }
                }
            }
        } else {
            for (var c5 = 0; c5 < 2; c5++) {
                for (var b5 = 0; b5 < 3; b5++) {
                    for (var i9 = 0; i9 < 2; i9++) {
                        for (var j10 = 0; j10 < 3; j10++) {
                            mul_init[k7].a[c5][b5][i9][j10] <== mul_init[k7 - 1].out[c5][b5][i9][j10];
                        }
                    }
                }
            }
        }
        for (var i10 = 0; i10 < 2; i10++) {
            for (var j11 = 0; j11 < 3; j11++) {
                mul_init[k7].c0[i10][j11] <== line_init[k7][0][i10][j11];
                mul_init[k7].c3[i10][j11] <== line_init[k7][1][i10][j11];
                mul_init[k7].c4[i10][j11] <== line_init[k7][2][i10][j11];
            }
        }
    }

    signal res_init[2][3][2][3];
    for (var c6 = 0; c6 < 2; c6++) {
        for (var b6 = 0; b6 < 3; b6++) {
            for (var i11 = 0; i11 < 2; i11++) {
                for (var j12 = 0; j12 < 3; j12++) {
                    res_init[c6][b6][i11][j12] <== mul_init[N - 1].out[c6][b6][i11][j12];
                }
            }
        }
    }

    component res_sq = Fp12Square();
    for (var c7 = 0; c7 < 2; c7++) {
        for (var b7 = 0; b7 < 3; b7++) {
            for (var i12 = 0; i12 < 2; i12++) {
                for (var j13 = 0; j13 < 3; j13++) {
                    res_sq.a[c7][b7][i12][j13] <== res_init[c7][b7][i12][j13];
                }
            }
        }
    }

    component pre_line[N];
    component pre_add[N];
    for (var k8 = 0; k8 < N; k8++) {
        pre_line[k8] = PairingG2LineComputeAtPoint();
        pre_add[k8] = PairingG2AddMixedStepAtPoint();
        for (var c8 = 0; c8 < 3; c8++) {
            for (var i13 = 0; i13 < 2; i13++) {
                for (var j14 = 0; j14 < 3; j14++) {
                    pre_line[k8].q_proj[c8][i13][j14] <== q_proj1[k8][c8][i13][j14];
                    pre_add[k8].q_proj[c8][i13][j14] <== q_proj1[k8][c8][i13][j14];
                }
            }
        }
        for (var i14 = 0; i14 < 2; i14++) {
            for (var j15 = 0; j15 < 3; j15++) {
                pre_line[k8].q_aff[0][i14][j15] <== q_neg[k8][0][i14][j15];
                pre_line[k8].q_aff[1][i14][j15] <== q_neg[k8][1][i14][j15];
                pre_add[k8].q_aff[0][i14][j15] <== q[k8][0][i14][j15];
                pre_add[k8].q_aff[1][i14][j15] <== q[k8][1][i14][j15];
            }
        }
        for (var j16 = 0; j16 < 3; j16++) {
            pre_line[k8].p[0][j16] <== p[k8][0][j16];
            pre_line[k8].p[1][j16] <== p[k8][1][j16];
            pre_add[k8].p[0][j16] <== p[k8][0][j16];
            pre_add[k8].p[1][j16] <== p[k8][1][j16];
        }
        pre_line[k8].active <== active[k8];
        pre_add[k8].active <== active[k8];
    }

    signal q_proj2[N][3][2][3];
    for (var k9 = 0; k9 < N; k9++) {
        for (var c9 = 0; c9 < 3; c9++) {
            for (var i15 = 0; i15 < 2; i15++) {
                for (var j17 = 0; j17 < 3; j17++) {
                    q_proj2[k9][c9][i15][j17] <== pre_add[k9].q_proj_out[c9][i15][j17];
                }
            }
        }
    }

    component pre_prod[N];
    component pre_mul[N];
    for (var k10 = 0; k10 < N; k10++) {
        pre_prod[k10] = PairingMul034By034();
        pre_mul[k10] = Fp12MulBy01234();
        for (var i16 = 0; i16 < 2; i16++) {
            for (var j18 = 0; j18 < 3; j18++) {
                pre_prod[k10].d0[i16][j18] <== pre_add[k10].line_out[0][i16][j18];
                pre_prod[k10].d3[i16][j18] <== pre_add[k10].line_out[1][i16][j18];
                pre_prod[k10].d4[i16][j18] <== pre_add[k10].line_out[2][i16][j18];
                pre_prod[k10].c0[i16][j18] <== pre_line[k10].line_out[0][i16][j18];
                pre_prod[k10].c3[i16][j18] <== pre_line[k10].line_out[1][i16][j18];
                pre_prod[k10].c4[i16][j18] <== pre_line[k10].line_out[2][i16][j18];
            }
        }
        if (k10 == 0) {
            for (var c10 = 0; c10 < 2; c10++) {
                for (var b10 = 0; b10 < 3; b10++) {
                    for (var i17 = 0; i17 < 2; i17++) {
                        for (var j19 = 0; j19 < 3; j19++) {
                            pre_mul[k10].a[c10][b10][i17][j19] <== res_sq.out[c10][b10][i17][j19];
                        }
                    }
                }
            }
        } else {
            for (var c11 = 0; c11 < 2; c11++) {
                for (var b11 = 0; b11 < 3; b11++) {
                    for (var i18 = 0; i18 < 2; i18++) {
                        for (var j20 = 0; j20 < 3; j20++) {
                            pre_mul[k10].a[c11][b11][i18][j20] <== pre_mul[k10 - 1].out[c11][b11][i18][j20];
                        }
                    }
                }
            }
        }
        for (var x = 0; x < 5; x++) {
            for (var i19 = 0; i19 < 2; i19++) {
                for (var j21 = 0; j21 < 3; j21++) {
                    pre_mul[k10].x[x][i19][j21] <== pre_prod[k10].out[x][i19][j21];
                }
            }
        }
    }

    signal res_pre[2][3][2][3];
    for (var c12 = 0; c12 < 2; c12++) {
        for (var b12 = 0; b12 < 3; b12++) {
            for (var i20 = 0; i20 < 2; i20++) {
                for (var j22 = 0; j22 < 3; j22++) {
                    res_pre[c12][b12][i20][j22] <== pre_mul[N - 1].out[c12][b12][i20][j22];
                }
            }
        }
    }

    var loop_digits[66] = [
        0, 0, 0, 1, 0, 1, 0, -1, 0, 0, -1, 0, 0, 0, 1, 0,
        0, -1, 0, -1, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0, -1, 0,
        0, 1, 0, -1, 0, 0, 1, 0, 0, 0, 0, 0, -1, 0, 0, -1,
        0, 1, 0, -1, 0, 0, 0, -1, 0, -1, 0, 0, 0, 1, 0, -1,
        0, 1
    ];

    signal res_loop[64][2][3][2][3];
    signal q_proj_state[64][N][3][2][3];
    for (var c13 = 0; c13 < 2; c13++) {
        for (var b13 = 0; b13 < 3; b13++) {
            for (var i21 = 0; i21 < 2; i21++) {
                for (var j23 = 0; j23 < 3; j23++) {
                    res_loop[0][c13][b13][i21][j23] <== res_pre[c13][b13][i21][j23];
                }
            }
        }
    }
    for (var k11 = 0; k11 < N; k11++) {
        for (var c14 = 0; c14 < 3; c14++) {
            for (var i22 = 0; i22 < 2; i22++) {
                for (var j24 = 0; j24 < 3; j24++) {
                    q_proj_state[0][k11][c14][i22][j24] <== q_proj2[k11][c14][i22][j24];
                }
            }
        }
    }

    component iter_sq[63];
    component iter_mul_034[63][N];
    component iter_mul_01234[63][N];
    component iter_dbl[63][N];
    component iter_add[63][N];
    component iter_prod[63][N];
    signal iter_res[63][N + 1][2][3][2][3];
    signal q_proj_next[63][N][3][2][3];
    for (var idx = 0; idx < 63; idx++) {
        iter_sq[idx] = Fp12Square();
        for (var c15 = 0; c15 < 2; c15++) {
            for (var b15 = 0; b15 < 3; b15++) {
                for (var i23 = 0; i23 < 2; i23++) {
                    for (var j25 = 0; j25 < 3; j25++) {
                        iter_sq[idx].a[c15][b15][i23][j25] <== res_loop[idx][c15][b15][i23][j25];
                    }
                }
            }
        }

        for (var c16 = 0; c16 < 2; c16++) {
            for (var b16 = 0; b16 < 3; b16++) {
                for (var i24 = 0; i24 < 2; i24++) {
                    for (var j26 = 0; j26 < 3; j26++) {
                        iter_res[idx][0][c16][b16][i24][j26] <== iter_sq[idx].out[c16][b16][i24][j26];
                    }
                }
            }
        }

        var digit = loop_digits[62 - idx];
        for (var k12 = 0; k12 < N; k12++) {
            iter_dbl[idx][k12] = PairingG2DoubleStepAtPoint();
            for (var c17 = 0; c17 < 3; c17++) {
                for (var i25 = 0; i25 < 2; i25++) {
                    for (var j27 = 0; j27 < 3; j27++) {
                        iter_dbl[idx][k12].q_proj[c17][i25][j27] <== q_proj_state[idx][k12][c17][i25][j27];
                    }
                }
            }
            for (var j28 = 0; j28 < 3; j28++) {
                iter_dbl[idx][k12].p[0][j28] <== p[k12][0][j28];
                iter_dbl[idx][k12].p[1][j28] <== p[k12][1][j28];
            }
            iter_dbl[idx][k12].active <== active[k12];

            if (digit == 0) {
                iter_mul_034[idx][k12] = Fp12MulBy034();
                for (var c18 = 0; c18 < 2; c18++) {
                    for (var b18 = 0; b18 < 3; b18++) {
                        for (var i26 = 0; i26 < 2; i26++) {
                            for (var j29 = 0; j29 < 3; j29++) {
                                iter_mul_034[idx][k12].a[c18][b18][i26][j29] <== iter_res[idx][k12][c18][b18][i26][j29];
                            }
                        }
                    }
                }
                for (var i27 = 0; i27 < 2; i27++) {
                    for (var j30 = 0; j30 < 3; j30++) {
                        iter_mul_034[idx][k12].c0[i27][j30] <== iter_dbl[idx][k12].line_out[0][i27][j30];
                        iter_mul_034[idx][k12].c3[i27][j30] <== iter_dbl[idx][k12].line_out[1][i27][j30];
                        iter_mul_034[idx][k12].c4[i27][j30] <== iter_dbl[idx][k12].line_out[2][i27][j30];
                    }
                }
                for (var c19 = 0; c19 < 2; c19++) {
                    for (var b19 = 0; b19 < 3; b19++) {
                        for (var i28 = 0; i28 < 2; i28++) {
                            for (var j31 = 0; j31 < 3; j31++) {
                                iter_res[idx][k12 + 1][c19][b19][i28][j31] <== iter_mul_034[idx][k12].out[c19][b19][i28][j31];
                            }
                        }
                    }
                }
                for (var c20 = 0; c20 < 3; c20++) {
                    for (var i29 = 0; i29 < 2; i29++) {
                        for (var j32 = 0; j32 < 3; j32++) {
                            q_proj_next[idx][k12][c20][i29][j32] <== iter_dbl[idx][k12].q_proj_out[c20][i29][j32];
                        }
                    }
                }
            } else {
                iter_add[idx][k12] = PairingG2AddMixedStepAtPoint();
                for (var c21 = 0; c21 < 3; c21++) {
                    for (var i30 = 0; i30 < 2; i30++) {
                        for (var j33 = 0; j33 < 3; j33++) {
                            iter_add[idx][k12].q_proj[c21][i30][j33] <== iter_dbl[idx][k12].q_proj_out[c21][i30][j33];
                        }
                    }
                }
                for (var i31 = 0; i31 < 2; i31++) {
                    for (var j34 = 0; j34 < 3; j34++) {
                        if (digit == 1) {
                            iter_add[idx][k12].q_aff[0][i31][j34] <== q[k12][0][i31][j34];
                            iter_add[idx][k12].q_aff[1][i31][j34] <== q[k12][1][i31][j34];
                        } else {
                            iter_add[idx][k12].q_aff[0][i31][j34] <== q_neg[k12][0][i31][j34];
                            iter_add[idx][k12].q_aff[1][i31][j34] <== q_neg[k12][1][i31][j34];
                        }
                    }
                }
                for (var j35 = 0; j35 < 3; j35++) {
                    iter_add[idx][k12].p[0][j35] <== p[k12][0][j35];
                    iter_add[idx][k12].p[1][j35] <== p[k12][1][j35];
                }
                iter_add[idx][k12].active <== active[k12];

                iter_prod[idx][k12] = PairingMul034By034();
                for (var i32 = 0; i32 < 2; i32++) {
                    for (var j36 = 0; j36 < 3; j36++) {
                        iter_prod[idx][k12].d0[i32][j36] <== iter_dbl[idx][k12].line_out[0][i32][j36];
                        iter_prod[idx][k12].d3[i32][j36] <== iter_dbl[idx][k12].line_out[1][i32][j36];
                        iter_prod[idx][k12].d4[i32][j36] <== iter_dbl[idx][k12].line_out[2][i32][j36];
                        iter_prod[idx][k12].c0[i32][j36] <== iter_add[idx][k12].line_out[0][i32][j36];
                        iter_prod[idx][k12].c3[i32][j36] <== iter_add[idx][k12].line_out[1][i32][j36];
                        iter_prod[idx][k12].c4[i32][j36] <== iter_add[idx][k12].line_out[2][i32][j36];
                    }
                }

                iter_mul_01234[idx][k12] = Fp12MulBy01234();
                for (var c22 = 0; c22 < 2; c22++) {
                    for (var b22 = 0; b22 < 3; b22++) {
                        for (var i33 = 0; i33 < 2; i33++) {
                            for (var j37 = 0; j37 < 3; j37++) {
                                iter_mul_01234[idx][k12].a[c22][b22][i33][j37] <== iter_res[idx][k12][c22][b22][i33][j37];
                            }
                        }
                    }
                }
                for (var x2 = 0; x2 < 5; x2++) {
                    for (var i34 = 0; i34 < 2; i34++) {
                        for (var j38 = 0; j38 < 3; j38++) {
                            iter_mul_01234[idx][k12].x[x2][i34][j38] <== iter_prod[idx][k12].out[x2][i34][j38];
                        }
                    }
                }
                for (var c23 = 0; c23 < 2; c23++) {
                    for (var b23 = 0; b23 < 3; b23++) {
                        for (var i35 = 0; i35 < 2; i35++) {
                            for (var j39 = 0; j39 < 3; j39++) {
                                iter_res[idx][k12 + 1][c23][b23][i35][j39] <== iter_mul_01234[idx][k12].out[c23][b23][i35][j39];
                            }
                        }
                    }
                }
                for (var c24 = 0; c24 < 3; c24++) {
                    for (var i36 = 0; i36 < 2; i36++) {
                        for (var j40 = 0; j40 < 3; j40++) {
                            q_proj_next[idx][k12][c24][i36][j40] <== iter_add[idx][k12].q_proj_out[c24][i36][j40];
                        }
                    }
                }
            }
        }

        for (var c25 = 0; c25 < 2; c25++) {
            for (var b25 = 0; b25 < 3; b25++) {
                for (var i37 = 0; i37 < 2; i37++) {
                    for (var j41 = 0; j41 < 3; j41++) {
                        res_loop[idx + 1][c25][b25][i37][j41] <== iter_res[idx][N][c25][b25][i37][j41];
                    }
                }
            }
        }
        for (var k13 = 0; k13 < N; k13++) {
            for (var c26 = 0; c26 < 3; c26++) {
                for (var i38 = 0; i38 < 2; i38++) {
                    for (var j42 = 0; j42 < 3; j42++) {
                        q_proj_state[idx + 1][k13][c26][i38][j42] <== q_proj_next[idx][k13][c26][i38][j42];
                    }
                }
            }
        }
    }

    component frob[N];
    component frob2[N];
    for (var k14 = 0; k14 < N; k14++) {
        frob[k14] = G2Frobenius();
        frob2[k14] = G2FrobeniusSquare();
        for (var i39 = 0; i39 < 2; i39++) {
            for (var j43 = 0; j43 < 3; j43++) {
                frob[k14].p[0][i39][j43] <== q[k14][0][i39][j43];
                frob[k14].p[1][i39][j43] <== q[k14][1][i39][j43];
                frob2[k14].p[0][i39][j43] <== q[k14][0][i39][j43];
                frob2[k14].p[1][i39][j43] <== q[k14][1][i39][j43];
            }
        }
    }

    component final_add[N];
    component final_line[N];
    component final_prod[N];
    component final_mul[N];
    for (var k15 = 0; k15 < N; k15++) {
        final_add[k15] = PairingG2AddMixedStepAtPoint();
        for (var c27 = 0; c27 < 3; c27++) {
            for (var i40 = 0; i40 < 2; i40++) {
                for (var j44 = 0; j44 < 3; j44++) {
                    final_add[k15].q_proj[c27][i40][j44] <== q_proj_state[63][k15][c27][i40][j44];
                }
            }
        }
        for (var i41 = 0; i41 < 2; i41++) {
            for (var j45 = 0; j45 < 3; j45++) {
                final_add[k15].q_aff[0][i41][j45] <== frob[k15].out[0][i41][j45];
                final_add[k15].q_aff[1][i41][j45] <== frob[k15].out[1][i41][j45];
            }
        }
        for (var j46 = 0; j46 < 3; j46++) {
            final_add[k15].p[0][j46] <== p[k15][0][j46];
            final_add[k15].p[1][j46] <== p[k15][1][j46];
        }
        final_add[k15].active <== active[k15];

        final_line[k15] = PairingG2LineComputeAtPoint();
        for (var c28 = 0; c28 < 3; c28++) {
            for (var i42 = 0; i42 < 2; i42++) {
                for (var j47 = 0; j47 < 3; j47++) {
                    final_line[k15].q_proj[c28][i42][j47] <== final_add[k15].q_proj_out[c28][i42][j47];
                }
            }
        }
        for (var i43 = 0; i43 < 2; i43++) {
            for (var j48 = 0; j48 < 3; j48++) {
                final_line[k15].q_aff[0][i43][j48] <== frob2[k15].out[0][i43][j48];
                final_line[k15].q_aff[1][i43][j48] <== frob2[k15].out[1][i43][j48];
            }
        }
        for (var j49 = 0; j49 < 3; j49++) {
            final_line[k15].p[0][j49] <== p[k15][0][j49];
            final_line[k15].p[1][j49] <== p[k15][1][j49];
        }
        final_line[k15].active <== active[k15];

        final_prod[k15] = PairingMul034By034();
        for (var i44 = 0; i44 < 2; i44++) {
            for (var j50 = 0; j50 < 3; j50++) {
                final_prod[k15].d0[i44][j50] <== final_line[k15].line_out[0][i44][j50];
                final_prod[k15].d3[i44][j50] <== final_line[k15].line_out[1][i44][j50];
                final_prod[k15].d4[i44][j50] <== final_line[k15].line_out[2][i44][j50];
                final_prod[k15].c0[i44][j50] <== final_add[k15].line_out[0][i44][j50];
                final_prod[k15].c3[i44][j50] <== final_add[k15].line_out[1][i44][j50];
                final_prod[k15].c4[i44][j50] <== final_add[k15].line_out[2][i44][j50];
            }
        }

        final_mul[k15] = Fp12MulBy01234();
        if (k15 == 0) {
            for (var c29 = 0; c29 < 2; c29++) {
                for (var b29 = 0; b29 < 3; b29++) {
                    for (var i45 = 0; i45 < 2; i45++) {
                        for (var j51 = 0; j51 < 3; j51++) {
                            final_mul[k15].a[c29][b29][i45][j51] <== res_loop[63][c29][b29][i45][j51];
                        }
                    }
                }
            }
        } else {
            for (var c30 = 0; c30 < 2; c30++) {
                for (var b30 = 0; b30 < 3; b30++) {
                    for (var i46 = 0; i46 < 2; i46++) {
                        for (var j52 = 0; j52 < 3; j52++) {
                            final_mul[k15].a[c30][b30][i46][j52] <== final_mul[k15 - 1].out[c30][b30][i46][j52];
                        }
                    }
                }
            }
        }
        for (var x3 = 0; x3 < 5; x3++) {
            for (var i47 = 0; i47 < 2; i47++) {
                for (var j53 = 0; j53 < 3; j53++) {
                    final_mul[k15].x[x3][i47][j53] <== final_prod[k15].out[x3][i47][j53];
                }
            }
        }
    }

    for (var c31 = 0; c31 < 2; c31++) {
        for (var b31 = 0; b31 < 3; b31++) {
            for (var i48 = 0; i48 < 2; i48++) {
                for (var j54 = 0; j54 < 3; j54++) {
                    out[c31][b31][i48][j54] <== final_mul[N - 1].out[c31][b31][i48][j54];
                }
            }
        }
    }
}

template PairingSingle() {
    signal input p[2][3];
    signal input q[2][2][3];
    signal input inv_miller[2][3][2][3];
    signal output out[2][3][2][3];

    component miller = PairingMillerLoop(1);
    for (var j = 0; j < 3; j++) {
        miller.p[0][0][j] <== p[0][j];
        miller.p[0][1][j] <== p[1][j];
    }
    for (var i2 = 0; i2 < 2; i2++) {
        for (var j2 = 0; j2 < 3; j2++) {
            miller.q[0][0][i2][j2] <== q[0][i2][j2];
            miller.q[0][1][i2][j2] <== q[1][i2][j2];
        }
    }

    component final = PairingFinalExponentiation();
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i3 = 0; i3 < 2; i3++) {
                for (var j3 = 0; j3 < 3; j3++) {
                    final.z[c][b][i3][j3] <== miller.out[c][b][i3][j3];
                    final.inv_z[c][b][i3][j3] <== inv_miller[c][b][i3][j3];
                }
            }
        }
    }
    for (var c2 = 0; c2 < 2; c2++) {
        for (var b2 = 0; b2 < 3; b2++) {
            for (var i4 = 0; i4 < 2; i4++) {
                for (var j4 = 0; j4 < 3; j4++) {
                    out[c2][b2][i4][j4] <== final.out[c2][b2][i4][j4];
                }
            }
        }
    }
}

template PairingMulti(N) {
    signal input p[N][2][3];
    signal input q[N][2][2][3];
    signal input inv_miller[2][3][2][3];
    signal output out[2][3][2][3];

    component miller = PairingMillerLoop(N);
    for (var k = 0; k < N; k++) {
        for (var j = 0; j < 3; j++) {
            miller.p[k][0][j] <== p[k][0][j];
            miller.p[k][1][j] <== p[k][1][j];
        }
        for (var i2 = 0; i2 < 2; i2++) {
            for (var j2 = 0; j2 < 3; j2++) {
                miller.q[k][0][i2][j2] <== q[k][0][i2][j2];
                miller.q[k][1][i2][j2] <== q[k][1][i2][j2];
            }
        }
    }

    component final = PairingFinalExponentiation();
    for (var c = 0; c < 2; c++) {
        for (var b = 0; b < 3; b++) {
            for (var i3 = 0; i3 < 2; i3++) {
                for (var j3 = 0; j3 < 3; j3++) {
                    final.z[c][b][i3][j3] <== miller.out[c][b][i3][j3];
                    final.inv_z[c][b][i3][j3] <== inv_miller[c][b][i3][j3];
                }
            }
        }
    }
    for (var c2 = 0; c2 < 2; c2++) {
        for (var b2 = 0; b2 < 3; b2++) {
            for (var i4 = 0; i4 < 2; i4++) {
                for (var j4 = 0; j4 < 3; j4++) {
                    out[c2][b2][i4][j4] <== final.out[c2][b2][i4][j4];
                }
            }
        }
    }
}
