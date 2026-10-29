import architecture_types::*;
import uart_types::*;

module alu_fpga_tb();
    logic       clk;       
    logic       rst_n; 

    uart_input_struct_t alu_in;
    uart_output_struct_t alu_out;

    hil alu(
        .clk(clk),
        .tx(test_tx),
        .rx()
    );

    logic[7:0] ascii_symbols[9] = '{8'd1, 8'd2, 8'd3, 8'd4, 8'd128, 8'd255, 8'd0, 8'd67, 8'd99};

    logic[7:0]      test_tx_data;
    logic           test_tx_ready;
    logic           test_tx_valid; 
    logic           test_tx; 
    
    uart_tx #(.BAUD_RATE(BOD_115200)) uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .log(0),
        .tx_data(test_tx_data),
        .tx_valid(test_tx_valid),
        .tx_ready(test_tx_ready),
        .tx(test_tx)
    );

    // logic[7:0]  rx_data;
    // logic       rx_ready;
    // logic       rx_done;
    // logic       rx;
    

    // uart_rx #(.BAUD_RATE(BOD_921600)) uart_rx (
    //     .clk(sim_clk),
    //     .rst_n(rst_n),
    //     .rx(rx),
    //     .can_receive(1'b1),
    //     .rx_data(rx_data),
    //     .rx_ready(rx_ready),
    //     .rx_done(rx_done)
    // );

    // always #1 clk = ~clk;
    always #20 clk = ~clk; 

    initial begin
        $dumpfile("response_sender.vcd");
        $dumpvars(0, top_uart_tb); 

        $display("---------------------------------------");
        $display("Starting uart testing suite");
        $display("---------------------------------------");

        clk = 1'b0;
        rst_n = 1'b0;

        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        $display("RESET RELEASED. Executing...");
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            test_tx_valid <= 1'b1; 
            if (test_tx_ready) begin
                test_tx_data <= $urandom_range(255, 1)[7:0];
                $strobe("Data sent");
            end
        end
    end

endmodule
