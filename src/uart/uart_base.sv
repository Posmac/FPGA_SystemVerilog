import ecp_types::*;
import uart_types::*;

module uart_rx 
#(
    parameter int BAUD_RATE = DEFAULT_BAUD_RATE
)
(
    input logic clk,
    input logic rst_n,
    input logic rx,
    input logic can_receive,

    output logic[7:0] rx_data,
    output logic rx_ready,
    output logic rx_done
);
    typedef enum logic [1:0] { IDLE, START, DATA, STOP } state_t;
    state_t current_state = IDLE;

    localparam int BOD_DIVISOR = CLK_FREQ / BAUD_RATE;
    localparam int BOD_HALF_DIVISOR = BOD_DIVISOR / 2;
    localparam int DIV_WIDTH = $clog2(BOD_DIVISOR);

    logic [DIV_WIDTH - 1: 0]    bod_counter = 0;
    logic [2:0]                 bit_index = 0;
    logic [7:0]                 data = 0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            bod_counter <= 0;
            bit_index <= 0;
            data <= 0;
            rx_ready <= 1'b1;
            rx_done <= 1'b0;
        end else begin
            if (bod_counter >= DIV_WIDTH'(BOD_DIVISOR - 1)) begin
                bod_counter <= 0;
            end else begin
                bod_counter <= bod_counter + 1;
            end

            if (rx_done) begin
                rx_done <= 1'b0;
            end

            if (32'(bod_counter) == BOD_HALF_DIVISOR) begin
                unique case (current_state)
                    IDLE: begin
                        if (rx == 1'b0 && can_receive) begin
                            current_state <= DATA;
                            rx_ready <= 1'b0;
                            bit_index     <= 0;
                            // $display("IDLE -> START");
                        end
                    end
                    START: begin
                        // if (rx == 1'b0) begin
                            // bit_index     <= 0;
                            // current_state <= DATA;
                            // $display("START -> DATA");
                        // end 
                    end
                    DATA: begin
                        // $display("DATA RX: %b", rx);
                        bit_index <= bit_index + 1;
                        data[bit_index] <= rx;
                        if (bit_index >= 3'd7) begin
                            current_state <= STOP;
                        end
                    end
                    STOP: begin
                        current_state <= IDLE;
                        if (rx == 1'b1) begin
                            rx_data <= data;
                            rx_done <= 1'b1;
                            // $display("Succesfull read: %b(%c)", data, data);
                        end else begin
                            // $display("Failed read: %b(%c)", data, data);
                            rx_data <= 0;
                        end
                        rx_ready <= 1'b1;
                    end
                endcase
            end
        end
    end

endmodule

module uart_tx
#(
    parameter int BAUD_RATE = DEFAULT_BAUD_RATE
)
(
    input logic         clk,
    input logic         rst_n,
    input logic         tx_valid, //outside status
    input logic[7:0]    tx_data,
    input logic         log,

    output logic        tx_ready, //internal ready status
    output logic        tx
);
    typedef enum logic [1:0] { IDLE, START, DATA, STOP } state_t;
    state_t current_state = IDLE;
 
    localparam int BOD_DIVISOR = CLK_FREQ / BAUD_RATE;
    localparam int BOD_HALF_DIVISOR = BOD_DIVISOR / 2;
    localparam int DIV_WIDTH = $clog2(BOD_DIVISOR);
    
    logic [DIV_WIDTH - 1: 0] bod_counter = 0;
    logic [2:0]              bit_index = 0;
    logic [7:0]              shift_reg = 0;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            bod_counter   <= 0;
            bit_index     <= 0;
            shift_reg     <= 0;
            tx            <= 1'b1;
            tx_ready      <= 1'b1;
        end else begin
            if (bod_counter >= DIV_WIDTH'(BOD_DIVISOR - 1)) begin
                bod_counter <= 0;
            end else begin
                bod_counter <= bod_counter + 1;
            end

            if (tx_valid && tx_ready) begin
                shift_reg <= tx_data;
                current_state <= IDLE;
                tx_ready <= 1'b0;
                // $display("UART: IDLE -> START %02h", tx_data);
            end

            if (bod_counter == 0) begin
                unique case (current_state)
                    IDLE: begin
                        if (!tx_ready) begin
                            tx <= 1'b1; 
                            if (log) begin
                                $display("  UART: IDLE -> START, D: %b(%c), I: %d, T: %b", shift_reg, shift_reg, bit_index, tx);
                            end
                            current_state <= START;
                        end 
                    end
                    START: begin
                        tx            <= 1'b0;
                        bit_index     <= 0;
                        current_state <= DATA;
                        if (log) begin
                            $display("UART: START -> DATA, D: %b, I: %d, T: %b", shift_reg, bit_index, tx);
                        end
                    end
                    DATA: begin
                        // $display("TX: %b, DATA: %b, INDEX: %d", shift_reg[bit_index], shift_reg, bit_index);
                        tx <= shift_reg[bit_index];
                        if (log) begin
                            $display("  UART: DATA: D:%b(%c) TX: %b I: %d", shift_reg, shift_reg, shift_reg[bit_index], bit_index);
                        end
                        if (bit_index == 3'd7) begin
                            if (log) begin
                                $display("  UART: DATA -> STOP");
                            end
                            current_state <= STOP;
                            bit_index <= 0;
                        end else begin
                            bit_index <= bit_index + 1;
                        end

                    end
                    STOP: begin
                        if (log) begin
                            $display("  UART: STOP -> IDLE");
                        end
                        tx            <= 1'b1;
                        tx_ready      <= 1'b1; // Освобождаем буфер строго в конце стоп-бита
                    end
                endcase
            end
        end
    end

endmodule