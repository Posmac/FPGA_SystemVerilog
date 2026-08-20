`timescale 1ns / 1ps

import constants::*;

module register_file_tb;
    logic clk = 0; // 1. Явная инициализация clk в 0
    logic rst;

    // in
    logic [ARCHITECTURE_WIDTH - 1: 0] instruction;
    logic [ARCHITECTURE_WIDTH - 1: 0] wdata;
    logic                             write_enabled;

    // out
    logic [ARCHITECTURE_WIDTH - 1: 0] rdata1;
    logic [ARCHITECTURE_WIDTH - 1: 0] rdata2;

    logic [ARCHITECTURE_WIDTH - 1: 0] expected_rdata1;
    logic [ARCHITECTURE_WIDTH - 1: 0] expected_rdata2;

    Register_File rf(
        .rst_in(rst),
        .*
    );

    int error_count = 0;
    int test_count = 0;
    
    // Золотая модель памяти
    logic [31:0] expected_rf [0:31] = '{default: 32'h0};
    
    // Вспомогательные переменные для генерации
    int raddr1;
    int raddr2;
    int waddr1;

    task check_result(string test_name); begin
        test_count++;
        // 2. Строгое трехзначное сравнение !== для обоих портов
        if (rdata1 !== expected_rdata1 || rdata2 !== expected_rdata2) begin
            error_count++;
            $display("Register File: %p", expected_rf);
            $display("Raddr1: %d, raddr2: %d, waddr: %d", raddr1, raddr2, waddr1);
            $error("%d:: [%s] OUT: r1=%d, r2=%d | EXPECTED: r1=%d, r2=%d. RST: %b", 
                   test_count, test_name, rdata1, rdata2, expected_rdata1, expected_rdata2, rst);
        end
    end endtask

    // Генератор тактового сигнала (период 10 нс)
    initial begin
        forever #5 clk = ~clk;
    end

    initial begin
            // Инициализация сигналов
        clk = 0;
        write_enabled = 0;
        instruction = 0;
        wdata = 0;
        
        // 1. Подаем сброс
        rst = 1;
        
        // 2. Ждем хотя бы 2-3 полных такта, чтобы сброс гарантированно
        // прошёл через все защелки и триггеры во всех 31 регистрах
        repeat (3) @(posedge clk);
        
        // 3. Снимаем сброс
        @(negedge clk);
        rst = 0;
        
        // Сбрасываем счетчик ошибок и модель
        expected_rf = '{default: 32'h0};
        error_count = 0;
        test_count = 0;

        $display("=== STARTING RANDOM TESTS ===");

        repeat (1_000_000) begin
            // Сменяем входы НА СПАДЕ такта (безопасная зона без гонок)
            @(negedge clk);

            raddr1 = $urandom() % 32;
            raddr2 = $urandom() % 32;
            waddr1 = $urandom() % 32;
            wdata  = $urandom() % 1000;

            write_enabled = ($urandom() % 100) > 30 ? 1 : 0; // ~70% случай записи
            rst           = ($urandom() % 100) == 0 ? 1 : 0; // ~1% редкий случай сброса

            instruction = '0;
            instruction[11:7]  = waddr1[4:0];
            instruction[19:15] = raddr1[4:0];
            instruction[24:20] = raddr2[4:0];

            // -------------------------------------------------------------
            // ОБНОВЛЕНИЕ ЗОЛОТОЙ МОДЕЛИ
            // -------------------------------------------------------------
            if (rst == 1) begin
                expected_rf = '{default: 32'h0};
                expected_rdata1 = expected_rf[raddr1];
                expected_rdata2 = expected_rf[raddr2];
            end else if (write_enabled == 1) begin
                expected_rdata1 = expected_rf[raddr1];
                expected_rdata2 = expected_rf[raddr2];
                if (waddr1 != 0) begin
                    expected_rf[waddr1] = wdata;
                end
            end else if (write_enabled == 0) begin
                expected_rdata1 = expected_rf[raddr1];
                expected_rdata2 = expected_rf[raddr2];
            end

            // $display("Register File: %p", expected_rf);
            // $display("Raddr1: %d, raddr2: %d, waddr: %d", raddr1, raddr2, waddr1);
            // $display("RST: %d, WE: ", rst, write_enabled);

            #1;
            check_result("Random_Test");
        end

        if (error_count == 0) begin
            $display("🎉 SUCCESS: All %0d tests passed without errors!", test_count);
        end else begin
            $display("❌ FAIL: Total errors: %0d / %0d", error_count, test_count);
        end

        $finish;
    end

endmodule