`timescale 1ns/1ps
`default_nettype none

module gen_u16 (
    input  wire logic [15:0]       a,
    input  wire logic [15:0]       b,
    output var  logic [15:0][31:0] pp
);

    integer row_idx;

    always_comb begin
        pp = '0;
        for (row_idx = 0; row_idx < 16; row_idx = row_idx + 1) begin
            if (b[row_idx]) begin
                pp[row_idx] = {16'b0, a} << row_idx;
            end
        end
    end

endmodule

`default_nettype wire
