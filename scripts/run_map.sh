#!/usr/bin/env bash
set -euo pipefail

: "${LIBERTY_FILE:?Set LIBERTY_FILE=/absolute/path/to/typical.lib}"

mkdir -p build reports

sed "s|@LIBERTY_FILE@|${LIBERTY_FILE}|g" \
    scripts/synth_yosys_map.ys.in \
    > build/synth_yosys_map.ys

yosys -s build/synth_yosys_map.ys | tee reports/yosys_mapped_synth.log
