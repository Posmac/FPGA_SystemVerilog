package ecp_types;
    localparam int CLK_FREQ = 25_000_000;
endpackage

package architecture_types;
  localparam int ARCHITECTURE_WIDTH = 32;
  localparam int ADDR_WIDTH = 10; // 2^10 = 1024
endpackage

package uart_types;
  localparam int DEFAULT_BAUD_RATE = 115200;
  localparam int BOD_115200 = 115200;
  localparam int BOD_921600 = 460800;
  // localparam int RX_BAUD_RATE = 115200;
  // localparam int TX_BAUD_RATE = 115200 * 8;
  // localparam int RX_BOD_DIVISOR = CLK_FREQ / RX_BAUD_RATE;
  // localparam int TX_BOD_DIVISOR = CLK_FREQ / TX_BAUD_RATE;
  // localparam int RX_BOD_HALF_DIVISOR = RX_BOD_DIVISOR / 2;
  // localparam int TX_BOD_HALF_DIVISOR = TX_BOD_DIVISOR / 2;
  // localparam int RX_DIV_WIDTH = $clog2(RX_BOD_DIVISOR);
  // localparam int TX_DIV_WIDTH = $clog2(TX_BOD_DIVISOR);

  typedef struct packed {
      logic clk;
      logic sim_clk;
      logic rst_n;
      logic rx;
  } uart_input_struct_t;

  typedef struct packed {
      logic tx;
  } uart_output_struct_t;
endpackage

package command_types;

  import architecture_types::*;

 typedef enum logic[7:0] {
      NONE,
      CMD_PING,
      CMD_ALU_EXEC
  } command_t;

  typedef enum logic[7:0] {
    ADD,
    SUB,
    XOR,
    OR,
    AND,
    SLL,
    SRL,
    SRA,
    SLT,
    SLTU
  } alu_command_t;

  typedef struct packed {
    logic[3:0]                        op_in;
    logic[ARCHITECTURE_WIDTH - 1 : 0] a_in;
    logic[ARCHITECTURE_WIDTH - 1 : 0] b_in;
  } alu_packet_struct_t;

endpackage

package packet_types;

  import command_types::*;
  import architecture_types::*;

  localparam int PACKET_TOTAL_SIZE  = 10;
  localparam int ARG_1_SIZE         = 4;
  localparam int ARG_2_SIZE         = 4;

  typedef struct packed {
      command_t                           cmd;    // 1byte
      logic [7:0]                         len;    // 1byte
      logic [ARCHITECTURE_WIDTH - 1: 0]   arg0;   // 4 bytes
      logic [ARCHITECTURE_WIDTH - 1: 0]   arg1;   // 4 bytes
  } packet_t;
endpackage

package packet_recv_types;
  typedef struct packed {
      logic       clk;
      logic       rst_n;
      logic       can_read;
      logic[7:0]  data;
  } packet_recv_input_struct_t;

  typedef struct packed {
      logic       is_done;
  } packet_recv_output_struct_t;
endpackage

package packet_validator_types;

  import packet_types::*;

  typedef struct packed {
    logic       clk;
    logic       rst_n;
    logic       can_validate;
    packet_t    packet;
  } packet_validator_input_struct_t;

  typedef struct packed {
    logic       is_valid;
  } packet_validator_output_struct_t;

endpackage

package commands_dispatcher_types;

  import packet_types::*;
  import command_types::*;

  typedef struct packed {
    logic     clk;
    logic     rst_n;
    logic     is_valid;
    packet_t  packet;
  } commands_dispatcher_input_struct_t;

  typedef struct packed {
    logic                 is_dispatched;
    command_t             command;
    alu_packet_struct_t   alu_packet;
  } commands_dispatcher_output_struct_t;

endpackage

package response_types;
  localparam int RESPONSE_BUFFER_SIZE = 32;

  typedef struct packed {
    logic [RESPONSE_BUFFER_SIZE - 1: 0][7:0]  buffer; 
    logic [7:0]                               len;
  } response_packet_t;

  typedef struct packed {
    logic               clk;
    logic               rst_n;
    logic               can_start_sending;
    response_packet_t   packet;
  } response_sender_input_struct_t;

  typedef struct packed {
    logic               is_in_progress;
    logic               was_sent;
    logic               tx;
  } response_sender_output_struct_t;

endpackage