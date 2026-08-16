# 1. Записываем constants.sv первым
echo "src/constants.sv" > files.f

# 2. Находим все остальные .sv файлы по папкам и добавляем их
find src/one_bit src/multi_bit src/elements src/memory src/riscv32i -name "*.sv" >> files.f

# 3. В конце добавляем тестбенч
echo "tb/riscv32/alu_tb.sv" >> files.f