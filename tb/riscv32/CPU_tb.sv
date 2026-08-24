`timescale 1ns / 1ps

import constants::*;

typedef enum logic [3:0] {
    ALU_ADD  = 4'b0000,
    ALU_SUB  = 4'b1000,
    ALU_XOR  = 4'b0100,
    ALU_OR   = 4'b0110,
    ALU_AND  = 4'b0111,
    ALU_SLL  = 4'b0001,
    ALU_SRL  = 4'b0101,
    ALU_SRA  = 4'b1101,
    ALU_SLT  = 4'b0010,
    ALU_SLTU = 4'b0011
} alu_op_t;
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

module CPU_tb;
    // Control
    logic clk;
    logic rst;

    logic [ARCHITECTURE_WIDTH-1:0]    instruction;
    logic [ARCHITECTURE_WIDTH-1:0]    next_instruction_address;
    //init data memory

    parameter int MEM_SIZE_BYTES = 128;
    parameter int NUM_WORDS      = MEM_SIZE_BYTES / 4;

    //init instruction memory
    Memory_Unit #(
        .MEM_SIZE_BYTES(MEM_SIZE_BYTES)
    ) Instruction_memory (
        .clk(clk),
        .rst_in(rst),
        .we(1'b0),
        .waddr('0),
        .wdata('0),
        .w_op('0),
        .raddr(next_instruction_address),
        .r_op(3'b010),
        .rdata(instruction)
    );

    //init CPU
    RISCV32_CPU cpu(
        .clk(clk),
        .rst_in(rst),
        .instruction(instruction),
        .next_instruction_address(next_instruction_address)
    );

    int random_rs1_addr = 0;
    int random_rs2_addr = 0;
    int random_rd_addr = 0;

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name);
        begin
            test_count++;
            // if (imm_ext != expected) begin 
                // $error("Error in IMM Decoder module for INSTR = %b. Wrong output OUT = %d(%b). Expected: %d(B: %b)", instr_in, imm_ext, imm_ext, expected, expected);
            // end
        end
    endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, CPU_tb);

    $display("---------------------------------------");
    $display("SYSTEM TEST FOR 32 bit CPU!");
	$display("---------------------------------------");

    rst = 1'b1;
    clk = 1'b1;
    #2;
    clk = 1'b0;
    rst = 1'b0;
    #2;

    //write instructions to memory
    //imm[11:0](0000_0000_1111) -- rs1(00000) -- func3(000) -- rd(00001) -- opcode(0010011)
    // ADDI x1, x0, 15    # x1 = 15
    Instruction_memory.mem[0] = 32'b000000001111_00000_000_00001_0010011;

    //imm[11:0](0000_0001_1011) -- rs1(00000) -- func3(000) -- rd(00010) -- opcode(0010011)
    // ADDI x2, x0, 27    # x2 = 27
    Instruction_memory.mem[1] = 32'b000000011011_00000_000_00010_0010011;
    
    //func7(000_0000) -- rs2(00010) -- rs1(00001) -- func3(000) -- rd(00011) --opcode(0110011)
    // ADD  x3, x1, x2    # x3 = 42
    Instruction_memory.mem[2] = 32'b0000000_00010_00001_000_00011_0110011;
    
    //func7(010_0000) -- rs2(00001) -- rs1(00011) -- func3(000) -- rd(00100) --opcode(0110011)
    // SUB  x4, x3, x1    # x4 = 42 - 15 = 27
    Instruction_memory.mem[3] = 32'b0100000_00001_00011_000_00100_0110011;
    #2;

    repeat (4) begin
        $display("\n\n CPU STATUS");
        $display("CLK: %b, RST: %b", clk, rst);
        $display("PC=%d, PC+4=%d, INSTR=%h",
                cpu.Program_Counter.pc_out,
                cpu.Program_Counter.pc_plus4,
                instruction);
        $display("ALU: alu_out: %d, slt_out: %b, sltu_out: %b",  cpu.Alu.a_out, cpu.Alu.slt_out, cpu.Alu.sltu_out);

        clk = 1;
        #1;
        clk = 0;
        #1;

        $display("CLK: %b, RST: %b", clk, rst);
        $display("Memory: raddr: %d, r_op: %d, rdata: %b", Instruction_memory.raddr, Instruction_memory.r_op, Instruction_memory.rdata);
        $display("Reg file: X1: %d, X2: %d, X3: %d, X4: %d", 
            cpu.Register_File.registers_out[1], 
            cpu.Register_File.registers_out[2], 
            cpu.Register_File.registers_out[3], 
            cpu.Register_File.registers_out[4], 
        );
    end

    repeat (100_000) begin
        random_rs1_addr = $urandom() % 32;
        random_rs2_addr = $urandom() % 32;
        random_rd_addr = $urandom() % 32;
    end

    // $display("CU: instr: %b, mem_read: %b, mem_write: %b, reg_file_src: %b, reg_file_write_en: %b, alu_op: %b, alu_first_src: %b, alu_second_src: %b", 
    //     cpu.Control_Unit.instruction,
    //     cpu.Control_Unit.mem_read,
    //     cpu.Control_Unit.mem_write,
    //     cpu.Control_Unit.reg_file_src,
    //     cpu.Control_Unit.reg_file_write_en,
    //     cpu.Control_Unit.alu_op,
    //     cpu.Control_Unit.alu_first_src,
    //     cpu.Control_Unit.alu_second_src);

    // $display("PC: clk: %b, rst_in: %b, write_en: %b, take_jump: %b, pc_jump: %d, pc_out: %d, pc_plus4: %d",
    //     cpu.Program_Counter.clk,
    //     cpu.Program_Counter.rst_in,
    //     cpu.Program_Counter.write_en,
    //     cpu.Program_Counter.take_jump,
    //     cpu.Program_Counter.pc_jump,
    //     cpu.Program_Counter.pc_out,
    //     cpu.Program_Counter.pc_plus4);
    $display("----------------------------------------------------------------");
    $display(" TESTING COMPLETE!");
    $display(" Total tests run: %0d", test_count);
    if (error_count == 0) begin
        $display(" 🎉 SUCCESS: All tests passed successfully!");
    end else begin
        $display(" ❌ ERROR: Found %0d mismatches!", error_count);
    end
    $display("----------------------------------------------------------------");
    
    $finish;    
  end

endmodule