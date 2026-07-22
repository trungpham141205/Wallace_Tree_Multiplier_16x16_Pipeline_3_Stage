`timescale 1ns/1ps
`default_nettype none

module brent_kung_adder_32 (
    input  wire logic [31:0] a,
    input  wire logic [31:0] b,
    input  wire logic        cin,
    output var  logic [31:0] sum,
    output var  logic        cout
);

    logic [31:0] g_bit;
    logic [31:0] p_bit;

    logic [31:0] g_up1,   p_up1;
    logic [31:0] g_up2,   p_up2;
    logic [31:0] g_up3,   p_up3;
    logic [31:0] g_up4,   p_up4;
    logic [31:0] g_up5,   p_up5;
    logic [31:0] g_down4, p_down4;
    logic [31:0] g_down3, p_down3;
    logic [31:0] g_down2, p_down2;
    logic [31:0] g_prefix, p_prefix;
    logic [32:0] carry;

    integer idx;

    always_comb begin
        g_bit = a & b;
        p_bit = a ^ b;

        g_up1 = g_bit;
        p_up1 = p_bit;
        for (idx = 1; idx < 32; idx = idx + 2) begin
            g_up1[idx] = g_bit[idx] | (p_bit[idx] & g_bit[idx-1]);
            p_up1[idx] = p_bit[idx] & p_bit[idx-1];
        end

        g_up2 = g_up1;
        p_up2 = p_up1;
        for (idx = 3; idx < 32; idx = idx + 4) begin
            g_up2[idx] = g_up1[idx] | (p_up1[idx] & g_up1[idx-2]);
            p_up2[idx] = p_up1[idx] & p_up1[idx-2];
        end

        g_up3 = g_up2;
        p_up3 = p_up2;
        for (idx = 7; idx < 32; idx = idx + 8) begin
            g_up3[idx] = g_up2[idx] | (p_up2[idx] & g_up2[idx-4]);
            p_up3[idx] = p_up2[idx] & p_up2[idx-4];
        end

        g_up4 = g_up3;
        p_up4 = p_up3;
        for (idx = 15; idx < 32; idx = idx + 16) begin
            g_up4[idx] = g_up3[idx] | (p_up3[idx] & g_up3[idx-8]);
            p_up4[idx] = p_up3[idx] & p_up3[idx-8];
        end

        g_up5     = g_up4;
        p_up5     = p_up4;
        g_up5[31] = g_up4[31] | (p_up4[31] & g_up4[15]);
        p_up5[31] = p_up4[31] & p_up4[15];

        g_down4     = g_up5;
        p_down4     = p_up5;
        g_down4[23] = g_up5[23] | (p_up5[23] & g_up5[15]);
        p_down4[23] = p_up5[23] & p_up5[15];

        g_down3 = g_down4;
        p_down3 = p_down4;
        for (idx = 11; idx <= 27; idx = idx + 8) begin
            g_down3[idx] = g_down4[idx] | (p_down4[idx] & g_down4[idx-4]);
            p_down3[idx] = p_down4[idx] & p_down4[idx-4];
        end

        g_down2 = g_down3;
        p_down2 = p_down3;
        for (idx = 5; idx <= 29; idx = idx + 4) begin
            g_down2[idx] = g_down3[idx] | (p_down3[idx] & g_down3[idx-2]);
            p_down2[idx] = p_down3[idx] & p_down3[idx-2];
        end

        g_prefix = g_down2;
        p_prefix = p_down2;
        for (idx = 2; idx <= 30; idx = idx + 2) begin
            g_prefix[idx] = g_down2[idx] | (p_down2[idx] & g_down2[idx-1]);
            p_prefix[idx] = p_down2[idx] & p_down2[idx-1];
        end

        carry    = '0;
        carry[0] = cin;
        for (idx = 0; idx < 32; idx = idx + 1) begin
            carry[idx+1] = g_prefix[idx] | (p_prefix[idx] & cin);
        end

        sum  = p_bit ^ carry[31:0];
        cout = carry[32];
    end

endmodule

`default_nettype wire
