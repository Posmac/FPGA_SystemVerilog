`timescale 1ns / 1ps

import constants::*;

module SRL_Multi_logic(
    input logic[ARCHITECTURE_WIDTH - 1: 0]  a_in,
    input logic[4:0]                        op_in,
    input logic                             fill_bit,
    output logic[ARCHITECTURE_WIDTH - 1: 0] a_out
);
    logic op_in_4;
    logic op_in_3;
    logic op_in_2;
    logic op_in_1;
    logic op_in_0;

    assign op_in_4 = op_in[4];
    assign op_in_3 = op_in[3];
    assign op_in_2 = op_in[2];
    assign op_in_1 = op_in[1];
    assign op_in_0 = op_in[0];
    //ACTUAL SHIFT
    //16 bit shift
    logic [ARCHITECTURE_WIDTH - 1 : 0] shift_16_result;
    always_comb begin
        for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : shift_16_loop
            if (op_in_4) begin
                shift_16_result[i] = a_in[(i + 16) % ARCHITECTURE_WIDTH];
            end else begin
                shift_16_result[i] = a_in[i];
            end
        end
    end
    //8 bit shift
    logic [ARCHITECTURE_WIDTH - 1 : 0] shift_8_result;
    always_comb begin
        for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : shift_8_loop
            if (op_in_3) begin
                shift_8_result[i] = shift_16_result[(i + 8) % ARCHITECTURE_WIDTH];
            end else begin
                shift_8_result[i] = shift_16_result[i];
            end
        end
    end
    //4 bit shift
    logic [ARCHITECTURE_WIDTH - 1 : 0] shift_4_result;
    always_comb begin
        for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : shift_4_loop
            if (op_in_2) begin
                shift_4_result[i] = shift_8_result[(i + 4) % ARCHITECTURE_WIDTH];
            end else begin
                shift_4_result[i] = shift_8_result[i];
            end
        end
    end
    //2 bit shift
    logic [ARCHITECTURE_WIDTH - 1 : 0] shift_2_result;
    always_comb begin
        for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : shift_2_loop
            if (op_in_1) begin
                shift_2_result[i] = shift_4_result[(i + 2) % ARCHITECTURE_WIDTH];
            end else begin
                shift_2_result[i] = shift_4_result[i];
            end
        end
    end
    //1 bit shift
    logic [ARCHITECTURE_WIDTH - 1 : 0] shift_out;
    always_comb begin
        for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : shift_1_loop
            if (op_in_0) begin
                shift_out[i] = shift_2_result[(i + 1) % ARCHITECTURE_WIDTH];
            end else begin
                shift_out[i] = shift_2_result[i];
            end
        end
    end

    logic [ARCHITECTURE_WIDTH - 1 : 0] mask_in;
    assign mask_in = {32{1'b1}};

    // mask 16
    logic [ARCHITECTURE_WIDTH - 1 : 0] mask_16_res;
    always_comb begin
        if (op_in_4) begin
            for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : mask_16_loop
                if (i + 16 < ARCHITECTURE_WIDTH) begin
                    mask_16_res[i] = mask_in[i + 16];
                end else begin
                    mask_16_res[i] = 1'b0;
                end
            end
        end else begin
            mask_16_res = mask_in;
        end
    end

    // mask 8
    logic [ARCHITECTURE_WIDTH - 1 : 0] mask_8_res;
    always_comb begin
        if (op_in_3) begin
            for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : mask_8_loop
                if (i + 8 < ARCHITECTURE_WIDTH) begin
                    mask_8_res[i] = mask_16_res[i + 8];
                end else begin
                    mask_8_res[i] = 1'b0;
                end
            end
        end else begin
            mask_8_res = mask_16_res;
        end
    end

    // mask 4
    logic [ARCHITECTURE_WIDTH - 1 : 0] mask_4_res;
    always_comb begin
        if (op_in_2) begin
            for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : mask_4_loop
                if (i + 4 < ARCHITECTURE_WIDTH) begin
                    mask_4_res[i] = mask_8_res[i + 4];
                end else begin
                    mask_4_res[i] = 1'b0;
                end
            end
        end else begin
            mask_4_res = mask_8_res;
        end
    end

    // mask 2
    logic [ARCHITECTURE_WIDTH - 1 : 0] mask_2_res;
    always_comb begin
        if (op_in_1) begin
            for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : mask_2_loop
                if (i + 2 < ARCHITECTURE_WIDTH) begin
                    mask_2_res[i] = mask_4_res[i + 2];
                end else begin
                    mask_2_res[i] = 1'b0;
                end
            end
        end else begin
            mask_2_res = mask_4_res;
        end
    end

    //mask 1
    logic [ARCHITECTURE_WIDTH - 1 : 0] mask_out;
    always_comb begin
        if (op_in_0) begin
            for (int i = 0; i < ARCHITECTURE_WIDTH; i = i + 1) begin : mask_1_loop
                if (i + 1 < ARCHITECTURE_WIDTH) begin
                    mask_out[i] = mask_2_res[i + 1];
                end else begin
                    mask_out[i] = 1'b0;
                end
            end
        end else begin
            mask_out = mask_2_res;
        end
    end

    //final result: 
    assign a_out = (shift_out & mask_out) | ({(ARCHITECTURE_WIDTH){fill_bit}} & ~mask_out);
endmodule