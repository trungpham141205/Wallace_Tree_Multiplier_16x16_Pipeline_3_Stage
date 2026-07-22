`timescale 1ns/1ps
`default_nettype none

module wallace_reduce_4to3 (
    input  wire logic [3:0][31:0] rows_in,
    output wire logic [2:0][31:0] rows_out,
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

    assign rows_out[2] = rows_in[3];

endmodule

`default_nettype wire
