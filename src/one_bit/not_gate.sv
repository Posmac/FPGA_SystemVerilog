`timescale 1ns / 1ps

module NOT_Gate_logic(
  input logic a_in,
  output logic a_out
);

  always_comb begin
    a_out = ~a_in;
  end

endmodule


module NOT_Gate_bit(
  input bit a_in,
  output bit a_out
);

  always_comb begin
    a_out = ~a_in;
  end

endmodule
