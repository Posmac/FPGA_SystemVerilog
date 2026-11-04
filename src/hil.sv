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

module hil(
      input logic clk,
    //   input logic sim_clk,
    //   input logic rst_n,
      input logic uart_gpio_rx, //tx from external UART
      output logic uart_gpio_tx //rx to external UART
    // input   uart_input_struct_t  in,
    // output  uart_output_struct_t out
);
    logic rst_n;
    assign rst_n = 1'b1;

    // ///
    response_sender_output_struct_t                     response_sender_out;
    assign uart_gpio_tx = response_sender_out.tx;
    ///

    ///
    logic[7:0]  rx_data;
    logic       rx_ready;
    logic       rx_done;

    uart_rx #(.BAUD_RATE(BOD_115200)) uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_gpio_rx),
        .can_receive(!response_sender_out.is_in_progress),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .rx_done(rx_done)
    );
    ///

    ///
    packet_recv_input_struct_t          packet_recv_in;
    assign packet_recv_in.clk =         clk;
    assign packet_recv_in.rst_n =       rst_n;
    assign packet_recv_in.can_read =    rx_done;
    assign packet_recv_in.data =        uart_rx.rx_data;

    packet_recv_output_struct_t         packet_recv_out;
 
    packet_receiver recv(
        .in     (packet_recv_in),
        .out    (packet_recv_out)
    );

    packet_validator_input_struct_t             packet_validator_in;
    assign packet_validator_in.clk =            clk;
    assign packet_validator_in.rst_n =          rst_n;
    assign packet_validator_in.can_validate =   packet_recv_out.is_done;
    assign packet_validator_in.packet =         recv.incoming_packet;

    packet_validator_output_struct_t            packet_validator_out;

    packet_validator validator(
        .in     (packet_validator_in),
        .out    (packet_validator_out)
    );

    commands_dispatcher_input_struct_t          commands_dispatcher_in;
    assign commands_dispatcher_in.clk =         clk;
    assign commands_dispatcher_in.rst_n =       rst_n;
    assign commands_dispatcher_in.packet =      validator.packet;
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

    always_ff @(posedge clk) begin
        // if(!rsn_n) begin
        // end begin
            response_prepared <= 1'b0;

            if (commands_dispatcher_out.is_dispatched) begin
                // $display("Ready");
                response_prepared <= 1'b1;
                response.len          <= 8'd16;
 
                // response.buffer[0]    <= "R"; // 'R'
                // response.buffer[1]    <= "E"; // 'E'
                // response.buffer[2]    <= ":"; // 'S'
                // response.buffer[3]    <= " "; // 'P'
                // response.buffer[4]    <= "R";
                // response.buffer[5]    <= "R";

                // response.buffer[6]    <= "R"; // Младший байт идет первым
                // response.buffer[7]    <= "R";
                // response.buffer[8]    <= "R";
                // response.buffer[9]    <= "R"; // Старший байт идет последним

                // response.buffer[10]   <= "R";               
                // response.buffer[11]   <= "R";
                // response.buffer[12]   <= "R";
                // response.buffer[13]   <= "R";
                
                // response.buffer[14]   <= 8'h0A; // '\n' (Line Feed - перенос строки)
                // response.buffer[15]   <= 8'h0D; // '\r' (Carriage Return - возврат каретки)

                // response_prepared <= 1'b1;
                // unique case(commands_dispatcher_out.command) 
                //     command_types::NONE: begin
                //         response.len      <= 8'd2; 
                //         response.buffer   <= '1;
                //     end
                //     command_types::CMD_PING: begin
                //         response.len      <= 8'd2; 
                //         response.buffer   <= '1;
                //     end
                //     command_types::CMD_ALU_EXEC: begin
                //         response_prepared <= 1'b1;
                //         response.len      <= 8'd16; // Полезная длина пакета

                        // 1. Полностью очищаем весь 32-байтный буфер
                        // response.buffer   <= '1;

                        // 2. Заполняем буфер линейно (слева направо, от 0 до 15)
                        // Байты 0..2: Заголовок пакета
                        response.buffer[0]  <= 8'd2;
                        response.buffer[1]  <= 8'd16;

                        // Байты 3..6: Вход А (Big-Endian — старший байт улетит первым)
                        response.buffer[2]  <= commands_dispatcher_out.alu_packet.a_in[31:24];
                        response.buffer[3]  <= commands_dispatcher_out.alu_packet.a_in[23:16];
                        response.buffer[4]  <= commands_dispatcher_out.alu_packet.a_in[15:8];
                        response.buffer[5]  <= commands_dispatcher_out.alu_packet.a_in[7:0];

                        response.buffer[6]    <= "R"; // Младший байт идет первым
                        response.buffer[7]    <= "R";
                        response.buffer[8]    <= "R";
                        response.buffer[9]    <= "R"; // Старший байт идет последним

                        // // // Байты 7..10: Вход B (Big-Endian)
                        // response.buffer[6]  <= commands_dispatcher_out.alu_packet.b_in[31:24];
                        // response.buffer[7]  <= commands_dispatcher_out.alu_packet.b_in[23:16];
                        // response.buffer[8]  <= commands_dispatcher_out.alu_packet.b_in[15:8];
                        // response.buffer[9]  <= commands_dispatcher_out.alu_packet.b_in[7:0];

                        // // // Байты 11..14: Результат вычисления ALU (Big-Endian)
                        response.buffer[10] <= a_out[31:24];
                        response.buffer[11] <= a_out[23:16];
                        response.buffer[12] <= a_out[15:8];
                        response.buffer[13] <= a_out[7:0];

                        // // Байт 15: Хвост пакета / Резерв
                        response.buffer[14]   <= 8'h0A; // '\n' (Line Feed - перенос строки)
                        response.buffer[15]   <= 8'h0D; // '\r' (Carriage Return - возврат каретки)
                        // $display("Response was prepared, sending");
                        // // Байты с 16 по 31 останутся нулевыми и не отправятся,
                        // // так как отправитель выйдет из цикла по условию (byte_index >= 16)

                        // $display("ALU Result: %d(%b):%d(%b) = %d(%b)", 
                        //         commands_dispatcher_out.alu_packet.a_in, commands_dispatcher_out.alu_packet.a_in, 
                        //         commands_dispatcher_out.alu_packet.b_in, commands_dispatcher_out.alu_packet.b_in, 
                        //         a_out, a_out);
                    // end
                    // default: begin
                    //     response.len      <= 8'd2; 
                    //     response.buffer   <= '1;
                    // end
                // endcase
            end
        // end
    end

    response_sender_input_struct_t                      response_sender_in;
    assign response_sender_in.clk =                     clk;
    assign response_sender_in.rst_n =                   rst_n;
    assign response_sender_in.can_start_sending =       response_prepared;
    assign response_sender_in.packet =                  response; 

    response_sender#(.BAUD_RATE(BOD_115200)) response_sender(
        .in     (response_sender_in),
        .out    (response_sender_out)
    );
endmodule