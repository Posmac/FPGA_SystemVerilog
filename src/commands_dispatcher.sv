`timescale 1ns / 1ps

import architecture_types::*;
import uart_types::*;
import packet_recv_types::*;
import packet_validator_types::*;
import commands_dispatcher_types::*;
import command_types::*;

typedef enum logic [1:0] { 
    NONE,
    ROUTE,
    FINISH
} commands_dispatcher_state_t;

//   typedef struct packed {
//     logic     clk;
//     logic     rst_n;
//     logic     is_valid;
//     packet_t  packet;
//   } commands_dispatcher_input_struct_t;

//   typedef struct packed {
//     logic                 is_dispatched;
//     command_t             command;
//     alu_packet_struct_t   alu_packet;
//   } commands_dispatcher_output_struct_t;
module commands_dispatcher(
    input commands_dispatcher_input_struct_t    in,
    output commands_dispatcher_output_struct_t  out
);
    commands_dispatcher_state_t current_state;

    always_ff @(posedge in.clk or negedge in.rst_n) begin
        if (!in.rst_n) begin
            current_state       <= NONE;
            out.is_dispatched   <= 1'b0;
        end begin
            if (out.is_dispatched) begin
                out.is_dispatched <= 1'b0;
            end
            unique case(current_state)
                NONE: begin
                    if (in.is_valid) begin
                        current_state <= ROUTE;
                    end
                end
                ROUTE: begin
                    //ALU
                    current_state <= FINISH;
                    if (in.packet.cmd > 0 && in.packet.cmd < 10 ) begin
                        out.command <= CMD_ALU_EXEC;
                        out.alu_packet.a_in <= in.packet.arg0;
                        out.alu_packet.b_in <= in.packet.arg1;
                        out.is_dispatched <= 1'b1;
                        unique case(command_types::alu_command_t'(in.packet.cmd))
                            ADD: begin
                                // add         [000]      0[0]0_0000             0_000 (in_0)               in_0
                                out.alu_packet.op_in <= 4'b0000;
                                $display("ADD");
                            end
                            SUB: begin
                                // sub         [000]      0[1]0_0000             1_000 (in_8)               in_8
                                out.alu_packet.op_in <= 4'b1000;
                                $display("SUB");
                            end
                            XOR: begin
                                // xor         [100]      0[0]0_0000             0_100 (in_4)               in_4
                                out.alu_packet.op_in <= 4'b0100;
                                $display("XOR");
                            end
                            OR: begin
                                // or          [110]      0[0]0_0000             0_110 (in_6)               in_6
                                out.alu_packet.op_in <= 4'b0110;
                                $display("OR");
                            end
                            AND: begin
                                // and         [111]      0[0]0_0000             0_111 (in_7)               in_7
                                out.alu_packet.op_in <= 4'b0111;
                                $display("AND");
                            end
                            SLL: begin
                                // sll         [001]      0[0]0_0000             0_001 (in_1)               in_1
                                out.alu_packet.op_in <= 4'b0001;
                                $display("SLL");
                            end
                            SRL: begin
                                // srl         [101]      0[0]0_0000             0_101 (in_5)               in_5
                                out.alu_packet.op_in <= 4'b0101;
                                $display("SRL");
                            end
                            SRA: begin
                                // sra         [101]      0[1]0_0000             1_101 (in_13)              in_13
                                out.alu_packet.op_in <= 4'b1101;
                                $display("SRA");
                            end
                            SLT: begin
                                // slt         [010]      0[0]0_0000             0_010 (in_2)               in_2
                                out.alu_packet.op_in <= 4'b0010;
                                $display("SLT");
                            end
                            SLTU: begin
                                // sltu        [011]      0[0]0_0000             0_011 (in_3)               in_3
                                out.alu_packet.op_in <= 4'b0011;
                                $display("SLTU");
                            end
                            default: begin
                                $display("Wrong cmd");
                            end
                        endcase
                    end
                    //PC
                    //ETC
                end
                FINISH: begin
                    current_state <= NONE;
                end
                default: begin
                end
            endcase
        end
    end

endmodule