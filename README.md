# FPGA RISC-V CPU + GPU

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

