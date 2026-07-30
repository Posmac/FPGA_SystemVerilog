
`timescale 1ns / 1ps

module half_sum_tb;
  logic tb_a_in_logic;
  logic tb_b_in_logic;
  logic tb_half_sum_out_logic;
  logic tb_carry_out_logic;  

  HALF_ADDER_logic hal(
    .a_in(tb_a_in_logic),
    .b_in(tb_b_in_logic),
    .half_sum_out(tb_half_sum_out_logic),
    .carry_out(tb_carry_out_logic)
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, hal);
    
    $display("---------------------------------------");
    $display("SYSTEM TEST FOR HALF SUM (LOGIC)");
	  $display("---------------------------------------");
    #10;

    //0 and 0
    tb_a_in_logic = 0;
    tb_b_in_logic = 0;
    #10
    
    if (tb_half_sum_out_logic !== 1'b0) begin
      $error("Error in HALF_ADDED 'half_sum'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, 1'b0);
    end
    if (tb_carry_out_logic !== 1'b0) begin
      $error("Error in HALF_ADDED 'carry'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_carry_out_logic, 1'b0);
    end

    $display("Success HALF_ADDED logic: A = %b, B = %b, HalfSum = %b, Carry = %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, tb_carry_out_logic);

    //1 and 0
    tb_a_in_logic = 1;
    tb_b_in_logic = 0;
    #10
    
    if (tb_half_sum_out_logic !== 1'b1) begin
      $error("Error in HALF_ADDED 'half_sum'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, 1'b1);
    end
    if (tb_carry_out_logic !== 1'b0) begin
      $error("Error in HALF_ADDED 'carry'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_carry_out_logic, 1'b0);
    end

    $display("Success HALF_ADDED logic: A = %b, B = %b, HalfSum = %b, Carry = %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, tb_carry_out_logic);

    //0 and 1
    tb_a_in_logic = 0;
    tb_b_in_logic = 1;
    #10
    
    if (tb_half_sum_out_logic !== 1'b1) begin
      $error("Error in HALF_ADDED 'half_sum'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, 1'b1);
    end
    if (tb_carry_out_logic !== 1'b0) begin
      $error("Error in HALF_ADDED 'carry'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_carry_out_logic, 1'b0);
    end

    $display("Success HALF_ADDED logic: A = %b, B = %b, HalfSum = %b, Carry = %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, tb_carry_out_logic);

    //1 and 1
    tb_a_in_logic = 1;
    tb_b_in_logic = 1;
    #10
    
    if (tb_half_sum_out_logic !== 1'b0) begin
      $error("Error in HALF_ADDED 'half_sum'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, 1'b0);
    end
    if (tb_carry_out_logic !== 1'b1) begin
      $error("Error in HALF_ADDED 'carry'. A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_carry_out_logic, 1'b1);
    end

    $display("Success HALF_ADDED logic: A = %b, B = %b, HalfSum = %b, Carry = %b", tb_a_in_logic, tb_b_in_logic, tb_half_sum_out_logic, tb_carry_out_logic);
    $finish
  end
  
endmodule

