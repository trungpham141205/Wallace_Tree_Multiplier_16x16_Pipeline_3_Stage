`timescale 1ns/1ps
`default_nettype none

module wallace_reduce_8to6 (
    input  wire logic [7:0][31:0] rows_in,
    output wire logic [5:0][31:0] rows_out,
    output wire logic [1:0]        overflow
);

    genvar group_idx;
    generate
        for (group_idx = 0; group_idx < 2; group_idx++) begin : gen_group
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

    assign rows_out[4] = rows_in[6];
    assign rows_out[5] = rows_in[7];

endmodule

`default_nettype wire
