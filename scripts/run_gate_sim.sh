#!/usr/bin/env bash
set -euo pipefail

: "${GATE_NETLIST:?Set GATE_NETLIST=/absolute/path/to/post-route.v}"
: "${SDF_FILE:?Set SDF_FILE=/absolute/path/to/post-route.sdf}"
: "${CELL_SIM_MODELS:?Set CELL_SIM_MODELS to a whitespace-separated list of library simulation Verilog files}"

mkdir -p build reports waves

# shellcheck disable=SC2086
iverilog -g2012 \
    -DSDF_ANNOTATE \
    -DSDF_FILE=\"${SDF_FILE}\" \
    -s tb_wallace_mul_u16_pipe3 \
    -o build/tb_wallace_mul_u16_pipe3_gate.vvp \
    ${CELL_SIM_MODELS} \
    "${GATE_NETLIST}" \
    tb/tb_wallace_mul_u16_pipe3.sv

vvp build/tb_wallace_mul_u16_pipe3_gate.vvp | tee reports/gate_sdf_sim.log
