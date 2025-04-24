`timescale 1ns/1ps

module tb_axis_fir();
    localparam integer unsigned CLOCK_PERIOD_NS = 10;
    localparam integer unsigned CLOCK_HALF_PERIOD_NS = CLOCK_PERIOD_NS / 2;

    logic tb_clk;
    logic tb_rst_n = 1'b0;

    always begin
        tb_clk = 1'b1;
        #CLOCK_HALF_PERIOD_NS;
        tb_clk = 1'b0;
        #CLOCK_HALF_PERIOD_NS;
    end

    axis_if source_if(tb_clk, tb_rst_n);
    axis_if sink_if(tb_clk, tb_rst_n);

    axis_fir dut (.s_axis(source_if.rx), .m_axis(sink_if.tx));

    initial begin
        @ (posedge tb_clk);
        source_if.TVALID <= 1'b0;
        tb_rst_n <= 1'b0;
        repeat(10) begin
            @ (posedge tb_clk);
        end

        tb_rst_n <= 1'b1;
        source_if.TDATA <= '0;
        source_if.TVALID <= 1'b1;
        sink_if.TREADY <= 1'b1;

        repeat(1000) begin
            @ (posedge tb_clk);
            sink_if.TREADY <= $urandom();
            if (source_if.TVALID) begin
                if (source_if.TREADY) begin
                    source_if.TVALID <= $urandom();
                end
            end else begin
                source_if.TVALID <= $urandom();
            end
        end

        @ (posedge tb_clk);
        source_if.TDATA <= 1;

        repeat(100) begin
            @ (posedge tb_clk);
            sink_if.TREADY <= $urandom();
            if (source_if.TVALID) begin
                if (source_if.TREADY) begin
                    source_if.TVALID <= $urandom();
                end
            end else begin
                source_if.TVALID <= $urandom();
            end
        end

        @ (posedge tb_clk);
        source_if.TDATA <= '0;

        repeat(1000) begin
            @ (posedge tb_clk);
            sink_if.TREADY <= $urandom();
            if (source_if.TVALID) begin
                if (source_if.TREADY) begin
                    source_if.TVALID <= $urandom();
                end
            end else begin
                source_if.TVALID <= $urandom();
            end
        end

        $finish();
    end

endmodule