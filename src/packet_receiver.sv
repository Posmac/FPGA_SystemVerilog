`timescale 1ns / 1ps

import architecture_types::*;
import uart_types::*;
import packet_types::*;
import packet_recv_types::*;
import command_types::*;

typedef enum logic [1:0] { 
    RECV_CMD, 
    RECV_LEN,
    RECV_ARG_1,
    RECV_ARG_2
} packet_receiver_state_t;

module packet_receiver(
    input   packet_recv_input_struct_t  in,
    output  packet_recv_output_struct_t out
);
    packet_t                    incoming_packet;
    packet_receiver_state_t     current_state = RECV_CMD;
    logic[3:0]                  current_recv_byte = 4'd0;

    //FLOW: 

    // UART
    //  ↓
    // Packet Decoder
    //  ↓
    // Command Dispatcher
    //  ↓
    // +-----+-----+-----+-----+
    // | ALU | CPU | RAM | GPIO|
    // +-----+-----+-----+-----+
    //  ↓
    // UART

    always_ff @(posedge in.clk or negedge in.rst_n) begin
        if (!in.rst_n) begin
            current_state       <= RECV_CMD;
            current_recv_byte   <= 4'd0;
            out.is_done         <= 1'b0;
        end begin
            if (out.is_done) begin
                out.is_done <= 1'b0;
            end

            unique case(current_state)
                RECV_CMD: begin
                    if (in.can_read) begin
                        current_state <= RECV_LEN;
                        incoming_packet.cmd <= command_t'(in.data[7:0]);
                        //filter shit out
                    end
                end 
                RECV_LEN: begin
                    if (in.can_read) begin
                        current_state <= RECV_ARG_1;
                        incoming_packet.len <= in.data[7:0];
                        //filter shit out
                    end
                end
                RECV_ARG_1: begin
                    if (32'(current_recv_byte) < ARG_1_SIZE) begin
                        if (in.can_read) begin
                            incoming_packet.arg0[current_recv_byte * 8 +: 8] <= in.data[7:0];
                            current_recv_byte <= current_recv_byte + 1;
                        end
                    end else begin
                        current_state <= RECV_ARG_2;
                        current_recv_byte <= 4'd0;
                    end
                end
                RECV_ARG_2: begin
                    if (32'(current_recv_byte) < ARG_2_SIZE) begin
                        if (in.can_read) begin
                            incoming_packet.arg1[current_recv_byte * 8 +: 8] <= in.data[7:0];
                            current_recv_byte <= current_recv_byte + 1;
                        end
                    end else begin
                        current_state <= RECV_CMD;
                        current_recv_byte <= 4'd0;
                        out.is_done <= 1'b1;
                        $strobe("Received data: CMD: %b, LEN: %b, ARG1: %b, ARG2: %b", incoming_packet.cmd, incoming_packet.len, incoming_packet.arg0, incoming_packet.arg1);
                    end
                end
            endcase
            
        end
    end

endmodule