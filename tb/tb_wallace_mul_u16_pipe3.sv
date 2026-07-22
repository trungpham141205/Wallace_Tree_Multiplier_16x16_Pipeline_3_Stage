`timescale 1ns/1ps
`default_nettype none

module tb_wallace_mul_u16_pipe3;

    localparam time CLK_PERIOD = 10ns;

    logic        clk;
    logic        rst_n;
    logic        in_valid;
    logic [15:0] a;
    logic [15:0] b;
    logic        out_valid;
    logic [31:0] product;
    logic        overflow_error;

    logic [31:0] expected_queue[$];

    int unsigned accepted_count;
    int unsigned checked_count;
    int unsigned error_count;
    integer      summary_fd;

    wallace_mul_u16_pipe3 dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .in_valid       (in_valid),
        .a              (a),
        .b              (b),
        .out_valid      (out_valid),
        .product        (product),
        .overflow_error (overflow_error)
    );

    initial begin
        $dumpfile("waves/tb_wallace_mul_u16_pipe3.vcd");
        $dumpvars(0, tb_wallace_mul_u16_pipe3);
    end

`ifdef SDF_ANNOTATE
    initial begin
        $display("Applying SDF: %s", `SDF_FILE);
        $sdf_annotate(`SDF_FILE, dut, , "reports/sdf_annotate.log", "MAXIMUM");
    end
`endif

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    task automatic drive_cycle (
        input logic        valid,
        input logic [15:0] lhs,
        input logic [15:0] rhs
    );
        logic [31:0] expected;
        begin
            @(negedge clk);
            in_valid = valid;
            a        = lhs;
            b        = rhs;

            if (valid) begin
                expected = {16'b0, lhs} * {16'b0, rhs};
                expected_queue.push_back(expected);
                accepted_count++;
            end
        end
    endtask

    always @(posedge clk) begin
        logic [31:0] expected;

        #1ns;

        if (!rst_n) begin
            expected_queue.delete();
        end
        else if (out_valid) begin
            if (expected_queue.size() == 0) begin
                error_count++;
                $error("Unexpected output product=%h", product);
            end
            else begin
                expected = expected_queue.pop_front();
                checked_count++;

                if (product !== expected) begin
                    error_count++;
                    $error("Product mismatch actual=%h expected=%h", product, expected);
                end

                if (overflow_error !== 1'b0) begin
                    error_count++;
                    $error("Unexpected overflow_error for product=%h", product);
                end
            end
        end
    end

    task automatic write_test_summary (
        input string result
    );
        begin
            summary_fd = $fopen(
                "reports/questa_test_summary.log",
                "w"
            );

            if (summary_fd == 0) begin
                $warning(
                    "Cannot open reports/questa_test_summary.log"
                );
            end
            else begin
                $fdisplay(
                    summary_fd,
                    "Wallace Multiplier Pipeline-3 RTL Simulation"
                );
                $fdisplay(summary_fd, "Result                : %s", result);
                $fdisplay(
                    summary_fd,
                    "Accepted transactions : %0d",
                    accepted_count
                );
                $fdisplay(
                    summary_fd,
                    "Checked transactions  : %0d",
                    checked_count
                );
                $fdisplay(
                    summary_fd,
                    "Errors                : %0d",
                    error_count
                );
                $fclose(summary_fd);
            end
        end
    endtask

    initial begin
        rst_n          = 1'b0;
        in_valid       = 1'b0;
        a              = 16'b0;
        b              = 16'b0;
        accepted_count = 0;
        checked_count  = 0;
        error_count    = 0;

        repeat (3) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        drive_cycle(1'b1, 16'h0000, 16'h0000);
        drive_cycle(1'b1, 16'h0001, 16'hFFFF);
        drive_cycle(1'b1, 16'hFFFF, 16'hFFFF);
        drive_cycle(1'b1, 16'h8000, 16'h8000);
        drive_cycle(1'b1, 16'hAAAA, 16'h5555);
        drive_cycle(1'b1, 16'h1234, 16'h5678);
        drive_cycle(1'b0, 16'h0000, 16'h0000);
        drive_cycle(1'b1, 16'h00FF, 16'h0101);

        repeat (2000) begin
            drive_cycle(
                ($urandom_range(0, 3) != 0),
                $urandom,
                $urandom
            );
        end

        repeat (6) begin
            drive_cycle(1'b0, 16'b0, 16'b0);
        end

        wait (expected_queue.size() == 0);
        repeat (2) @(posedge clk);

        $display("----------------------------------------");
        $display("Accepted transactions : %0d", accepted_count);
        $display("Checked transactions  : %0d", checked_count);
        $display("Errors                : %0d", error_count);
        $display("----------------------------------------");

        if (checked_count != accepted_count) begin
            write_test_summary("FAIL");
            $fatal(1, "Transaction count mismatch");
        end

        if (error_count != 0) begin
            write_test_summary("FAIL");
            $fatal(1, "PIPE3 WALLACE MULTIPLIER TEST FAILED");
        end

        write_test_summary("PASS");
        $display("ALL TESTS PASSED");
        $finish;
    end

endmodule

`default_nettype wire
