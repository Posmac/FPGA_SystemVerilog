`timescale 1ns / 1ps

import constants::*;

module FULL_ADDER_Multi_logic_tb;

    // Сигналы для подключения к DUT
    logic [ARCHITECTURE_WIDTH-1:0] tb_a;
    logic [ARCHITECTURE_WIDTH-1:0] tb_b;
    logic                            tb_c_in;
    logic [ARCHITECTURE_WIDTH-1:0] tb_sum;
    logic                            tb_carry_out;

    // Ожидаемые значения (на 1 бит шире для переноса)
    logic [ARCHITECTURE_WIDTH:0]   expected;
    logic [ARCHITECTURE_WIDTH-1:0] exp_sum;
    logic                            exp_carry;

    // Переменная для подсчета ошибок
    int error_count = 0;
    int test_count = 0;

    // Подключение тестируемого 32-битного сумматора
    FULL_ADDER_Multi_logic dut (
        .a_in         (tb_a),
        .b_in         (tb_b),
        .c_in         (tb_c_in),
        .hf_out       (tb_sum),
        .carry_out    (tb_carry_out)
    );

    // Функция автоматической проверки результата
    task check_result(string test_name);
        begin
            test_count++;
            // Математическая модель идеального сумматора
            expected = tb_a + tb_b + tb_c_in;
            exp_sum   = expected[ARCHITECTURE_WIDTH-1:0];
            exp_carry = expected[ARCHITECTURE_WIDTH];

            // Проверка с учетом возможных X/Z (используем !==)
            if (tb_sum !== exp_sum || tb_carry_out !== exp_carry) begin
                $error("❌ FAIL [%s]: A=%h, B=%h, C_IN=%b | Got: Sum=%h, Carry=%b | Exp: Sum=%h, Carry=%b", 
                        test_name, tb_a, tb_b, tb_c_in, tb_sum, tb_carry_out, exp_sum, exp_carry);
                error_count++;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, FULL_ADDER_Multi_logic_tb);

        $display("----------------------------------------------------------------");
        $display(" STARTING SMART TEST FOR 32-BIT ADDER");
        $display("----------------------------------------------------------------");

        // === ЭТАП 1: КРИТИЧЕСКИЕ ТОЧКИ (CORNER CASES) ===
        
        // Тест 1: Все нули
        tb_a = 32'h0000_0000; tb_b = 32'h0000_0000; tb_c_in = 0; #10;
        check_result("All Zeros");
        tb_a = 32'h0000_0000; tb_b = 32'h0000_0000; tb_c_in = 1; #10;
        check_result("All Zeros + C_IN");

        // Тест 2: Максимальные значения (Проверка полного переполнения)
        tb_a = 32'hFFFF_FFFF; tb_b = 32'hFFFF_FFFF; tb_c_in = 0; #10;
        check_result("All Ones");
        tb_a = 32'hFFFF_FFFF; tb_b = 32'hFFFF_FFFF; tb_c_in = 1; #10;
        check_result("All Ones + C_IN");

        // Тест 3: Чередование битов (Поиск замыканий соседних дорожек)
        tb_a = 32'h5555_5555; tb_b = 32'hAAAA_AAAA; tb_c_in = 0; #10;
        check_result("Alternating 1");
        tb_a = 32'hAAAA_AAAA; tb_b = 32'h5555_5555; tb_c_in = 1; #10;
        check_result("Alternating 2");

        // Тест 4: Переход через границу знака и переполнение на 1
        tb_a = 32'hFFFF_FFFF; tb_b = 32'h0000_0001; tb_c_in = 0; #10;
        check_result("Overflow by 1");
        tb_a = 32'h7FFF_FFFF; tb_b = 32'h7FFF_FFFF; tb_c_in = 0; #10;
        check_result("Max Positive Signed");

        // === ЭТАП 2: СЛУЧАЙНЫЕ ТЕСТЫ (RANDOM TESTING) ===
        // Запускаем 100 000 случайных комбинаций
        repeat (100000) begin
            tb_a    = $urandom(); // Генерирует случайное 32-битное число
            tb_b    = $urandom();
            tb_c_in = $urandom_range(0, 1); // Случайный бит 0 или 1
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
