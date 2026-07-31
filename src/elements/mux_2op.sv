`timescale 1ns / 1ps

import constants::*;

module MUX_2_Op_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  b_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  c_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  d_in,
    input logic[1:0]                        op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);

    always_comb begin
        unique case (op_in)
            2'b00: a_out = a_in;
            2'b01: a_out = b_in;
            2'b10: a_out = c_in;
            2'b11: a_out = d_in;
            default: a_out = '0;
        endcase
    end

endmodule