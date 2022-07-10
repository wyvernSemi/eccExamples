# eccExamples
Error correction and detection example Verilog for Hamming and Reed-Solomon ECC, to accompany presentation material.

The two examples given are for a 13 bit Hamming code, encding 8 bit bytes, with single error correction, double error detection&mdash;and an RS(7,5) Reed-Solomon code with single error correction, double error detection over 15 bits encoded to 21 bits. The RS code was adapted from that in John Watkinson's _The Art of Digital Audio (3rd Edition), Focal Press (2001)_.

Each Verilog example contains a simulation test bench, which have been tried using ModelSim, but should run on almost any simulator. The code is self-checking and runs through all possible conditions to check the encdings.
