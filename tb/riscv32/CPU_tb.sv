`timescale 1ns / 1ps

import constants::*;

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

    //write instructions to memory
    // ADDI x1, x0, 15    # x1 = 15
    // ADDI x2, x0, 27    # x2 = 27
    // ADD  x3, x1, x2    # x3 = 42
    // SUB  x4, x3, x1    # x4 = 27

    //check results
    //check next pc

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