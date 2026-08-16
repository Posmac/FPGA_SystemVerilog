`timescale 1ns / 1ps

import constants::*;

module Register_multi(
    input logic                             clk,
    input logic                             rst_in,
    input logic                             load_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  d_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] q_out
);
    genvar i;
    generate
        for (i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : dff_loop
            D_Flip_flop dff(
                .clk(clk),
                .rst_in(rst_in),
                .load_in(load_in),
                .d_in(d_in[i]),
                .q_out(q_out[i])
            );
        end
    endgenerate

endmodule