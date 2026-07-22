`timescale 1ns/1ps
`default_nettype none

module wallace_stage2_comb (
    input  wire logic [5:0][31:0] rows_in,
    output wire logic [1:0][31:0] rows_out,
    output wire logic              overflow_error
);

    wire logic [3:0][31:0] level_4_rows;
    wire logic [2:0][31:0] level_3_rows;

    wire logic [1:0] overflow_6to4;
    wire logic       overflow_4to3;
    wire logic       overflow_3to2;

    wallace_reduce_6to4 u_reduce_6to4 (
        .rows_in  (rows_in),
        .rows_out (level_4_rows),
        .overflow (overflow_6to4)
    );

    wallace_reduce_4to3 u_reduce_4to3 (
        .rows_in  (level_4_rows),
        .rows_out (level_3_rows),
        .overflow (overflow_4to3)
    );

    wallace_reduce_3to2 u_reduce_3to2 (
        .rows_in  (level_3_rows),
        .rows_out (rows_out),
        .overflow (overflow_3to2)
    );

    assign overflow_error = (|overflow_6to4) |
                            overflow_4to3    |
                            overflow_3to2;

endmodule

`default_nettype wire
