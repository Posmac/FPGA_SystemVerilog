`timescale 1ns / 1ps

import constants::*;

module program_counter_tb;

    // Control
    logic clk;
    logic rst;

    // Inputs
    logic [ARCHITECTURE_WIDTH-1:0] pc_next;
    logic                          write_en;

    // Outputs
    logic [ARCHITECTURE_WIDTH-1:0] pc_out;
    logic [ARCHITECTURE_WIDTH-1:0] pc_plus4;

    // Expected
    logic [ARCHITECTURE_WIDTH-1:0] expected_pc_out;
    logic [ARCHITECTURE_WIDTH-1:0] expected_pc_plus4;

    Program_Counter pc(
        .rst_in(rst),
        .*
    );

    int test_count  = 0;
    int error_count = 0;

    int cnt_rst_0 = 0;
    int cnt_rst_1 = 0;

    int cnt_we_0  = 0;
    int cnt_we_1  = 0;

    // особенно интересно
    int cnt_rst1_we0 = 0;
    int cnt_rst1_we1 = 0;
    int cnt_rst0_we0 = 0;
    int cnt_rst0_we1 = 0;

    //------------------------------------------------------------
    // Helpers
    //------------------------------------------------------------

    task tick;
    begin
        @(posedge clk);
        #5;
    end
    endtask

    task check_result(string test_name);
    begin
        test_count++;

        if ((pc_out !== expected_pc_out) ||
            (pc_plus4 !== expected_pc_plus4))
        begin
            error_count++;

            $error(
                "[%s] PC ERROR\nOUT:      pc=%0d plus4=%0d\nEXPECTED: pc=%0d plus4=%0d\nRST=%0d WEN=%0d NEXT=%0d",
                test_name,
                pc_out,
                pc_plus4,
                expected_pc_out,
                expected_pc_plus4,
                rst,
                write_en,
                pc_next
            );
        end
    end
    endtask

    //------------------------------------------------------------
    // Clock
    //------------------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //------------------------------------------------------------
    // Tests
    //------------------------------------------------------------

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, program_counter_tb);

        $display("---------------------------------------");
        $display("SYSTEM TEST FOR 32 bit PC");
        $display("---------------------------------------");

        //--------------------------------------------------------
        // RESET TEST
        //--------------------------------------------------------

        rst      = 1;
        write_en = 1;
        pc_next  = 32'hFFFFFFFF;

        expected_pc_out   = 32'd0;
        expected_pc_plus4 = 32'd4;

        tick();
        check_result("RESET");

        //--------------------------------------------------------
        // WRITE TEST
        //--------------------------------------------------------

        rst      = 0;
        write_en = 1;
        pc_next  = 32'h12345678;

        expected_pc_out   = 32'h12345678;
        expected_pc_plus4 = 32'h1234567C;

        tick();
        check_result("WRITE");

        //--------------------------------------------------------
        // HOLD TEST
        //--------------------------------------------------------

        write_en = 0;
        pc_next  = 32'hDEADBEEF;

        expected_pc_out   = 32'h12345678;
        expected_pc_plus4 = 32'h1234567C;

        tick();
        check_result("HOLD");

        //--------------------------------------------------------
        // RANDOM TESTS
        //--------------------------------------------------------

        $display("---------------------------------------");
        $display("RANDOM TESTS START");
        $display("---------------------------------------");

        repeat (1_000_000) begin

            logic [31:0] prev_pc;

            prev_pc = pc_out;

            rst      = (($urandom() % 100) == 5);
            write_en = $urandom() > $urandom() ? 1'b0 : 1'b1;

            pc_next  = $urandom() % 1000;

            if (rst) begin
                expected_pc_out   = 32'd0;
                expected_pc_plus4 = 32'd4;
            end
            else if (write_en) begin
                expected_pc_out   = pc_next;
                expected_pc_plus4 = pc_next + 32'd4;
            end
            else begin
                expected_pc_out   = prev_pc;
                expected_pc_plus4 = prev_pc + 32'd4;
            end

            if (rst)
                cnt_rst_1++;
            else
                cnt_rst_0++;

            if (write_en)
                cnt_we_1++;
            else
                cnt_we_0++;

            case ({rst, write_en})
                2'b00: cnt_rst0_we0++;
                2'b01: cnt_rst0_we1++;
                2'b10: cnt_rst1_we0++;
                2'b11: cnt_rst1_we1++;
            endcase

            tick();
            check_result("RANDOM");

        end

        //--------------------------------------------------------
        // Summary
        //--------------------------------------------------------

        $display("---------------------------------------");
        $display("PC TEST COMPLETE");
        $display("---------------------------------------");

        $display("---------------------------------------");
        $display("COVERAGE");
        $display("---------------------------------------");

        $display("RST=0 : %0d", cnt_rst_0);
        $display("RST=1 : %0d", cnt_rst_1);

        $display("WEN=0 : %0d", cnt_we_0);
        $display("WEN=1 : %0d", cnt_we_1);

        $display("");

        $display("RST=0 WEN=0 : %0d", cnt_rst0_we0);
        $display("RST=0 WEN=1 : %0d", cnt_rst0_we1);
        $display("RST=1 WEN=0 : %0d", cnt_rst1_we0);
        $display("RST=1 WEN=1 : %0d", cnt_rst1_we1);

        $display("Total tests: %0d", test_count);

        if (error_count == 0)
            $display("🎉 SUCCESS: All tests passed!");
        else
            $display("❌ ERROR: %0d failures", error_count);

        $finish;
    end

endmodule