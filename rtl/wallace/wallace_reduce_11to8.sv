`timescale 1ns/1ps
`default_nettype none

module wallace_reduce_11to8 (
    input  wire logic [10:0][31:0] rows_in,
    output wire logic [7:0][31:0]  rows_out,
    output wire logic [2:0]         overflow
);

    genvar group_idx;
    generate
        for (group_idx = 0; group_idx < 3; group_idx++) begin : gen_group
            csa_3_2 #(.WIDTH(32)) u_csa_3_2 (
                .x        (rows_in[(3*group_idx)    ]),
                .y        (rows_in[(3*group_idx) + 1]),
                .z        (rows_in[(3*group_idx) + 2]),
                .sum      (rows_out[(2*group_idx)    ]),
                .carry    (rows_out[(2*group_idx) + 1]),
                .overflow (overflow[group_idx])
            );
        end
    endgenerate

    assign rows_out[6] = rows_in[9];
    assign rows_out[7] = rows_in[10];

endmodule

`default_nettype wire
