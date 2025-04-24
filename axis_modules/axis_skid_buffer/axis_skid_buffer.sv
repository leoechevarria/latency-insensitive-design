module axis_skid_buffer
(
    axis_if.rx  s_axis,
    axis_if.tx  m_axis
);

if (s_axis.AXIS_PARAMETERS != m_axis.AXIS_PARAMETERS)
    $error("Width of AXI4-Stream signals differs between interfaces.");

localparam integer unsigned TOTAL_WIDTH = s_axis.TDATA_WIDTH + (2*s_axis.TDATA_BYTES) + 1 + s_axis.TID_WIDTH + s_axis.TDEST_WIDTH + s_axis.TUSER_WIDTH;

logic [TOTAL_WIDTH-1:0] input_vector;
assign input_vector = {s_axis.TUSER, s_axis.TDEST, s_axis.TID, s_axis.TLAST, s_axis.TKEEP, s_axis.TSTRB, s_axis.TDATA};
logic [TOTAL_WIDTH-1:0] output_vector;
assign {m_axis.TUSER, m_axis.TDEST, m_axis.TID, m_axis.TLAST, m_axis.TKEEP, m_axis.TSTRB, m_axis.TDATA} = output_vector;

skid_buffer_core #(
    .NB_DATA    ( TOTAL_WIDTH           )
) alldata_skid_buffer (
    .i_clk      ( s_axis.ACLK           ),
    .i_rst_n    ( s_axis.ARESETn        ),
    .o_ready    ( s_axis.TREADY         ),
    .i_valid    ( s_axis.TVALID         ),
    .i_data     ( input_vector          ),
    .i_ready    ( m_axis.TREADY         ),
    .o_valid    ( m_axis.TVALID         ),
    .o_data     ( output_vector         )
);

endmodule