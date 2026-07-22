`timescale 1ns/1ps
`default_nettype none

module wallace_reduce_16to11 (
    input  wire logic [15:0][31:0] rows_in,
    output wire logic [10:0][31:0] rows_out,
    output wire logic [4:0]         overflow
);

    genvar group_idx;
    generate
        for (group_idx = 0; group_idx < 5; group_idx++) begin : gen_group
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

    assign rows_out[10] = rows_in[15];

endmodule

`default_nettype wire
