#!/usr/bin/env python3
import os
import subprocess
import sys
from pathlib import Path

# Пути
TESTS_DIR = Path("/Users/nicolaiposmac/Work/riscv-tests/isa")
ENV_DIR = Path("/Users/nicolaiposmac/Work/riscv-tests/env")
VERILOG_DIR = Path("/Users/nicolaiposmac/Work/verilog")

# Настройки инструментария
CC = "riscv64-unknown-elf-gcc"
OBJCOPY = "riscv64-unknown-elf-objcopy"

CFLAGS = [
    "-march=rv32i_zicsr",
    "-mabi=ilp32",
    "-static",
    "-nostdlib",
    "-nostartfiles",
    "-ffreestanding",
    "-O2",
    f"-I{ENV_DIR}",
    f"-I{ENV_DIR / 'p'}",
    f"-I{TESTS_DIR / 'macros' / 'scalar'}",
    "-Wl,-Ttext=0x0",
    "-Wl,--entry=_start",
]

EXCLUDE_NAMES = {"Makefrag", "Makefile", "README.md"}
EXCLUDE_EXT = {".dump", ".hex", ".elf", ".o", ".po", ".txt", ".mk", ".py", ".sh"}

def is_test_source(file_path: Path) -> bool:
    if file_path.name in EXCLUDE_NAMES or file_path.name.startswith("."):
        return False
    if file_path.suffix in EXCLUDE_EXT:
        return False
    return True

def run_command(cmd, cwd=None, timeout=None):
    try:
        result = subprocess.run(cmd, cwd=cwd, text=True, timeout=timeout)
        return result.returncode == 0
    except subprocess.TimeoutExpired:
        print(f"⏰ Превышен лимит времени ({timeout} сек)!")
        return False
    except Exception as e:
        print(f"❌ Ошибка выполнения: {e}")
        return False

def main():
    target_dir = TESTS_DIR / "rv32ui" if (TESTS_DIR / "rv32ui").exists() else TESTS_DIR
    test_files = [f for f in target_dir.rglob("*") if f.is_file() and is_test_source(f)]
    
    if not test_files:
        print(f"⚠️  Файлы тестов не найдены в {target_dir}")
        sys.exit(0)

    print(f"=== Найдено тестов: {len(test_files)} в {target_dir} ===")

    passed = 0
    failed = 0

    for src in sorted(test_files):
        # Очищаем имя от .S, чтобы получить чистый 'add', 'addi' и т.д.
        clean_name = src.name.replace(".S", "")
        
        elf_file = VERILOG_DIR / f"{clean_name}.elf"
        hex_file = VERILOG_DIR / f"{clean_name}.hex"

        print(f"\n----------------------------------------")
        print(f"▶ Сборка теста: {clean_name}")

        # 1. Компиляция
        compile_cmd = [CC] + CFLAGS + ["-x", "assembler-with-cpp", str(src), "-o", str(elf_file)]
        if not run_command(compile_cmd):
            failed += 1
            continue

        # 2. Конвертация в hex (выходной файл кладём прямо в VERILOG_DIR)
        objcopy_cmd = [
            OBJCOPY,
            "-O", "verilog",
            "--verilog-data-width=4",
            str(elf_file),
            str(hex_file)
        ]
        if not run_command(objcopy_cmd):
            elf_file.unlink(missing_ok=True)
            failed += 1
            continue

        # 3. Запуск симуляции — передаём только имя hex-файла без полных путей
        print(f"🚀 Запуск симуляции: {hex_file.name}")
        sim_cmd = ["./run_one.sh", f"+HEX_FILE={hex_file.name}"]
        
        if run_command(sim_cmd, cwd=VERILOG_DIR, timeout=10):
            passed += 1
        else:
            print(f"❌ Тест {clean_name} провалился или завис")
            failed += 1

        # Очистка артефактов
        elf_file.unlink(missing_ok=True)
        hex_file.unlink(missing_ok=True)

    print("\n========================================")
    print(f"Итоги: Успешно: {passed} | Ошибок: {failed}")

if __name__ == "__main__":
    main()