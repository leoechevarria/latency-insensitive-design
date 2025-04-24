package fir_pkg;

    localparam integer unsigned COEFF_WIDTH = 16;
    localparam integer unsigned N_COEFFS = 16;

    typedef logic signed [COEFF_WIDTH-1:0] fir_coeff_t [N_COEFFS-1:0];

    localparam fir_coeff_t FIR_COEFF_DEFAULT = '{
    // localparam logic [COEFF_WIDTH-1:0] FIR_COEFF_DEFAULT [N_COEFFS-1:0] = '{
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1,
        16'd1
    };

endpackage