`timescale 1ns / 1ps

import architecture_types::*;
import uart_types::*;
import packet_types::*;
import packet_validator_types::*;

module packet_validator (
    input packet_validator_input_struct_t   in,
    output packet_validator_output_struct_t out
);

    typedef enum logic [1:0] { 
        START,
        CHECK,
        SUCCESS,
        ERROR
    } packet_validator_state_t;

    packet_validator_state_t    current_state = START;
    packet_t                    packet;
    logic valid;
    assign valid = out.is_valid;

    always_ff @(posedge in.clk) begin
        // if (!in.rst_n) begin
        //     // current_state       <= START;
        //     // out.is_valid        <= 1'b0;
        // end else begin

        // if (out.is_valid) begin
        out.is_valid <= 1'b0;
        // end

        unique case (current_state)
            START: begin
                out.is_valid <= 1'b0; 
                if (in.can_validate) begin
                    packet <= in.packet;
                    current_state <= CHECK;
                end    
            end
            CHECK: begin
                if (packet.len > 8'd0) begin
                    current_state <= SUCCESS;
                end else begin
                    current_state <= ERROR;
                end
            end
            SUCCESS: begin
                current_state   <= START;
                out.is_valid    <= 1'b1;
                `ifndef SYNTHESIS
                    $strobe("VALID");
                `endif
            end

            ERROR: begin
                current_state   <= START;
                out.is_valid    <= 1'b0;
                `ifndef SYNTHESIS
                    $strobe("INVALID");
                `endif
            end

        endcase
        // end
    end

endmodule