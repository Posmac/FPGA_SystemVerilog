`timescale 1ns / 1ps

import constants::*;

// CLK
// RST_IN
// PC_SRC
// WRITE_EN

module PC_Multi_logic (
    input  logic                             clk,
    input  logic                             rst_in,

    input  logic[ARCHITECTURE_WIDTH - 1: 0]  pc_next,   // New value from branch control unit
    input  logic                             write_en,  // Stalling: 1 - обновляем PC, 0 - замораживаем (для будущих пайплайнов/пауз)

    output logic [ARCHITECTURE_WIDTH - 1:0]  pc_out,
    output logic [ARCHITECTURE_WIDTH - 1:0]  pc_plus4
);
    //calculate possible new value of the PC for PC+4 and PC+IMM
    logic[ARCHITECTURE_WIDTH - 1: 0] reg_plu4_out;
    logic[ARCHITECTURE_WIDTH - 1: 0] reg_out;
    FULL_ADDER_Multi_logic reg_plus4(
        .a_in(reg_out),
        .b_in(32'd4),
        .c_in(1'b0),
        .hf_out(reg_plu4_out),
        .carry_out()
    );

    //save it
    Register_multi pc_reg(
        .clk(clk),
        .rst_in(rst_in),
        .load_in(write_en),
        .d_in(pc_next),
        .q_out(reg_out)
    );

    assign pc_out = reg_out;
    assign pc_plus4 = reg_plu4_out;

endmodule
