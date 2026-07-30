`timescale 1ns / 1ps

module full_adder_tb;

    logic tb_a;
    logic tb_b;
    logic tb_c_in;
    logic tb_sum;
    logic tb_carry_out;

    logic exp_sum;
    logic exp_carry;
    int i;

    FULL_ADDER_logic dut (
        .a_in         (tb_a),
        .b_in         (tb_b),
        .c_in         (tb_c_in),
        .half_sum_out (tb_sum),
        .carry_out    (tb_carry_out)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, full_adder_tb);

        $display("----------------------------------------------------------------");
        $display(" SYSTEM TEST FOR FULL ADDER (ALL 8 COMBINATIONS)");
        $display("----------------------------------------------------------------");

        for (i = 0; i < 8; i = i + 1) begin
            
            tb_a    = i[2]; // Старший бит числа
            tb_b    = i[1]; // Средний бит
            tb_c_in = i[0]; // Младший бит

            #10;

            {exp_carry, exp_sum} = tb_a + tb_b + tb_c_in;

            if (tb_sum !== exp_sum || tb_carry_out !== exp_carry) begin
                $error("❌ FAIL: A=%b B=%b C_IN=%b | Got Sum=%b Carry=%b | Expected Sum=%b Carry=%b",
                       tb_a, tb_b, tb_c_in, tb_sum, tb_carry_out, exp_sum, exp_carry);
            end else begin
                $display("✅ Success FULL_ADDER: A=%b, B=%b, C_IN=%b | Sum = %b, Carry = %b", 
                         tb_a, tb_b, tb_c_in, tb_sum, tb_carry_out);
            end
        end

        $display("----------------------------------------------------------------");
        $display(" FULL ADDER TESTING COMPLETE!");
        $display("----------------------------------------------------------------");
        $finish;
    end

endmodule
