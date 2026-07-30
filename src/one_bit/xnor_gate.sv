`timescale 1ns / 1ps

module XNOR_Gate_logic(
  input logic a_in,
  input logic b_in,
  output logic a_out
);

  always_comb begin
    a_out = ~( (a_in | b_in) & ~(a_in & b_in) );
  end
  
endmodule


module XNOR_Gate_bit(
  input bit a_in,
  input bit b_in,
  output bit a_out
);

  always_comb begin
    a_out = ~( (a_in | b_in) & ~(a_in & b_in) );
  end

endmodule
