# ============================================================================
# Design      : wallace_mul_u16_pipe3
# Mode        : Functional
# Clock       : 100 MHz
# Reset       : Synchronous active-low; rst_n is intentionally timed as data.
# Units       : Time values are in ns. Capacitance follows the loaded library.
# ============================================================================

set DESIGN_NAME wallace_mul_u16_pipe3
set CLK_NAME    core_clk
set CLK_PERIOD  10.000

create_clock \
    -name $CLK_NAME \
    -period $CLK_PERIOD \
    -waveform {0.000 5.000} \
    [get_ports clk]

# Clock quality assumptions. Replace using CTS targets during physical design.
set_clock_uncertainty -setup 0.200 [get_clocks $CLK_NAME]
set_clock_uncertainty -hold  0.050 [get_clocks $CLK_NAME]
set_clock_transition         0.100 [get_clocks $CLK_NAME]

# External interface budget.
set DATA_INPUTS [remove_from_collection [all_inputs] [get_ports clk]]
set DATA_OUTPUTS [all_outputs]

set_input_delay  -clock $CLK_NAME -max 1.500 $DATA_INPUTS
set_input_delay  -clock $CLK_NAME -min 0.200 $DATA_INPUTS
set_output_delay -clock $CLK_NAME -max 1.500 $DATA_OUTPUTS
set_output_delay -clock $CLK_NAME -min 0.200 $DATA_OUTPUTS

set_input_transition 0.100 $DATA_INPUTS

# Generic electrical constraints. Revisit after selecting the standard-cell library
# and actual top-level load model.
set_max_fanout     16    [current_design]
set_max_transition 0.500 [current_design]
set_load           0.050 $DATA_OUTPUTS

# No multicycle or false paths are declared in functional mode.
# In particular, rst_n is synchronous and must meet setup/hold timing.
