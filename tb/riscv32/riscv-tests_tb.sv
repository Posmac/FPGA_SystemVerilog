`timescale 1ns / 1ps

import constants::*;

module riscv_tests_tb;
    // Control
    logic clk;
    logic rst;

    // Instruction memory wires
    logic [ARCHITECTURE_WIDTH-1:0]    instruction;
    logic [ARCHITECTURE_WIDTH-1:0]    next_instruction_address;

    // Data memory wires
    logic                             we;
    logic [ARCHITECTURE_WIDTH-1:0]    waddr;
    logic [ARCHITECTURE_WIDTH-1:0]    wdata;
    logic [2:0]                       w_op;   
    logic [ARCHITECTURE_WIDTH-1:0]    raddr;
    logic [2:0]                       r_op;   
    logic [ARCHITECTURE_WIDTH-1:0]    rdata;

    // Объем памяти для riscv-tests (минимум 64 КБ)
    parameter int MEM_SIZE_BYTES = 64 * 1024; 
    
    // Строка для хранения пути к текущему HEX файлу
    string hex_file_path;

    // Init instruction memory (INIT_FILE оставляем пустым, загрузка идет динамически)
    Memory_Unit #(
        .MEM_SIZE_BYTES(MEM_SIZE_BYTES),
        .INIT_FILE("") 
    ) Instruction_memory (
        .clk(clk),
        .rst_in(1'b0),
        .we(1'b0),
        .waddr('0),
        .wdata('0),
        .w_op('0),
        .raddr(next_instruction_address),
        .r_op(3'b010), // Word read
        .rdata(instruction)
    );

    // Init data memory (INIT_FILE оставляем пустым, загрузка идет динамически)
    Memory_Unit #(
        .MEM_SIZE_BYTES(MEM_SIZE_BYTES),
        .INIT_FILE("")
    ) Data_memory (
        .clk(clk),
        .rst_in(1'b0),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .w_op(w_op),
        .raddr(raddr),
        .r_op(r_op),
        .rdata(rdata)
    );

    // Init CPU
    RISCV32_CPU cpu(
        .clk(clk),
        .rst_in(rst),
        .instruction(instruction),
        .next_instruction_address(next_instruction_address),
        .data_memory_we(we),
        .data_memory_waddr(waddr),
        .data_memory_wdata(wdata),
        .data_memory_w_op(w_op),
        .data_memory_raddr(raddr),
        .data_memory_r_op(r_op),
        .data_memory_rdata(rdata)
    );

    initial begin
        // Исправлено имя топ-модуля для сохранения VCD
        $dumpfile("dump.vcd");
        $dumpvars(0, riscv_tests_tb);

        $display("---------------------------------------");
        $display("   RUNNING RISCV-TESTS COMPLIANCE      ");
        $display("---------------------------------------");

        // Динамически получаем имя файла из команды запуска симулятора 
        if ($value$plusargs("HEX_FILE=%s", hex_file_path)) begin
            $display("Loading hex file: %s", hex_file_path);
            
            // Загружаем один и тот же HEX файл в оба независимых банка памяти
            // (Убедитесь, что массив внутри Memory_Unit называется именно "mem")
            $readmemh(hex_file_path, Instruction_memory.mem);
            $readmemh(hex_file_path, Data_memory.mem);

            // Проверяем, загрузилась ли секция .data (адрес 0x2000 -> 0x2000/4 = 0x800 слово или 0x2000 слово)
            $display("DEBUG MEM AT 0x2000 (word index 0x800): 0x%8h", Data_memory.mem[32'h2000 / 4]);
            $display("DEBUG MEM AT 0x2000 (word index 0x2000): 0x%8h", Data_memory.mem[32'h2000]);

        end else begin
            $display("ERROR: No +HEX_FILE arg provided! Exit.");
            $finish;
        end

        clk = 1'b0;
        rst = 1'b1;

        // Сброс системы
        repeat (5) @(posedge clk);
        rst = 1'b0;
        $display("RESET RELEASED. Executing...");

        // Таймаут для защиты от бесконечного цикла, если процессор зависнет
        fork
            begin
                repeat (50000) @(posedge clk);
                $display("ERROR: Simulation timeout reached!");
                $finish;
            end
            
            // Наблюдение за результатом (Специфика riscv-tests)
            begin
                forever @(posedge clk) begin
                    // x3 (gp) == 1 означает SUCCESS.
                    // x3 > 1 (и нечетное) означает FAIL на определенном подтесте.
                    if (!rst && instruction == 32'h00000073 &&
                        cpu.Register_File.registers_out[3] != 0) begin
                        $display("\n=============================================");
                        if (cpu.Register_File.registers_out[3] == 32'h1) begin
                            $display(">>> TEST PASSED SUCCESSFULLY <<<");
                        end else begin
                            // Номер проваленного теста: (gp >> 1)
                            $display(">>> TEST FAILED! Failed test case ID: %0d", (cpu.Register_File.registers_out[3] >> 1));
                            $fatal(1, "RISC-V compliance test failed");
                        end
                        $display("=============================================\n");
                        $finish;
                    end
                end
            end
        join
    end

    // CLOCK GENERATOR
    always #5 clk = ~clk;

    // LOGGER
    always @(posedge clk) begin
        if (!rst) begin
            $display("T=%0t | PC=0x%8h(%d) | INSTR=0x%8h | gp(x3)=%0d | a4(x14)=0x%8h(%d) | a5(x15)=0x%8h(%d) | t2(x7)=0x%8h(%d), | sp(x2)=0x%8h(%d)",
                $time, 
                next_instruction_address, 
                next_instruction_address, 
                instruction, 
                cpu.Register_File.registers_out[3],  // gp — номер подтеста
                cpu.Register_File.registers_out[14], // a0 — результат работы AUIPC
                cpu.Register_File.registers_out[14], // a0 — результат работы AUIPC
                cpu.Register_File.registers_out[15], // a1 — результат работы AUIPC
                cpu.Register_File.registers_out[15], // a1 — результат работы AUIPC
                cpu.Register_File.registers_out[7],   // t2 — эталонное значение
                cpu.Register_File.registers_out[7],  // t2 — эталонное значение
                cpu.Register_File.registers_out[2],  // t2 — эталонное значение
                cpu.Register_File.registers_out[2]   // t2 — эталонное значение
            );
            // $display("ALU: OUT: %d, src1: %d, src2: %d", cpu.alu_out, cpu.alu_first_out, cpu.alu_second_out);
            // $display("LW_DBG | raddr=0x%8h | word_raddr=0x%8h | r_op=%0d | raw_word=0x%8h | rdata=0x%8h", 
            //     Data_memory.raddr, Data_memory.word_raddr, Data_memory.r_op, Data_memory.raw_word, Data_memory.rdata);
        end
    end

endmodule
