// Register ABI Name Description Saver
// x0 zero Zero constant —
// x1 ra Return address Callee
// x2 sp Stack pointer Callee
// x3 gp Global pointer —
// x4 tp Thread pointer —
// x5-x7 t0-t2 Temporaries Caller
// x8 s0 / fp Saved / frame pointer Callee
// x9 s1 Saved register Callee
// x10-x11 a0-a1 Fn args/return values Caller
// x12-x17 a2-a7 Fn args Caller
// x18-x27 s2-s11 Saved registers Callee
// x28-x31 t3-t6 Temporaries Caller
// f0-7 ft0-7 FP temporaries Caller
// f8-9 fs0-1 FP saved registers Callee
// f10-11 fa0-1 FP args/return values Caller
// f12-17 fa2-7 FP args Caller
// f18-27 fs2-11 FP saved registers Callee
// f28-31 ft8-11 FP temporaries Caller

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


`timescale 1ns / 1ps

import constants::*;

module Register_File(
    input logic                             clk,
    input logic                             rst_in,
    input logic[4:0]                        raddr1,
    input logic[4:0]                        raddr2,

    input logic[4:0]                        waddr,
    input logic[ARCHITECTURE_WIDTH - 1: 0]  wdata,
    input logic                             we,

    output logic[ARCHITECTURE_WIDTH - 1: 0] rdata1,
    output logic[ARCHITECTURE_WIDTH - 1: 0] rdata2
);
    //convert we for waddr to array of we bus
    logic [31:0] load_en_bus;
    logic [ARCHITECTURE_WIDTH - 1: 0] decoded_waddr; // 0 - 31 integer representing one of the registers
    Decoder_5_to_32 we_decoder(
        .a_in(waddr),
        .a_out(decoded_waddr)
    );
    assign load_en_bus = decoded_waddr & {32{we}};

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
    assign rdata1 = registers_out[raddr1];
    assign rdata2 = registers_out[raddr2];
endmodule


