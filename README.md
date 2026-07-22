# Unsigned 16x16 Wallace Multiplier — 3-Stage Pipeline

Project này tái cấu trúc datapath của repo `skibidizz/wallace_multi` thành RTL synthesizable và backend-ready.

## Kiến trúc

```text
Stage 1: partial products + Wallace reduction 16 -> 11 -> 8 -> 6
         register 6 rows

Stage 2: Wallace reduction 6 -> 4 -> 3 -> 2
         register sum row và shifted-carry row

Stage 3: Brent-Kung final adder 32-bit
         register product
```

`csa_3_2` đã dịch carry sang trái một bit. Vì vậy carry row của Stage 2 được đưa trực tiếp vào final adder, không dịch thêm lần nữa.

## Interface

| Signal | Direction | Width | Meaning |
|---|---:|---:|---|
| `clk` | input | 1 | Rising-edge clock |
| `rst_n` | input | 1 | Synchronous active-low reset |
| `in_valid` | input | 1 | Input operands are valid |
| `a`, `b` | input | 16 | Unsigned operands |
| `out_valid` | output | 1 | `product` is valid |
| `product` | output | 32 | Unsigned multiplication result |
| `overflow_error` | output | 1 | Internal datapath error indicator; must remain zero for legal unsigned 16x16 inputs |

The pipeline accepts one transaction per clock when `in_valid=1`. Bubbles are supported. There is no backpressure.

## Directory structure

```text
rtl/          Synthesizable SystemVerilog
  common/     Full adder and 3:2 carry-save compressor
  partial_product/
  wallace/    Reduction levels and combinational stages
  adder/      Behavioral synthesizable Brent-Kung prefix adder
  top/        Three-stage pipelined top

tb/           Self-checking RTL/gate-level testbench
constraints/  Primary SDC for 100 MHz functional mode
scripts/      RTL simulation, synthesis, mapping, STA and SDF simulation
backend/      Backend handoff notes
build/        Generated netlists and simulator binaries
reports/      Simulation/synthesis/STA reports
waves/        Waveforms
```

## RTL simulation

Requires Icarus Verilog:

```bash
make sim
```

## Generic synthesis

Requires Yosys:

```bash
make synth
```

## Standard-cell mapping and STA

```bash
export LIBERTY_FILE=/absolute/path/to/typical.lib
make map
make sta
```

The SDC is applied by OpenSTA and is also suitable as the initial constraint file for Design Compiler, Genus, OpenROAD or Innovus. Re-budget IO delays, uncertainty, slew and load before signoff.

## Post-route timing simulation

After backend exports a post-route netlist and SDF:

```bash
export GATE_NETLIST=/absolute/path/to/post_route.v
export SDF_FILE=/absolute/path/to/post_route.sdf
export CELL_SIM_MODELS="/path/to/stdcells.v /path/to/io_cells.v"
make gate
```

SDC constrains static timing analysis; SDF carries extracted cell/interconnect delays into gate-level simulation. Both are required for a complete timing-verification handoff.

## Questa 2025.2

Command-line regression:

```bash
./scripts/run_questa_rtl.sh
```

GUI with predefined waveform:

```bash
vsim -do scripts/questa_rtl.do
```

All module input ports explicitly declare `wire logic`, while procedural outputs explicitly declare `var logic`. This avoids Questa `vlog-2892` when `default_nettype none` is enabled.

### Questa logs

Batch regression with persistent logs:

```bash
make questa
```

or:

```bash
./scripts/run_questa_rtl.sh
```

Generated files:

```text
reports/questa_compile.log       Complete library setup and vlog output
reports/questa_sim.log           Elaboration, simulation and scoreboard output
reports/questa_test_summary.log  Compact PASS/FAIL transaction summary
vsim.wlf                         Questa waveform database
```

Use a reproducible random seed:

```bash
QUESTA_SEED=12345 make questa
```

GUI run with the same logging behavior:

```bash
QUESTA_SEED=12345 make questa-gui
```

## Questa package extraction

The ZIP contains the top-level directory `wallace_multi_pipe3_backend_ready/`.
Extract it from `~/Downloads` and enter that newly extracted directory before running `make questa`.
