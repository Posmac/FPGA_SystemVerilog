import ecp_types::*;
import uart_types::*;

module uart_cpu_debug
(
    input logic         clk,
    input logic         rst_n,
    input logic         rx,
    output logic        tx
);
    logic[7:0]  rx_data;
    logic       rx_ready;
    logic       rx_done;
    
    logic[7:0]  tx_data;
    logic       tx_valid = 1'b0;
    logic       tx_ready;

    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) begin
    //         tx_data  <= 8'b0;
    //     end else begin
    //         if (rx_ready && tx_ready && rx) begin
    //             $display("Data: %h -> %h", rx_data, rx_data, tx_data, tx_data);
    //             // tx_data <= rx_data + 1;
    //             tx_valid <= 1'b1;
    //         end else begin
    //             tx_valid <= 1'b0;
    //         end
    //     end
    // end

    // uart_tx #(
    //     .CLK_FREQ(CLK_FREQ),
    //     .BAUD_RATE(BAUD_RATE)
    // ) uart_tx (
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .log(1'b0),
    //     .tx_data(tx_data),
    //     .tx_valid(tx_valid),
    //     .tx_ready(tx_ready),
    //     .tx(tx)
    // );
 
    uart_rx uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rx_done(rx_done)
    );
endmodule