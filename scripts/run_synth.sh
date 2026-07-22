#!/usr/bin/env bash
set -euo pipefail

mkdir -p build reports

yosys -s scripts/synth_yosys.ys | tee reports/yosys_generic_synth.log
