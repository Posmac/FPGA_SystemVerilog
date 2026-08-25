`timescale 1ns / 1ps

import constants::*;

typedef enum logic [3:0] {
    ALU_ADD  = 4'b0000,
    ALU_SUB  = 4'b1000,
    ALU_XOR  = 4'b0100,
    ALU_OR   = 4'b0110,
    ALU_AND  = 4'b0111,
    ALU_SLL  = 4'b0001,
    ALU_SRL  = 4'b0101,
    ALU_SRA  = 4'b1101,
    ALU_SLT  = 4'b0010,
    ALU_SLTU = 4'b0011
} alu_op_t;
// R-types     f3 (3b)    f7 (7b)               4bits opcode {f7[5], f3}   in_num
// add         [000]      0[0]0_0000             0_000 (in_0)               in_0
// sub         [000]      0[1]0_0000             1_000 (in_8)               in_8
// xor         [100]      0[0]0_0000             0_100 (in_4)               in_4
// or          [110]      0[0]0_0000             0_110 (in_6)               in_6
// and         [111]      0[0]0_0000             0_111 (in_7)               in_7

// sll         [001]      0[0]0_0000             0_001 (in_1)               in_1
// srl         [101]      0[0]0_0000             0_101 (in_5)               in_5
// sra         [101]      0[1]0_0000             1_101 (in_13)              in_13
// slt         [010]      0[0]0_0000             0_010 (in_2)               in_2
// sltu        [011]      0[0]0_0000             0_011 (in_3)               in_3

module CPU_tb;
    // Control
    logic clk;
    logic rst;

    //instruction memory wires
    logic [ARCHITECTURE_WIDTH-1:0]    instruction;
    logic [ARCHITECTURE_WIDTH-1:0]    next_instruction_address;
    //data memory wires
    logic                             we;
    logic [ARCHITECTURE_WIDTH-1:0]    waddr;
    logic [ARCHITECTURE_WIDTH-1:0]    wdata;
    logic [2:0]                       w_op;   // 0: SB, 1: SH, 2: SW
    logic [ARCHITECTURE_WIDTH-1:0]    raddr;
    logic [2:0]                       r_op;   // 0: LB, 1: LH, 2: LW, 3: LBU, 4: LHU
    logic [ARCHITECTURE_WIDTH-1:0]    rdata;

    parameter int MEM_SIZE_BYTES = 128;
    parameter int NUM_WORDS      = MEM_SIZE_BYTES / 4;

    //init instruction memory
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
        .r_op(3'b010),
        .rdata(instruction)
    );

    //init data memory
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

    //init CPU
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

    int random_rs1_addr = 0;
    int random_rs2_addr = 0;
    int random_rd_addr = 0;

    int random_rs1_data = 0;
    int random_rs2_data = 0;
    int random_imm_data = 0;

    int error_count = 0;
    int test_count = 0;
    task check_result(string test_name);
        begin
            test_count++;
            // if (imm_ext != expected) begin 
                // $error("Error in IMM Decoder module for INSTR = %b. Wrong output OUT = %d(%b). Expected: %d(B: %b)", instr_in, imm_ext, imm_ext, expected, expected);
            // end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, CPU_tb);

        $display("---------------------------------------");
        $display("SYSTEM TEST FOR 32 bit CPU!");
        $display("---------------------------------------");

        // -------------------------------------------------
        // INIT
        // -------------------------------------------------

        clk = 1'b0;
        rst = 1'b1;

        // -------------------------------------------------
        // PROGRAM LOAD
        // -------------------------------------------------

        // // ADDI x1,x0,15
        // Instruction_memory.mem[0] =
        //     32'b000000001111_00000_000_00001_0010011;

        // // ADDI x2,x0,27
        // Instruction_memory.mem[1] =
        //     32'b000000011011_00000_000_00010_0010011;

        // // ADD x3,x1,x2
        // Instruction_memory.mem[2] =
        //     32'b0000000_00010_00001_000_00011_0110011;

        // // SUB x4,x3,x1
        // Instruction_memory.mem[3] =
        //     32'b0100000_00001_00011_000_00100_0110011;

        //0010011 IMM: imm(12) rs1(5) f3(3) rd(5) opcode(7)
        //0110011 Rtype: f7(7) rs2(5) rs1(5) f3(3) rd(5) opcode(7)

        // //1. ADDI x1, x0, -123
        // Instruction_memory.mem[0] = 32'b111110000101_00000_000_00001_0010011;

        // //2. ADDI x2, x0, 49
        // Instruction_memory.mem[1] = 32'b000000110001_00000_000_00010_0010011;

        // //3. ADD  x3, x1, x2
        // Instruction_memory.mem[2] = 32'b0000000_00010_00001_000_00011_0110011;

        // //4. SUB  x4, x1, x2
        // Instruction_memory.mem[3] = 32'b0100000_00010_00001_000_00100_0110011;

        // //5. XOR  x5, x1, x2
        // Instruction_memory.mem[4] = 32'b0000000_00010_00001_100_00101_0110011;

        // //6. OR   x6, x1, x2
        // Instruction_memory.mem[5] = 32'b0000000_00010_00001_110_00110_0110011;

        // //7. AND  x7, x1, x2
        // Instruction_memory.mem[6] = 32'b0000000_00010_00001_111_00111_0110011;

        // //8. SLL  x8, x1, x2
        // Instruction_memory.mem[7] = 32'b0000000_00010_00001_001_01000_0110011;

        // //9. SRL  x9, x1, x2
        // Instruction_memory.mem[8] = 32'b0000000_00010_00001_101_01001_0110011;

        // //10. SRA x10, x1, x2
        // Instruction_memory.mem[9] = 32'b0100000_00010_00001_101_01010_0110011;

        // //11. SLT  x11,x1, x2
        // Instruction_memory.mem[10] = 32'b0000000_00010_00001_010_01011_0110011;

        // //12. SLTU x12,x1, x2
        // Instruction_memory.mem[11] = 32'b0000000_00010_00001_011_01100_0110011;


        // //1. ADDI x1, x0, -123
        // Instruction_memory.mem[0] = 32'b111110000101_00000_000_00001_0010011;

        // //2. ADDI x2, x0, 49
        // Instruction_memory.mem[1] = 32'b000000110001_00000_000_00010_0010011;

        // //3. ADD  x3, x1, x2
        // Instruction_memory.mem[2] = 32'b0000000_00010_00001_000_00011_0110011;

        // //4. SUB  x4, x1, x2
        // Instruction_memory.mem[3] = 32'b0100000_00010_00001_000_00100_0110011;

        // //5. XOR  x5, x1, x2
        // Instruction_memory.mem[4] = 32'b0000000_00010_00001_100_00101_0110011;

        // //6. OR   x6, x1, x2
        // Instruction_memory.mem[5] = 32'b0000000_00010_00001_110_00110_0110011;

        // //7. AND  x7, x1, x2
        // Instruction_memory.mem[6] = 32'b0000000_00010_00001_111_00111_0110011;

        // //8. SLL  x8, x1, x2
        // Instruction_memory.mem[7] = 32'b0000000_00010_00001_001_01000_0110011;

        // //9. SRL  x9, x1, x2
        // Instruction_memory.mem[8] = 32'b0000000_00010_00001_101_01001_0110011;

        // //10. SRA x10, x1, x2
        // Instruction_memory.mem[9] = 32'b0100000_00010_00001_101_01010_0110011;

        // //11. SLT  x11,x1, x2
        // Instruction_memory.mem[10] = 32'b0000000_00010_00001_010_01011_0110011;

        // //12. SLTU x12,x1, x2
        // Instruction_memory.mem[11] = 32'b0000000_00010_00001_011_01100_0110011;

        // //1. ADDI x1, x0, -123
        // Instruction_memory.mem[0] = 32'b111110000101_00000_000_00001_0010011;

        // //2. ADDI x2, x0, 49
        // Instruction_memory.mem[1] = 32'b000000110001_00000_000_00010_0010011;

        // //3. XORI x3, x1, 49
        // Instruction_memory.mem[2] = 32'b000000110001_00001_100_00011_0010011;

        // //4. ORI x4, x1, 49
        // Instruction_memory.mem[3] = 32'b000000110001_00001_110_00100_0010011;

        // //5. ANDI x5, x1, 49
        // Instruction_memory.mem[4] = 32'b000000110001_00001_111_00101_0010011;

        // //6. SLLI x6, x1, 17
        // Instruction_memory.mem[5] = 32'b0000000_10001_00001_001_00110_0010011;

        // //7. SRLI x7, x1, 17
        // Instruction_memory.mem[6] = 32'b0000000_10001_00001_101_00111_0010011;

        // //8. SRAI x8, x1, 17
        // Instruction_memory.mem[7] = 32'b0100000_10001_00001_101_01000_0010011;

        // //9. SLTI x9, x1, 49
        // Instruction_memory.mem[8] = 32'b000000110001_00001_010_01001_0010011;

        // //10. SLTIU x10, x1, 49
        // Instruction_memory.mem[9] = 32'b000000110001_00001_011_01010_0010011;

        // // x1 = 100
        // Instruction_memory.mem[0] = 32'b000001100100_00000_000_00001_0010011;

        // // x2 = 123
        // Instruction_memory.mem[1] = 32'b000001111011_00000_000_00010_0010011;

        // // SW x2,0(x1)
        // Instruction_memory.mem[2] = 32'b0000000_00010_00001_010_00000_0100011;

        // // LW x3,0(x1)
        // Instruction_memory.mem[3] = 32'b000000000000_00001_010_00011_0000011;

        // // NOP
        // Instruction_memory.mem[4] = 32'h00000013;

        // x1 = 100 (Базовый адрес)
        Instruction_memory.mem[0]  = 32'b000001100100_00000_000_00001_0010011; // ADDI x1, x0, 100

        // x2 = -128 (0xFFFFFF80)
        Instruction_memory.mem[1]  = 32'b111110000000_00000_000_00010_0010011; // ADDI x2, x0, -128

        // SB x2, 0(x1) -> пишем 0x80 в байт 0
        Instruction_memory.mem[2]  = 32'b0000000_00010_00001_000_00000_0100011; // SB (funct3 = 000)

        // LB x3, 0(x1) -> должно дать 0xFFFFFF80 (-128)
        Instruction_memory.mem[3]  = 32'b000000000000_00001_000_00011_0000011; // LB (funct3 = 000)

        // LBU x4, 0(x1) -> должно дать 0x00000080 (128)
        Instruction_memory.mem[4]  = 32'b000000000000_00001_100_00100_0000011; // LBU (funct3 = 100)

        // x2 = 255 (0x000000FF)
        Instruction_memory.mem[5]  = 32'b000011111111_00000_000_00010_0010011; // ADDI x2, x0, 255

        // SB x2, 1(x1) -> пишем 0xFF в байт 1 (адрес 101)
        Instruction_memory.mem[6]  = 32'b0000000_00010_00001_000_00001_0100011; // SB (imm = 1)

        // LBU x5, 1(x1) -> должно дать 0x000000FF (255)
        Instruction_memory.mem[7]  = 32'b000000000001_00001_100_00101_0000011; // LBU (imm = 1)

        // x2 = 0xFFFF8000 (Готовим отриц. полуслово 0x8000)
        Instruction_memory.mem[8]  = 32'b11111111111111111000_00010_0110111;  // LUI x2, 0xFFFFF
        Instruction_memory.mem[9]  = 32'b100000000000_00010_000_00010_0010011; // ADDI x2, x2, -2048

        // SH x2, 2(x1) -> пишем полуслово 0x8000 в байты 2..3 (адрес 102)
        Instruction_memory.mem[10] = 32'b0000000_00010_00001_001_00010_0100011; // SH (funct3 = 001, imm = 2)

        // LH x6, 2(x1) -> должно дать 0xFFFF8000 (-32768)
        Instruction_memory.mem[11] = 32'b000000000010_00001_001_00110_0000011; // LH (funct3 = 001, imm = 2)

        // LHU x7, 2(x1) -> должно дать 0x00008000 (32768)
        Instruction_memory.mem[12] = 32'b000000000010_00001_101_00111_0000011; // LHU (funct3 = 101, imm = 2)

        // LW x8, 0(x1) -> Контрольный чтец всего слова!
        Instruction_memory.mem[13] = 32'b000000000000_00001_010_01000_0000011; // LW (funct3 = 010)

        // NOP
        Instruction_memory.mem[14] = 32'h00000013;

        $display("");
        $display("PROGRAM DUMP");
        $display("mem[0] = %h", Instruction_memory.mem[0]);
        $display("mem[1] = %h", Instruction_memory.mem[1]);
        $display("mem[2] = %h", Instruction_memory.mem[2]);
        $display("mem[3] = %h", Instruction_memory.mem[3]);
        $display("mem[4] = %h", Instruction_memory.mem[4]);
        $display("mem[5] = %h", Instruction_memory.mem[5]);
        $display("mem[6] = %h", Instruction_memory.mem[6]);
        $display("mem[7] = %h", Instruction_memory.mem[7]);
        $display("mem[8] = %h", Instruction_memory.mem[8]);
        $display("mem[9] = %h", Instruction_memory.mem[9]);
        $display("mem[10] = %h", Instruction_memory.mem[10]);
        $display("mem[11] = %h", Instruction_memory.mem[11]);
        $display("mem[12] = %h", Instruction_memory.mem[12]);
        $display("mem[13] = %h", Instruction_memory.mem[13]);
        $display("mem[14] = %h", Instruction_memory.mem[14]);
        $display("");

        // -------------------------------------------------
        // RESET
        // -------------------------------------------------

        repeat (3) @(posedge clk);

        rst = 1'b0;

        $display("");
        $display("RESET RELEASED AT T=%0t", $time);
        $display("");

        // даем процессору поработать
        repeat (15) @(posedge clk);

        // -------------------------------------------------
        // FINAL STATE
        // -------------------------------------------------

        $display("");
        $display("FINAL REGISTER STATE");
        $display("X1 = %h", (cpu.Register_File.registers_out[1]));
        $display("X2 = %h", (cpu.Register_File.registers_out[2]));
        $display("X3 = %h", (cpu.Register_File.registers_out[3]));
        $display("X4 = %h", (cpu.Register_File.registers_out[4]));
        $display("X5 = %h", (cpu.Register_File.registers_out[5]));
        $display("X6 = %h", (cpu.Register_File.registers_out[6]));
        $display("X7 = %h", (cpu.Register_File.registers_out[7]));
        $display("X8 = %h", (cpu.Register_File.registers_out[8]));
        $display("X9 = %h", (cpu.Register_File.registers_out[9]));
        $display("X10 = %h", (cpu.Register_File.registers_out[10]));
        $display("X11 = %h", (cpu.Register_File.registers_out[11]));
        $display("X12 = %h", (cpu.Register_File.registers_out[12]));

        $display("");
        $display("DATA MEMORY STATE");

        $display("mem[25] = %h", Data_memory.mem[25]);
        $display("mem[26] = %h", Data_memory.mem[26]);
        $display("mem[27] = %h", Data_memory.mem[27]);

        $display("X3 = %0d", $signed(cpu.Register_File.registers_out[3]));

        $finish;
    end

    // -------------------------------------------------
    // CLOCK GENERATOR
    // -------------------------------------------------

    always #5 clk = ~clk;

    // -------------------------------------------------
    // DEBUG LOGGER
    // -------------------------------------------------

    always @(posedge clk) begin

        $display("");
        $display("========================================================");
        $display("TIME = %0t", $time);

        $display(
            "CLK=%b RST=%b",
            clk,
            rst
        );

        // $display(
        //     "PC=%0d PC+4=%0d NEXT_INSTR_ADDR=%0d",
        //     cpu.Program_Counter.pc_out,
        //     cpu.Program_Counter.pc_plus4,
        //     next_instruction_address
        // );

        $display(
            "INSTR=%h",
            instruction
        );

        $display(
            "OPCODE=%b RD=%0d RS1=%0d RS2=%0d",
            instruction[6:0],
            instruction[11:7],
            instruction[19:15],
            instruction[24:20]
        );

        $display(
            "MEM_RADDR=%0d MEM_RDATA=%d",
            Instruction_memory.raddr,
            Instruction_memory.rdata
        );

        $display(
            "X1=%h X2=%h, X3=%h  X4=%h X5=%h X6=%h X7=%h X8=%h X9=%h X10=%h X11=%h X12=%h, IMM=%0d, REG WRITE EN: %0d ",
            cpu.Register_File.registers_out[1],
            cpu.Register_File.registers_out[2],
            cpu.Register_File.registers_out[3],
            cpu.Register_File.registers_out[4],
            cpu.Register_File.registers_out[5],
            cpu.Register_File.registers_out[6],
            cpu.Register_File.registers_out[7],
            cpu.Register_File.registers_out[8],
            cpu.Register_File.registers_out[9],
            cpu.Register_File.registers_out[10],
            cpu.Register_File.registers_out[11],
            cpu.Register_File.registers_out[12],
            cpu.imm_ext,
            cpu.reg_file_write_en
        );

        $display(
            "DMEM: WE=%b WADDR=%0d WDATA=%h WOP=%0d",
            we,
            waddr,
            wdata,
            w_op
        );

        $display(
            "DMEM: RADDR=%0d RDATA=%h ROP=%0d",
            raddr,
            rdata,
            r_op
        );

        $display(
            "CPU_MEM: WE=%b WADDR=%0d RADDR=%0d",
            cpu.data_memory_we,
            cpu.data_memory_waddr,
            cpu.data_memory_raddr
        );

        $display(
            "STORE: rs1=%0d rs2=%0d alu_addr=%0d we=%b",
            cpu.Register_File.rdata1,
            cpu.Register_File.rdata2,
            cpu.Alu.a_out,
            cpu.Control_Unit.mem_write
        );

        $display(
            "ALU_OUT=%0d",
            cpu.Alu.a_out
        );

        $display("========================================================");
    end

endmodule