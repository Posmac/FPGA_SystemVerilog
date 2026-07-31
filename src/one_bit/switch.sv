`timescale 1ns / 1ps

import constants::*;

module SWITCH_logic(
    input logic a_in,
    input logic selector_bit_in,
    output logic a_out,
    output logic b_out
);

    always_comb begin
        a_out = 1'b0;
        b_out = 1'b0;

        unique case(selector_bit_in)
            1'b0: a_out = a_in;
            1'b1: b_out = a_in;
        endcase
    end

endmodule