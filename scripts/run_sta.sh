#!/usr/bin/env bash
set -euo pipefail

: "${LIBERTY_FILE:?Set LIBERTY_FILE=/absolute/path/to/typical.lib}"
export GATE_NETLIST="${GATE_NETLIST:-build/wallace_mul_u16_pipe3_mapped.v}"

mkdir -p reports

if command -v sta >/dev/null 2>&1; then
    sta scripts/opensta_sta.tcl | tee reports/opensta_timing.rpt
elif command -v opensta >/dev/null 2>&1; then
    opensta scripts/opensta_sta.tcl | tee reports/opensta_timing.rpt
else
    echo "ERROR: OpenSTA executable not found (sta/opensta)" >&2
    exit 127
fi
