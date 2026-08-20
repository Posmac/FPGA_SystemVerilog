`timescale 1ns / 1ps

import constants::*;

module Register_File(
    input logic                             clk,
    input logic                             rst_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  instruction,

    input logic[ARCHITECTURE_WIDTH - 1: 0]  wdata,
    input logic                             write_enabled,

    output logic[ARCHITECTURE_WIDTH - 1: 0] rdata1,
    output logic[ARCHITECTURE_WIDTH - 1: 0] rdata2
);
    // 1. Используем честный assign для непрерывной связки адресов
    logic [4:0] addr1;
    logic [4:0] addr2;
    logic [4:0] waddr;

    assign addr1 = instruction[19:15];
    assign addr2 = instruction[24:20];
    assign waddr = instruction[11:7];

    // 2. Явно задаем 32-битный вектор для выхода декодера
    logic [31:0] decoded_waddr;
    logic [31:0] load_en_bus;

    Decoder_5_to_32 we_decoder(
        .a_in(waddr),
        .a_out(decoded_waddr)
    );

    // Маскируем маску разрешения записи
    assign load_en_bus = decoded_waddr & {32{write_enabled}};

    logic [ARCHITECTURE_WIDTH-1:0] registers_out [0:31];

    // Генерация 31 регистра (x1..x31)
    genvar r;
    generate
        for (r = 1; r < 32; r = r + 1) begin : reg_file_gen
            Register_multi reg_inst (
                .clk    (clk),
                .rst_in (rst_in),
                .load_in(load_en_bus[r]), 
                .d_in   (wdata),
                .q_out  (registers_out[r])
            );               
        end
    endgenerate

    // x0 всегда жестко привязан к 0
    assign registers_out[0] = '0;

    // Комбинационное чтение через мультиплексор
    assign rdata1 = registers_out[addr1];
    assign rdata2 = registers_out[addr2];

endmodule