// op1	op0	output
// 0	0	X and Y
// 0	1	X or Y
// 1	0	X xor Y
// 1	1	invert X
`timescale 1ns / 1ps

import constants::*;

module LU_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  b_in,
    input logic[1:0]                        op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);

    //X and Y
    logic[ARCHITECTURE_WIDTH - 1: 0] x_and_y_out;
    AND_Multi_logic x_and_y(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(x_and_y_out)
    );

    //X or Y
    logic[ARCHITECTURE_WIDTH - 1: 0] x_or_y_out;
    OR_Multi_logic x_or_y(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(x_or_y_out)
    );

    //X xor Y
    logic[ARCHITECTURE_WIDTH - 1: 0] x_xor_y_out;
    XOR_Multi_logic x_xor_y(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(x_xor_y_out)
    );

    // inv X
    logic[ARCHITECTURE_WIDTH - 1: 0] x_inv_out;
    INVERTOR_Multi_logic x_inv(
        .a_in(a_in),
        .a_out(x_inv_out)
    );

    MUX_2_Op_Multi_logic x_y_mux(
        .a_in(x_and_y_out),
        .b_in(x_or_y_out),
        .c_in(x_xor_y_out),
        .d_in(x_inv_out),
        .op_in(op_in),
        .a_out(a_out)
    );

endmodule
