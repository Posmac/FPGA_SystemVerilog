`timescale 1ns / 1ps

module SR_Latch(
    input logic s_in,
    input logic r_in,
    output logic a_out
);
    logic r_out;
    logic s_out;
    NAND_Gate_logic s(
        .a_in(s_in),
        .b_in(r_out),
        .a_out(s_out)
    );

    NAND_Gate_logic r(
        .a_in(r_in),
        .b_in(s_out),
        .a_out(r_out)
    );

    assign a_out = r_out;

endmodule