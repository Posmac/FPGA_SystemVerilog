`timescale 1ns / 1ps

module HALF_ADDER_logic(
  input logic a_in,
  input logic b_in,
  output logic half_sum_out,
  output logic carry_out
);

  AND_Gate_logic agl(
    .a_in(a_in),
    .b_in(b_in),
    .a_out(carry_out)
  );

  XOR_Gate_logic xgl(
    .a_in(a_in),
    .b_in(b_in),
    .a_out(half_sum_out)
  );
  
endmodule
