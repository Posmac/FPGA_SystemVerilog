`timescale 1ns / 1ps

import constants::*;

module program_counter_tb;
    logic clk;
    logic rst;

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name); begin
        test_count++;

    end endtask

    task tick; begin
        @(posedge clk);
        #1;
    end endtask

    initial begin
        forever begin
            #5;
            clk = ~clk;
        end
    end

    initial begin
        
    end

endmodule