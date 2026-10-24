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
    logic[7:0]  rx_data;
    logic       rx_ready;
    logic       rx_done;

    uart_rx #(.BAUD_RATE(BOD_115200)) uart_rx (
        .clk(in.clk),
        .rst_n(in.rst_n),
        .rx(in.rx),
        .can_receive(1'b1),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rx_done(rx_done)
    );

    packet_recv_input_struct_t          packet_recv_in;
    assign packet_recv_in.clk =         in.clk;
    assign packet_recv_in.rst_n =       in.rst_n;
    assign packet_recv_in.can_read =    uart_rx.rx_done;
    assign packet_recv_in.data =        uart_rx.rx_data;

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

    logic               response_prepared;
    response_packet_t   response;

    always_ff @(posedge in.clk or negedge in.rst_n) begin
        if (!in.rst_n) begin
        end begin
            if(response_sender_out.was_sent) begin
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
                        response.len      <= 8'd16; // Полезная длина пакета

                        // 1. Полностью очищаем весь 32-байтный буфер
                        response.buffer   <= '0;

                        // 2. Заполняем буфер линейно (слева направо, от 0 до 15)
                        // Байты 0..2: Заголовок пакета
                        response.buffer[0]  <= command_types::CMD_ALU_EXEC;
                        response.buffer[1]  <= 8'd16;
                        response.buffer[2]  <= 8'h00; // Статус (OK)

                        // // Байты 3..6: Вход А (Big-Endian — старший байт улетит первым)
                        response.buffer[3]  <= commands_dispatcher_out.alu_packet.a_in[31:24];
                        response.buffer[4]  <= commands_dispatcher_out.alu_packet.a_in[23:16];
                        response.buffer[5]  <= commands_dispatcher_out.alu_packet.a_in[15:8];
                        response.buffer[6]  <= commands_dispatcher_out.alu_packet.a_in[7:0];

                        // // Байты 7..10: Вход B (Big-Endian)
                        response.buffer[7]  <= commands_dispatcher_out.alu_packet.b_in[31:24];
                        response.buffer[8]  <= commands_dispatcher_out.alu_packet.b_in[23:16];
                        response.buffer[9]  <= commands_dispatcher_out.alu_packet.b_in[15:8];
                        response.buffer[10] <= commands_dispatcher_out.alu_packet.b_in[7:0];

                        // // Байты 11..14: Результат вычисления ALU (Big-Endian)
                        response.buffer[11] <= a_out[31:24];
                        response.buffer[12] <= a_out[23:16];
                        response.buffer[13] <= a_out[15:8];
                        response.buffer[14] <= a_out[7:0];

                        // // Байт 15: Хвост пакета / Резерв
                        response.buffer[15] <= 8'h00;
                        $display("Response was prepared, sending");
                        // Байты с 16 по 31 останутся нулевыми и не отправятся,
                        // так как отправитель выйдет из цикла по условию (byte_index >= 16)

                        $display("ALU Result: %d(%b):%d(%b) = %d(%b)", 
                                commands_dispatcher_out.alu_packet.a_in, commands_dispatcher_out.alu_packet.a_in, 
                                commands_dispatcher_out.alu_packet.b_in, commands_dispatcher_out.alu_packet.b_in, 
                                a_out, a_out);
                    end
                    default: begin
                        response.len <= '0;
                    end
                endcase
            end
        end
    end

    response_sender_input_struct_t                      response_sender_in;
    assign response_sender_in.clk =                     in.clk;
    assign response_sender_in.rst_n =                   in.rst_n;
    assign response_sender_in.can_start_sending =       response_prepared;
    assign response_sender_in.packet =                  response; 

    response_sender_output_struct_t                     response_sender_out;
    assign out.tx = response_sender_out.tx;

    response_sender#(.BAUD_RATE(BOD_921600)) response_sender(
        .in     (response_sender_in),
        .out    (response_sender_out)
    );

    //LOGGING
    always_ff @(posedge in.clk or negedge in.rst_n) begin
        if (!in.rst_n) begin
        end begin
            // if (response_prepared) begin
            // end
            if (response_sender_out.was_sent) begin
                $display("=== [TX PACKET SENT] ===");
                $display("Type/Cmd: 0x%02h", response.buffer[0]);
                $display("Length:   %0d bytes", response.len);
                // $display("Buffer: %b", response.buffer);
                $write("Raw Data: ");
                for (int i = 0; i < response.len; i++) begin
                    $write("%02h ", response.buffer[i]);
                end
                $display("\n========================\n");
            end

        end
    end

endmodule