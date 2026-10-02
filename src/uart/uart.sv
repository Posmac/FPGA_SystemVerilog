module uart #
(
    parameter int CLK_FREQ = 25_000_000,
    parameter int BAUD_RATE = 115200
)
(
    input logic         clk,
    input logic         rst_n,
    input logic         rx,
    output logic        tx
);
    logic[7:0]  rx_data;
    logic       rx_ready;
    
    logic[7:0]  tx_data;
    logic       tx_valid = 1'b1;
    logic       tx_ready;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data  <= 8'b0;
        end else begin
            if (rx_ready && tx_ready && rx) begin
                $strobe("Data: %b(%c) -> %b(%c)", rx_data, rx_data, tx_data, tx_data);
                tx_data <= rx_data + 1;
                tx_valid <= 1'b1;
            end else begin
                tx_valid <= 1'b0;
            end
        end
    end

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .log(1'b0),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .tx_ready(tx_ready),
        .tx(tx)
    );
 
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_rx (
        .clk(clk),
        .rst_n(rst_n),
        .rx(rx),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );
endmodule


module uart_rx #
(
    parameter int CLK_FREQ = 25_000_000,
    parameter int BAUD_RATE = 115200
)
(
    input logic clk,
    input logic rst_n,
    input logic rx,
    
    output logic[7:0] rx_data,
    output logic rx_ready
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
        end else begin
            if (bod_counter >= DIV_WIDTH'(BOD_DIVISOR - 1)) begin
                bod_counter <= 0;
            end else begin
                bod_counter <= bod_counter + 1;
            end

            if (32'(bod_counter) == BOD_HALF_DIVISOR) begin
                unique case (current_state)
                    IDLE: begin
                        if (rx == 1'b1) begin
                            current_state <= START;
                            rx_ready <= 1'b0;
                            // $display("IDLE -> START");
                        end
                    end
                    START: begin
                        if (rx == 1'b0) begin
                            bit_index     <= 0;
                            current_state <= DATA;
                            // $display("START -> DATA");
                        end 
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

module uart_tx #
(
    parameter int CLK_FREQ = 25_000_000,
    parameter int BAUD_RATE = 115200
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
                // $display("  UART: IDLE -> START");
            end

            if (bod_counter == 0) begin
                unique case (current_state)
                    IDLE: begin
                        tx <= 1'b1;
                        if (!tx_ready) begin
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