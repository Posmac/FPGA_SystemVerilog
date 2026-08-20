`timescale 1ns / 1ps

import constants::*;

module memory_unit_tb;

    parameter int MEM_SIZE_BYTES = 4096;
    parameter int NUM_WORDS      = MEM_SIZE_BYTES / 4;
    parameter int NUM_TESTS      = 10_000_000;

    // Сигналы DUT
    logic                             clk;
    logic                             rst;
    logic                             we;
    logic [ARCHITECTURE_WIDTH-1:0]    waddr;
    logic [ARCHITECTURE_WIDTH-1:0]    wdata;
    logic [2:0]                       w_op;

    logic [ARCHITECTURE_WIDTH-1:0]    raddr;
    logic [2:0]                       r_op;
    logic [ARCHITECTURE_WIDTH-1:0]    rdata;

    // Подключение памяти
    Memory_Unit #(
        .MEM_SIZE_BYTES(MEM_SIZE_BYTES)
    ) dut (
        .clk(clk),
        .rst_in(rst),
        .we(we),
        .waddr(waddr),
        .wdata(wdata),
        .w_op(w_op),
        .raddr(raddr),
        .r_op(r_op),
        .rdata(rdata)
    );

    // Генератор тактового сигнала (период 10 нс)
    always #5 clk = ~clk;

    // Золотая модель (байтовый массив)
    byte ref_mem [0:MEM_SIZE_BYTES-1];

    // Статистика
    longint total_tests  = 0;
    longint total_writes = 0;
    longint total_reads  = 0;
    longint total_resets = 0;
    longint errors       = 0;

    // Функция вычисления ожидаемого значения
    function logic [31:0] get_expected_read(logic [31:0] addr, logic [2:0] op);
        logic [7:0]  b0, b1, b2, b3;
        logic [7:0]  cur_b;
        logic [15:0] cur_h;

        b0 = ref_mem[addr];
        b1 = ref_mem[addr + 1];
        b2 = ref_mem[addr + 2];
        b3 = ref_mem[addr + 3];

        cur_b = b0;
        cur_h = {b1, b0};

        case (op)
            3'd0: return {{24{cur_b[7]}}, cur_b};         // LB
            3'd1: return {{16{cur_h[15]}}, cur_h};        // LH
            3'd2: return {b3, b2, b1, b0};                // LW
            3'd3: return {24'b0, cur_b};                  // LBU
            3'd4: return {16'b0, cur_h};                  // LHU
            default: return 32'h0;
        endcase
    endfunction

    // Основной процесс
    initial begin
        clk   = 0;
        rst   = 1;
        we    = 0;
        waddr = 0;
        wdata = 0;
        w_op  = 0;
        raddr = 0;
        r_op  = 0;

        for (int i = 0; i < MEM_SIZE_BYTES; i++) begin
            ref_mem[i] = 8'h00;
        end

        $display("==================================================");
        $display("=== STARTING MEMORY UNIT STRESS TEST (10M RUNS) ==");
        $display("==================================================");

        // Держим сброс пару тактов, чтобы гарантированно очистить mem[]
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        for (int i = 0; i < NUM_TESTS; i++) begin
            logic        rand_rst;
            logic        rand_we;
            logic [31:0] rand_waddr, rand_raddr;
            logic [31:0] rand_wdata;
            logic [2:0]  rand_wop, rand_rop;
            logic [31:0] expected_data;

            // 1. Генерация рандома с кастами типы
            rand_rst   = ($urandom() % 100) == 0 ? 1'b1 : 1'b0; // ~1% редкий сброс
            rand_we    = 1'($urandom_range(0, 1));
            rand_wop   = 3'($urandom_range(0, 2)); // SB, SH, SW
            rand_rop   = 3'($urandom_range(0, 4)); // LB, LH, LW, LBU, LHU

            rand_waddr = ($urandom() % (MEM_SIZE_BYTES - 4));
            rand_raddr = ($urandom() % (MEM_SIZE_BYTES - 4));
            rand_wdata = $urandom();

            // 2. ЧЕСТНОЕ ВЫРАВНИВАНИЕ АДРЕСОВ RISC-V
            case (rand_wop)
                3'd1: rand_waddr[0]   = 1'b0;  // SH -> кратен 2
                3'd2: rand_waddr[1:0] = 2'b00; // SW -> кратен 4
                default: ;
            endcase

            case (rand_rop)
                3'd1, 3'd4: rand_raddr[0]   = 1'b0;  // LH, LHU -> кратен 2
                3'd2:       rand_raddr[1:0] = 2'b00; // LW -> кратен 4
                default:    ;
            endcase

            // 3. Выставляем сигналы на спаде
            @(negedge clk);
            rst   = rand_rst;
            we    = rand_we;
            waddr = rand_waddr;
            wdata = rand_wdata;
            w_op  = rand_wop;

            raddr = rand_raddr;
            r_op  = rand_rop;

            // DUT'ный mem[] — синхронный BRAM без обхода (read-before-write):
            // если запись и чтение в этом такте попадают в одно слово, читается
            // СТАРОЕ значение. Поэтому считаем ожидаемые данные ДО применения
            // записи/сброса к референсной модели.
            total_reads++;
            expected_data = rand_rst ? 32'h0 : get_expected_read(rand_raddr, rand_rop);

            // Обновляем референс
            if (rand_rst) begin
                total_resets++;
                for (int b = 0; b < MEM_SIZE_BYTES; b++) begin
                    ref_mem[b] = 8'h00;
                end
            end else if (rand_we) begin
                total_writes++;
                case (rand_wop)
                    3'd0: begin // SB
                        ref_mem[rand_waddr] = rand_wdata[7:0];
                    end
                    3'd1: begin // SH
                        ref_mem[rand_waddr]   = rand_wdata[7:0];
                        ref_mem[rand_waddr+1] = rand_wdata[15:8];
                    end
                    3'd2: begin // SW
                        ref_mem[rand_waddr]   = rand_wdata[7:0];
                        ref_mem[rand_waddr+1] = rand_wdata[15:8];
                        ref_mem[rand_waddr+2] = rand_wdata[23:16];
                        ref_mem[rand_waddr+3] = rand_wdata[31:24];
                    end
                    default: ;
                endcase
            end

            // 4. Синхронизируемся с фронтом BRAM
            @(posedge clk);
            #1;

            // 5. Проверка
            if (rdata !== expected_data) begin
                errors++;
                $display("[ERROR @ Test %0d] RADDR: 0x%0h | ROP: %0d | GOT: 0x%0h | EXPECTED: 0x%0h",
                         i, rand_raddr, rand_rop, rdata, expected_data);
                if (errors > 10) begin
                    $display("Too many errors! Aborting simulation.");
                    $stop;
                end
            end

            total_tests++;

            if ((i + 1) % 1_000_000 == 0) begin
                $display("Progress: %0d / %0d tests completed...", i + 1, NUM_TESTS);
            end
        end

        $display("\n==================================================");
        $display("===           FINAL TEST REPORT                ===");
        $display("==================================================");
        $display(" Total Operations Executed : %0d", total_tests);
        $display(" Write Transactions        : %0d", total_writes);
        $display(" Read Transactions         : %0d", total_reads);
        $display(" Reset Transactions        : %0d", total_resets);
        $display(" Errors Found              : %0d", errors);
        $display("--------------------------------------------------");
        
        if (errors == 0) begin
            $display(" 🎉 SUCCESS: All %0d tests passed clean!", NUM_TESTS);
        end else begin
            $display(" ❌ FAIL: Found %0d mismatch errors!", errors);
        end
        $display("==================================================\n");

        $finish;
    end

endmodule