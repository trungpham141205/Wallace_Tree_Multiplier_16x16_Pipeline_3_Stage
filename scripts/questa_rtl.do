transcript on

file mkdir reports
file mkdir waves
file mkdir build

set compile_log "reports/questa_compile.log"
set sim_log     "reports/questa_sim.log"
set summary_log "reports/questa_test_summary.log"

if {[info exists ::env(QUESTA_SEED)]} {
    set questa_seed $::env(QUESTA_SEED)
} else {
    set questa_seed 1
}

puts "========================================"
puts "Questa RTL GUI run"
puts "Seed: $questa_seed"
puts "========================================"

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

if {[catch {
    vlog -sv -work work -l $compile_log -f tb/filelist.f
} compile_error]} {
    set fh [open $summary_log w]
    puts $fh "Wallace Multiplier Pipeline-3 RTL Simulation"
    puts $fh "Result                : COMPILE_FAIL"
    puts $fh "Seed                  : $questa_seed"
    puts $fh "Compile log           : $compile_log"
    close $fh
    puts stderr "COMPILE FAILED: $compile_error"
    puts stderr "See $compile_log"
    quit -code 2 -force
}

if {[catch {
    vsim -sv_seed $questa_seed -voptargs=+acc -l $sim_log work.tb_wallace_mul_u16_pipe3
} elaborate_error]} {
    set fh [open $summary_log w]
    puts $fh "Wallace Multiplier Pipeline-3 RTL Simulation"
    puts $fh "Result                : ELABORATION_FAIL"
    puts $fh "Seed                  : $questa_seed"
    puts $fh "Simulation log        : $sim_log"
    close $fh
    puts stderr "ELABORATION FAILED: $elaborate_error"
    puts stderr "See $sim_log"
    quit -code 3 -force
}

log -r /*

add wave -divider "INPUT"
add wave -radix binary sim:/tb_wallace_mul_u16_pipe3/clk
add wave -radix binary sim:/tb_wallace_mul_u16_pipe3/rst_n
add wave -radix binary sim:/tb_wallace_mul_u16_pipe3/in_valid
add wave -radix hex    sim:/tb_wallace_mul_u16_pipe3/a
add wave -radix hex    sim:/tb_wallace_mul_u16_pipe3/b

add wave -divider "PIPELINE VALID"
add wave -radix binary sim:/tb_wallace_mul_u16_pipe3/dut/stage1_valid_q
add wave -radix binary sim:/tb_wallace_mul_u16_pipe3/dut/stage2_valid_q
add wave -radix binary sim:/tb_wallace_mul_u16_pipe3/out_valid

add wave -divider "PIPELINE DATA"
add wave -radix hex sim:/tb_wallace_mul_u16_pipe3/dut/stage1_rows_q
add wave -radix hex sim:/tb_wallace_mul_u16_pipe3/dut/stage2_rows_q
add wave -radix hex sim:/tb_wallace_mul_u16_pipe3/product
add wave -radix binary sim:/tb_wallace_mul_u16_pipe3/overflow_error

add wave -divider "SCOREBOARD"
add wave sim:/tb_wallace_mul_u16_pipe3/accepted_count
add wave sim:/tb_wallace_mul_u16_pipe3/checked_count
add wave sim:/tb_wallace_mul_u16_pipe3/error_count

run -all
wave zoom full

set accepted [examine -radix decimal sim:/tb_wallace_mul_u16_pipe3/accepted_count]
set checked  [examine -radix decimal sim:/tb_wallace_mul_u16_pipe3/checked_count]
set errors   [examine -radix decimal sim:/tb_wallace_mul_u16_pipe3/error_count]

if {$errors == 0 && $accepted == $checked} {
    set result "PASS"
} else {
    set result "TEST_FAIL"
}

set fh [open $summary_log w]
puts $fh "Wallace Multiplier Pipeline-3 RTL Simulation"
puts $fh "Result                : $result"
puts $fh "Seed                  : $questa_seed"
puts $fh "Accepted transactions : $accepted"
puts $fh "Checked transactions  : $checked"
puts $fh "Errors                : $errors"
puts $fh "Compile log           : $compile_log"
puts $fh "Simulation log        : $sim_log"
puts $fh "Waveform              : vsim.wlf"
close $fh

puts "Compile log : $compile_log"
puts "Simulation  : $sim_log"
puts "Summary     : $summary_log"
puts "Waveform    : vsim.wlf"
