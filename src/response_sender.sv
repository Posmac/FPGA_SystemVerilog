`timescale 1ns / 1ps

import architecture_types::*;
import uart_types::*;
import command_types::*;
import response_types::*;

module response_sender #(
    BAUD_RATE = DEFAULT_BAUD_RATE
) (
    input response_sender_input_struct_t    in,
    output response_sender_output_struct_t  out
);
    typedef enum logic [1:0] { IDLE, START, DATA, STOP } response_sender_state_t;

    response_sender_state_t current_state = IDLE;

    logic[7:0]              tx_data = '0;
    logic                   tx_ready;
    logic[7:0]              byte_index = '0;

    uart_tx #(.BAUD_RATE(BAUD_RATE)) uart(
        .clk(in.clk),
        .rst_n(in.rst_n),
        .log(1'b0),
        .tx_valid(out.is_in_progress),
        .tx_data(tx_data),
        .tx_ready(tx_ready),
        .tx(out.tx)
    );

    always_ff @(posedge in.clk) begin
        if (!in.rst_n) begin
            current_state <= IDLE;
            out.was_sent <= '0;
            out.is_in_progress <= '0;
        end else begin
            if (out.was_sent) begin
                out.was_sent <= '0;
            end

            unique case (current_state)
                IDLE: begin
                    out.was_sent <= '0;
                    out.is_in_progress <= '0;
                    if (in.can_start_sending && !out.was_sent && tx_ready) begin
                        current_state <= START;
                        byte_index <= '0;
                    end
                end
                START: begin
                    current_state <= DATA;
                end
                DATA: begin
                    if (tx_ready) begin
                        out.is_in_progress <= '1;
                        if (byte_index >= in.packet.len) begin
                            current_state <= STOP;
                        end else begin
                            byte_index <= byte_index + 1;
                            tx_data <= in.packet.buffer[byte_index];
                        end
                    end
                end
                STOP: begin
                    if (tx_ready) begin
                        byte_index <= '0;
                        current_state <= IDLE;
                        out.was_sent <= '1;
                        out.is_in_progress <= '0;
                    end
                end
            endcase
        end
    end

endmodule