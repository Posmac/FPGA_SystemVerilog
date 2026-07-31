`timescale 1ns / 1ps

import constants::*;

module MUX_4_Op_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_0,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_1,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_2,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_3,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_4,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_5,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_6,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_7,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_8,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_9,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_10,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_11,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_12,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_13,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_14,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  in_15,
    input logic[3:0]                        op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);

    always_comb begin
        unique case (op_in)
            4'b0000: a_out = in_0;
            4'b0001: a_out = in_1;
            4'b0010: a_out = in_2;
            4'b0011: a_out = in_3;
            4'b0100: a_out = in_4;
            4'b0101: a_out = in_5;
            4'b0110: a_out = in_6;
            4'b0111: a_out = in_7;
            4'b1000: a_out = in_8;
            4'b1001: a_out = in_9;
            4'b1010: a_out = in_10;
            4'b1011: a_out = in_11;
            4'b1100: a_out = in_12;
            4'b1101: a_out = in_13;
            4'b1110: a_out = in_14;
            4'b1111: a_out = in_15;
            default: a_out = '0;
        endcase
    end

endmodule