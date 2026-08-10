`timescale 1ns / 1ps

import constants::*;

module IMM_decoder (
    input  logic [31:0] instr,
    output logic [31:0] imm_ext
);

    logic [6:0] opcode;
    assign opcode = instr[6:0];

    //R: 0110011
    //I: 0010011 (alu imm)
    //I: 0000011 (load)
    //S: 0100011 (store)
    //B: 1100011 (branch)
    //J: 1101111 (jump)
    //I: 1100111 (jump + load)
    //U: 0110111 (load upper)
    //U: 0010111 (add upper imm)
    //I: 1110011 (call/break)

    always_comb begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: // I-type (ALU-imm, Load, JALR)
                imm_ext = { {20{instr[31]}}, instr[31:20] };

            7'b0100011: // S-type (Store)
                imm_ext = { {20{instr[31]}}, instr[31:25], instr[11:7] };

            7'b1100011: // B-type (Branch)
                imm_ext = { {20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 };

            7'b0110111, 7'b0010111: // U-type (LUI, AUIPC)
                imm_ext = { instr[31:12], 12'b0 };

            7'b1101111: // J-type (JAL)
                imm_ext = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };

            default: 
                imm_ext = 32'b0;
        endcase
    end

endmodule