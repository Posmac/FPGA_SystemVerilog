`timescale 1ns / 1ps

import constants::*;

module MUX_1_Op_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  b_in,
    input logic                             op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);

    always_comb begin
        unique case (op_in)
            1'b0: a_out = a_in;
            1'b1: a_out = b_in;
            default: a_out = '0;
        endcase
    end

endmodule