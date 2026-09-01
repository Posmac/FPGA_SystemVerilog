#!/usr/bin/env bash

HEX_DIR="/Users/nicolaiposmac/Work/riscv-tests/hex_files"
SIM="./obj_dir/Vriscv_tests_tb"

passed=0
failed=0
failed_tests=()

echo "---------------------------------------"
echo " 🚀 RUNNING ALL RV32UI COMPLIANCE TESTS "
echo "---------------------------------------"

for hex in "$HEX_DIR"/rv32ui-p-*.hex; do
    [ -f "$hex" ] || continue
    test_name=$(basename "$hex" .hex)
    
    # Запуск симуляции и перехват вывода
    output=$("$SIM" "+HEX_FILE=$hex" 2>&1)
    
    if echo "$output" | grep -q "TEST PASSED SUCCESSFULLY"; then
        echo "✅ $test_name ... PASSED"
        passed=$((passed + 1))
    else
        echo "❌ $test_name ... FAILED"
        failed=$((failed + 1))
        failed_tests+=("$test_name")
    fi
done

echo "---------------------------------------"
echo "📊 ИТОГ: Прошло: $passed | Упало: $failed"
if [ ${#failed_tests[@]} -gt 0 ]; then
    echo "Список упавших тестов:"
    for t in "${failed_tests[@]}"; do
        echo "  - $t"
    done
fi
echo "---------------------------------------"