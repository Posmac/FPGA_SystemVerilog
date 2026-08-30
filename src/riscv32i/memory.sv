`timescale 1ns / 1ps

import constants::*;

module Memory_Unit #(
    parameter int MEM_SIZE_BYTES = 4096,
    parameter int NUM_WORDS      = MEM_SIZE_BYTES / 4,
    parameter string INIT_FILE = ""
)(
    input  logic                             clk,
    input  logic                             rst_in,

    // Порт записи (Write)
    input  logic                             we,
    input  logic [ARCHITECTURE_WIDTH-1:0]    waddr,
    input  logic [ARCHITECTURE_WIDTH-1:0]    wdata,
    input  logic [2:0]                       w_op,   // 0: SB, 1: SH, 2: SW

    // Порт чтения (Read) — синхронный (BRAM compatible)
    input  logic [ARCHITECTURE_WIDTH-1:0]    raddr,
    input  logic [2:0]                       r_op,   // 0: LB, 1: LH, 2: LW, 3: LBU, 4: LHU

    output logic [ARCHITECTURE_WIDTH-1:0]    rdata
);

    // Память объявляем 32-битными словами — честный Block RAM
    logic [31:0] mem [0:NUM_WORDS-1];

    // ------------------------------------------------------------------------
    // 1. ЗАПИСЬ (Синхронная, с байтовыми масками)
    // ------------------------------------------------------------------------
    logic [$clog2(NUM_WORDS)-1:0] word_waddr;
    logic [1:0]                   byte_offset_w;

    assign word_waddr    = waddr[$clog2(NUM_WORDS)+1 : 2];
    assign byte_offset_w = waddr[1:0];

    always_ff @(posedge clk) begin
        if (rst_in) begin
            for (int i = 0; i < NUM_WORDS; i++) begin
                mem[i] = 32'h0;
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

                3'd1: begin // SH (Store Halfword - выровнен по 2 байтам)
                    if (byte_offset_w[1] == 1'b0)
                        mem[word_waddr][15:0]  <= wdata[15:0];
                    else
                        mem[word_waddr][31:16] <= wdata[15:0];
                end

                3'd2: begin // SW (Store Word - выровнен по 4 байтам)
                    mem[word_waddr] <= wdata;
                end

                default: ;
            endcase
        end
    end

    // ------------------------------------------------------------------------
    // 2. ЧТЕНИЕ (Синхронная выборка BRAM + декодирование)
    // ------------------------------------------------------------------------
    logic [$clog2(NUM_WORDS)-1:0] word_raddr;
    assign word_raddr = raddr[$clog2(NUM_WORDS)+1 : 2];

    logic [31:0] raw_word;
    logic [1:0]  byte_offset_r_reg;
    logic [2:0]  r_op_reg;

    always_comb begin
    // always_ff @(posedge clk) begin
        // if (rst_in) begin
        //     raw_word          <= 32'h0;
        //     byte_offset_r_reg <= 2'b00;
        //     r_op_reg          <= 3'd0;
        // end else begin
            
        // end
        raw_word          = mem[word_raddr];
        byte_offset_r_reg = raddr[1:0];
        r_op_reg          = r_op;
    end

    // $display("Info: waddr: %b, raddr: %b, raw_word: %b", word_raddr, raddr, raw_word);

    // Выбираем байт и полуслово без WIDTHTRUNC
    logic [31:0] shifted_word;
    logic [7:0]  selected_byte;
    logic [15:0] selected_halfword;

    assign shifted_word      = raw_word >> (byte_offset_r_reg * 8);
    assign selected_byte     = shifted_word[7:0];
    assign selected_halfword = (byte_offset_r_reg[1] == 1'b0) ? raw_word[15:0] : raw_word[31:16];

    // Знаковое / беззнаковое расширение
    always_comb begin
        case (r_op_reg)
            3'd0: rdata = {{24{selected_byte[7]}}, selected_byte};         // LB
            3'd1: rdata = {{16{selected_halfword[15]}}, selected_halfword}; // LH
            3'd2: rdata = raw_word;                                         // LW
            3'd4: rdata = {24'b0, selected_byte};                           // LBU
            3'd5: rdata = {16'b0, selected_halfword};                       // LHU
            default: rdata = 32'b0;
        endcase
    end

    // initial begin
    //     if (INIT_FILE != "") begin
    //         $readmemh(INIT_FILE, mem);
    //     end
    // end

endmodule