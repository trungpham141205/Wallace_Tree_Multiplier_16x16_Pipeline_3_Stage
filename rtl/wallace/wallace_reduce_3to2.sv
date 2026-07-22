`timescale 1ns/1ps
`default_nettype none

module wallace_reduce_3to2 (
    input  wire logic [2:0][31:0] rows_in,
    output wire logic [1:0][31:0] rows_out,
    output wire logic              overflow
);

    csa_3_2 #(.WIDTH(32)) u_csa_3_2 (
        .x        (rows_in[0]),
        .y        (rows_in[1]),
        .z        (rows_in[2]),
        .sum      (rows_out[0]),
        .carry    (rows_out[1]),
        .overflow (overflow)
    );

endmodule

`default_nettype wire
