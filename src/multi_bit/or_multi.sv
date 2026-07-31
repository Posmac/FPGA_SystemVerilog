`timescale 1ns / 1ps

import constants::*;

module OR_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  b_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    genvar i;
    generate
        for (i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : adder_loop
            OR_Gate_logic l(
                .a_in(a_in[i]),
                .b_in(b_in[i]),
                .a_out(a_out[i])
            );
        end
    endgenerate
endmodule