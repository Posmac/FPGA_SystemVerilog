`timescale 1ns / 1ps

module D_Flip_flop(
    input  logic clk,
    input  logic rst_in,
    input  logic load_in,
    input  logic d_in,
    output logic q_out
);
    logic clk_inv;
    NOT_Gate_logic not_clk(
        .a_in (clk),
        .a_out(clk_inv)
    );

    logic d_selected;
    MUX_1_Op_Multi_logic d_mux(
        .a_in (q_out),
        .b_in (d_in),      
        .op_in(load_in),
        .a_out(d_selected)
    );

    logic master_latch_out;
    D_Latch master_latch (
        .a_in  (d_selected),
        .e_in  (clk_inv),
        .rst_in(rst_in),
        .a_out (master_latch_out)
    );

    logic slave_latch_out;
    D_Latch slave_latch(
        .a_in  (master_latch_out),
        .e_in  (clk),
        .rst_in(rst_in),
        .a_out (slave_latch_out)
    );

    assign q_out = slave_latch_out;

endmodule