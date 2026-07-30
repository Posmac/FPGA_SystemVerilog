`timescale 1ns / 1ps

import constants::*;

module INCREMENTOR_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1:0] a_in,
    output logic[ARCHITECTURE_WIDTH - 1:0] a_out
);

    logic[ARCHITECTURE_WIDTH - 1: 0] pos_pin;
    assign pos_pin = 32'h0000_0001; 

    FULL_ADDER_Multi_logic adder(
        .a_in(a_in),
        .b_in(pos_pin),
        .c_in(1'b0),
        .hf_out(a_out),
        .carry_out()
    );

endmodule
