
// sra rd,rs1,rs2
// Description
// Performs arithmetic right shift on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2

`timescale 1ns / 1ps

import constants::*;

module ARITHMETIC_RIGHT_SHIFT(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[4:0]                        op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    RIGHT_BIT_SHIFT rbs(
        .a_in(a_in),
        .op_in(op_in),
        .fill_bit(a_in[ARCHITECTURE_WIDTH - 1]),
        .a_out(a_out)
    );
endmodule