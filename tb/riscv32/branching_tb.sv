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

    logic[ARCHITECTURE_WIDTH - 1: 0] pc_jump;
    logic                            take_jump;

    logic[ARCHITECTURE_WIDTH - 1: 0] expected_pc_jump;
    logic                            expected_take_jump;

    Branch_Unit br(
        .instruction(instruction),
        .slt(slt),
        .sltu(sltu),
        .pc(pc),
        .rs1(rs1),
        .rs2(rs2),
        .imm(imm),
        .pc_jump(pc_jump),
        .take_jump(take_jump)
    );

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name);
        begin
            test_count++;
            if (pc_jump != expected_pc_jump || take_jump != expected_take_jump) begin
                $error("Error in Branch module for INSTR = %b, SLT = %d, SLTU = %d, RS1 = %d, RS2 = %d, IMM = %d, PC: %d. \n Wrong output PC_jump = %d, take_jump = %b. Expected: PC_jump = %d, take_jump = %d", instruction, slt, sltu, rs1, rs2, imm, pc, pc_jump, take_jump, expected_pc_jump, expected_take_jump);
            end
        end
    endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, br);

    $display("---------------------------------------");
    $display("SYSTEM TEST FOR 32 bit Branch control unit");
	$display("---------------------------------------");

    #10;
    $display("---------------------------------------");
    $display("Branching (BEQ) Start");
	$display("---------------------------------------");

    // logic beq; //0x0
    // beq Branch == B 1100011 0x0 if(rs1 == rs2) PC += imm
    //  beq == 1 && func3 == 3'd0
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1100011;
        instruction[14:12] = 3'd0;

        if ($urandom_range(0, 1) == 1) begin
            rs2 = rs1; 
        end else begin
            rs2 = rs1 + $urandom_range(1, 100); 
        end

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        if (rs1 == rs2) begin
            expected_pc_jump = pc + imm;
            expected_take_jump = 1'b1; 
        end else begin 
            expected_pc_jump = pc;
            expected_take_jump = 1'b0; 
        end
        #10;
        check_result("BEQ TEST");
    end

    $display("---------------------------------------");
    $display("Branching (BEQ) Success");
	$display("---------------------------------------");

    #10;
    $display("---------------------------------------");
    $display("Branching (BNE) Start");
	$display("---------------------------------------");

    // bne Branch != B 1100011 0x1 if(rs1 != rs2) PC += imm
    // logic bne; //0x1 
    // bne == 1 && func3 == 3'd1
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1100011;
        instruction[14:12] = 3'd1;

        if ($urandom_range(0, 1) == 1) begin
            rs2 = rs1; 
        end else begin
            rs2 = rs1 + $urandom_range(1, 100); 
        end

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        if (rs1 != rs2) begin
            expected_pc_jump = pc + imm;
            expected_take_jump = 1'b1; 
        end else begin 
            expected_pc_jump = pc;
            expected_take_jump = 1'b0; 
        end
        #10;
        check_result("BNE TEST");
    end

    $display("---------------------------------------");
    $display("Branching (BLT) Success");
	$display("---------------------------------------");

    // blt Branch < B 1100011 0x4 if(rs1 < rs2) PC += imm
    // logic blt; //0x4
    // blt == 1 && func3 == 3'd4
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));
        rs2 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1100011;
        instruction[14:12] = 3'd4;

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        if ($signed(rs1) < $signed(rs2)) begin
            expected_pc_jump = pc + imm;
            expected_take_jump = 1'b1; 
        end else begin 
            expected_pc_jump = pc;
            expected_take_jump = 1'b0; 
        end
        #10;
        check_result("BLT TEST");
    end

    $display("---------------------------------------");
    $display("Branching (BLT) Success");
	$display("---------------------------------------");

    $display("---------------------------------------");
    $display("Branching (BGE) Success");
	$display("---------------------------------------");

    // bge Branch ≥ B 1100011 0x5 if(rs1 >= rs2) PC += imm
    // logic bge; //0x5
    // bge == 1 && func3 == 3'd5
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));
        rs2 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1100011;
        instruction[14:12] = 3'd5;

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        if ($signed(rs1) >= $signed(rs2)) begin
            expected_pc_jump = pc + imm;
            expected_take_jump = 1'b1; 
        end else begin 
            expected_pc_jump = pc;
            expected_take_jump = 1'b0; 
        end
        #10;
        check_result("BGE TEST");
    end

    $display("---------------------------------------");
    $display("Branching (BGE) Success");
	$display("---------------------------------------");

    $display("---------------------------------------");
    $display("Branching (BLTU) Success");
	$display("---------------------------------------");
    
    // bltu Branch < (U) B 1100011 0x6 if(rs1 < rs2) PC += imm zero-extends
    // logic bltu; //0x6
    // bltu == 1 && func3 == 3'd6
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));
        rs2 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1100011;
        instruction[14:12] = 3'd6;

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        if (rs1 < rs2) begin
            expected_pc_jump = pc + imm;
            expected_take_jump = 1'b1; 
        end else begin 
            expected_pc_jump = pc;
            expected_take_jump = 1'b0; 
        end
        #10;
        check_result("BLTU TEST");
    end

    $display("---------------------------------------");
    $display("Branching (BLTU) Success");
	$display("---------------------------------------");

    $display("---------------------------------------");
    $display("Branching (BGEU) Success");
	$display("---------------------------------------");
    
    // bgeu Branch ≥ (U) B 1100011 0x7 if(rs1 >= rs2) PC += imm zero-extend
    // logic bgeu; //0x7
    // bgeu == 1 && func3 == 3'd7
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));
        rs2 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1100011;
        instruction[14:12] = 3'd7;

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        if (rs1 >= rs2) begin
            expected_pc_jump = pc + imm;
            expected_take_jump = 1'b1; 
        end else begin 
            expected_pc_jump = pc;
            expected_take_jump = 1'b0; 
        end
        #10;
        check_result("BGEU TEST");
    end

    $display("---------------------------------------");
    $display("Branching (BGEU) Success");
	$display("---------------------------------------");

    //others
    $display("---------------------------------------");
    $display("Branching (JAL) Success");
	$display("---------------------------------------");

    // J and Link 
    // rd = PC+4; PC += imm
    // 7'b1101111: begin
    // take_jump = 1'b1;
    // pc_jump = pc + imm;
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));
        rs2 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1101111;

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        expected_pc_jump = pc + imm;
        expected_take_jump = 1'b1; 
        #10;
        check_result("JAL TEST");
    end

    $display("---------------------------------------");
    $display("Branching (JAL) Success");
	$display("---------------------------------------");


    $display("---------------------------------------");
    $display("Branching (JALR) Success");
	$display("---------------------------------------");

    //J and Link reg
    // rd = PC+4; PC = rs1 + imm
    // 7'b1100111: begin 
    // take_jump = 1'b1;
    // pc_jump = rs1 + imm;
    repeat (1000000) begin
        pc  = $urandom();
        rs1 = $signed(int'($urandom));
        rs2 = $signed(int'($urandom));

        instruction = '0;
        instruction[6:0] = 7'b1100111;

        imm = $signed(int'($urandom_range(-4096, 4096)));
        slt  = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        sltu = (rs1 < rs2) ? 1 : 0;

        expected_pc_jump = (rs1 + imm) & ~32'd1;
        expected_take_jump = 1'b1; 
        #10;
        check_result("JALR TEST");
    end

    $display("---------------------------------------");
    $display("Branching (JALR) Success");
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
