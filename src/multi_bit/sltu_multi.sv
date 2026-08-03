`timescale 1ns / 1ps

import constants::*;

// Format
// sltu rd,rs1,rs2
// Description
// Place the value 1 in register rd if register rs1 is less than register rs2 when both are treated as unsigned numbers, else 0 is written to rd.
// Implementation
// x[rd] = x[rs1] <u x[rs2]

module SLTU_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0] a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0] b_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    logic[ARCHITECTURE_WIDTH - 1: 0] b_inv;
    INVERTOR_Multi_logic INV_b(
        .a_in(b_in),
        .a_out(b_inv)
    );

    logic carry;
    FULL_ADDER_Multi_logic ADD(
        .a_in(a_in),
        .b_in(b_inv),
        .c_in(1'b1),
        .hf_out(),
        .carry_out(carry)
    );

    logic result;
    NOT_Gate_logic res(
        .a_in(carry),
        .a_out(result)
    );
 
    assign a_out = {31'b0, result};

endmodule