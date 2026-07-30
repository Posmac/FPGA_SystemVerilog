`timescale 1ns / 1ps

import constants::*;

module FULL_ADDER_Multi_logic(
  input logic[ARCHITECTURE_WIDTH - 1:0] a_in,
  input logic[ARCHITECTURE_WIDTH - 1:0] b_in,
  input logic                           c_in,

  output logic[ARCHITECTURE_WIDTH - 1:0] hf_out,
  output logic                           carry_out
);

    logic[ARCHITECTURE_WIDTH - 1:0] carry_inter;
    
    FULL_ADDER_logic fal_1(
      .a_in(a_in[0]),
      .b_in(b_in[0]),
      .c_in(c_in),
      .half_sum_out(hf_out[0]),
      .carry_out(carry_inter[0])
    );

    genvar i;
    generate
        for (i = 1; i < ARCHITECTURE_WIDTH - 1; i = i + 1) begin : adder_loop
            FULL_ADDER_logic fal (
                .a_in         (a_in[i]),
                .b_in         (b_in[i]),
                .c_in         (carry_inter[i-1]),
                .half_sum_out (hf_out[i]),
                .carry_out    (carry_inter[i])
            );
        end
    endgenerate
      
    FULL_ADDER_logic fal_final(
      .a_in(a_in[ARCHITECTURE_WIDTH - 1]),
      .b_in(b_in[ARCHITECTURE_WIDTH - 1]),
      .c_in(carry_inter[ARCHITECTURE_WIDTH - 2]),
      .half_sum_out(hf_out[ARCHITECTURE_WIDTH - 1]),
      .carry_out(carry_out)
    );
endmodule
