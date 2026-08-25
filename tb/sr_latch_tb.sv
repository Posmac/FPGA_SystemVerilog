`timescale 1ns / 1ps

module sr_latch_tb;
    logic s_in;
    logic r_in;
    logic a_out;

    SR_Latch dut (
        .s_in(s_in),
        .r_in(r_in),
        .a_out(a_out)
    );

    task automatic check(input logic expected, input string name);
        if (a_out !== expected)
            $fatal(1, "%s: expected %b, got %b", name, expected, a_out);
        $display("PASS: %s", name);
    endtask

    initial begin
        $dumpfile("sr_latch_tb.vcd");
        $dumpvars(0, sr_latch_tb);

        // NAND SR-latch inputs are active low.
        s_in = 1'b0;
        r_in = 1'b1;
        #1;
        check(1'b1, "set input drives output high");

        s_in = 1'b1;
        r_in = 1'b1;
        #1;
        check(1'b1, "hold high state");

        s_in = 1'b1;
        r_in = 1'b0;
        #1;
        check(1'b0, "reset input drives output low");

        s_in = 1'b1;
        r_in = 1'b1;
        #1;
        check(1'b0, "hold low state");

        $display("SR_Latch test completed successfully");
        $finish;
    end
endmodule