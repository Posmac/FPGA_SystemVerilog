`timescale 1ns / 1ps

import constants::*;

module imm_decoder_tb;
    logic[ARCHITECTURE_WIDTH - 1: 0] instr_in;
    logic[ARCHITECTURE_WIDTH - 1: 0] imm_ext;

    logic[ARCHITECTURE_WIDTH - 1: 0] expected;
    
    IMM_decoder decoder(
        .instr(instr_in),
        .imm_ext(imm_ext)
    );

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name);
        begin
            test_count++;
            if (imm_ext != expected) begin 
                $error("Error in IMM Decoder module for INSTR = %b. Wrong output OUT = %d(%b). Expected: %d(B: %b)", instr_in, imm_ext, imm_ext, expected, expected);
            end
        end
    endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, decoder);

    $display("---------------------------------------");
    $display("SYSTEM TEST FOR 32 bit IMM Decoder");
	$display("---------------------------------------");
	
    #10;
    $display("---------------------------------------");
    $display("IMM(ALU) Start");
	$display("---------------------------------------");
    
    //I: 0010011 (alu imm)
    repeat (1000000) begin
        instr_in = '0;
        expected = $signed(int'($urandom));
        expected = $signed(expected) >>> 20;
        instr_in[6:0] = 7'b0010011;
        instr_in[31] = expected[11];
        instr_in[30:20] = expected[10:0];
        #10;
        check_result("IMM ALU TEST");
    end

    $display("---------------------------------------");
    $display("IMM(ALU) Success");
	$display("---------------------------------------");

    //------------------------------------------------------------

    #10;
    $display("---------------------------------------");
    $display("IMM(Load) Start");
	$display("---------------------------------------");
    
    //I: 0000011 (load)
    //I: 1100111 (jump + load)
    //I: 1110011 (call/break)
    repeat (1000000) begin
        instr_in = '0;
        expected = $signed(int'($urandom));
        expected = $signed(expected) >>> 20;
        instr_in[6:0] = 7'b0000011;
        instr_in[31] = expected[11];
        instr_in[30:20] = expected[10:0];
        #10;
        check_result("IMM LOAD TEST");
    end

    $display("---------------------------------------");
    $display("IMM(LOAD) Success");
	$display("---------------------------------------");

    //------------------------------------------------------------

    #10;
    $display("---------------------------------------");
    $display("IMM(Store) Start");
	$display("---------------------------------------");
    
    //S: 0100011 (store)
    repeat (1000000) begin
        instr_in = '0;
        expected = $signed(int'($urandom));
        expected = $signed(expected) >>> 20;
        instr_in[6:0] = 7'b0100011;
        instr_in[31] = expected[11];
        instr_in[30:25] = expected[10:5];
        instr_in[11:8] = expected[4:1];
        instr_in[7] = expected[0];
        #10;
        check_result("IMM STORE TEST");
    end

    $display("---------------------------------------");
    $display("IMM(STORE) Success");
	$display("---------------------------------------");

    //------------------------------------------------------------

    #10;
    $display("---------------------------------------");
    $display("IMM(BRANCH) Start");
	$display("---------------------------------------");

    //B: 1100011 (branch)
    // assign imm_b = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };
    repeat (1000000) begin
        instr_in = '0;
        expected = int'($urandom());
        expected = $signed(expected) >> 19;
        expected[0] = 1'b0;
        expected[31:13] = {19{expected[12]}};
        // $display("Expected: %d(%b)", expected, expected[12:2]);
        instr_in[6:0] = 7'b1100011;
        instr_in[31] = expected[12];
        instr_in[7] = expected[11];
        instr_in[30:25] = expected[10:5];
        instr_in[11:8] = expected[4:1];
        #10;
        // $display("instr=%b", instr_in);
        // $display("opcode=%b", decoder.opcode);
        // $display("imm_i=%0d (%b)", decoder.imm_i, decoder.imm_i);
        // $display("imm_ext=%0d (%b)", imm_ext, imm_ext);
        // $display("expected=%0d (%b)", expected, expected);
        check_result("IMM BRANCH TEST");
    end

    $display("---------------------------------------");
    $display("IMM(BRANCH) Success");
	$display("---------------------------------------");

    //------------------------------------------------------------

    #10;
    $display("---------------------------------------");
    $display("IMM(JUMP) Start");
	$display("---------------------------------------");

    //J: 1101111 (jump)
    // assign imm_j = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
    repeat (1000000) begin
        instr_in = '0;
        expected = int'($urandom());
        expected = $signed(expected) >> 11;

        expected[0] = 1'b0;
        expected[31:20] = {12{expected[20]}};
        // // $display("Expected: %d(%b)", expected, expected[12:2]);
        instr_in[6:0] = 7'b1101111;
        instr_in[31] = expected[20];
        instr_in[19:12] = expected[19:12];
        instr_in[20] = expected[11];
        instr_in[30:25] = expected[10:5];
        instr_in[24:21] = expected[4:1];
        #10;
        // $display("instr=%b", instr_in);
        // $display("opcode=%b", decoder.opcode);
        // $display("imm_i=%0d (%b)", decoder.imm_i, decoder.imm_i);
        // $display("imm_ext=%0d (%b)", imm_ext, imm_ext);
        // $display("expected=%0d (%b)", expected, expected);
        check_result("IMM JUMP TEST");
    end

    $display("---------------------------------------");
    $display("IMM(UPPER) Success");
	$display("---------------------------------------");

    //U: 0110111 (load upper)
    //U: 0010111 (add upper imm)
    // assign imm_u = { instr[31:12], 12'b0 };
    repeat (1000000) begin
        instr_in = '0;
        expected = int'($urandom());
        expected = $signed(expected);
        expected[11:0] = '0;

        // // $display("Expected: %d(%b)", expected, expected[12:2]);
        instr_in[6:0] = 7'b0110111;
        instr_in[31:12] = expected[31:12];
        #10;
        // $display("instr=%b", instr_in);
        // $display("opcode=%b", decoder.opcode);
        // $display("imm_i=%0d (%b)", decoder.imm_i, decoder.imm_i);
        // $display("imm_ext=%0d (%b)", imm_ext, imm_ext);
        // $display("expected=%0d (%b)", expected, expected);
        check_result("IMM UPPER TEST");
    end

    $display("---------------------------------------");
    $display("IMM(UPPER) Success");
	$display("---------------------------------------");
    //------------------------------------------------------------
    // EDGE CASES
    //------------------------------------------------------------

    #10;
    $display("---------------------------------------");
    $display("IMM EDGE CASES Start");
    $display("---------------------------------------");

    // ---------------------------------------------------------
    // I-Type
    // ---------------------------------------------------------

    // 0
    instr_in = '0;
    expected = 0;
    instr_in[6:0] = 7'b0010011;
    instr_in[31:20] = expected[11:0];
    #10;
    check_result("I IMM EDGE 0");

    // +2047
    instr_in = '0;
    expected = 2047;
    instr_in[6:0] = 7'b0010011;
    instr_in[31:20] = expected[11:0];
    #10;
    check_result("I IMM EDGE MAX");

    // -2048
    instr_in = '0;
    expected = -2048;
    instr_in[6:0] = 7'b0010011;
    instr_in[31:20] = expected[11:0];
    #10;
    check_result("I IMM EDGE MIN");

    // -1
    instr_in = '0;
    expected = -1;
    instr_in[6:0] = 7'b0010011;
    instr_in[31:20] = expected[11:0];
    #10;
    check_result("I IMM EDGE -1");

    //---------------------------------------------------------
    // B-Type
    //---------------------------------------------------------

    // Max positive branch offset
    instr_in = '0;
    expected = 4094;

    instr_in[6:0]   = 7'b1100011;
    instr_in[31]    = expected[12];
    instr_in[7]     = expected[11];
    instr_in[30:25] = expected[10:5];
    instr_in[11:8]  = expected[4:1];

    #10;
    check_result("B IMM EDGE MAX");

    // Max negative branch offset
    instr_in = '0;
    expected = -4096;

    instr_in[6:0]   = 7'b1100011;
    instr_in[31]    = expected[12];
    instr_in[7]     = expected[11];
    instr_in[30:25] = expected[10:5];
    instr_in[11:8]  = expected[4:1];

    #10;
    check_result("B IMM EDGE MIN");

    // Check isolated bits
    instr_in = '0;
    expected = 2;

    instr_in[6:0]   = 7'b1100011;
    instr_in[31]    = expected[12];
    instr_in[7]     = expected[11];
    instr_in[30:25] = expected[10:5];
    instr_in[11:8]  = expected[4:1];

    #10;
    check_result("B IMM EDGE BIT1");

    instr_in = '0;
    expected = 2048;

    instr_in[6:0]   = 7'b1100011;
    instr_in[31]    = expected[12];
    instr_in[7]     = expected[11];
    instr_in[30:25] = expected[10:5];
    instr_in[11:8]  = expected[4:1];

    #10;
    check_result("B IMM EDGE BIT11");

    //---------------------------------------------------------
    // J-Type
    //---------------------------------------------------------

    instr_in = '0;
    expected = 1048574;

    instr_in[6:0]    = 7'b1101111;
    instr_in[31]     = expected[20];
    instr_in[19:12]  = expected[19:12];
    instr_in[20]     = expected[11];
    instr_in[30:25]  = expected[10:5];
    instr_in[24:21]  = expected[4:1];

    #10;
    check_result("J IMM EDGE MAX");

    instr_in = '0;
    expected = -1048576;

    instr_in[6:0]    = 7'b1101111;
    instr_in[31]     = expected[20];
    instr_in[19:12]  = expected[19:12];
    instr_in[20]     = expected[11];
    instr_in[30:25]  = expected[10:5];
    instr_in[24:21]  = expected[4:1];

    #10;
    check_result("J IMM EDGE MIN");

    // Проверка imm[11]
    instr_in = '0;
    expected = 2048;

    instr_in[6:0]    = 7'b1101111;
    instr_in[31]     = expected[20];
    instr_in[19:12]  = expected[19:12];
    instr_in[20]     = expected[11];
    instr_in[30:25]  = expected[10:5];
    instr_in[24:21]  = expected[4:1];

    #10;
    check_result("J IMM EDGE BIT11");

    //---------------------------------------------------------
    // U-Type
    //---------------------------------------------------------

    instr_in = '0;
    expected = 32'h00000000;
    instr_in[6:0] = 7'b0110111;
    instr_in[31:12] = expected[31:12];
    #10;
    check_result("U IMM ZERO");

    instr_in = '0;
    expected = 32'h7FFFF000;
    instr_in[6:0] = 7'b0110111;
    instr_in[31:12] = expected[31:12];
    #10;
    check_result("U IMM POS MAX");

    instr_in = '0;
    expected = 32'h80000000;
    instr_in[6:0] = 7'b0110111;
    instr_in[31:12] = expected[31:12];
    #10;
    check_result("U IMM NEG MIN");

    instr_in = '0;
    expected = 32'hFFFFF000;
    instr_in[6:0] = 7'b0110111;
    instr_in[31:12] = expected[31:12];
    #10;
    check_result("U IMM ALL ONES");

    $display("---------------------------------------");
    $display("IMM EDGE CASES Success");
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

