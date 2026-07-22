`timescale 1ns/1ps
`default_nettype none

module wallace_stage1_comb (
    input  wire logic [15:0]      a,
    input  wire logic [15:0]      b,
    output wire logic [5:0][31:0] rows_out,
    output wire logic             overflow_error
);

    wire logic [15:0][31:0] pp_rows;
    wire logic [10:0][31:0] level_11_rows;
    wire logic [7:0][31:0]  level_8_rows;

    wire logic [4:0] overflow_16to11;
    wire logic [2:0] overflow_11to8;
    wire logic [1:0] overflow_8to6;

    gen_u16 u_gen_u16 (
        .a  (a),
        .b  (b),
        .pp (pp_rows)
    );

    wallace_reduce_16to11 u_reduce_16to11 (
        .rows_in  (pp_rows),
        .rows_out (level_11_rows),
        .overflow (overflow_16to11)
    );

    wallace_reduce_11to8 u_reduce_11to8 (
        .rows_in  (level_11_rows),
        .rows_out (level_8_rows),
        .overflow (overflow_11to8)
    );

    wallace_reduce_8to6 u_reduce_8to6 (
        .rows_in  (level_8_rows),
        .rows_out (rows_out),
        .overflow (overflow_8to6)
    );

    assign overflow_error = (|overflow_16to11) |
                            (|overflow_11to8)  |
                            (|overflow_8to6);

endmodule

`default_nettype wire
