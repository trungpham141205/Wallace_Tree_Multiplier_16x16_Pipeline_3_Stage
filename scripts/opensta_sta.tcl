if {![info exists ::env(LIBERTY_FILE)]} {
    puts stderr "ERROR: LIBERTY_FILE is not set"
    exit 2
}

if {![info exists ::env(GATE_NETLIST)]} {
    set ::env(GATE_NETLIST) "build/wallace_mul_u16_pipe3_mapped.v"
}

read_liberty $::env(LIBERTY_FILE)
read_verilog $::env(GATE_NETLIST)
link_design wallace_mul_u16_pipe3
read_sdc constraints/wallace_mul_u16_pipe3.sdc

check_setup
report_checks -path_delay max -group_count 10 -endpoint_count 10 -digits 3
report_checks -path_delay min -group_count 10 -endpoint_count 10 -digits 3
report_worst_slack -max
report_worst_slack -min
report_tns
