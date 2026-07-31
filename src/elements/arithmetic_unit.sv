// op1	op0	output
// 0	0	X + Y
// 1	0	X - Y
// 0	1	X + 1
// 1	1	X - 1
`timescale 1ns / 1ps

import constants::*;

module AU_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  b_in,
    input logic[1:0]                        op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);

    //X + Y
    logic[ARCHITECTURE_WIDTH - 1: 0] x_plus_y_out;
    FULL_ADDER_Multi_logic x_plus_y(
        .a_in(a_in),
        .b_in(b_in),
        .c_in(1'b0),
        .hf_out(x_plus_y_out),
        .carry_out()
    );

    //X - Y
    logic[ARCHITECTURE_WIDTH - 1: 0] x_sub_y_out;
    SUBSTRACTOR_Multi_logic_optimized x_sub_y(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(x_sub_y_out)
    );

    //X + 1
    logic[ARCHITECTURE_WIDTH - 1: 0] x_inc_out;
    INCREMENTOR_Multi_logic x_inc(
        .a_in(a_in),
        .a_out(x_inc_out)
    );

    // X - 1
    logic[ARCHITECTURE_WIDTH - 1: 0] x_dec_out;
    DECREMENTOR_Multi_logic x_dec(
        .a_in(a_in),
        .a_out(x_dec_out)
    );

    MUX_2_Op_Multi_logic x_y_mux(
        .a_in(x_plus_y_out),
        .b_in(x_inc_out),
        .c_in(x_sub_y_out),
        .d_in(x_dec_out),
        .op_in(op_in),
        .a_out(a_out)
    );

endmodule
