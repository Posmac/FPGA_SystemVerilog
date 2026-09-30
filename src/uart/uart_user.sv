module uart_user
(
    input   logic     clk, // Пин P3
    input   logic     rst_n, //async reset
    input   logic     send, //
    output  logic     tx   // Пин J17
);
    localparam int MESSAGE_LEN = 14;
    localparam logic [8*MESSAGE_LEN-1:0] MESSAGE = "Hello Ioan!!\r\n";
    typedef enum logic [1:0] { IDLE, START, DATA, STOP } state_t;

    state_t      current_state = IDLE;
    logic        tx_valid = '0;
    logic[7:0]   tx_data = '0;
    logic[3:0]   byte_index = '0;

    //uart internal specific shit
    logic        tx_ready;
    uart_tx uart(
        .clk(clk),
        .rst_n(rst_n),
        .tx_valid(tx_valid),
        .tx_data(tx_data),
        .tx_ready(tx_ready),
        .tx(tx),
        .tx_ready_led()
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= IDLE;
            tx_valid <= '0;
            byte_index <= '0;
        end else begin
            unique case (current_state)
                IDLE: begin
                    if (!send && tx_ready) begin
                        $display("USER: IDLE -> START");
                        current_state <= START;
                    end
                end
                START: begin
                    byte_index <= '0;
                    current_state <= DATA;
                    // tx_valid <= 1'b0;
                    // tx_data  <= MESSAGE[(MESSAGE_LEN - 1) * 8 +: 8];
                    $display("USER: START -> DATA");
                end
                DATA: begin
                    if (tx_ready) begin
                        if (tx_valid) begin
                            $display("USER DATA: r=%b v=%b d=%c i=%0d",
                                tx_ready,
                                tx_valid,
                                tx_data,
                                byte_index - 1);
                        end

                        if (32'(byte_index) >= MESSAGE_LEN) begin
                            current_state <= STOP;
                            tx_valid <= '0;
                            $display("USER DATA -> STOP");
                        end else begin
                            byte_index <= byte_index + 1;
                            tx_valid <= 1'b1;
                            tx_data <= MESSAGE[8 * (MESSAGE_LEN - 1 - 32'(byte_index)) +: 8];
                            // tx_data <= MESSAGE[32'(byte_index) * 8 +: 8];
                        end
                    end
                end
                STOP: begin
                    if (tx_ready) begin
                        byte_index <= '0;
                        tx_valid <= '0;
                        current_state <= IDLE;
                        $display("USER: STOP -> IDLE \n\n");
                    end
                end
            endcase
        end
    end

endmodule
