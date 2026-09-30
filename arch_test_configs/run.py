import argparse
import filecmp
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ELF_DIR = ROOT / "work/cvw-rv32imc/elfs/rv32i/I"
REFERENCE_DIR = ROOT / "work/cvw-rv32imc/build/rv32i/I"
RESULTS_DIR = ROOT / "work/cvw-rv32imc/dut-results"
SIM_EXECUTABLE = ROOT.parent / "verilog/obj_dir/Vriscv_arch_tests_tb"

print(ROOT.parent)

def signature_bounds(elf_path: Path) -> tuple[str, str]:
    output = subprocess.check_output(["riscv64-unknown-elf-nm", elf_path], text=True)
    symbols = {}
    for line in output.splitlines():
        fields = line.split()
        if len(fields) >= 3:
            symbols[fields[-1]] = fields[0]

    try:
        return symbols["begin_signature"], symbols["end_signature"]
    except KeyError as error:
        raise RuntimeError(f"missing ELF symbol: {error.args[0]}") from error


def create_hex(elf_path: Path, bin_path: Path, hex_path: Path) -> None:
    subprocess.run(
        ["riscv64-unknown-elf-objcopy", "-O", "binary", elf_path, bin_path],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.PIPE,
        text=True,
    )
    data = bin_path.read_bytes()
    data += b"\x00" * (-len(data) % 4)

    with hex_path.open("w") as hex_file:
        for offset in range(0, len(data), 4):
            word = int.from_bytes(data[offset : offset + 4], byteorder="little")
            hex_file.write(f"{word:08x}\n")

    bin_path.unlink()


def classify_log(log_path: Path, returncode: int) -> str:
    passed = False
    failed = False
    timed_out = False
    with log_path.open(errors="replace") as log_file:
        for line in log_file:
            passed |= "[TB] TEST PASSED" in line
            failed |= "[TB] TEST FAILED" in line
            timed_out |= "Simulation timeout reached" in line

    if passed:
        return "PASS"
    if failed:
        return "FAIL"
    if timed_out:
        return "TIMEOUT"
    return "ERROR" if returncode else "UNKNOWN"


def compare_signature(elf_path: Path, signature_path: Path, log_path: Path) -> tuple[str, float]:
    start_time = time.monotonic()
    reference_path = REFERENCE_DIR / f"{elf_path.stem}.sig"

    if not signature_path.is_file():
        status = "ERROR"
        message = f"DUT signature not found: {signature_path}"
    elif not reference_path.is_file():
        status = "ERROR"
        message = f"Sail reference signature not found: {reference_path}"
    elif filecmp.cmp(signature_path, reference_path, shallow=False):
        status = "PASS"
        message = f"DUT signature matches Sail reference: {reference_path}"
    else:
        status = "MISMATCH"
        message = f"DUT signature differs from Sail reference: {reference_path}"

    log_path.write_text(f"{message}\n")
    return status, time.monotonic() - start_time


def run_test(elf_path: Path, timeout: float) -> tuple[str, float, Path, str, float, Path]:
    test_dir = RESULTS_DIR / elf_path.stem
    test_dir.mkdir(parents=True, exist_ok=True)
    bin_path = test_dir / "program.bin"
    hex_path = test_dir / "program.hex"
    signature_path = test_dir / "dut.signature"
    log_path = test_dir / "simulation.log"
    signature_log_path = test_dir / "signature.log"
    start_time = time.monotonic()
    signature_path.unlink(missing_ok=True)

    try:
        start_sig, end_sig = signature_bounds(elf_path)
        create_hex(elf_path, bin_path, hex_path)
        command = [
            os.fspath(SIM_EXECUTABLE),
            f"+HEX_FILE={hex_path}",
            f"+SIGNATURE={signature_path}",
            f"+SIG_START=0x{start_sig}",
            f"+SIG_END=0x{end_sig}",
        ]
        with log_path.open("w") as log_file:
            result = subprocess.run(
                command,
                stdout=log_file,
                stderr=subprocess.STDOUT,
                timeout=timeout,
                check=False,
            )
        status = classify_log(log_path, result.returncode)
    except subprocess.TimeoutExpired:
        status = "TIMEOUT"
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        log_path.write_text(f"{type(error).__name__}: {error}\n")
        status = "ERROR"

    duration = time.monotonic() - start_time
    signature_status, signature_duration = compare_signature(elf_path, signature_path, signature_log_path)
    return status, duration, log_path, signature_status, signature_duration, signature_log_path


def color_status(status: str) -> str:
    if not sys.stdout.isatty():
        return status
    colors = {
        "PASS": "\033[32m",
        "FAIL": "\033[31m",
        "MISMATCH": "\033[31m",
        "TIMEOUT": "\033[33m",
        "ERROR": "\033[35m",
        "UNKNOWN": "\033[36m",
    }
    return f"{colors[status]}{status}\033[0m"


def main() -> int:
    parser = argparse.ArgumentParser(description="Run self-checking RV32I ELFs on the Verilator DUT")
    parser.add_argument("--test", help="run one test by stem, for example I-add-00")
    parser.add_argument("--timeout", type=float, default=60.0, help="wall-clock timeout per test in seconds")
    args = parser.parse_args()

    if not SIM_EXECUTABLE.is_file():
        parser.error(f"simulation binary not found: {SIM_EXECUTABLE}")

    elf_paths = sorted(ELF_DIR.glob("*.elf"))
    if args.test:
        elf_paths = [path for path in elf_paths if path.stem == args.test]
    if not elf_paths:
        parser.error(f"no matching ELF files found in {ELF_DIR}")

    RESULTS_DIR.mkdir(parents=True, exist_ok=True)
    results = []
    total = len(elf_paths)
    denominator = f"{total}+{total}"
    print(f"Running {total} RV32I tests and {total} signature checks\n")
    for index, elf_path in enumerate(elf_paths, start=1):
        test_number = index * 2 - 1
        dump_number = index * 2
        print(f"[{test_number:02d}/{denominator}] {elf_path.stem:<23}", end="", flush=True)
        status, duration, log_path, dump_status, dump_duration, dump_log_path = run_test(elf_path, args.timeout)
        results.append((elf_path.stem, status, duration, log_path))
        print(f" {color_status(status):<16} {duration:7.2f}s")
        dump_name = f"{elf_path.stem}_dump"
        results.append((dump_name, dump_status, dump_duration, dump_log_path))
        print(f"[{dump_number:02d}/{denominator}] {dump_name:<23} {color_status(dump_status):<16} {dump_duration:7.2f}s")

    print("\nResults")
    print(f"{'Test':<20} {'Status':<10} {'Time':>9}  Log")
    print(f"{'-' * 20} {'-' * 10} {'-' * 9}  {'-' * 30}")
    for name, status, duration, log_path in results:
        print(f"{name:<20} {color_status(status):<18} {duration:8.2f}s  {log_path.relative_to(ROOT)}")

    counts = {
        status: sum(result[1] == status for result in results)
        for status in ("PASS", "FAIL", "MISMATCH", "TIMEOUT", "ERROR", "UNKNOWN")
    }
    print(
        f"\nTotal: {len(results)} | PASS: {counts['PASS']} | FAIL: {counts['FAIL']} | "
        f"MISMATCH: {counts['MISMATCH']} | TIMEOUT: {counts['TIMEOUT']} | "
        f"ERROR: {counts['ERROR'] + counts['UNKNOWN']}"
    )
    return 0 if counts["PASS"] == len(results) else 1


if __name__ == "__main__":
    raise SystemExit(main())