`timescale 1ns / 1ps

import constants::*;

module alu_tb;
    logic[ARCHITECTURE_WIDTH - 1: 0] tb_a_in;
    logic[ARCHITECTURE_WIDTH - 1: 0] tb_b_in;
    logic[3:0] tb_op_in;
    logic[ARCHITECTURE_WIDTH - 1: 0] tb_a_out;
    logic[ARCHITECTURE_WIDTH - 1: 0] tb_slt_out;
    logic[ARCHITECTURE_WIDTH - 1: 0] tb_sltu_out;

    logic[ARCHITECTURE_WIDTH - 1: 0]   expected_alu;
    logic[ARCHITECTURE_WIDTH - 1: 0]   expected_slt;
    logic[ARCHITECTURE_WIDTH - 1: 0]   expected_sltu;

    ALU_32I alu(
        .a_in(tb_a_in),
        .b_in(tb_b_in),
        .op_in(tb_op_in),
        .a_out(tb_a_out),
        .slt_out(tb_slt_out),
        .sltu_out(tb_sltu_out)
    );

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name);
        begin
            test_count++;

            expected_slt  = ($signed(tb_a_in) < $signed(tb_b_in)) ? 1 : 0;
            expected_sltu = (tb_a_in < tb_b_in) ? 1 : 0;

            if (tb_slt_out !== expected_slt) begin
                $error(
                    "SLT FLAG ERROR. A=%h B=%h OUT=%0d EXP=%0d",
                    tb_a_in, tb_b_in, tb_slt_out, expected_slt
                );
            end

            if (tb_sltu_out !== expected_sltu) begin
                $error(
                    "SLTU FLAG ERROR. A=%h B=%h OUT=%0d EXP=%0d",
                    tb_a_in, tb_b_in, tb_sltu_out, expected_sltu
                );
            end

            if (tb_op_in == 4'b0000) begin //add
                expected_alu = tb_a_in + tb_b_in;
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(ADD) module for A = %d, B = %d, OP = %d. Wrong output OUT = %d. expected_alu: %d", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b1000) begin //sub
                expected_alu = tb_a_in - tb_b_in;
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(SUB) module for A = %d, B = %d, OP = %d. Wrong output OUT = %d. expected_alu: %d", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b0100) begin //xor
                //(a_in | b_in) & ~(a_in & b_in);
                expected_alu = (tb_a_in | tb_b_in) & ~(tb_a_in & tb_b_in);
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(XOR) module for A = %b, B = %b, OP = %b. Wrong output OUT = %b. expected_alu: %b", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b0110) begin //or
                expected_alu = (tb_a_in | tb_b_in);
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(OR) module for A = %b, B = %b, OP = %b. Wrong output OUT = %b. expected_alu: %b", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b0111) begin //and
                expected_alu = (tb_a_in & tb_b_in);
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(AND) module for A = %b, B = %b, OP = %b. Wrong output OUT = %b. expected_alu: %b", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b0001) begin //sll
                expected_alu = tb_a_in << (tb_b_in);
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(SLL) module for A = %b, B = %d, OP = %b. Wrong output OUT = %b. expected_alu: %b", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b0101) begin //srl
                expected_alu = tb_a_in >> tb_b_in;
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(SRL) module for A = %b, B = %d, OP = %b. Wrong output OUT = %b. expected_alu: %b", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b1101) begin //sra
                expected_alu = $signed(tb_a_in) >>> tb_b_in;
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(SRA) module for A = %b, B = %d, OP = %b. Wrong output OUT = %b. expected_alu: %b", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b0010) begin //slt
                expected_alu = $signed(tb_a_in) < $signed(tb_b_in) ? 1 : 0;
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(SLT) module for A = %d, B = %d, OP = %b. Wrong output OUT = %d. expected_alu: %d", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end else if (tb_op_in == 4'b0011) begin //sltu
                expected_alu = tb_a_in < tb_b_in ? 1 : 0;
                if (tb_a_out !== expected_alu) begin
                    $error("Error in ALU(SLTU) module for A = %d, B = %d, OP = %b. Wrong output OUT = %d. expected_alu: %d", tb_a_in, tb_b_in, tb_op_in, tb_a_out, expected_alu);
                end
            end
        end
    endtask

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, alu);
    
    $display("---------------------------------------");
    $display("SYSTEM TEST FOR 32 bit ALU");
	$display("---------------------------------------");
	
    $display("Initial state for ALU: A = %d, d = %d, OP = %d, OUT = %d", tb_a_in, tb_b_in, tb_op_in, tb_a_out);
    #10;
    // add         [000]      0[0]0_0000             0_000 (in_0)               in_0
    // sub         [000]      0[1]0_0000             1_000 (in_8)               in_8
    // xor         [100]      0[0]0_0000             0_100 (in_4)               in_4
    // or          [110]      0[0]0_0000             0_110 (in_6)               in_6
    // and         [111]      0[0]0_0000             0_111 (in_7)               in_7
    
    $display("---------------------------------------");
    $display("ADD Start");
	$display("---------------------------------------");
    
    //CHECK ADD OPERATION    
    tb_op_in = 4'b0000;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom();
        #10;
        check_result("ADD TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = int'($urandom()); 
        #10;
        check_result("ADD TEST");
    end

    // Edge cases for ADD
    tb_a_in = 32'b0; tb_b_in = 32'b0; #10; check_result("ADD EDGE: 0+0");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'h1; #10; check_result("ADD EDGE: MAX+1");
    tb_a_in = 32'h7FFFFFFF; tb_b_in = 32'h7FFFFFFF; #10; check_result("ADD EDGE: MAX_INT+MAX_INT");
    tb_a_in = 32'h80000000; tb_b_in = 32'h80000000; #10; check_result("ADD EDGE: MIN_INT+MIN_INT");

    $display("---------------------------------------");
    $display("ADD Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("SUB Start");
	$display("---------------------------------------");    

    //SUB
    tb_op_in = 4'b1000;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom();
        #10;
        check_result("SUB TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = int'($urandom()); 
        #10;
        check_result("SUB TEST");
    end

    // Edge cases for SUB
    tb_a_in = 32'b0; tb_b_in = 32'b0; #10; check_result("SUB EDGE: 0-0");
    tb_a_in = 32'b0; tb_b_in = 32'hFFFFFFFF; #10; check_result("SUB EDGE: 0-MAX");
    tb_a_in = 32'h7FFFFFFF; tb_b_in = 32'h80000000; #10; check_result("SUB EDGE: MAX_INT-MIN_INT");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'h1; #10; check_result("SUB EDGE: MAX-1");

    $display("---------------------------------------");
    $display("SUB Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("XOR Start");
	$display("---------------------------------------");
    
    //XOR
    tb_op_in = 4'b0100;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom();
        #10;
        check_result("XOR TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = int'($urandom()); 
        #10;
        check_result("XOR TEST");
    end

    // Edge cases for XOR
    tb_a_in = 32'b0; tb_b_in = 32'b0; #10; check_result("XOR EDGE: 0^0");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'hFFFFFFFF; #10; check_result("XOR EDGE: MAX^MAX");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'b0; #10; check_result("XOR EDGE: MAX^0");
    tb_a_in = 32'hAAAAAAAA; tb_b_in = 32'h55555555; #10; check_result("XOR EDGE: pattern^inverted");

    $display("---------------------------------------");
    $display("XOR Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("OR Start");
	$display("---------------------------------------");

    //OR
    tb_op_in = 4'b0110;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom();
        #10;
        check_result("OR TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = int'($urandom()); 
        #10;
        check_result("OR TEST");
    end

    // Edge cases for OR
    tb_a_in = 32'b0; tb_b_in = 32'b0; #10; check_result("OR EDGE: 0|0");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'hFFFFFFFF; #10; check_result("OR EDGE: MAX|MAX");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'b0; #10; check_result("OR EDGE: MAX|0");
    tb_a_in = 32'b1; tb_b_in = 32'b0; #10; check_result("OR EDGE: 1|0");

    $display("---------------------------------------");
    $display("OR Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("AND Start");
	$display("---------------------------------------");

    //AND
    tb_op_in = 4'b0111;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom();
        #10;
        check_result("AND TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = int'($urandom()); 
        #10;
        check_result("AND TEST");
    end

    // Edge cases for AND
    tb_a_in = 32'b0; tb_b_in = 32'b0; #10; check_result("AND EDGE: 0&0");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'hFFFFFFFF; #10; check_result("AND EDGE: MAX&MAX");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'b0; #10; check_result("AND EDGE: MAX&0");
    tb_a_in = 32'b1; tb_b_in = 32'b1; #10; check_result("AND EDGE: 1&1");

    $display("---------------------------------------");
    $display("AND Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("SLL Start");
	$display("---------------------------------------");

    // sll         [001]      0[0]0_0000             0_001 (in_1)               in_1
    // srl         [101]      0[0]0_0000             0_101 (in_5)               in_5
    // sra         [101]      0[1]0_0000             1_101 (in_13)              in_13
    // slt         [010]      0[0]0_0000             0_010 (in_2)               in_2
    // sltu        [011]      0[0]0_0000             0_011 (in_3)               in_3
    //SLL 
    tb_op_in = 4'b0001;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom() >> 27;
        #10;
        check_result("SLL TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = $urandom() >> 27; 
        #10;
        check_result("SLL TEST");
    end

    // Edge cases for SLL
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'd0; #10; check_result("SLL EDGE: MAX<<0");
    tb_a_in = 32'b1; tb_b_in = 32'd31; #10; check_result("SLL EDGE: 1<<31");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'd31; #10; check_result("SLL EDGE: MAX<<31");
    tb_a_in = 32'b0; tb_b_in = 32'd31; #10; check_result("SLL EDGE: 0<<31");

    $display("---------------------------------------");
    $display("SLL Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("SRL Start");
	$display("---------------------------------------");

    //SRL
    tb_op_in = 4'b0101;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom() >> 27;
        #10;
        check_result("SRL TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = $urandom() >> 27; 
        #10;
        check_result("SRL TEST");
    end

    // Edge cases for SRL
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'd0; #10; check_result("SRL EDGE: MAX>>0");
    tb_a_in = 32'h80000000; tb_b_in = 32'd31; #10; check_result("SRL EDGE: 0x80000000>>31");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'd31; #10; check_result("SRL EDGE: MAX>>31");
    tb_a_in = 32'b0; tb_b_in = 32'd31; #10; check_result("SRL EDGE: 0>>31");

    $display("---------------------------------------");
    $display("SRL Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("SRA Start");
	$display("---------------------------------------");
    
    //SRA
    tb_op_in = 4'b1101;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom() >> 27;
        #10;
        check_result("SRA TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = $urandom() >> 27; 
        #10;
        check_result("SRA TEST");
    end

    // Edge cases for SRA
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'd0; #10; check_result("SRA EDGE: -1>>>0");
    tb_a_in = 32'h80000000; tb_b_in = 32'd31; #10; check_result("SRA EDGE: MIN_INT>>>31");
    tb_a_in = 32'h7FFFFFFF; tb_b_in = 32'd31; #10; check_result("SRA EDGE: MAX_INT>>>31");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'd31; #10; check_result("SRA EDGE: -1>>>31");

    $display("---------------------------------------");
    $display("SRA Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("SLU Start");
	$display("---------------------------------------");

    //SLU
    tb_op_in = 4'b0010;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom();
        #10;
        check_result("SLU TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = int'($urandom()); 
        #10;
        check_result("SLU TEST");
    end

    // Edge cases for SLT
    tb_a_in = 32'b0; tb_b_in = 32'b0; #10; check_result("SLT EDGE: 0<0");
    tb_a_in = 32'h80000000; tb_b_in = 32'h7FFFFFFF; #10; check_result("SLT EDGE: MIN_INT<MAX_INT");
    tb_a_in = 32'h7FFFFFFF; tb_b_in = 32'h80000000; #10; check_result("SLT EDGE: MAX_INT<MIN_INT");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'b1; #10; check_result("SLT EDGE: -1<1");

    $display("---------------------------------------");
    $display("SLU Success");
	$display("---------------------------------------");
    $display("---------------------------------------");
    $display("SLTU Start");
	$display("---------------------------------------");

    //SLTU
    tb_op_in = 4'b0011;
    repeat (1000000) begin
        tb_a_in = $urandom();
        tb_b_in = $urandom();
        #10;
        check_result("SLTU TEST");
        #10;
        tb_a_in = int'($urandom()); 
        tb_b_in = int'($urandom()); 
        #10;
        check_result("SLTU TEST");
    end

    // Edge cases for SLTU
    tb_a_in = 32'b0; tb_b_in = 32'b0; #10; check_result("SLTU EDGE: 0<0");
    tb_a_in = 32'hFFFFFFFF; tb_b_in = 32'h7FFFFFFF; #10; check_result("SLTU EDGE: MAX<0x7FFFFFFF");
    tb_a_in = 32'h80000000; tb_b_in = 32'hFFFFFFFF; #10; check_result("SLTU EDGE: 0x80000000<MAX");
    tb_a_in = 32'b1; tb_b_in = 32'hFFFFFFFF; #10; check_result("SLTU EDGE: 1<MAX");

    $display("---------------------------------------");
    $display("SLTU Success");
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

