// `timescale 1ns / 1ps

// import constants::*;

// module tb_memory #(
//     parameter int MEM_SIZE_BYTES = 4096 // Размер памяти в байтах для теста
// )(
//     input  logic                          clk,

//     // Порт записи (Write)
//     input  logic                          we,
//     input  logic [ARCHITECTURE_WIDTH-1:0] waddr,
//     input  logic [ARCHITECTURE_WIDTH-1:0] wdata,
//     input  logic [2:0]                    w_op,   // 0: SB, 1: SH, 2: SW

//     // Порт чтения (Read) — выдает данные мгновенно!
//     input  logic [ARCHITECTURE_WIDTH-1:0] raddr,
//     input  logic [2:0]                    r_op,   // 0: LB, 1: LH, 2: LW, 3: LBU, 4: LHU

//     output logic [ARCHITECTURE_WIDTH-1:0] rdata
// );

//     // Память объявляется как байтовый массив — это сильно упрощает жизнь в симуляторе
//     logic [7:0] mem [0:MEM_SIZE_BYTES-1];

//     // ------------------------------------------------------------------------
//     // 1. ЗАПИСЬ (Синхронная по фронту clk)
//     // ------------------------------------------------------------------------
//     always_ff @(posedge clk) begin
//         if (we) begin
//             case (w_op)
//                 3'd0: begin // SB (Store Byte)
//                     mem[waddr] <= wdata[7:0];
//                 end
//                 3'd1: begin // SH (Store Halfword)
//                     mem[waddr]   <= wdata[7:0];
//                     mem[waddr+1] <= wdata[15:8];
//                 end
//                 3'd2: begin // SW (Store Word)
//                     mem[waddr]   <= wdata[7:0];
//                     mem[waddr+1] <= wdata[15:8];
//                     mem[waddr+2] <= wdata[23:16];
//                     mem[waddr+3] <= wdata[31:24];
//                 end
//                 default: ;
//             endcase
//         end
//     end

//     // ------------------------------------------------------------------------
//     // 2. ЧТЕНИЕ (Комбинаторное — данные доступны МГНОВЕННО)
//     // ------------------------------------------------------------------------
//     logic [31:0] raw_word;

//     // Собираем 32-битное слово из байтового массива
//     assign raw_word = { mem[raddr+3], mem[raddr+2], mem[raddr+1], mem[raddr] };

//     always_comb begin
//         case (r_op)
//             3'd0: rdata = {{24{mem[raddr][7]}}, mem[raddr]};             // LB  (Знаковое расширение байта)
//             3'd1: rdata = {{16{mem[raddr+1][7]}}, mem[raddr+1], mem[raddr]}; // LH (Знаковое расширение полуслова)
//             3'd2: rdata = raw_word;                                       // LW  (Слово целиком)
//             3'd3: rdata = {24'b0, mem[raddr]};                            // LBU (Беззнаковый байт)
//             3'd4: rdata = {16'b0, mem[raddr+1], mem[raddr]};              // LHU (Беззнаковое полуслово)
//             default: rdata = 32'b0;
//         endcase
//     end

//     // Инициализация памяти из HEX-файла для тестов
//     initial begin
//         // Заполняем нулями на всякий случай
//         for (int i = 0; i < MEM_SIZE_BYTES; i++) begin
//             mem[i] = 8 me'h00;
//         end
//         // Загружаем прошивку
//         $readmemh("program.mem", mem);
//     end

// endmodule
