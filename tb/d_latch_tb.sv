`timescale 1ns / 1ps

module d_latch_tb;
    logic a_in;
    logic e_in;
    logic rst_in;
    logic a_out;

    D_Latch dut (
        .a_in(a_in),
        .e_in(e_in),
        .rst_in(rst_in),
        .a_out(a_out)
    );

    task automatic check(input logic expected, input string name);
        if (a_out !== expected)
            $fatal(1, "%s: expected %b, got %b", name, expected, a_out);
        $display("PASS: %s", name);
    endtask

    initial begin
        $dumpfile("d_latch_tb.vcd");
        $dumpvars(0, d_latch_tb);

        rst_in = 1'b1;
        a_in = 1'b1;
        e_in = 1'b0;
        #1;
        check(1'b0, "reset clears output");

        rst_in = 1'b0;
        e_in = 1'b1;
        a_in = 1'b1;
        #1;
        check(1'b1, "transparent latch captures one");

        a_in = 1'b0;
        #1;
        check(1'b0, "transparent latch captures zero");

        e_in = 1'b0;
        a_in = 1'b1;
        #1;
        check(1'b0, "closed latch holds previous value");

        $display("D_Latch test completed successfully");
        $finish;
    end
endmodule