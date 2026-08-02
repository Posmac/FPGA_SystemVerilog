`timescale 1ns / 1ps

import constants::*;

module LEFT_BIT_SHIFT(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[4:0]                        op_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);

    //invert a_in
    logic[ARCHITECTURE_WIDTH - 1: 0] reversed_in;
    assign reversed_in = {<<{a_in}}; // Revert bits order

    logic[ARCHITECTURE_WIDTH - 1: 0] inv_out;
    RIGHT_BIT_SHIFT rbs(
        .a_in(reversed_in),
        .op_in(op_in),
        .a_out(inv_out)
    );

    //invert out
    assign a_out = {<<{inv_out}};

endmodule