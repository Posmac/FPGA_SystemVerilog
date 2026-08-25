`timescale 1ns / 1ps

import constants::*;

module RISCV32_CPU(
     //control signals
    input logic clk,
    input logic rst_in,

    //data memory and instruction memory bus
    //====INSTR_MEMORY====
    // Memory_Unit Instruction_memory(),
    input logic [ARCHITECTURE_WIDTH-1:0]    instruction, //left for compatibility for other modules (.*)
    output logic [ARCHITECTURE_WIDTH-1:0]    next_instruction_address,

    //====DATA_MEMORY====
    // Memory_Unit Data_memory();
    // Порт записи (Write)
    output  logic                               data_memory_we,
    output  logic [ARCHITECTURE_WIDTH-1:0]      data_memory_waddr,
    output  logic [ARCHITECTURE_WIDTH-1:0]      data_memory_wdata,
    output  logic [2:0]                         data_memory_w_op,   // 0: SB, 1: SH, 2: SW
    // Порт чтения (Read) — синхронный (BRAM compatible)
    output  logic [ARCHITECTURE_WIDTH-1:0]      data_memory_raddr,
    output  logic [2:0]                         data_memory_r_op,   // 0: LB, 1: LH, 2: LW, 3: LBU, 4: LHU
    input   logic [ARCHITECTURE_WIDTH-1:0]      data_memory_rdata
);
    //==============DEFINE ALL MODULES/==============
    //====ALU====
    logic [ARCHITECTURE_WIDTH - 1: 0]    alu_out;
    logic [ARCHITECTURE_WIDTH - 1: 0]    slt_out;
    logic [ARCHITECTURE_WIDTH - 1: 0]    sltu_out;
    Alu_Unit Alu(
        .a_in(alu_first_out),           // <---- INPUT
        .b_in(alu_second_out),          // <---- INPUT  
        .op_in(alu_op),                 // <---- INPUT
        .a_out(alu_out),                // ----> OUTPUT
        .slt_out(slt_out),              // ----> OUTPUT
        .sltu_out(sltu_out)             // ----> OUTPUT
    );

    //====BU====
    logic[ARCHITECTURE_WIDTH - 1: 0] pc_jump;
    logic                            take_jump;
    Branch_Unit Branch_Unit(
        .instruction(instruction),
        .slt(slt_out[0]),
        .sltu(sltu_out[0]),
        .pc(pc_out),
        .rs1(alu_first_out),
        .rs2(alu_second_out),
        .imm(imm_ext),
        .pc_jump(pc_jump),
        .take_jump(take_jump)
    );

    //====CU====
    logic                           mem_read;
    logic[1:0]                      reg_file_src;
    logic                           reg_file_write_en;
    logic[3:0]                      alu_op;
    logic                           alu_first_src;
    logic                           alu_second_src;
    Control_Unit Control_Unit(
        .instruction(instruction),              // <---- INPUT
        .mem_read(mem_read),                    // ----> OUTPUT
        .mem_write(data_memory_we),             // ----> OUTPUT
        .reg_file_src(reg_file_src),            // ----> OUTPUT
        .reg_file_write_en(reg_file_write_en),  // ----> OUTPUT
        .alu_op(alu_op),                        // ----> OUTPUT
        .alu_first_src(alu_first_src),          // ----> OUTPUT
        .alu_second_src(alu_second_src)         // ----> OUTPUT
    );

    logic[ARCHITECTURE_WIDTH - 1: 0] alu_first_out;
    MUX_1_Op_Multi_logic alu_first_mux(
        .a_in(reg_file_rs1),    // <---- INPUT
        .b_in('0),              // <---- INPUT
        .op_in(alu_first_src),  // <---- INPUT
        .a_out(alu_first_out)   // ----> OUTPUT
    );

    logic[ARCHITECTURE_WIDTH - 1: 0] alu_second_out;
    MUX_1_Op_Multi_logic alu_second_mux(
        .a_in(reg_file_rs2),        // <---- INPUT
        .b_in(imm_ext),             // <---- INPUT
        .op_in(alu_second_src),     // <---- INPUT
        .a_out(alu_second_out)      // ----> OUTPUT
    );

    // ====IMM====
    logic [ARCHITECTURE_WIDTH - 1: 0] instr;
    logic [ARCHITECTURE_WIDTH - 1: 0] imm_ext;
    Imm_Unit Imm_Unit(
        .instr(instruction),    // <---- INPUT
        .imm_ext(imm_ext)       // ----> OUTPUT
    );

    //====PC====
    logic [ARCHITECTURE_WIDTH - 1:0]  pc_out;
    logic [ARCHITECTURE_WIDTH - 1:0]  pc_plus4;
    Program_Counter Program_Counter (
    .clk       (clk),           // <---- INPUT
    .rst_in    (rst_in),        // <---- INPUT
    .write_en  (1'b1),          // <---- INPUT
    .take_jump (take_jump),     // <---- INPUT
    .pc_jump   (pc_jump),       // <---- INPUT
    .pc_out    (pc_out),        // ----> OUTPUT
    .pc_plus4  (pc_plus4)       // ----> OUTPUT
    );

    //what value to save into regfile: 0: ALU, 1: Mem, 2: Pc + 4, 3: Imm
    MUX_2_Op_Multi_logic reg_file_wdata_mux(
        .a_in(alu_out),             // <---- INPUT 
        .b_in(data_memory_rdata),   // <---- INPUT
        .c_in(pc_plus4),            // <---- INPUT
        .d_in(imm_ext),             // <---- INPUT
        .op_in(reg_file_src),       // <---- INPUT
        .a_out(reg_file_wdata)      // <---- INPUT
    );

    //====REG_FILE====
    logic[ARCHITECTURE_WIDTH - 1: 0] reg_file_wdata;
    logic[ARCHITECTURE_WIDTH - 1: 0] reg_file_rs1;
    logic[ARCHITECTURE_WIDTH - 1: 0] reg_file_rs2;
    Register_File Register_File(
        .clk(clk),                                  // <---- INPUT
        .rst_in(rst_in),                            // <---- INPUT
        .instruction(instruction),                  // <---- INPUT
        .wdata(reg_file_wdata),                     // <---- INPUT
        .write_enabled(reg_file_write_en),          // <---- INPUT
        .rdata1(reg_file_rs1),                      // ----> OUTPUT
        .rdata2(reg_file_rs2)                       // ----> OUTPUT
    );

    // output  logic [ARCHITECTURE_WIDTH-1:0]      data_memory_waddr,
    assign data_memory_waddr = alu_out;

    // output  logic [ARCHITECTURE_WIDTH-1:0]      data_memory_wdata,
    assign data_memory_wdata = reg_file_rs2;

    // output  logic [ARCHITECTURE_WIDTH-1:0]      data_memory_raddr,
    assign data_memory_raddr = alu_out;

    // pc out
    assign next_instruction_address = pc_out;

    // output  logic [2:0] data_memory_r_op,   // 0: LB, 1: LH, 2: LW, 3: LBU, 4: LHU
    assign data_memory_r_op = instruction[14:12];
    
    // output  logic [2:0] data_memory_w_op,   // 0: SB, 1: SH, 2: SW
    assign data_memory_w_op = instruction[14:12];

endmodule