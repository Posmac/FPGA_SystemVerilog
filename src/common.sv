`timescale 1ns / 1ps

import architecture_types::*;
import uart_types::*;
import packet_types::*;
import packet_recv_types::*;
import packet_validator_types::*;
import commands_dispatcher_types::*;
import response_types::*;

// UART RX
//  ↓
// Packet Receiver
//  ↓
// Packet Decoder/Validator
//  ↓
// Command dispatcher
//  ↓
// +-----+-----+-----+-----+
// | ALU | CPU | RAM | GPIO|
// +-----+-----+-----+-----+
//  ↓
// UART TX

module common(
    input   uart_input_struct_t  in,
    output  uart_output_struct_t out
);
    uart_cpu_debug uart(
        .clk    (in.clk),
        .rst_n  (in.rst_n),
        .rx     (in.rx),
        .tx     (out.tx)
    );

    packet_recv_input_struct_t          packet_recv_in;
    assign packet_recv_in.clk =         in.clk;
    assign packet_recv_in.rst_n =       in.rst_n;
    assign packet_recv_in.can_read =    uart.rx_done;
    assign packet_recv_in.data =        uart.rx_data;

    packet_recv_output_struct_t         packet_recv_out;
 
    packet_receiver recv(
        .in     (packet_recv_in),
        .out    (packet_recv_out)
    );

    packet_validator_input_struct_t             packet_validator_in;
    assign packet_validator_in.clk =            in.clk;
    assign packet_validator_in.rst_n =          in.rst_n;
    assign packet_validator_in.can_validate =   packet_recv_out.is_done;
    assign packet_validator_in.packet =         recv.incoming_packet;

    packet_validator_output_struct_t            packet_validator_out;

    packet_validator validator(
        .in     (packet_validator_in),
        .out    (packet_validator_out)
    );

    commands_dispatcher_input_struct_t          commands_dispatcher_in;
    assign commands_dispatcher_in.clk =         in.clk;
    assign commands_dispatcher_in.rst_n =       in.rst_n;
    assign commands_dispatcher_in.packet =      recv.incoming_packet;
    assign commands_dispatcher_in.is_valid =    packet_validator_out.is_valid;

    commands_dispatcher_output_struct_t         commands_dispatcher_out;

    commands_dispatcher dispatcher(
        .in     (commands_dispatcher_in),
        .out    (commands_dispatcher_out)
    );

    logic [ARCHITECTURE_WIDTH - 1: 0]    a_out;
    logic [ARCHITECTURE_WIDTH - 1: 0]    slt_out;
    logic [ARCHITECTURE_WIDTH - 1: 0]    sltu_out;

    Alu_Unit alu(
        .a_in       (commands_dispatcher_out.alu_packet.a_in),
        .b_in       (commands_dispatcher_out.alu_packet.b_in),
        .op_in      (commands_dispatcher_out.alu_packet.op_in),
        .a_out      (a_out),
        .slt_out    (slt_out),
        .sltu_out   (sltu_out)
    );

    logic   response_prepared;
    always_ff @(posedge in.clk or negedge in.rst_n) begin
        if (!in.rst_n) begin
        end begin
            if(response_prepared) begin
                response_prepared <= 1'b0;
            end

            if (commands_dispatcher_out.is_dispatched) begin
                unique case(commands_dispatcher_out.command) 
                    command_types::NONE: begin
                    end
                    command_types::CMD_PING: begin
                    end
                    command_types::CMD_ALU_EXEC: begin
                        response_prepared <= 1'b1;
                        // $display("ALU Result: %d", a_out);
                    end
                    default: begin
                    end
                endcase
            end
        end
    end

    response_sender_input_struct_t          response_sender_in;
    assign response_sender_in.clk =         in.clk;
    assign response_sender_in.rst_n =       in.rst_n;
    assign response_sender_in.can_send =    commands_dispatcher_out.is_dispatched;
    // assign response_sender_in.packet 

    response_sender_output_struct_t         response_sender_out;
    //was_sent  

    response_sender response_sender(
        .in     (response_sender_in),
        .out    (response_sender_out)
    );

    //LOGGING
    // always_ff @(posedge in.clk or negedge in.rst_n) begin
    //     if (!in.rst_n) begin
    //     end begin
    //         if (packet_validator_out.is_valid) begin
    //             // $strobe("Received data: CMD: %b, LEN: %b, ARG1: %b, ARG2: %b", recv.incoming_packet.cmd, recv.incoming_packet.len, recv.incoming_packet.arg0, recv.incoming_packet.arg1);
    //         end
    //     end
    // end

endmodule