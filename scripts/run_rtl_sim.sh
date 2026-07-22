#!/usr/bin/env bash
set -euo pipefail

mkdir -p build reports waves

iverilog -g2012 \
    -s tb_wallace_mul_u16_pipe3 \
    -o build/tb_wallace_mul_u16_pipe3.vvp \
    -f tb/filelist.f

vvp build/tb_wallace_mul_u16_pipe3.vvp | tee reports/rtl_sim.log
