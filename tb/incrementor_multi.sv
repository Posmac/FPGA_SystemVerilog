`timescale 1ns / 1ps

import constants::*;

module INCREMENTOR_Multi_logic_tb;

    // Сигналы для подключения к DUT
    logic [ARCHITECTURE_WIDTH-1:0] tb_a_in;
    logic [ARCHITECTURE_WIDTH-1:0] tb_a_out;

    // Ожидаемые значения
    logic [ARCHITECTURE_WIDTH-1:0] exp_sum;

    // Переменные для подсчета ошибок
    int error_count = 0;
    int test_count = 0;

    // Подключение тестируемого 32-битного инкрементора
    INCREMENTOR_Multi_logic dut (
        .a_in  (tb_a_in),
        .a_out (tb_a_out)
    );

    // Функция автоматической проверки результата
    task check_result(string test_name);
        begin
            test_count++;
            
            // Математическая модель идеального инкрементора
            exp_sum = tb_a_in + 1'b1;

            // Проверка с учетом возможных X/Z (используем !==)
            if (tb_a_out !== exp_sum) begin
                $error("❌ FAIL [%s]: A_IN=%h | Got: A_OUT=%h | Exp: A_OUT=%h", 
                       test_name, tb_a_in, tb_a_out, exp_sum);
                error_count++;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, INCREMENTOR_Multi_logic_tb);

        $display("----------------------------------------------------------------");
        $display("   STARTING SMART TEST FOR 32-BIT INCREMENTOR");
        $display("----------------------------------------------------------------");

        // === ЭТАП 1: КРИТИЧЕСКИЕ ТОЧКИ (CORNER CASES) ===

        // Тест 1: Все нули (старт отсчета)
        tb_a_in = 32'h0000_0000;
        #10;
        check_result("All Zeros");

        // Тест 2: Максимальное значение (проверка переполнения в 0)
        tb_a_in = 32'hFFFF_FFFF;
        #10;
        check_result("All Ones (Overflow)");

        // Тест 3: Чередование битов
        tb_a_in = 32'h5555_5555;
        #10;
        check_result("Alternating 5s");

        tb_a_in = 32'hAAAA_AAAA;
        #10;
        check_result("Alternating As");

        // Тест 4: Переход через знаковую границу (младшая половина заполнена)
        tb_a_in = 32'h0000_FFFF;
        #10;
        check_result("Half Width Carry Cascade");

        // Тест 5: Максимальное положительное знаковое
        tb_a_in = 32'h7FFF_FFFF;
        #10;
        check_result("Max Positive Signed");


        // === ЭТАП 2: СЛУЧАЙНЫЕ ТЕСТЫ (RANDOM TESTING) ===
        // Запускаем 100 000 случайных комбинаций
        repeat (100000) begin
            tb_a_in = $urandom(); // Генерирует случайное 32-битное число
            #10;
            check_result("Random Test");
        end


        // === ИТОГИ ТЕСТИРОВАНИЯ ===
        $display("----------------------------------------------------------------");
        $display(" TESTING COMPLETE!");
        $display(" Total tests run: %0d", test_count);
        if (error_count == 0) begin
            $display(" 🎉 SUCCESS: All tests passed successfully!");
        end else begin
            $display(" ❌ ERROR: Found %0d mismatches!", error_count);
        end
        $display("----------------------------------------------------------------");
        
        $finish;
    end

endmodule
