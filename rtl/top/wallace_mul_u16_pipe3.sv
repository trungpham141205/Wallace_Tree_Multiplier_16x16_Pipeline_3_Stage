`timescale 1ns/1ps
`default_nettype none

module wallace_mul_u16_pipe3 (
    input  wire logic        clk,
    input  wire logic        rst_n,
    input  wire logic        in_valid,
    input  wire logic [15:0] a,
    input  wire logic [15:0] b,
    output var  logic        out_valid,
    output var  logic [31:0] product,
    output var  logic        overflow_error
);

    wire logic [5:0][31:0] stage1_rows_d;
    logic      [5:0][31:0] stage1_rows_q;
    wire logic              stage1_overflow_d;
    logic              stage1_overflow_q;
    logic              stage1_valid_q;

    wire logic [1:0][31:0] stage2_rows_d;
    logic      [1:0][31:0] stage2_rows_q;
    wire logic              stage2_overflow_d;
    logic              stage2_overflow_q;
    logic              stage2_valid_q;

    wire logic [31:0] stage3_product_d;
    wire logic        stage3_cout_d;

    wallace_stage1_comb u_wallace_stage1_comb (
        .a              (a),
        .b              (b),
        .rows_out       (stage1_rows_d),
        .overflow_error (stage1_overflow_d)
    );

    wallace_stage2_comb u_wallace_stage2_comb (
        .rows_in        (stage1_rows_q),
        .rows_out       (stage2_rows_d),
        .overflow_error (stage2_overflow_d)
    );

    brent_kung_adder_32 u_brent_kung_adder_32 (
        .a    (stage2_rows_q[0]),
        .b    (stage2_rows_q[1]),
        .cin  (1'b0),
        .sum  (stage3_product_d),
        .cout (stage3_cout_d)
    );

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            stage1_rows_q     <= '0;
            stage1_overflow_q <= 1'b0;
            stage1_valid_q    <= 1'b0;
        end
        else begin
            stage1_valid_q <= in_valid;
            if (in_valid) begin
                stage1_rows_q     <= stage1_rows_d;
                stage1_overflow_q <= stage1_overflow_d;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            stage2_rows_q     <= '0;
            stage2_overflow_q <= 1'b0;
            stage2_valid_q    <= 1'b0;
        end
        else begin
            stage2_valid_q <= stage1_valid_q;
            if (stage1_valid_q) begin
                stage2_rows_q     <= stage2_rows_d;
                stage2_overflow_q <= stage1_overflow_q |
                                     stage2_overflow_d;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid      <= 1'b0;
            product        <= 32'b0;
            overflow_error <= 1'b0;
        end
        else begin
            out_valid <= stage2_valid_q;
            if (stage2_valid_q) begin
                product        <= stage3_product_d;
                overflow_error <= stage2_overflow_q |
                                  stage3_cout_d;
            end
        end
    end

endmodule

`default_nettype wire
