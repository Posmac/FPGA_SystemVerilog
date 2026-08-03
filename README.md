# FPGA RISC-V32IM CPU + GPU

## Project goal
Build an educational but synthesis-friendly FPGA SoC around a 5-stage pipelined RISC-V 32-bit CPU (RV32I first, then RV32M) and a simple GPU/video pipeline.

Target outcomes:
- Stable RV32I ALU and core datapath on FPGA
- Stable 5-stage CPU pipeline (IF/ID/EX/MEM/WB)
- Deterministic hazard handling (forwarding, stalls, flushes)
- RV32M extension support (MUL/DIV family)
- Memory-mapped GPU block (framebuffer or tile engine)
- Repeatable simulation and synthesis flow

## Target CPU microarchitecture
- Pipeline: IF -> ID -> EX -> MEM -> WB
- Baseline ISA: RV32I
- Next ISA step: RV32M
- Required control features:
	- data hazard detection and forwarding
	- load-use stall insertion
	- branch/jump flush and PC redirection
	- clean reset and pipeline register initialization

## Current state
Status: pre-alpha (foundation stage).

What is already in the repository:
- One-bit logic cells and combinational primitives in src/one_bit
- Multi-bit arithmetic and logic blocks in src/multi_bit
- Composite units in src/elements
- RV32I ALU top-level draft in src/riscv32i/alu.sv
- Several self-checking testbenches in tb (adder, subtractor, incrementor, gates)
- Synthesis artifact example in build/rls.json

## Quality assessment
Overall score: 6.0/10.

Strengths:
- Good decomposition into one-bit and multi-bit reusable blocks
- Uses parameterized architecture width through constants package
- Includes random plus corner-case style tests for some arithmetic modules
- Clear educational intent and readable module boundaries

Main risks and issues:
- Build and simulation flow is not yet reproducible end-to-end (command hints are partially outdated)
- Shift path still has simulator portability issues (Icarus does not support the streaming concatenation used in sll)
- Partial test coverage for RV32I ALU operations and no integration-level CPU tests yet
- Mixed naming style and typo drift reduce maintainability (example: SUBSTRACTOR spelling)

## Done checklist
- [x] Basic one-bit gates and adders
- [x] 32-bit adder/subtractor/incrementor/decrementor family
- [x] 32-bit bitwise blocks (and/or/xor/xnor/invert)
- [x] Initial shift and compare blocks (sll/srl/sra/slt/sltu)
- [x] ALU shift wiring migrated to SLL/SRL/SRA modules
- [x] Initial ALU wiring for RV32I R-type operation map
- [x] Initial unit-level testbenches

## Work remaining
Priority 0 (stabilization):
- [x] Explicitly wire shift amount as b_in[4:0] in ALU shift ops
- [ ] Resolve sll implementation portability for Icarus (or standardize on a simulator that supports current syntax)
- [ ] Unify and verify simulator command set (iverilog/verilator/questa)
- [ ] Add a single smoke test that compiles all RTL and runs at least one ALU test

Priority 1 (RV32I core readiness):
- [ ] Finalize ALU operation truth table against RISC-V spec
- [ ] Add branch compare outputs and flags as needed by control path
- [ ] Build register file, immediate generator, and control decoder
- [ ] Implement pipeline registers IF/ID, ID/EX, EX/MEM, MEM/WB
- [ ] Implement forwarding unit (EX/MEM -> EX, MEM/WB -> EX)
- [ ] Implement hazard unit (load-use stall + control hazard flush)
- [ ] Implement branch/jump resolution path and PC muxing
- [ ] Add instruction-level tests for ADD/SUB/logic/shift/SLT/SLTU

Priority 2 (RV32M extension):
- [ ] Add MUL, MULH, MULHSU, MULHU
- [ ] Add DIV, DIVU, REM, REMU with defined latency and corner-case behavior
- [ ] Extend decode/control and verification suite for RV32M

Priority 3 (memory subsystem and platform):
- [ ] Introduce instruction/data memory model and bus interface
- [ ] Define MMIO map
- [ ] Add timer/UART or debug MMIO for bring-up

Priority 4 (GPU block):
- [ ] Choose first GPU scope: framebuffer blitter or tile rasterizer
- [ ] Define CPU-GPU command interface and synchronization
- [ ] Add video timing output path (for example VGA/HDMI pipeline)
- [ ] Add demo workload (moving sprite, triangle, or Mandelbrot)

Priority 5 (FPGA implementation):
- [ ] Add board constraints and clock/reset tree
- [ ] Add synthesis, PnR, timing, and bitstream scripts
- [ ] Close timing and run on hardware
- [ ] Measure LUT/FF/BRAM/DSP and Fmax, then optimize

## Suggested repository structure growth
- docs/ for architecture notes and ISA compliance tracking
- sim/ for unified simulation scripts
- scripts/ for synthesis and CI helpers
- ci/ for lint and smoke checks

## Suggested development workflow
1. Keep every RTL change paired with at least one test update.
2. Run lint + compile + unit tests before committing.
3. Track ISA coverage in a visible checklist.
4. Add a lightweight CI smoke pipeline early.

## Near-term milestone proposal (2-4 weeks)
- Milestone M1: RV32I ALU stable and fully tested
- Milestone M2: 5-stage RV32I pipeline runs arithmetic and memory microprograms in simulation
- Milestone M3: Hazard logic validated (forwarding/stall/flush test matrix green)
- Milestone M4: FPGA bring-up with UART prints and basic GPU MMIO register access

## Notes
This repository has a strong educational hardware base. The main next step is engineering hardening: consistent interfaces, deterministic build flow, and coverage-driven verification.
