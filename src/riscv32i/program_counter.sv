`timescale 1ns / 1ps

import constants::*;

module Program_Counter (
    input  logic                             clk,
    input  logic                             rst_in,

    // Управление
    input  logic                             write_en,   // 1 - обновляем PC, 0 - пауза
    input  logic                             take_jump,  // 0 - PC+4, 1 - pc_jump

    // Входные данные
    input  logic [ARCHITECTURE_WIDTH - 1: 0] pc_jump,    // Адрес из Branch Unit (для JAL/BEQ...)

    // Выходы
    output logic [ARCHITECTURE_WIDTH - 1: 0] pc_out,
    output logic [ARCHITECTURE_WIDTH - 1: 0] pc_plus4
);

    // 1. Вычисляем PC + 4
    FULL_ADDER_Multi_logic adder_pc4 (
        .a_in      (pc_out),
        .b_in      (32'd4),
        .c_in      (1'b0),
        .hf_out    (pc_plus4),
        .carry_out ()
    );

    // 2. Выбираем между последовательным шагом (a_in) и прыжком (b_in)
    logic [ARCHITECTURE_WIDTH - 1: 0] next_address;

    MUX_1_Op_Multi_logic pc_mux (
        .a_in  (pc_plus4),     // op_in = 0 -> PC + 4
        .b_in  (pc_jump),      // op_in = 1 -> pc_jump
        .op_in (take_jump),
        .a_out (next_address)
    );

    // 3. Регистр PC
    Register_multi pc_reg (
        .clk     (clk),
        .rst_in  (rst_in),
        .load_in (write_en),
        .d_in    (next_address),
        .q_out   (pc_out)
    );

endmodule