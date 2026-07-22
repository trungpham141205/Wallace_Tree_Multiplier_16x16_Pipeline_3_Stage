`timescale 1ns/1ps
`default_nettype none

module full_adder_1b (
    input  wire logic a,
    input  wire logic b,
    input  wire logic cin,
    output var  logic sum,
    output var  logic cout
);

    always_comb begin
        sum  = a ^ b ^ cin;
        cout = (a & b) | (a & cin) | (b & cin);
    end

endmodule

`default_nettype wire
