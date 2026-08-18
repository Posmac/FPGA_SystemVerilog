`timescale 1ns / 1ps

import constants::*;

module control_unit_tb;
    //unit in
    logic[ARCHITECTURE_WIDTH - 1: 0] instruction;

    //unit out 
    logic mem_read;
    logic mem_write;

    logic[1:0] reg_file_src;
    logic reg_file_write_en;

    logic[3:0] alu_op;
    logic alu_first_src;
    logic alu_second_src;

    //expected out
    logic expected_mem_read;
    logic expected_mem_write;

    logic[1:0] expected_reg_file_src;
    logic expected_reg_file_write_en;

    logic[3:0] expected_alu_op;
    logic expected_alu_first_src;
    logic expected_alu_second_src;

    Control_Unit unit(
        .instruction(instruction),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .reg_file_src(reg_file_src),
        .reg_file_write_en(reg_file_write_en),
        .alu_op(alu_op),
        .alu_first_src(alu_first_src),
        .alu_second_src(alu_second_src)
    );

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name);
            begin
                test_count++;
                
                if (mem_read           !== expected_mem_read           ||
                    mem_write          !== expected_mem_write          ||
                    reg_file_src       !== expected_reg_file_src       ||
                    reg_file_write_en  !== expected_reg_file_write_en  ||
                    alu_op             !== expected_alu_op             ||
                    alu_first_src      !== expected_alu_first_src      ||
                    alu_second_src     !== expected_alu_second_src) begin
                    
                    error_count++;

                    $error(
                        "\n========================================================================"  +
                        "\n❌ [FAIL] %s | INSTR = 0x%h (%b)"                                       +
                        "\n------------------------------------------------------------------------"  +
                        "\n  SIGNAL           | ACTUAL | EXPECTED | STATUS"                               +
                        "\n------------------------------------------------------------------------"  +
                        "\n  mem_read         |   %1b    |    %1b     | %s"                               +
                        "\n  mem_write        |   %1b    |    %1b     | %s"                               +
                        "\n  reg_file_src     |   %2b   |    %2b    | %s"                               +
                        "\n  reg_file_write_en|   %1b    |    %1b     | %s"                               +
                        "\n  alu_op           |   %4b |    %4b    | %s"                               +
                        "\n  alu_first_src    |   %1b    |    %1b     | %s"                               +
                        "\n  alu_second_src   |   %1b    |    %1b     | %s"                               +
                        "\n========================================================================",
                        test_name, instruction, instruction,
                        (mem_read === expected_mem_read)                   ? "OK" : "MISMATCH!", mem_read, expected_mem_read,
                        (mem_write === expected_mem_write)                 ? "OK" : "MISMATCH!", mem_write, expected_mem_write,
                        (reg_file_src === expected_reg_file_src)           ? "OK" : "MISMATCH!", reg_file_src, expected_reg_file_src,
                        (reg_file_write_en === expected_reg_file_write_en) ? "OK" : "MISMATCH!", reg_file_write_en, expected_reg_file_write_en,
                        (alu_op === expected_alu_op)                       ? "OK" : "MISMATCH!", alu_op, expected_alu_op,
                        (alu_first_src === expected_alu_first_src)         ? "OK" : "MISMATCH!", alu_first_src, expected_alu_first_src,
                        (alu_second_src === expected_alu_second_src)       ? "OK" : "MISMATCH!", alu_second_src, expected_alu_second_src
                    );
                end
            end        
    endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, br);

    $display("---------------------------------------");
    $display("SYSTEM TEST FOR 32 bit Control Unit");
	$display("---------------------------------------");

    // #10;
    // $display("---------------------------------------");
    // $display("Branching (BEQ) Start");
	// $display("---------------------------------------");

    // // logic beq; //0x0
    // // beq Branch == B 1100011 0x0 if(rs1 == rs2) PC += imm
    // //  beq == 1 && func3 == 3'd0
    // repeat (1000000) begin
    //     pc  = $urandom();
    //     rs1 = $signed(int'($urandom));

    //     instruction = '0;
    //     instruction[6:0] = 7'b1100011;
    //     instruction[14:12] = 3'd0;

    //     if ($urandom_range(0, 1) == 1) begin
    //         rs2 = rs1; 
    //     end else begin
    //         rs2 = rs1 + $urandom_range(1, 100); 
    //     end

    //     imm = $signed(int'($urandom_range(-4096, 4096)));
    //     slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
    //     sltu = (rs1 < rs2) ? 1 : 0;

    //     if (rs1 == rs2) begin
    //         expected_pc_next = pc + imm;
    //         expected_pc_write = 1'b1; 
    //     end else begin 
    //         expected_pc_next = pc;
    //         expected_pc_write = 1'b0; 
    //     end
    //     #10;
    //     check_result("BEQ TEST");
    // end

    // $display("---------------------------------------");
    // $display("Branching (BEQ) Success");
	// $display("---------------------------------------");

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
