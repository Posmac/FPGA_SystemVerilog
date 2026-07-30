`timescale 1ns / 1ps

module FULL_ADDER_logic(
  input logic a_in,
  input logic b_in,
  input logic c_in,
  output logic half_sum_out,
  output logic carry_out
);

  logic hf_sum_1;
  logic hf_carry_1;
  logic hf_carry_2;

  HALF_ADDER_logic hal_a_b(
    .a_in(a_in),
    .b_in(b_in),
    .half_sum_out(hf_sum_1),
    .carry_out(hf_carry_1)
  );

  HALF_ADDER_logic hal_final(
    .a_in(c_in),
    .b_in(hf_sum_1),
    .half_sum_out(half_sum_out),
    .carry_out(hf_carry_2)
  );
  
 //Half Sum OR Half Carry
  OR_Gate_logic hsohc(
    .a_in(hf_carry_2),
    .b_in(hf_carry_1),
    .a_out(carry_out)
  );
    
endmodule
