`timescale 1ns / 1ps

import constants::*;

module register_multi_tb;
    logic clk;
    logic rst_in;
    logic load_in;
    logic [ARCHITECTURE_WIDTH - 1:0] d_in;
    logic [ARCHITECTURE_WIDTH - 1:0] q_out;

    Register_multi dut (
        .clk(clk), .rst_in(rst_in), .load_in(load_in),
        .d_in(d_in), .q_out(q_out)
    );

    always #5 clk = ~clk;

    task automatic check(
        input logic [ARCHITECTURE_WIDTH - 1:0] expected,
        input string name
    );
        if (q_out !== expected)
            $fatal(1, "%s: expected %h, got %h", name, expected, q_out);
        $display("PASS: %s", name);
    endtask

    initial begin
        $dumpfile("register_multi_tb.vcd");
        $dumpvars(0, register_multi_tb);
        clk = 1'b0;
        rst_in = 1'b1;
        load_in = 1'b0;
        d_in = '0;
        #1;
        check('0, "reset clears all bits");

        rst_in = 1'b0;
        load_in = 1'b1;
        d_in = 32'hA5A5_5A5A;
        @(posedge clk);
        #1;
        check(32'hA5A5_5A5A, "loads complete word");

        load_in = 1'b0;
        d_in = 32'hFFFF_FFFF;
        @(posedge clk);
        #1;
        check(32'hA5A5_5A5A, "holds word when load is disabled");

        load_in = 1'b1;
        d_in = 32'h0123_4567;
        @(posedge clk);
        #1;
        check(32'h0123_4567, "updates every bit on rising edge");
        $display("Register_multi test completed successfully");
        $finish;
    end
endmodule