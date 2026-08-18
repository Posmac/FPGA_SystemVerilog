`timescale 1ns / 1ps

import constants::*;
// R-types     f3 (3b)    f7 (7b)               4bits opcode {f7[5], f3}   in_num
// add         [000]      0[0]0_0000             0_000 (in_0)               in_0
// sub         [000]      0[1]0_0000             1_000 (in_8)               in_8
// xor         [100]      0[0]0_0000             0_100 (in_4)               in_4
// or          [110]      0[0]0_0000             0_110 (in_6)               in_6
// and         [111]      0[0]0_0000             0_111 (in_7)               in_7

// sll         [001]      0[0]0_0000             0_001 (in_1)               in_1
// srl         [101]      0[0]0_0000             0_101 (in_5)               in_5
// sra         [101]      0[1]0_0000             1_101 (in_13)              in_13
// slt         [010]      0[0]0_0000             0_010 (in_2)               in_2
// sltu        [011]      0[0]0_0000             0_011 (in_3)               in_3

// [ ] Объединить ADD и SUB в один сумматор: делать b_in ^ {32{is_sub}} и подавать is_sub на c_in.
// [ ] Схлопнуть SLT и SLTU в вычитатель: получать результат сравнения напрямую из флагов знака и переноса модуля SUB (без отдельной схемы).
// [ ] Унифицировать сдвигатели (SLL, SRL, SRA): объединить их в один Barrel Shifter с управлением fill_bit (0 или a_in[31]) и входами/выходами через реверс битов {<<{}}.
// [ ] Использовать case вместо 16-входового MUX: заменить массивный мультиплексор MUX_4_Op на простой always_comb с оператором case(op_in), чтобы синтезатор сам построил оптимальное дерево логики.
 // [ ] Добавить Clock Gating / Mux Fine-Gating (опционально): отключать входы неиспользуемых блоков, чтобы они не щелкали транзисторами впустую на каждом такте и не жрали динамическую мощность.

module ALU_32I(
    input logic[ARCHITECTURE_WIDTH - 1: 0]      a_in,
    input logic[ARCHITECTURE_WIDTH - 1: 0]      b_in,
    input logic[3:0]                            op_in,
    output logic [ARCHITECTURE_WIDTH - 1: 0]    a_out,
    output logic [ARCHITECTURE_WIDTH - 1: 0]    slt_out,
    output logic [ARCHITECTURE_WIDTH - 1: 0]    sltu_out
);
    //add
    logic[ARCHITECTURE_WIDTH - 1: 0] ADD_out;
    FULL_ADDER_Multi_logic ADD(
        .a_in(a_in),
        .b_in(b_in),
        .c_in(1'b0),
        .hf_out(ADD_out),
        .carry_out()
    );

    //sub
    logic[ARCHITECTURE_WIDTH - 1: 0] SUB_out;
    SUBSTRACTOR_Multi_logic_optimized SUB(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(SUB_out)
    );

    //xor
    logic[ARCHITECTURE_WIDTH - 1: 0] XOR_out;
    XOR_Multi_logic XOR(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(XOR_out)
    );

    //and
    logic[ARCHITECTURE_WIDTH - 1: 0] AND_out;
    AND_Multi_logic AND(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(AND_out)
    );

    //X or Y
    logic[ARCHITECTURE_WIDTH - 1: 0] OR_out;
    OR_Multi_logic OR(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(OR_out)
    );

    //sll
    logic[ARCHITECTURE_WIDTH - 1: 0] SLL_out;
    SLL_Multi_logic SLL(
        .a_in(a_in),
        .op_in(b_in[4:0]),
        .a_out(SLL_out)
    );

    //srl
    logic[ARCHITECTURE_WIDTH - 1: 0] SRL_out;
    SRL_Multi_logic SRL(
        .a_in(a_in),
        .op_in(b_in[4:0]),
        .fill_bit(1'b0),
        .a_out(SRL_out)
    );

    //sra
    logic[ARCHITECTURE_WIDTH - 1: 0] SRA_out;
    SRA_Multi_logic SRA(
        .a_in(a_in),
        .op_in(b_in[4:0]),
        .a_out(SRA_out)
    );

    //slt
    logic[ARCHITECTURE_WIDTH - 1: 0] SLT_out;
    SLT_Multi_logic SLT(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(SLT_out)
    );

    //sltu
    logic[ARCHITECTURE_WIDTH - 1: 0] SLTU_out;
    SLTU_Multi_logic SLTU(
        .a_in(a_in),
        .b_in(b_in),
        .a_out(SLTU_out)
    );

    MUX_4_Op_Multi_logic MUX_4_Op(
    .in_0(ADD_out),
    .in_1(SLL_out),
    .in_2(SLT_out),
    .in_3(SLTU_out),
    .in_4(XOR_out),
    .in_5(SRL_out),
    .in_6(OR_out),
    .in_7(AND_out),
    .in_8(SUB_out),
    .in_9(32'b0),
    .in_10(32'b0),
    .in_11(32'b0),
    .in_12(32'b0),
    .in_13(SRA_out),
    .in_14(32'b0),
    .in_15(32'b0),
    .op_in(op_in),
    .a_out(a_out)
    );

    assign slt_out = SLT_out;
    assign sltu_out = SLTU_out;
endmodule