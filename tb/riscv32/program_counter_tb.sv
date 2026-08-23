`timescale 1ns / 1ps

import constants::*;

module program_counter_tb;

    // Control
    logic clk;
    logic rst;

    // Inputs
    logic                          write_en;
    logic                          take_jump;
    logic [ARCHITECTURE_WIDTH-1:0] pc_jump;

    // Outputs
    logic [ARCHITECTURE_WIDTH-1:0] pc_out;
    logic [ARCHITECTURE_WIDTH-1:0] pc_plus4;

    // Expected
    logic [ARCHITECTURE_WIDTH-1:0] expected_pc_out;
    logic [ARCHITECTURE_WIDTH-1:0] expected_pc_plus4;

    Program_Counter pc (
        .clk       (clk),
        .rst_in    (rst),
        .write_en  (write_en),
        .take_jump (take_jump),
        .pc_jump   (pc_jump),
        .pc_out    (pc_out),
        .pc_plus4  (pc_plus4)
    );

    int test_count  = 0;
    int error_count = 0;

    int cnt_rst_0 = 0;
    int cnt_rst_1 = 0;

    int cnt_we_0  = 0;
    int cnt_we_1  = 0;

    int cnt_rst0_we0 = 0;
    int cnt_rst0_we1 = 0;
    int cnt_rst1_we0 = 0;
    int cnt_rst1_we1 = 0;

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
                "[%s] PC ERROR\nOUT:      pc=%0d plus4=%0d\nEXPECTED: pc=%0d plus4=%0d\nRST=%0d WEN=%0d JUMP_EN=%0d JUMP_ADDR=%0d",
                test_name,
                pc_out,
                pc_plus4,
                expected_pc_out,
                expected_pc_plus4,
                rst,
                write_en,
                take_jump,
                pc_jump
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

        rst       = 1;
        write_en  = 1;
        take_jump = 0;
        pc_jump   = 32'hFFFFFFFF;

        expected_pc_out   = 32'd0;
        expected_pc_plus4 = 32'd4;

        tick();
        check_result("RESET");

        //--------------------------------------------------------
        // SEQUENTIAL STEP TEST (PC + 4)
        //--------------------------------------------------------

        rst       = 0;
        write_en  = 1;
        take_jump = 0;
        pc_jump   = 32'h12345678;

        expected_pc_out   = 32'd4; // Предыдущий PC был 0, стал 4
        expected_pc_plus4 = 32'd8;

        tick();
        check_result("STEP_PC4");

        //--------------------------------------------------------
        // JUMP TEST (pc_jump)
        //--------------------------------------------------------

        rst       = 0;
        write_en  = 1;
        take_jump = 1;
        pc_jump   = 32'h00000100;

        expected_pc_out   = 32'h00000100;
        expected_pc_plus4 = 32'h00000104;

        tick();
        check_result("JUMP");

        //--------------------------------------------------------
        // HOLD TEST (write_en = 0)
        //--------------------------------------------------------

        write_en  = 0;
        take_jump = 1;
        pc_jump   = 32'hDEADBEEF;

        // Должен удержать старое значение (0x100)
        expected_pc_out   = 32'h00000100;
        expected_pc_plus4 = 32'h00000104;

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
            logic [31:0] prev_plus4;

            prev_pc    = pc_out;
            prev_plus4 = pc_plus4;

            rst       = (($urandom() % 100) == 5);
            write_en  = ($urandom() > $urandom());
            take_jump = ($urandom() > $urandom());

            pc_jump   = ($urandom() % 1000) * 4; // Выравниваем по 4 байта

            if (rst) begin
                expected_pc_out   = 32'd0;
                expected_pc_plus4 = 32'd4;
            end
            else if (write_en) begin
                if (take_jump) begin
                    expected_pc_out   = pc_jump;
                    expected_pc_plus4 = pc_jump + 32'd4;
                end else begin
                    expected_pc_out   = prev_plus4;
                    expected_pc_plus4 = prev_plus4 + 32'd4;
                end
            end
            else begin
                expected_pc_out   = prev_pc;
                expected_pc_plus4 = prev_plus4;
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