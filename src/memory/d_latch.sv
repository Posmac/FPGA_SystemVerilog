`timescale 1ns / 1ps

module D_Latch(
    input logic     a_in, //data signal
    input logic     e_in, //clock signal
    input logic     rst_in, //reset signal
    output logic    a_out   //out signal
);
    //Data handle path controlled by clock
    logic b_in_out;
    NOT_Gate_logic a_inv(
        .a_in(a_in),
        .a_out(b_in_out)
    );

    logic a_out_enabled;
    logic b_out_enabled;
    NAND_Gate_logic a_enabled(
        .a_in(a_in),
        .b_in(e_in),
        .a_out(a_out_enabled)
    );

    NAND_Gate_logic b_enabled(
        .a_in(b_in_out),
        .b_in(e_in),
        .a_out(b_out_enabled)
    );

    //combine 2 paths
    logic a_out_rst;
    logic b_out_rst;
    MUX_1_Op_Multi_single in_1(
        .a_in(a_out_enabled),
        .b_in(1'b0),
        .op_in(rst_in),
        .a_out(a_out_rst)
    );
    MUX_1_Op_Multi_single in_2(
        .a_in(b_out_enabled),
        .b_in(1'b1),
        .op_in(rst_in),
        .a_out(b_out_rst)
    );
   
    SR_Latch sr(
        .s_in(a_out_rst),
        .r_in(b_out_rst),
        .a_out(a_out)
    );

endmodule