module axis_fir
#(
    fir_pkg::fir_coeff_t coeff = fir_pkg::FIR_COEFF_DEFAULT
)
(
    axis_if.rx  s_axis,
    axis_if.tx  m_axis
);

// INFO AND CHECKS

if (s_axis.AXIS_PARAMETERS != m_axis.AXIS_PARAMETERS)
    $error("Width of AXI4-Stream signals differs between interfaces.");

initial begin
    $display("NUMBER OF TAPS IN FIR FILTER: %0d", $size(coeff));
end

// IO IFACES AND USEFUL AUX SIGNALS

axis_if #(.AXIS_PARAMETERS(s_axis.AXIS_PARAMETERS)) input_sb_iface(s_axis.ACLK, s_axis.ARESETn);
axis_if #(.AXIS_PARAMETERS(m_axis.AXIS_PARAMETERS)) output_sb_iface(m_axis.ACLK, m_axis.ARESETn);

axis_skid_buffer input_sb   (.s_axis(s_axis),           .m_axis(input_sb_iface) );
axis_skid_buffer output_sb  (.s_axis(output_sb_iface),  .m_axis(m_axis)         );

logic input_transaction_ack, output_transaction_ack;
assign input_transaction_ack    = input_sb_iface.TVALID     &&  input_sb_iface.TREADY;
assign output_transaction_ack   = output_sb_iface.TVALID    &&  output_sb_iface.TREADY;

///////////////////////////////////
//
//            s_axis
//      ________|_________
//     |    ____|_____    |
//     |   |_input_sb_|   |
//     |        |         |
//     |  input_sb_iface  |
//     |        |         |
//     |        |         |
//     |   module logic   |
//     |        |         |
//     |        |         |
//     |  output_sb_iface |
//     |    ____|_____    |
//     |   |output_sb_|   |
//     |________|_________|
//              |
//           m_axis
//
///////////////////////////////////

logic [$clog2($size(coeff)):0] coeff_counter;

always_ff @ (posedge s_axis.ACLK) begin
    if (!s_axis.ARESETn) begin
        coeff_counter <= '0;
    end else if (input_transaction_ack) begin
        if (coeff_counter < $size(coeff)+1)
            coeff_counter <= coeff_counter + 1'b1;
    end
end

assign input_sb_iface.TREADY = output_sb_iface.TREADY;
assign output_sb_iface.TVALID = input_sb_iface.TVALID && (coeff_counter > $size(coeff));

// --> input and output transaction acknowledge signals are the same (except for the gating of the first invalid samples)
// this is a particular case for this pipeline where an input sample pushes
// the pipeline further and causes the end of the pipeline to pop the last sample
// --> the condition for the pipeline to advance is having new valid data at the input
//     (s_axis.TVALID) + having room to deliver the data (m_axis.TREADY)

logic pipeline_advance;
assign pipeline_advance = input_transaction_ack;

logic signed [$size(coeff)-1:0][63:0] data_delay_line;

always_ff @ (posedge s_axis.ACLK) begin
    if (pipeline_advance) begin
        data_delay_line[0] <= input_sb_iface.TDATA;
        for (int i = 0; i < $size(coeff)-1; i = i + 1) begin
            data_delay_line[i+1] <= data_delay_line[i];
        end
    end
end

logic signed [$size(coeff)-1:0][63:0] sum_delay_line;

always_ff @ (posedge s_axis.ACLK) begin
    if (pipeline_advance) begin
        sum_delay_line[0] <= (data_delay_line[0] * coeff[0]);
        for (int i = 1; i < $size(coeff); i = i + 1) begin
            sum_delay_line[i] <= (data_delay_line[i] * coeff[i]);
        end
    end
end

logic [63:0] whole_sum;

always_comb begin
    whole_sum = 0;
    for (int i = 0; i < $size(coeff); i = i + 1) begin
        whole_sum = whole_sum + sum_delay_line[i];
    end
end

assign output_sb_iface.TDATA = whole_sum;

endmodule
