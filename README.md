# FPGA RISC-V CPU + GPU

//24.08.2026(21:49 pm) CPU IS ALIVE AND EXECUTED FIRST 4 INSTRUCTIONS PROGRAM!! 
--------------------------------------
SYSTEM TEST FOR 32 bit CPU!
---------------------------------------
 CPU STATUS
CLK: 0, RST: 0
PC=         0, PC+4=         4, INSTR=00f00093
ALU: alu_out:         15, slt_out: 00000000000000000000000000000001, sltu_out: 00000000000000000000000000000001
CLK: 0, RST: 0
Memory: raddr:          4, r_op: 2, rdata: 00000001101100000000000100010011
Reg file: X1:         15, X2:          0, X3:          0, X4:          0 


 CPU STATUS
CLK: 0, RST: 0
PC=         4, PC+4=         8, INSTR=01b00113
ALU: alu_out:         27, slt_out: 00000000000000000000000000000001, sltu_out: 00000000000000000000000000000001
CLK: 0, RST: 0
Memory: raddr:          8, r_op: 2, rdata: 00000000001000001000000110110011
Reg file: X1:         15, X2:         27, X3:          0, X4:          0 


 CPU STATUS
CLK: 0, RST: 0
PC=         8, PC+4=        12, INSTR=002081b3
ALU: alu_out:         42, slt_out: 00000000000000000000000000000001, sltu_out: 00000000000000000000000000000001
CLK: 0, RST: 0
Memory: raddr:         12, r_op: 2, rdata: 01000000000100011000001000110011
Reg file: X1:         15, X2:         27, X3:         42, X4:          0 


 CPU STATUS
CLK: 0, RST: 0
PC=        12, PC+4=        16, INSTR=40118233
ALU: alu_out:         27, slt_out: 00000000000000000000000000000000, sltu_out: 00000000000000000000000000000000
CLK: 0, RST: 0
Memory: raddr:         16, r_op: 2, rdata: 00000000000000000000000000000000
Reg file: X1:         15, X2:         27, X3:         42, X4:         27 
----------------------------------------------------------------
 TESTING COMPLETE!
 Total tests run: 0
 🎉 SUCCESS: All tests passed successfully!
----------------------------------------------------------------

RV32I CPU Integration Status

✅ ADD
✅ SUB
✅ XOR
✅ OR
✅ AND
✅ SLL
✅ SRL
✅ SRA
✅ SLT
✅ SLTU

✅ ADDI
✅ XORI
✅ ORI
✅ ANDI
✅ SLLI
✅ SRLI
✅ SRAI
✅ SLTI
✅ SLTIU

✅ LB
✅ LH
✅ LH
✅ LBU
✅ LHU

✅ SB
✅ SH 
✅ SW 

Verified through full CPU datapath:
Fetch -> Decode -> Execute -> Writeback

RV32I STATUS

✅ Program Counter
✅ Instruction Memory
✅ Register File
✅ Immediate Decoder
✅ ALU
✅ R-Type Instructions
✅ I-Type Instructions
✅ L-Type Instructions
✅ S-Type Instructions


## 1. Why this project exists
This project exists to build a custom computing platform on FPGA and go through the full path from basic logic blocks to a working CPU + GPU system.

Practical value:
- hands-on digital design practice in SystemVerilog;
- understanding how CPU datapath and control path are built;
- creating a base for graphics and system-level experiments on real hardware.

## 2. Project goal: CPU + GPU
Build an FPGA system with a 32-bit RISC-V CPU and a simple GPU block.

Final target:
- CPU: a 5-stage pipeline (IF, ID, EX, MEM, WB), starting with RV32I and then extending to RV32M;
- GPU: a separate memory-mapped block for basic graphics output;
- CPU and GPU connected through shared memory/interface and synchronization.

## 3. Implementation plan (high-level)
1. ALU
- finalize and stabilize RV32I operations (add/sub/logic/shift/slt/sltu);
- remove simulation incompatibilities and close basic corner cases.

2. PC and Fetch
- implement the program counter (PC), increment logic, and branch/jump redirection;
- add instruction fetch logic (IF stage).

3. Decoder and Control
- decode RV32I instructions;
- generate control signals for ALU, register file, memory, and branch logic.

4. Register file and Datapath
- integrate the register file and immediate generator;
- assemble the full datapath across pipeline stages.

5. Memory
- connect instruction and data memory;
- prepare MMIO space for peripherals and GPU.

6. Synchronization
- add forwarding, stall, and flush handling for hazards;
- synchronize CPU and GPU via control/status registers and interrupts/polling.

7. GPU block
- first working version: framebuffer or tile-based block;
- minimal graphics demo scenario.

## 4. What is already done
The repository already contains a working foundation of low-level logic and ALU-related components.

Completed modules:
- one-bit primitives: AND/OR/XOR/XNOR/NOT/NAND/NOR, half adder, full adder, mux;
- multi-bit blocks: adder, subtractor, incrementor, decrementor, invertor, bitwise logic;
- shift and compare blocks: sll/srl/sra/slt/sltu;
- immediate preprocessing and branch blocks: imm_pre_alu, branching;
- composite blocks: arithmetic_unit, logic_unit, mux_2op, mux_4op;
- top-level RV32I R-type ALU with operation selection by op_in.

Verification done:
- unit testbenches exist for basic blocks (including random testing for part of the 32-bit arithmetic);
- a synthesis artifact (Yosys JSON) exists to inspect logic structure.

Current state:
- the CPU foundation is ready;
- the next major step is integrating the full 5-stage pipeline around the current ALU and datapath blocks.

  <img width="1212" height="952" alt="image" src="https://github.com/user-attachments/assets/fd9a6738-2000-4d46-89f0-76fabb85364c" />

