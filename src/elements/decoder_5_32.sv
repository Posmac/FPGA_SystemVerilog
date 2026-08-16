`timescale 1ns / 1ps

import constants::*;

module Decoder_5_to_32(
    input  logic [4:0]  a_in,
    output logic [ARCHITECTURE_WIDTH - 1 : 0] a_out
);
    always_comb begin
        unique case (a_in)
            5'd0:  a_out[0]  = 1'b1;
            5'd1:  a_out[1]  = 1'b1;
            5'd2:  a_out[2]  = 1'b1;
            5'd3:  a_out[3]  = 1'b1;
            5'd4:  a_out[4]  = 1'b1;
            5'd5:  a_out[5]  = 1'b1;
            5'd6:  a_out[6]  = 1'b1;
            5'd7:  a_out[7]  = 1'b1;
            5'd8:  a_out[8]  = 1'b1;
            5'd9:  a_out[9]  = 1'b1;
            5'd10: a_out[10] = 1'b1;
            5'd11: a_out[11] = 1'b1;
            5'd12: a_out[12] = 1'b1;
            5'd13: a_out[13] = 1'b1;
            5'd14: a_out[14] = 1'b1;
            5'd15: a_out[15] = 1'b1;
            5'd16: a_out[16] = 1'b1;
            5'd17: a_out[17] = 1'b1;
            5'd18: a_out[18] = 1'b1;
            5'd19: a_out[19] = 1'b1;
            5'd20: a_out[20] = 1'b1;
            5'd21: a_out[21] = 1'b1;
            5'd22: a_out[22] = 1'b1;
            5'd23: a_out[23] = 1'b1;
            5'd24: a_out[24] = 1'b1;
            5'd25: a_out[25] = 1'b1;
            5'd26: a_out[26] = 1'b1;
            5'd27: a_out[27] = 1'b1;
            5'd28: a_out[28] = 1'b1;
            5'd29: a_out[29] = 1'b1;
            5'd30: a_out[30] = 1'b1;
            5'd31: a_out[31] = 1'b1;
            default: a_out = '0;            
        endcase         
    end

endmodule