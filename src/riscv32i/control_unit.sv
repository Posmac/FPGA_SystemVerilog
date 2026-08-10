`timescale 1ns / 1ps

import constants::*;

// memRead
// reg_file_src
// ALUOp
// memWrite
// ALUSrc
// RegWrite

// R-types     f3 (3b)    f7 (7b)               4bits opcode {f7[5], f3}   in_num
// add         [000]      0[0]0_0000             0_000 (in_0)               in_0
// sub         [000]      0[1]0_0000             1_000 (in_8)               in_8
// xor         [100]      0[0]0_0000             0_100 (in_4)               in_4
// or          [110]      0[0]0_0000             0_110 (in_6)               in_6
// and         [111]      0[0]0_0000             0_111 (in_7)               in_7

// sll         [001]      0[0]0_0000             0_001 (in_1)               in_1
// srl         [101]      0[0]0_0000             0_101 (in_5)               in_5
// sra         [101]      0[1]0_0000             1_101 (in_13)              in_13
// slt         [010]      0[0]0_0000             0_010 (in_2)               in_2
// sltu        [011]      0[0]0_0000             0_011 (in_3)               in_3

module Control_Unit(
    input logic[ARCHITECTURE_WIDTH - 1: 0] instruction;

    output logic                           mem_read;
    output logic                           mem_write;

    output logic[1:0]                      reg_file_src;
    output logic                           reg_file_write_en;
    
    output logic[3:0]                      alu_op;
    output logic                           alu_first_src;
    output logic                           alu_second_src;
);
    logic[6:0] opcode;
    logic[2:0] func3;

    assign opcode = instruction[6:0];
    assign func3 = instruction[14:12];

    assing alu_first_src = 1'b0;   //first value for alu: 0: rs1, 1: pc
    assing alu_second_src = 1'b0;   //second value for alu: 0: rs2, 1: imm
    assing alu_op = 4'b0000; //op: {func7[5], ..func3]

    assing mem_read = 1'b0;  //read from data memory: 0/1
    assing mem_write = 1'b0; //write to memory

    assing reg_file_write_en = 1'b0; //save to reg file or not: 0/1
    assing reg_file_src = 2'b00; //what value to save into regfile: 0: ALU, 1: Mem, 2: Pc + 4, 3: Imm

    always_comb begin : op_selector
        unique case (opcode)
            //R type
            // rd = rs1 XX rs2
            7'b0110011 begin
                reg_file_write_en = 1'b1; //enable reg file write
                reg_file_src = 1'b00;     //write ALU out (00)

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'b0;    //second op: rs2
                alu_op = {instruction[30], func3}; //alu op: add,sub,xor,or, etc..

                mem_write = 1'b0; //no mem write
                mem_read = 1'b0;  //no mem read
            end
            //I type (addi)
            7'b0010011 begin
                reg_file_write_en = 1'b1; //enable reg file write
                reg_file_src = 1'b00;      //write ALU out (00)

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'b1;    //Imm value
                if (func3 == 3'b001 || func3 == 3'b101) begin
                    alu_op = {instruction[30], func3};
                end else begin
                    alu_op = {1'b0, func3};
                end

                mem_read = 1'b0; //no mem write
                mem_write = 1'b0; //no mem read
            end
            //I type (load from memory to regfile) 
            //rd = M[rs1+imm][0:7]
            7'b0000011 begin
                reg_file_write_en = 1'b0; //write to reg file
                reg_file_src = 1'b01;     //write data memory out value (01)

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'b1; //rs1 + Imm
                alu_op = 4'b0000; //ADDI op

                mem_write = 1'b0; //no mem write
                mem_read = 1'b1; //READ from memory
            end
            //S type (store into memory from alu)
            //M[rs1+imm][0:7] = rs2[0:7]
            7'b0100011 begin
                reg_file_write_en = 1'b0; //no reg file write
                reg_file_src = 1'b0;    //dont care, because write_en = 0

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'10; //rs1 + imm
                alu_op = 4'b0000; //ADDI

                mem_write = 1'b1; //WRITE to memory
                mem_read = 1'b0;  //no mem read
            end
            //B type (branch)
            //if(rs1 == rs2) PC += imm
            7'b1100011 begin
                reg_file_write_en = 1'b0;  //no reg file write
                reg_file_src = 1'b0;       //dont care, because write_en = 0

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'b0;     //rs1 - rs2
                alu_op = 4'b1000;          //SUB rs1, rs2

                mem_read = 1'b0;            //no mem read
                mem_write = 1'b0;           //no mem write
            end
            //J and Link 
            //rd = PC+4; PC += imm
            7'b1101111 begin
                reg_file_write_en = 1'b1;   //reg file write en
                reg_file_src = 2'b10;       //reg file wdata: PC + 4

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'b0;      //dont care
                alu_op = 4'b0000;           //dont care

                mem_read = 1'b0;            //no mem read
                mem_write = 1'b0;           //no mem write
            end
            //J and Link reg
            //rd = PC+4; PC = rs1 + imm
            7'b1100111 begin 
                reg_file_write_en = 1'b1;   //reg file write on
                reg_file_src = 2'b10;       //reg file wdata: PC + 4

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'b0;      //dont care
                alu_op = 4'b0000;           //dont care

                mem_read = 1'b0;            //no mem read
                mem_write = 1'b0;           //no mem write
            end
            //U load upper imm
            //rd = imm << 12
            7'b0110111 begin
                reg_file_write_en = 1'b1;   //reg file write on
                reg_file_src = 2'b11;       //reg file src: imm(4)

                alu_first_src = 1'b0;       //first is rs1
                alu_second_src = 1'b0;      //dont care
                alu_op = 4'b0000;           //dont care

                mem_read = 1'b0;            //no mem read
                mem_write = 1'b0;           //no mem write
            end
            //U add upper imm to reg
            //rd = PC + (imm << 12)
            7'b0010111 begin
                reg_file_write_en = 1'b1;   //reg file write on
                reg_file_src = 2'b00;       //reg file src: alu out

                alu_first_src = 1'b1;       //first is PC
                alu_second_src = 1'b1;      //PC + imm. second is imm
                alu_op = 4'b0000;           //ADDI    

                mem_read = 1'b0;            //no mem read
                mem_write = 1'b0;           //no mem write
            end
            endcase
        end

endmodule
