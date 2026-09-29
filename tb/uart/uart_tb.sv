module top_uart_tb();
    logic       clk;   //system clock (our is 25Mhz);
    logic       rst_n; //async reset
    logic       tx;    //physical wire to Reciever

    int counter;

    // logic tx_valid = '0;
    // logic tx_ready;
    // uart_tx uart(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .tx_valid(tx_valid),
    //     .tx_data(8'b10101010),
    //     .tx_ready(tx_ready),
    //     .tx(tx),
    //     .tx_ready_led()
    // );

    logic        send = '1;
    uart_user uart(
        .clk(clk),
        .rst_n(rst_n),
        .send(send),
        .tx(tx)
    );
   
    // Генератор тактов
    always #5 clk = ~clk;

    initial begin
        $dumpfile("uart_dump.vcd");
        $dumpvars(0, uart);

        $display("---------------------------------------");
        $display("Starting uart testing suite");
        $display("---------------------------------------");

        clk = 1'b0;
        rst_n = 1'b0;

        // Сброс системы
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        $display("RESET RELEASED. Executing...");
    end
        // LOGGER
        always_ff @(posedge clk) begin
            if (rst_n) begin
                counter <= counter + 1;
                if (counter >= 500000) begin
                    send <= ~send;
                    // tx_valid = ~tx_valid;
                    counter <= '0;
                    // $display("Valid: %b", tx_valid);
                end 

                // $display("T=%t | clk=%d | tx=%b | send_next_hello_world=%b | rst = %b \n has_data_to_sent=%b, data=%d, message_index=%d, state=%b, ready=%b",
                //     $time,
                //     clk,
                //     tx,
                //     send_next_hello_world,
                //     rst_n,
                //     uart.has_data_to_sent,
                //     uart.data,
                //     uart.message_index,
                //     uart.data_transmission_state,
                //     uart.tx_ready
                // );
            end
        end

endmodule