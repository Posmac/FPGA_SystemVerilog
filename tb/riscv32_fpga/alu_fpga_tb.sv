import architecture_types::*;
import uart_types::*;

module alu_fpga_tb();
    logic       clk;       
    logic       sim_clk = 0;   
    logic       rst_n; 

    int counter;
    int slow_counter;

    uart_input_struct_t alu_in;
    uart_output_struct_t alu_out;

    assign alu_in.rx = test_tx;
    assign alu_in.clk = sim_clk;
    // assign alu_in.sim_clk = sim_clk;
    assign alu_in.rst_n = rst_n;

    hil alu(
        .in(alu_in),
        .out(alu_out)
    );

    logic[7:0] ascii_symbols[9] = '{8'd1, 8'd2, 8'd3, 8'd4, 8'd128, 8'd255, 8'd0, 8'd67, 8'd99};

    logic[7:0]      test_tx_data;
    logic           test_tx_ready;
    logic           test_tx_valid; 
    logic           test_tx; 
    
    uart_tx #(.BAUD_RATE(BOD_115200)) uart_tx (
        .clk(sim_clk),
        .rst_n(rst_n),
        .log(0),
        .tx_data(test_tx_data),
        .tx_valid(test_tx_valid),
        .tx_ready(test_tx_ready),
        .tx(test_tx)
    );

    logic[7:0]  rx_data;
    logic       rx_ready;
    logic       rx_done;

    uart_rx #(.BAUD_RATE(BOD_921600)) uart_rx (
        .clk(sim_clk),
        .rst_n(rst_n),
        .rx(alu_out.tx),
        .can_receive(alu.response_prepared),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rx_done(rx_done)
    );

    always #1 clk = ~clk;

    initial begin
        $dumpfile("uart_dump.vcd");
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
        if (!rst_n) begin
            counter <= '0;
            sim_clk <= 1'b0;
        end else begin
            counter <= counter + 1;
            if (counter >= 5) begin
                counter <= '0;
                sim_clk <= ~sim_clk; 
            end 
            // if (rx_done) begin
            //     $display("RX: %b", rx_done);
            // end
        end
    end

    always_ff @(posedge sim_clk) begin
        if (rst_n) begin
            slow_counter <= slow_counter + 1;
            if (slow_counter >= 0) begin
                if (test_tx_ready && !test_tx_valid) begin
                    test_tx_valid <= 1'b1; 
                    test_tx_data <= ascii_symbols[$urandom_range(8, 0)];
                end else if (test_tx_valid) begin
                    test_tx_valid <= 1'b0;
                end
            end else begin
                test_tx_valid <= 1'b0;
            end

            if (rx_done == 1'b1) begin
                $display("Received: %02h", rx_data);
            end
        end
    end

endmodule
