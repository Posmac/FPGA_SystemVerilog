#!/bin/bash
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module alu_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module imm_decoder_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module branching_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module control_unit_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module program_counter_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module register_file_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module memory_unit_tb -Wno-UNOPTFLAT -f files.f
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module riscv_tests_tb -Wno-UNOPTFLAT -f files.f
# verilator_bin --binary --main -j 0 --trace --timescale 1ns/1ps --top-module riscv_tests_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module sr_latch_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module d_latch_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module d_flip_flop_tb -Wno-UNOPTFLAT -f files.f
# # verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module register_multi_tb -Wno-UNOPTFLAT -f files.f

# # clear & clear

# # ./obj_dir/Valu_tb
# # ./obj_dir/Vimm_decoder_tb
# # ./obj_dir/Vbranching_tb
# # ./obj_dir/Vcontrol_unit_tb
# # ./obj_dir/Vprogram_counter_tb
# # ./obj_dir/Vregister_file_tb
# # ./obj_dir/Vmemory_unit_tb
# ./obj_dir/Vriscv_tests_tb +HEX_FILE=c_src/towers.hex
# # ./obj_dir/Vsr_latch_tb
# # ./obj_dir/Vd_latch_tb
# # ./obj_dir/Vd_flip_flop_tb
# # ./obj_dir/Vregister_multi_tb

#!/bin/bash
# Перекомпилируем тестбенч, если нужно (или это делается отдельно)
# verilator --binary -j 0 --trace --timescale 1ns/1ps --top-module riscv_tests_tb -Wno-UNOPTFLAT -f files.f

# verilator_bin --binary --main -j 0 --trace --timescale 1ns/1ps --top-module riscv_tests_tb -Wno-UNOPTFLAT -f files.f
verilator_bin --binary --main -j 0 --trace --timescale 1ns/1ps --top-module riscv_arch_tests_tb -Wno-UNOPTFLAT -f files.f

# Запускаем бинарник Verilator, передавая hex-файл из первого аргумента ($1)
if [[ "$1" == +HEX_FILE=* ]]; then
	hex_arg="$1"
else
	hex_arg="+HEX_FILE=$1"
fi

# ./obj_dir/Vriscv_tests_tb "$hex_arg"
./obj_dir/Vriscv_arch_tests_tb "$hex_arg"