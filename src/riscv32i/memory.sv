`timescale 1ns / 1ps

import constants::*;

module Memory_Unit #(
    parameter int MEM_SIZE_BYTES = 65536,
    parameter int NUM_WORDS      = MEM_SIZE_BYTES / 4,
    parameter string INIT_FILE   = ""
)(
    input  logic                             clk,
    input  logic                             rst_in,

    // Порт записи (Write)
    input  logic                             we,
    input  logic [ARCHITECTURE_WIDTH-1:0]    waddr,
    input  logic [ARCHITECTURE_WIDTH-1:0]    wdata,
    input  logic [2:0]                       w_op,   // 0: SB, 1: SH, 2: SW

    // Порт чтения (Read)
    input  logic [ARCHITECTURE_WIDTH-1:0]    raddr,
    input  logic [2:0]                       r_op,   // 0: LB, 1: LH, 2: LW, 3: LBU, 4: LHU

    output logic [ARCHITECTURE_WIDTH-1:0]    rdata
);

    localparam int ADDR_WIDTH = $clog2(NUM_WORDS);

    // Память объявляем 32-битными словами
    logic [31:0] mem [0:NUM_WORDS-1];

    // ------------------------------------------------------------------------
    // 1. ЗАПИСЬ (Синхронная, с поддержкой unaligned access)
    // ------------------------------------------------------------------------
    logic [ADDR_WIDTH-1:0] word_waddr;
    logic [1:0]            byte_offset_w;

    assign word_waddr    = waddr[ADDR_WIDTH+1 : 2];
    assign byte_offset_w = waddr[1:0];

    always_ff @(posedge clk) begin
        if (rst_in) begin
            for (int i = 0; i < NUM_WORDS; i++) begin
                mem[i] <= 32'h0;
            end
        end else if (we) begin
            case (w_op)
                3'd0: begin // SB (Store Byte)
                    case (byte_offset_w)
                        2'b00: mem[word_waddr][7:0]   <= wdata[7:0];
                        2'b01: mem[word_waddr][15:8]  <= wdata[7:0];
                        2'b10: mem[word_waddr][23:16] <= wdata[7:0];
                        2'b11: mem[word_waddr][31:24] <= wdata[7:0];
                    endcase
                end

                3'd1: begin // SH (Store Halfword)
                    case (byte_offset_w)
                        2'b00: mem[word_waddr][15:0]  <= wdata[15:0];
                        2'b01: mem[word_waddr][23:8]  <= wdata[15:0];
                        2'b10: mem[word_waddr][31:16] <= wdata[15:0];
                        2'b11: begin
                            mem[word_waddr][31:24] <= wdata[7:0];
/* verilator lint_off WIDTHEXPAND */
                            if (32'(word_waddr) + 1 < NUM_WORDS)
                                mem[word_waddr + 1'b1][7:0] <= wdata[15:8];
/* verilator lint_on WIDTHEXPAND */
                        end
                    endcase
                end

                3'd2: begin // SW (Store Word)
                    case (byte_offset_w)
                        2'b00: mem[word_waddr] <= wdata;
                        2'b01: begin
                            mem[word_waddr][31:8] <= wdata[23:0];
/* verilator lint_off WIDTHEXPAND */
                            if (32'(word_waddr) + 1 < NUM_WORDS)
                                mem[word_waddr + 1'b1][7:0] <= wdata[31:24];
/* verilator lint_on WIDTHEXPAND */
                        end
                        2'b10: begin
                            mem[word_waddr][31:16] <= wdata[15:0];
/* verilator lint_off WIDTHEXPAND */
                            if (32'(word_waddr) + 1 < NUM_WORDS)
                                mem[word_waddr + 1'b1][15:0] <= wdata[31:16];
/* verilator lint_on WIDTHEXPAND */
                        end
                        2'b11: begin
                            mem[word_waddr][31:24] <= wdata[7:0];
/* verilator lint_off WIDTHEXPAND */
                            if (32'(word_waddr) + 1 < NUM_WORDS)
                                mem[word_waddr + 1'b1][23:0] <= wdata[31:8];
/* verilator lint_on WIDTHEXPAND */
                        end
                    endcase
                end

                default: ;
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // 2. ЧТЕНИЕ (Асинхронный 64-битный слайсер для unaligned)
    // ------------------------------------------------------------------------
    logic [ADDR_WIDTH-1:0] word_raddr;
    logic [1:0]            byte_offset_r;

    assign word_raddr    = raddr[ADDR_WIDTH+1 : 2];
    assign byte_offset_r = raddr[1:0];

    logic [31:0] current_word;
    logic [31:0] next_word;
    logic [63:0] combined_64bit;
    logic [63:0] shifted_64bit;

    assign current_word   = mem[word_raddr];
/* verilator lint_off WIDTHEXPAND */
    assign next_word      = (32'(word_raddr) + 1 < NUM_WORDS) ? mem[word_raddr + 1'b1] : 32'h0;
/* verilator lint_on WIDTHEXPAND */
    assign combined_64bit = {next_word, current_word};

    assign shifted_64bit  = combined_64bit >> (32'(byte_offset_r) * 8);

    logic [7:0]  selected_byte;
    logic [15:0] selected_halfword;
    logic [31:0] selected_word;

    assign selected_byte     = shifted_64bit[7:0];
    assign selected_halfword = shifted_64bit[15:0];
    assign selected_word     = shifted_64bit[31:0];

    always_comb begin
        case (r_op)
            3'd0: rdata = {{24{selected_byte[7]}}, selected_byte};          // LB
            3'd1: rdata = {{16{selected_halfword[15]}}, selected_halfword};  // LH
            3'd2: rdata = selected_word;                                     // LW
            3'd4: rdata = {24'b0, selected_byte};                            // LBU
            3'd5: rdata = {16'b0, selected_halfword};                        // LHU
            default: rdata = 32'b0;
        endcase
    end

endmodule