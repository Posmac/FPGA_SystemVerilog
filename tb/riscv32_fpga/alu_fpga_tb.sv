import architecture_types::*;
import uart_types::*;

module alu_fpga_tb();
    logic       clk;       // Быстрый системный клок
    logic       sim_clk = 0;   // Замедленный клок для симуляции
    logic       rst_n; 
    // logic       tx;    
    // logic       rx;    

    int counter;
    int slow_counter;

    uart_input_struct_t alu_in;
    uart_output_struct_t alu_out;

    assign alu_in.rx = test_tx;
    assign alu_in.clk = sim_clk;
    assign alu_in.rst_n = rst_n;

    common alu(
        .in(alu_in),
        .out(alu_out)
    );

    logic[7:0] ascii_symbols[9] = '{8'd1, 8'd2, 8'd3, 8'd4, 8'd128, 8'd255, 8'd0, 8'd67, 8'd99};

    logic[7:0]      test_tx_data;
    logic           test_tx_ready;
    logic           test_tx_valid; // Убрали '1' отсюда, будем управлять в always_ff
    logic           test_tx; 
    
    uart_tx uart_tx(
        .clk(sim_clk),
        .rst_n(rst_n),
        .log(0),
        .tx_data(test_tx_data),
        .tx_valid(test_tx_valid),
        .tx_ready(test_tx_ready),
        .tx(test_tx)
    );

    // Генератор тактов (быстрый)
    always #1 clk = ~clk;

    initial begin
        $dumpfile("uart_dump.vcd");
        $dumpvars(0, top_uart_tb); // Дампим весь тестбенч

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

    // Генератор медленного клока (Делитель частоты)
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            counter <= '0;
            sim_clk <= 1'b0;
        end else begin
            counter <= counter + 1;
            if (counter >= 5) begin
                counter <= '0;
                sim_clk <= ~sim_clk; // !!! ИСПРАВЛЕНО: используем <= вместо =
            end 
        end
    end

    // Работаем на медленном клоке
    always_ff @(posedge sim_clk) begin
        if (rst_n) begin
            slow_counter <= slow_counter + 1;
            if (slow_counter >= 0) begin
                // Если передатчик готов и мы ещё не шлём данные
                if (test_tx_ready && !test_tx_valid) begin
                    test_tx_valid <= 1'b1; // Выставляем валидность
                    test_tx_data <= ascii_symbols[$urandom_range(8, 0)];
                    // $display("Sent data: %h", test_tx_data);
                end else if (test_tx_valid) begin
                    // Как только передатчик защёлкнул данные (ушёл с ready), снимаем valid
                    test_tx_valid <= 1'b0;
                    // $display("Sent data: %c", test_tx_data);
                end
            end else begin
                test_tx_valid <= 1'b0;
            end
           
            // Вывод информации на каждом "медленном" такте
            // $display("TEST: % b", test_tx);
        end
    end

endmodule
