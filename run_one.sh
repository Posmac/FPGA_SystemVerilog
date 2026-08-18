
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module alu_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module imm_decoder_tb -Wno-UNOPTFLAT -f files.f
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module branching_tb -Wno-UNOPTFLAT -f files.f

# ./obj_dir/Valu_tb
# ./obj_dir/Vimm_decoder_tb
./obj_dir/Vbranching_tb
