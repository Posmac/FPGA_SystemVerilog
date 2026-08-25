
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module alu_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module imm_decoder_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module branching_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module control_unit_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module program_counter_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module register_file_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module memory_unit_tb -Wno-UNOPTFLAT -f files.f
verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module CPU_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module sr_latch_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module d_latch_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module d_flip_flop_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module register_multi_tb -Wno-UNOPTFLAT -f files.f

# clear & clear

# ./obj_dir/Valu_tb
# ./obj_dir/Vimm_decoder_tb
# ./obj_dir/Vbranching_tb
# ./obj_dir/Vcontrol_unit_tb
# ./obj_dir/Vprogram_counter_tb
# ./obj_dir/Vregister_file_tb
# ./obj_dir/Vmemory_unit_tb
./obj_dir/VCPU_tb
# ./obj_dir/Vsr_latch_tb
# ./obj_dir/Vd_latch_tb
# ./obj_dir/Vd_flip_flop_tb
# ./obj_dir/Vregister_multi_tb