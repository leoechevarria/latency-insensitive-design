module skid_buffer_core
#(
    parameter integer unsigned  NB_DATA = 32
)
(
    input  logic                i_clk,
    input  logic                i_rst_n,

    // input iface
    output logic                o_ready,
    input  logic                i_valid,
    input  logic [NB_DATA-1:0]  i_data,

    // output iface
    input  logic                i_ready,
    output logic                o_valid,
    output logic [NB_DATA-1:0]  o_data
);

    logic valid_d = 1'b0;
    logic [NB_DATA-1:0] aux_data = '0;

    always_ff @(posedge i_clk) begin
        if (~o_valid | i_ready) begin
            o_data <= o_ready ? i_data : aux_data;
        end
    end

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_valid <= 1'b0;
        end else begin
            if (~o_ready | i_valid) begin
                o_valid <= 1'b1;
            end else if (i_ready) begin
                o_valid <= 1'b0;
            end
        end
    end

    always_ff @(posedge i_clk) begin
        if (o_ready) begin
            aux_data <= i_data;
        end
    end

    always_ff @(posedge i_clk) begin
        if (!i_rst_n) begin
            o_ready <= 1'b1;
        end else begin
            if (~o_valid | i_ready) begin
                o_ready <= 1'b1;
            end else if (i_valid) begin
                o_ready <= 1'b0;
            end
        end
    end

endmodule