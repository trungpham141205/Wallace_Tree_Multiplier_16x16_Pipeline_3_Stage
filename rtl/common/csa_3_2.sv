`timescale 1ns/1ps
`default_nettype none

module csa_3_2 #(
    parameter int unsigned WIDTH = 32
) (
    input  wire logic [WIDTH-1:0] x,
    input  wire logic [WIDTH-1:0] y,
    input  wire logic [WIDTH-1:0] z,
    output var  logic [WIDTH-1:0] sum,
    output var  logic [WIDTH-1:0] carry,
    output var  logic             overflow
);

    logic [WIDTH-1:0] carry_raw;

    always_comb begin
        sum       = x ^ y ^ z;
        carry_raw = (x & y) | (x & z) | (y & z);
        carry     = {carry_raw[WIDTH-2:0], 1'b0};
        overflow  = carry_raw[WIDTH-1];
    end

endmodule

`default_nettype wire
