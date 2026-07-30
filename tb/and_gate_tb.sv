`timescale 1ns / 1ps

module ang_gate_tb;
  logic tb_a_in_logic;
  logic tb_b_in_logic;
  logic tb_a_out_logic;
  
  bit tb_a_in_bit;
  bit tb_b_in_bit;
  bit tb_a_out_bit;
  
  AND_Gate_logic agl (
    .a_in(tb_a_in_logic),
    .b_in(tb_b_in_logic),
    .a_out(tb_a_out_logic)
  );
  
  AND_Gate_bit agb (
    .a_in(tb_a_in_bit),
    .b_in(tb_b_in_bit),
    .a_out(tb_a_out_bit)
  );
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, agl);
    $dumpvars(1, agb);
    
    $display("---------------------------------------");
    $display("SYSTEM TEST FOR AND GATES (LOGIC AND BIT)");
	$display("---------------------------------------");
	
    $display("Initial state for AND logic: A = %b, B = %b, OUT = %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic);
    $display("Initial state for AND bit: A = %b, B = %b, OUT = %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit);
    #10;
    
    tb_a_in_logic = 1;
    tb_b_in_logic = 0;
    tb_a_in_bit = 1;
    tb_b_in_bit = 0;
    #10
    
    if (tb_a_out_logic !== 1'b0) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic, 1'b0);
    end
    if (tb_a_out_bit !== 1'b0) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit, 1'b0);
    end
    
    $display("Success AND logic: A = %b, B = %b, OUT = %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic);
    $display("Success AND bit: A = %b, B = %b, OUT = %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit);
    
    tb_a_in_logic = 0;
    tb_b_in_logic = 1;
    tb_a_in_bit = 0;
    tb_b_in_bit = 1;
    #10
    
    if (tb_a_out_logic !== 1'b0) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic, 1'b0);
    end
    if (tb_a_out_bit !== 1'b0) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit, 1'b0);
    end
    
    $display("Success AND logic: A = %b, B = %b, OUT = %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic);
    $display("Success AND bit: A = %b, B = %b, OUT = %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit);
    
    
    tb_a_in_logic = 1;
    tb_b_in_logic = 1;
    tb_a_in_bit = 1;
    tb_b_in_bit = 1;
    #10
    
    if (tb_a_out_logic !== 1'b1) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic, 1'b1);
    end
    if (tb_a_out_bit !== 1'b1) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit, 1'b1);
    end
    
    $display("Success AND logic: A = %b, B = %b, OUT = %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic);
    $display("Success AND bit: A = %b, B = %b, OUT = %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit);
    
    tb_a_in_logic = 0;
    tb_b_in_logic = 0;
    tb_a_in_bit = 0;
    tb_b_in_bit = 0;
    #10
    
    if (tb_a_out_logic !== 1'b0) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic, 1'b0);
    end
    if (tb_a_out_bit !== 1'b0) begin
      $error("Error in AND logic gate for A = %b, B = %b. Wrong output OUT = %b. Expected: %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit, 1'b0);
    end
    
    $display("Success AND logic: A = %b, B = %b, OUT = %b", tb_a_in_logic, tb_b_in_logic, tb_a_out_logic);
    $display("Success AND bit: A = %b, B = %b, OUT = %b", tb_a_in_bit, tb_b_in_bit, tb_a_out_bit);
    $finish
    
  end
  
endmodule

