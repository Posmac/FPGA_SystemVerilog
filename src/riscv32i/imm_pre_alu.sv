`timescale 1ns / 1ps

import constants::*;

// module ALU_RISCV32I(
//     input logic[ARCHITECTURE_WIDTH - 1: 0]      a_in,
//     input logic[ARCHITECTURE_WIDTH - 1: 0]      b_in,
//     input logic[3:0]                            op_in,
//     output logic [ARCHITECTURE_WIDTH - 1: 0]    a_out
// );

// addi ADD Immediate I 0010011 0x0 rd = rs1 + imm
// xori XOR Immediate I 0010011 0x4 rd = rs1 ˆ imm
// ori OR Immediate I 0010011 0x6 rd = rs1 | imm
// andi AND Immediate I 0010011 0x7 rd = rs1 & imm
// slli Shift Left Logical Imm I 0010011 0x1 imm[5:11]=0x00 rd = rs1 << imm[0:4]
// srli Shift Right Logical Imm I 0010011 0x5 imm[5:11]=0x00 rd = rs1 >> imm[0:4]
// srai Shift Right Arith Imm I 0010011 0x5 imm[5:11]=0x20 rd = rs1 >> imm[0:4] msb-extends
// slti Set Less Than Imm I 0010011 0x2 rd = (rs1 < imm)?1:0
// sltiu Set Less Than Imm (U) I 0010011 0x3 rd = (rs1 < imm)?1:0 zero-extends

module IMM_Pre_ALU(
    input  logic [ARCHITECTURE_WIDTH - 1:0] a_in,     
    input  logic [11:0]                     imm_in,    
    input  logic [2:0]                      func3_in,  

    output logic [ARCHITECTURE_WIDTH - 1:0] a_out,     
    output logic [ARCHITECTURE_WIDTH - 1:0] b_out,   
    output logic [3:0]                      op_out     
);

    assign a_out = a_in;

    always_comb begin
        if ((func3_in == 3'b101) && imm_in[10]) begin
            op_out = {1'b1, func3_in}; 
        end else begin
            op_out = {1'b0, func3_in}; 
        end

        if (func3_in == 3'b011) begin
            b_out = {{ (ARCHITECTURE_WIDTH - 12){1'b0} }, imm_in};
        end else begin
            b_out = {{ (ARCHITECTURE_WIDTH - 12){imm_in[11]} }, imm_in};
        end
    end

endmodule