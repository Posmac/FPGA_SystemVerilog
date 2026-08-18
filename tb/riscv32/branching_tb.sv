`timescale 1ns / 1ps

import constants::*;

module branching_tb;
    logic[ARCHITECTURE_WIDTH - 1: 0] instruction;
    logic                            slt;
    logic                            sltu;

    logic[ARCHITECTURE_WIDTH - 1: 0] pc;
    logic[ARCHITECTURE_WIDTH - 1: 0] rs1;
    logic[ARCHITECTURE_WIDTH - 1: 0] rs2;
    logic[ARCHITECTURE_WIDTH - 1: 0] imm;

    logic[ARCHITECTURE_WIDTH - 1: 0] pc_next;
    logic                            pc_write;

    logic[ARCHITECTURE_WIDTH - 1: 0] expected_pc_next;
    logic[ARCHITECTURE_WIDTH - 1: 0] expected_pc_write;

    Branch_Unit br(
        .instruction(instruction),
        .slt(slt),
        .sltu(sltu),
        .pc(pc),
        .rs1(rs1),
        .rs2(rs2),
        .imm(imm),
        .pc_next(pc_next),
        .pc_write(pc_write)
    );

    assign pc = 32'd0;

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name);
        begin
            test_count++;
            
            //$error("Error in IMM Decoder module for INSTR = %b. Wrong output OUT = %d(%b). Expected: %d(B: %b)", instr_in, imm_ext, imm_ext, expected, expected);
        end
    endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, decoder);

    $display("---------------------------------------");
    $display("SYSTEM TEST FOR 32 bit Branch control unit");
	$display("---------------------------------------");
	
    #10;
    $display("---------------------------------------");
    $display("Branching (BEQ) Start");
	$display("---------------------------------------");

// bne Branch != B 1100011 0x1 if(rs1 != rs2) PC += imm
// blt Branch < B 1100011 0x4 if(rs1 < rs2) PC += imm
// bge Branch ≥ B 1100011 0x5 if(rs1 >= rs2) PC += imm
// bltu Branch < (U) B 1100011 0x6 if(rs1 < rs2) PC += imm zero-extends
// bgeu Branch ≥ (U) B 1100011 0x7 if(rs1 >= rs2) PC += imm zero-extend

//     logic bne; //0x1 
//     logic blt; //0x4
//     logic bge; //0x5
//     logic bltu; //0x6
//     logic bgeu; //0x7

//  beq == 1 && func3 == 3'd0
//                     || bne == 1 && func3 == 3'd1
//                     || blt == 1 && func3 == 3'd4
//                     || bge == 1 && func3 == 3'd5
//                     || bltu == 1 && func3 == 3'd6
//                     || bgeu == 1 && func3 == 3'd7

    // logic beq; //0x0
    // beq Branch == B 1100011 0x0 if(rs1 == rs2) PC += imm
    repeat (100000) begin
        instruction = '0;
        instruction[6:0] = 7'b1100011;
        instruction[14:12] = 3'd0;
        rs1 = $signed(int'($urandom));
        rs2 = $signed(int'($urandom));
        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        // expected_pc_next 
        #10;
        check_result("BEQ TEST");
    end

    $display("---------------------------------------");
    $display("Branching (BEQ) Success");
	$display("---------------------------------------");

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

