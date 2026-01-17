# BN254 Pairing in Noir

## Groth16 Verifier Optimization Notes

For SP1 Groth16 verification, we now use a 3-bit joint-window MSM (w=3) with
precomputed `ic` combinations. This reduces the number of expensive G1 additions
needed to compute L (the public-input linear combination), cutting overall
constraints compared to the naive double-and-add per input.


## Performance Notes

2 pairings:
constraints: 1812974
ACIR opcodes: 8196
proving time: 15.38s

3 pairings: 
constraints: 2035715
ACIR opcodes: 8196
proving time: 16s

4 pairing:
constraints: 2227841 
ACIR opcodes: 8912
proving time: 16.7s

