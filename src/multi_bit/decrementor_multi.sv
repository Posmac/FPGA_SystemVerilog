`timescale 1ns / 1ps

import constants::*;

module DECREMENTOR_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1:0] a_in,
    output logic[ARCHITECTURE_WIDTH - 1:0] a_out
);

    logic[ARCHITECTURE_WIDTH - 1: 0] one_bit;
    assign one_bit = 32'h0000_0001; 

    SUBSTRACTOR_Multi_logic sub(
        .a_in(a_in),
        .b_in(one_bit),
        .a_out(a_out)
    );

endmodule
