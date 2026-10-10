`timescale 1ns / 1ps

import architecture_types::*;

module INVERTOR_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0] a_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    always_comb begin
        a_out = ~a_in;
    end

endmodule