`timescale 1ns / 1ps

import constants::*;

module SUBSTRACTOR_Multi_logic_tb;

    // Signals for connecting to Design Under Test (DUT)
    logic [ARCHITECTURE_WIDTH-1:0] tb_a;
    logic [ARCHITECTURE_WIDTH-1:0] tb_b;
    logic [ARCHITECTURE_WIDTH-1:0] tb_out;

    // Expected values for validation
    logic [ARCHITECTURE_WIDTH-1:0] exp_out;

    // Counters for test status
    int error_count = 0;
    int test_count = 0;

    // Instantiate the Device Under Test (DUT)
    SUBSTRACTOR_Multi_logic dut (
        .a_in  (tb_a),
        .b_in  (tb_b),
        .a_out (tb_out)
    );

    // Task for automatic result verification
    task check_result(string test_name);
        begin
            test_count++;
            
            // Mathematical model of an ideal behavioral subtractor
            // Note: In 32-bit unsigned arithmetic, overflow/underflow wraps around automatically
            exp_out = tb_a - tb_b;

            // Check using !== to properly handle potential X/Z states
            if (tb_out !== exp_out) begin
                $error("❌ FAIL [%s]: A=%h, B=%h | Got: Out=%h | Exp: Out=%h", 
                       test_name, tb_a, tb_b, tb_out, exp_out);
                error_count++;
            end
        end
    endtask

    initial begin
        // Setup VCD dumping for waveform analysis
        $dumpfile("dump.vcd");
        $dumpvars(0, SUBSTRACTOR_Multi_logic_tb);

        $display("----------------------------------------------------------------");
        $display("        STARTING SMART TEST FOR 32-BIT SUBSTRACTOR");
        $display("----------------------------------------------------------------");

        // === STAGE 1: CORNER CASES ===

        // Test 1: Zero subtraction (A - 0 = A)
        tb_a = 32'h1234_5678;
        tb_b = 32'h0000_0000;
        #10;
        check_result("Subtracting Zero");

        // Test 2: Identity subtraction (A - A = 0)
        tb_a = 32'hFFFF_FFFF;
        tb_b = 32'hFFFF_FFFF;
        #10;
        check_result("Subtracting Itself (Max)");

        tb_a = 32'h5555_5555;
        tb_b = 32'h5555_5555;
        #10;
        check_result("Subtracting Itself (Alternating)");

        // Test 3: Underflow to Max (0 - 1 = FFFFFFFF)
        tb_a = 32'h0000_0000;
        tb_b = 32'h0000_0001;
        #10;
        check_result("Underflow by 1");

        // Test 4: Alternating bits and complex patterns
        tb_a = 32'h5555_5555;
        tb_b = 32'hAAAA_AAAA;
        #10;
        check_result("Alternating 1");

        tb_a = 32'hAAAA_AAAA;
        tb_b = 32'h5555_5555;
        #10;
        check_result("Alternating 2");

        // Test 5: Maximum signed boundaries transition
        tb_a = 32'h7FFF_FFFF; // Max Positive Signed
        tb_b = 32'h8000_0000; // Min Negative Signed
        #10;
        check_result("Signed Boundaries");


        // === STAGE 2: RANDOM TESTING ===
        // Running 100,000 random test combinations
        repeat (100000) begin
            tb_a = $urandom(); // Generates random 32-bit unsigned integer
            tb_b = $urandom();
            #10;
            check_result("Random Test");
        end


        // === TESTING SUMMARY ===
        $display("----------------------------------------------------------------");
        $display("        TESTING COMPLETE!");
        $display("        Total tests run: %0d", test_count);
        if (error_count == 0) begin
            $display("        🎉 SUCCESS: All tests passed successfully!");
        end else begin
            $display("        ❌ ERROR: Found %0d mismatches!", error_count);
        end
        $display("----------------------------------------------------------------");
        $finish;
    end

endmodule
