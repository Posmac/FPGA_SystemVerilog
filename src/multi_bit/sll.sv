`timescale 1ns / 1ps

import constants::*;

module SLL_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[4:0]                        op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    logic [ARCHITECTURE_WIDTH - 1: 0] reversed_in;
    always_comb begin
        for (int i = 0; i < ARCHITECTURE_WIDTH; i++) begin
            reversed_in[i] = a_in[(ARCHITECTURE_WIDTH - 1) - i];
        end
    end

    logic[ARCHITECTURE_WIDTH - 1: 0] inv_out;
    SRL_Multi_logic rbs(
        .a_in(reversed_in),
        .op_in(op_in),
        .fill_bit(1'b0),
        .a_out(inv_out)
    );

    //invert out
    always_comb begin
        for (int i = 0; i < ARCHITECTURE_WIDTH; i++) begin
            a_out[i] = inv_out[(ARCHITECTURE_WIDTH - 1) - i];
        end
    end

endmodule