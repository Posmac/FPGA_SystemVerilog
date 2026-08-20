
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module alu_tb -Wno-UNOPTFLAT -f files.f
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module imm_decoder_tb -Wno-UNOPTFLAT -f files.f
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module branching_tb -Wno-UNOPTFLAT -f files.f
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module control_unit_tb -Wno-UNOPTFLAT -f files.f
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module program_counter_tb -Wno-UNOPTFLAT -f files.f
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module register_file_tb -Wno-UNOPTFLAT -f files.f

./obj_dir/Valu_tb
./obj_dir/Vimm_decoder_tb
./obj_dir/Vbranching_tb
./obj_dir/Vcontrol_unit_tb
./obj_dir/Vprogram_counter_tb
./obj_dir/Vregister_file_tb