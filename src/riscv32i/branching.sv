`timescale 1ns / 1ps

import constants::*;

// beq Branch == B 1100011 0x0 if(rs1 == rs2) PC += imm
// bne Branch != B 1100011 0x1 if(rs1 != rs2) PC += imm
// blt Branch < B 1100011 0x4 if(rs1 < rs2) PC += imm
// bge Branch ≥ B 1100011 0x5 if(rs1 >= rs2) PC += imm
// bltu Branch < (U) B 1100011 0x6 if(rs1 < rs2) PC += imm zero-extends
// bgeu Branch ≥ (U) B 1100011 0x7 if(rs1 >= rs2) PC += imm zero-extend

module Branch_Unit(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  alu_res_out,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  instruction,
    input logic                             slt,
    input logic                             sltu,

    input logic[ARCHITECTURE_WIDTH -1: 0]   pc,
    input logic[ARCHITECTURE_WIDTH -1: 0]   rs1,
    input logic[ARCHITECTURE_WIDTH -1: 0]   imm,

    output logic[ARCHITECTURE_WIDTH - 1: 0] pc_next,
    output logic[ARCHITECTURE_WIDTH - 1: 0] pc_write
);
    logic beq; //0x0
    logic bne; //0x1 
    logic blt; //0x4
    logic bge; //0x5
    logic bltu; //0x6
    logic bgeu; //0x7

    assign beq = alu_res_out == '0; //if difference between x - y == 0
    assign bne = !beq; //if difference between x - y != 0

    assign blt = slt;//if x < y (SIGNED)
    assign bge = !slt;//if x >= y (SIGNED)

    assign bltu = sltu; //if x < y (UNSIGNED)
    assign bgeu = !sltu; //if x >= y (UNSIGNED)

    assign opcode = instruction[6:0];
    assign func3 = instruction[14:12];

    assign alu_first_src = 1'b0;   //first value for alu: 0: rs1, 1: pc
    assign alu_second_src = 1'b0;   //second value for alu: 0: rs2, 1: imm
    assign alu_op = 4'b0000; //op: {func7[5], ..func3]

    assign mem_read = 1'b0;  //read from data memory: 0/1
    assign mem_write = 1'b0; //write to memory

    assign reg_file_write_en = 1'b0; //save to reg file or not: 0/1
    assign reg_file_src = 2'b00; //what value to save into regfile: 0: ALU, 1: Mem, 2: Pc + 4, 3: Imm

    always_comb begin : op_selector
        unique case (opcode)
            //B type (branch)
            //if(rs1 == rs2) PC += imm
            7'b1100011: begin
                if (
                    beq == 1 && func3 == 3'd0
                    || bne == 1 && func3 == 3'd1
                    || blt == 1 && func3 == 3'd4
                    || bge == 1 && func3 == 3'd5
                    || bltu == 1 && func3 == 3'd6
                    || bgeu == 1 && func3 == 3'd7
                ) begin
                    pc_write = 1'b1;
                    pc_next = pc + imm; 
                end
            end
            //J and Link 
            //rd = PC+4; PC += imm
            7'b1101111: begin
                pc_write = 1'b1;
                pc_next = pc + imm;
            end
            //J and Link reg
            //rd = PC+4; PC = rs1 + imm
            7'b1100111: begin 
                pc_write = 1'b1;
                pc_next = rs1 + imm;
            end
            endcase
        end

endmodule