`timescale 1ns / 1ps;

import constants::*;

module SUBSTRACTOR_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0] a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0] b_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    //COMPLEMENT SUBSTRACTION ALGORITHM
    //1. Invert b
    logic[ARCHITECTURE_WIDTH - 1: 0] b_inv_in;
    INVERTOR_Multi_logic b_invertor(
        .a_in(b_in),
        .a_out(b_inv_in)
    );

    //2. Add 1 to inverted b
    logic[ARCHITECTURE_WIDTH - 1: 0] b_inv_add_1;
    INCREMENTOR_Multi_logic b_inv_incremented(
        .a_in(b_inv_in),
        .a_out(b_inv_add_1)
    );

    //3. Add a + processed b
    FULL_ADDER_Multi_logic result(
        .a_in(a_in),
        .b_in(b_inv_add_1),
        .c_in(1'b0),
        .hf_out(a_out),
        //drop carry bit
        .carry_out()
    );
endmodule

module SUBSTRACTOR_Multi_logic_optimized(
    input logic[ARCHITECTURE_WIDTH - 1: 0] a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0] b_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    // 1. invert b
    logic[ARCHITECTURE_WIDTH - 1: 0] b_inv_in;
    INVERTOR_Multi_logic b_invertor(
        .a_in(b_in),
        .a_out(b_inv_in)
    );

    // 2 и 3. Add (a_in + b_inv_in) + pass 1 as carry bit (c_in)
    FULL_ADDER_Multi_logic result(
        .a_in(a_in),
        .b_in(b_inv_in),
        .c_in(1'b1),        // <-- 1'b1 instead of 1'b0
        .hf_out(a_out),
        .carry_out()
    );
endmodule