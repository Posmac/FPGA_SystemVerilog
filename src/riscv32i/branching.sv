`timescale 1ns / 1ps

import constants::*;

// beq Branch == B 1100011 0x0 if(rs1 == rs2) PC += imm
// bne Branch != B 1100011 0x1 if(rs1 != rs2) PC += imm
// blt Branch < B 1100011 0x4 if(rs1 < rs2) PC += imm
// bge Branch ≥ B 1100011 0x5 if(rs1 >= rs2) PC += imm
// bltu Branch < (U) B 1100011 0x6 if(rs1 < rs2) PC += imm zero-extends
// bgeu Branch ≥ (U) B 1100011 0x7 if(rs1 >= rs2) PC += imm zero-extend

module BR_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic                             slt,
    input logic                             sltu,
    output logic                            beq,
    output logic                            bne,
    output logic                            blt,
    output logic                            bge,
    output logic                            bltu,
    output logic                            bgeu
);
    logic eq_zero;
    assign beq = a_in == '0; //if difference between x - y == 0
    assign bne = !beq; //if difference between x - y != 0

    assign blt = slt;//if x < y (SIGNED)
    assign bge = !slt;//if x >= y (SIGNED)

    assign bltu = sltu; //if x < y (UNSIGNED)
    assign bgeu = !sltu; //if x >= y (UNSIGNED)
endmodule