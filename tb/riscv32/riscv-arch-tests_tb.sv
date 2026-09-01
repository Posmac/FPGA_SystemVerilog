`timescale 1ns / 1ps

import constants::*;

module riscv_arch_tests_tb;
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

    // Объем памяти (512 КБ под наши новые требования)
    parameter int MEM_SIZE_BYTES = 1024 * 1024; 
    
    // Переменные для путей к файлам и границ сигнатуры
    string hex_file_path;
    string sig_file_path;

    int unsigned sig_start_addr = 32'h2000; 
    int unsigned sig_end_addr   = 32'h3000;

    // Память инструкций
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

    // Память данных
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

    // CPU
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

    // -------------------------------------------------------------------------
    // Таск для дампа сигнатуры в формате RISCOF
    // -------------------------------------------------------------------------
    task dump_signature();
        int f;
        logic [31:0] word_val;
        
        f = $fopen(sig_file_path, "w");
        if (f != 0) begin
            $display(" Dumping signature to: %s (from 0x%08h to 0x%08h)", sig_file_path, sig_start_addr, sig_end_addr);
            
            for (int addr = sig_start_addr; addr < sig_end_addr; addr += 4) begin
                word_val = Data_memory.mem[addr >> 2];
                $fdisplay(f, "%08h", word_val);
            end
            
            $fclose(f);
            $display(" Signature dump complete.");
        end else begin
            $display("ERROR: Could not open signature file %s for writing!", sig_file_path);
        end
    endtask

    // -------------------------------------------------------------------------
    // Инициализация и главный процесс
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, riscv_arch_tests_tb);

        // 1. Получаем путь к HEX
        if ($value$plusargs("HEX_FILE=%s", hex_file_path)) begin
            $display("Loading hex file: %s", hex_file_path);
            $readmemh(hex_file_path, Instruction_memory.mem);
            $readmemh(hex_file_path, Data_memory.mem);
        end else begin
            $display("ERROR: No +HEX_FILE arg provided! Exit.");
            $finish;
        end

        // 2. Путь к файлу сигнатуры
        if (!$value$plusargs("SIGNATURE=%s", sig_file_path)) begin
            sig_file_path = "dut.signature";
        end

        // 3. Динамические границы сигнатуры (если передаются из обертки/скрипта запуска)
        void'($value$plusargs("SIG_START=%h", sig_start_addr));
        void'($value$plusargs("SIG_END=%h", sig_end_addr));

        clk = 1'b0;
        rst = 1'b1;

        // Сброс (исправлена опечатка)
        repeat (5) @(posedge clk);
        rst = 1'b0;

        // Тайм-аут и отслеживание EBREAK
        fork
            begin
                repeat (1000000) @(posedge clk);
                $display("ERROR: Simulation timeout reached!");
                dump_signature();
                $finish;
            end
            begin
            forever begin
                @(posedge clk);
                #1;

                case (Data_memory.mem[sig_end_addr >> 2])
                    32'd1: begin
                        $display("[TB] TEST PASSED");
                        dump_signature();
                        $finish;
                    end

                    32'd3: begin
                        $display("[TB] TEST FAILED");
                        dump_signature();
                        $finish;
                    end
                endcase
            end
        end
        join
    end

    // Генератор тактов
    always #5 clk = ~clk;

    always @(posedge clk) begin
    if (rst) begin // Поменяйте на !rst, если сброс активен по нулю
        $display("T=%0t [RESET] PC=0x%08h", $time, cpu.pc_out);
    end else begin
        $display("T=%0t | PC=0x%08h | Inst=0x%08h | BranchTaken=%b | x8=0x%08h ",
            $time, 
            next_instruction_address,// Куда полетим дальше
            instruction,             // Инструкция на шине
            cpu.take_jump,
            cpu.Register_File.registers_out[8]
        );
    end
end

endmodule