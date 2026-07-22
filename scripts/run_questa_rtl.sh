#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REPORT_DIR="reports"
COMPILE_LOG="$REPORT_DIR/questa_compile.log"
SIM_LOG="$REPORT_DIR/questa_sim.log"
SUMMARY_LOG="$REPORT_DIR/questa_test_summary.log"
SEED="${QUESTA_SEED:-1}"

mkdir -p "$REPORT_DIR" waves build
rm -rf work transcript vsim.wlf modelsim.ini
rm -f "$COMPILE_LOG" "$SIM_LOG" "$SUMMARY_LOG"

echo "========================================"
echo "Questa RTL regression"
echo "Project : $ROOT_DIR"
echo "Seed    : $SEED"
echo "========================================"

set +e
{
    echo "[SETUP] Creating work library"
    vlib work
    vmap work work

    echo "[COMPILE] vlog -sv -work work -f tb/filelist.f"
    vlog -sv -work work -f tb/filelist.f
} 2>&1 | tee "$COMPILE_LOG"
compile_status=${PIPESTATUS[0]}
set -e

if [[ $compile_status -ne 0 ]]; then
    {
        echo "Wallace Multiplier Pipeline-3 RTL Simulation"
        echo "Result                : COMPILE_FAIL"
        echo "Seed                  : $SEED"
        echo "Compile log           : $COMPILE_LOG"
    } > "$SUMMARY_LOG"
    echo "[FAIL] Compile failed. See $COMPILE_LOG"
    exit "$compile_status"
fi

echo "[PASS] Compile completed. Log: $COMPILE_LOG"

set +e
vsim -c \
    -sv_seed "$SEED" \
    -voptargs=+acc \
    -l "$SIM_LOG" \
    work.tb_wallace_mul_u16_pipe3 \
    -do "onerror {quit -code 1 -force}; log -r /*; run -all; quit -code 0 -force"
sim_status=$?
set -e

accepted="$(grep -E 'Accepted transactions[[:space:]]*:' "$SIM_LOG" | tail -1 | sed -E 's/^#[[:space:]]*//' || true)"
checked="$(grep -E 'Checked transactions[[:space:]]*:' "$SIM_LOG" | tail -1 | sed -E 's/^#[[:space:]]*//' || true)"
scoreboard_errors="$(grep -E '^#[[:space:]]*Errors[[:space:]]*:' "$SIM_LOG" | head -1 | sed -E 's/^#[[:space:]]*//' || true)"

result="PASS"
if [[ $sim_status -ne 0 ]]; then
    result="SIM_FAIL"
elif ! grep -q "ALL TESTS PASSED" "$SIM_LOG"; then
    result="TEST_FAIL"
elif ! grep -Eq '^#[[:space:]]*Errors[[:space:]]*:[[:space:]]*0[[:space:]]*$' "$SIM_LOG"; then
    result="TEST_FAIL"
fi

{
    echo "Wallace Multiplier Pipeline-3 RTL Simulation"
    echo "Result                : $result"
    echo "Seed                  : $SEED"
    [[ -n "$accepted" ]] && echo "$accepted"
    [[ -n "$checked" ]] && echo "$checked"
    [[ -n "$scoreboard_errors" ]] && echo "$scoreboard_errors"
    echo "Compile log           : $COMPILE_LOG"
    echo "Simulation log        : $SIM_LOG"
    echo "Waveform              : vsim.wlf"
} > "$SUMMARY_LOG"

cat "$SUMMARY_LOG"

if [[ "$result" != "PASS" ]]; then
    echo "[FAIL] Questa RTL regression failed. See $SIM_LOG"
    exit 1
fi

echo "========================================"
echo "[PASS] Questa RTL regression completed"
echo "Compile log : $COMPILE_LOG"
echo "Simulation  : $SIM_LOG"
echo "Summary     : $SUMMARY_LOG"
echo "Waveform    : vsim.wlf"
echo "========================================"
