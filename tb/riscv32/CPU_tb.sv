`timescale 1ns / 1ps

import constants::*;

module CPU_tb;
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

    parameter int MEM_SIZE_BYTES = 256;
    parameter int NUM_WORDS      = MEM_SIZE_BYTES / 4;

    // Init instruction memory
    Memory_Unit #(
        .MEM_SIZE_BYTES(MEM_SIZE_BYTES)
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

    // Init data memory
    Memory_Unit #(
        .MEM_SIZE_BYTES(MEM_SIZE_BYTES)
    ) Data_memory (
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
        $dumpfile("dump.vcd");
        $dumpvars(0, CPU_tb);

        $display("---------------------------------------");
        $display("FULL SYSTEM SMOKE TEST (RV32I)");
        $display("---------------------------------------");

        clk = 1'b0;
        rst = 1'b1;

        // -------------------------------------------------
        // PROGRAM LOAD (Вектор инструкций с ветвлением)
        // -------------------------------------------------
        // Word index = PC / 4

        // 0x00: addi x2, x0, 3       (x2 = 3, счетчик цикла)
        Instruction_memory.mem[0]  = 32'h00300113;

        // 0x04: addi x3, x0, 0       (x3 = 0, аккумулятор суммы)
        Instruction_memory.mem[1]  = 32'h00000193;

        // 0x08: loop: add x3, x3, x2 (x3 = x3 + x2)
        Instruction_memory.mem[2]  = 32'h002181b3;

        // 0x0C: addi x2, x2, -1      (x2 = x2 - 1)
        Instruction_memory.mem[3]  = 32'hfff10113;

        // 0x10: bne x2, x0, -8       (если x2 != 0, прыжок назад на 0x08 -> offset = -8)
        Instruction_memory.mem[4]  = 32'hfe011ce3;

        // 0x14: addi x4, x0, 6       (x4 = 6, ожидаемая сумма 3+2+1)
        Instruction_memory.mem[5]  = 32'h00600213;

        // 0x18: bne x3, x4, 16       (если x3 != x4, прыжок на FAIL -> offset = +16)
        Instruction_memory.mem[6]  = 32'h00419863;

        // 0x1C (28): jal x1, 8  (прыжок с 28 на 36 -> PASS)
        Instruction_memory.mem[7] = 32'h008000ef;

        // 0x20: FAIL: addi x10, x0, 0xBAD (x10 = 0xBAD -> МАРКЕР ОШИБКИ)
        Instruction_memory.mem[8]  = 32'hbad00513;

        // 0x24: PASS: addi x10, x0, 0xA5  (x10 = 0xA5  -> МАРКЕР УСПЕХА!)
        Instruction_memory.mem[9]  = 32'h0a500513;

        // 0x28: NOP
        Instruction_memory.mem[10] = 32'h00000013;

        // -------------------------------------------------
        // RESET RELEASE
        // -------------------------------------------------
        repeat (3) @(posedge clk);
        rst = 1'b0;

        $display("\nRESET RELEASED AT T=%0t\n", $time);

        // Даем времени на прохождение цикла и прыжков
        repeat (25) @(posedge clk);

        // -------------------------------------------------
        // FINAL STATE VERIFICATION
        // -------------------------------------------------
        $display("\n========================================================");
        $display("FINAL CPU STATE VERIFICATION");
        $display("========================================================");
        $display("PC Address : 0x%d", next_instruction_address);
        $display("X1 (RA)    : 0x%h (Expected: 0x00000020)", cpu.Register_File.registers_out[1]);
        $display("X2 (cnt)   : 0x%h (Expected: 0x00000000)", cpu.Register_File.registers_out[2]);
        $display("X3 (sum)   : 0x%h (Expected: 0x00000006)", cpu.Register_File.registers_out[3]);
        $display("X4 (target): 0x%h (Expected: 0x00000006)", cpu.Register_File.registers_out[4]);
        $display("--------------------------------------------------------");
        $display("X10 (STATUS CODE): 0x%h", cpu.Register_File.registers_out[10]);
        
        if (cpu.Register_File.registers_out[10] == 32'h000000A5) begin
            $display(">> RESULT: SUCCESS! ALL BRANCHES & JUMPS PASSED! <<");
        end else begin
            $display(">> RESULT: FAILED! (Status code != 0xA5) <<");
        end
        $display("========================================================\n");

        $finish;
    end

    // -------------------------------------------------
    // CLOCK GENERATOR
    // -------------------------------------------------
    always #5 clk = ~clk;

    // -------------------------------------------------
    // DEBUG LOGGER (Потактный логер для вейвформ)
    // -------------------------------------------------
    always @(posedge clk) begin
        if (!rst) begin
            $display("T=%0t | PC=0x%d | INSTR=0x%h | X2=%0d X3=%0d X10=0x%h",
                $time,
                next_instruction_address,
                instruction,
                cpu.Register_File.registers_out[2],
                cpu.Register_File.registers_out[3],
                cpu.Register_File.registers_out[10]
            );
        end
    end

endmodule