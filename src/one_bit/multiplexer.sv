`timescale 1ns / 1ps

import constants::*;

module MUX_logic(
    input logic a_in,
    input logic b_in,
    input logic selector_bit_in,
    output logic a_out
);

    always_comb begin
        unique case(selector_bit_in)
            1'b0: a_out = a_in;
            1'b1: a_out = b_in;
        endcase 
    end

endmodule