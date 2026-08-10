// +-----------------------------------+
//                   |           Register_File           |
//                   |                                   |
//    clk ---------->|                                   |
//    rst_n -------->|                                   |
//                   |                                   |
//    -- Порт чтения 1 (RS1) --                          |
//    raddr1[4:0] -->|                                   |----> rdata1[31:0]
//                   |                                   |
//    -- Порт чтения 2 (RS2) --                          |
//    raddr2[4:0] -->|                                   |----> rdata2[31:0]
//                   |                                   |
//    -- Порт записи (RD) --                             |
//    waddr[4:0] --->|                                   |
//    wdata[31:0] -->|                                   |
//    we (write_en) ->|                                   |
//                   +-----------------------------------+

// CLK	=====>	"REG
// FILE"					
// RST_IN	=====>						
// INSTRUCTION	RADDR1						
// 	RADDR2						
// 	WADDR						
// WDATA	=====>						
// WE	=====>						
							
							
// 						=====>	RDATA1
// 						=====>	RDATA2

`timescale 1ns / 1ps

import constants::*;

module Register_File(
    input logic                             clk,
    input logic                             rst_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  instruction;

    input logic[ARCHITECTURE_WIDTH - 1: 0]  wdata,
    input logic                             write_enabled,

    output logic[ARCHITECTURE_WIDTH - 1: 0] rdata1,
    output logic[ARCHITECTURE_WIDTH - 1: 0] rdata2
);
    logic addr1 = instruction[19:15];
    logic addr2 = instruction[24-20];
    logic waddr = instruction[11:7];

    //convert write_enabled for waddr to array of write_enabled bus
    logic [31:0] load_en_bus;
    logic [ARCHITECTURE_WIDTH - 1: 0] decoded_waddr; // 0 - 31 integer representing one of the registers
    Decoder_5_to_32 we_decoder(
        .a_in(waddr),
        .a_out(decoded_waddr)
    );
    assign load_en_bus = decoded_waddr & {32{write_enabled}};

    logic[ARCHITECTURE_WIDTH-1:0] registers_out [0:31];

    //generate register files
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

    assign registers_out[0] = '0;
    assign rdata1 = registers_out[addr1];
    assign rdata2 = registers_out[addr2];
endmodule


