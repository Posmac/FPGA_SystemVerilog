`timescale 1ns / 1ps

module d_flip_flop_tb;
    logic clk;
    logic rst_in;
    logic load_in;
    logic d_in;
    logic q_out;

    D_Flip_flop dut (
        .clk(clk), .rst_in(rst_in), .load_in(load_in),
        .d_in(d_in), .q_out(q_out)
    );

    always #5 clk = ~clk;

    task automatic check(input logic expected, input string name);
        if (q_out !== expected)
            $fatal(1, "%s: expected %b, got %b", name, expected, q_out);
        $display("PASS: %s", name);
    endtask

    initial begin
        $dumpfile("d_flip_flop_tb.vcd");
        $dumpvars(0, d_flip_flop_tb);
        clk = 1'b0;
        rst_in = 1'b1;
        load_in = 1'b0;
        d_in = 1'b0;
        #1;
        check(1'b0, "reset clears output");

        rst_in = 1'b0;
        load_in = 1'b1;
        d_in = 1'b1;
        @(posedge clk);
        #1;
        check(1'b1, "loads one on rising edge");

        d_in = 1'b0;
        #2;
        check(1'b1, "ignores data between edges");
        @(posedge clk);
        #1;
        check(1'b0, "loads zero on rising edge");

        load_in = 1'b0;
        d_in = 1'b1;
        @(posedge clk);
        #1;
        check(1'b0, "holds value when load is disabled");
        $display("D_Flip_flop test completed successfully");
        $finish;
    end
endmodule