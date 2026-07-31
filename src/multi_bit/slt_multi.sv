`timescale 1ns / 1ps

import constants::*;

// Format
// slt rd,rs1,rs2
// Description
// Place the value 1 in register rd if register rs1 is less than register rs2
// when both are treated as signed numbers, else 0 is written to rd.

module SLT_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0] a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0] b_in,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    //RES = (SA & ~SB) OR ( (SA XNOR SB) & Sdiff )
    logic sa;
    logic sb;

    assign sa = a_in[31];
    assign sb = b_in[31];

    //~SB
    logic inv_b_out;
    NOT_Gate_logic INV_b(
        .a_in(sb),
        .a_out(inv_b_out)
    );

    //SA & ~SB
    logic a_and_inv_b_out;
    AND_Gate_logic AND_a_inv_b(
        .a_in(sa),
        .b_in(inv_b_out),
        .a_out(a_and_inv_b_out)
    );

    //SA XNOR SB
    logic a_xnor_b_out;
    XNOR_Gate_logic XNOR_a_b(
        .a_in(sa),
        .b_in(sb),
        .a_out(a_xnor_b_out)
    );

    //Sdiff
    logic[ARCHITECTURE_WIDTH - 1: 0] a_sub_b_out;
    SUBSTRACTOR_Multi_logic_optimized SUB_a_b(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(a_sub_b_out)  
    );

    logic sdiff;
    assign sdiff = a_sub_b_out[31];

    //( (SA XNOR SB) & Sdiff )
    logic a_xnor_b_and_diff_out;
    AND_Gate_logic AND_xnor_diff(
        .a_in(a_xnor_b_out),
        .b_in(sdiff),
        .a_out(a_xnor_b_and_diff_out)
    );

    //RES = (SA & ~SB) OR ( (SA XNOR SB) & Sdiff )
    logic res;
    OR_Gate_logic result(
        .a_in(a_and_inv_b_out),
        .b_in(a_xnor_b_and_diff_out),
        .a_out(res)
    );

    assign a_out = {31'b0, res};

endmodule