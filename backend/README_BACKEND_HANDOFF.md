# Backend handoff

## Required inputs

- RTL top: `wallace_mul_u16_pipe3`
- RTL file list: `rtl/filelist.f`
- Timing constraints: `constraints/wallace_mul_u16_pipe3.sdc`
- Functional clock: `clk`, 10 ns period (100 MHz)
- Reset: `rst_n`, synchronous active-low

## Timing paths that must remain enabled

The design contains only single-clock synchronous paths. No false path and no multicycle path is required in functional mode. Because reset is synchronous, `rst_n` must be timed as a normal data input.

## Before place-and-route

Update the following values using the real chip-level budget:

- Clock period and waveform
- Setup/hold uncertainty
- Input and output delays
- Input slew
- Output load
- Maximum transition and fanout

## Physical-design outputs for signoff simulation

Export these from the backend flow:

- Post-route Verilog netlist
- Standard-cell simulation models
- SDF with maximum and minimum delays
- Final propagated-clock SDC
- Setup and hold timing reports

Use `scripts/run_gate_sim.sh` for SDF-annotated simulation after those files are available.
