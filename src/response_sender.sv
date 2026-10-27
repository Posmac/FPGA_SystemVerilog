`timescale 1ns / 1ps

import architecture_types::*;
import uart_types::*;
import command_types::*;
import response_types::*;

// package response_types;
//   localparam int RESPONSE_BUFFER_SIZE = 32;

//   typedef struct packed {
//     logic [RESPONSE_BUFFER_SIZE - 1: 0][7:0]  buffer; 
//     logic [7:0]                               len;
//   } response_packet_t;

//   typedef struct packed {
//     logic               clk;
//     logic               rst_n;
//     logic               can_start_sending;
//     response_packet_t   packet;
//   } response_sender_input_struct_t;

//   typedef struct packed {
//     logic               was_sent;
//     logic               tx;
//   } response_sender_output_struct_t;

// endpackage

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
            // tx_valid <= '0;
            // byte_index <= '0;
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
                        // $display("USER: IDLE -> START");
                    end
                end
                START: begin
                    current_state <= DATA;
                    // tx_data <= in.packet.buffer[byte_index];
                    // byte_index <= byte_index + 1;
                    // $display("USER: START -> DATA");
                end
                DATA: begin
                    // current_state <= STOP;
                    // $display("USER DATA -> STOP");

                    if (tx_ready) begin
                        // if (tx_valid) begin
                            // $display("USER DATA: r=%b v=%b d=%c i=%0d",
                            //     tx_ready,
                            //     tx_valid,
                            //     tx_data,
                            //     byte_index - 1);
                        // end
                        out.is_in_progress <= '1;
                        if (byte_index >= in.packet.len) begin
                            current_state <= STOP;
                            // $display("USER DATA -> STOP");
                        end else begin
                            byte_index <= byte_index + 1;
                            tx_data <= in.packet.buffer[byte_index];
                            // tx_data <= 8'(in.packet.buffer[32'(8 * (RESPONSE_BUFFER_SIZE - 1 - 32'(byte_index))) +: 8]);
                            // $display("DATA: %02h \n", in.packet.buffer[byte_index]);
                        end
                    end
                end
                STOP: begin
                    if (tx_ready) begin
                        byte_index <= '0;
                        current_state <= IDLE;
                        out.was_sent <= '1;
                        out.is_in_progress <= '0;
                        // $display("USER: STOP -> IDLE");
                    end
                end
            endcase
        end
    end

endmodule