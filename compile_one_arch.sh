
ARCH_TEST_ROOT="/Users/nicolaiposmac/Work/riscv-arch-test"

riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 \
    -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
    -DTEST_FLEN=0 \
    -DTEST_FILE='"I-add-00.S"' \
    -DSAIL_CLINT_BASE_ADDRESS=0x0 \
    -DSAIL_SIMPLE_INTERRUPT_GENERATOR_BASE_ADDRESS=0x0 \
    -I./env \
    -I$ARCH_TEST_ROOT/tests/env \
    -I$ARCH_TEST_ROOT/config/spike/spike-RVI20U32 \
    -T env/link.ld \
    /Users/nicolaiposmac/Work/riscv-arch-test/tests/rv32i/I/I-add-00.S \
    -o /Users/nicolaiposmac/Work/verilog/arch_hex/I-add-00.elf

# # Путь к корню репозитория riscv-arch-test
# ARCH_TEST_ROOT="/Users/nicolaiposmac/Work/riscv-arch-test/tests"

# riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 \
#     -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
#     -I./env \
#     -I$ARCH_TEST_ROOT/env \
#     -I$ARCH_TEST_ROOT/framework/include \
#     -T env/link.ld \
#     /Users/nicolaiposmac/Work/riscv-arch-test/tests/rv32i/I/I-add-00.S \
#     -o /Users/nicolaiposmac/Work/verilog/arch_hex/I-add-00.elf

# # 1. Компиляция assembly -> ELF
# riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 \
#     -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles \
#     -I./env \
#     -T env/link.ld \
#     /Users/nicolaiposmac/Work/riscv-arch-test/tests/rv32i/I/I-add-00.S \
#     -o /Users/nicolaiposmac/Work/verilog/arch_hex/I-add-00.elf

# 2. Извлечение адресов сигнатуры (они понадобятся тестбенчу!)
riscv64-unknown-elf-nm /Users/nicolaiposmac/Work/verilog/arch_hex/I-add-00.elf | grep -E "(begin_signature|end_signature)"

# 3. Перевод ELF в HEX для $readmemh в SystemVerilog
riscv64-unknown-elf-objcopy -O verilog /Users/nicolaiposmac/Work/verilog/arch_hex/I-add-00.elf \
            /Users/nicolaiposmac/Work/verilog/arch_hex/I-add-00.hex