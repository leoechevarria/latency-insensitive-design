package axis_pkg;

    typedef struct packed {
        integer unsigned TDATA_BYTES;
        integer unsigned TID_WIDTH;
        integer unsigned TDEST_WIDTH;
        integer unsigned TUSER_WIDTH;
    } axis_parameters_t;

    localparam axis_parameters_t AXIS_PARAMETERS_DEFAULT = {
        32'd4, //TDATA_BYTES
        32'd8, //TID_WIDTH
        32'd8, //TDEST_WIDT
        32'd8  //TUSER_WIDTH
    };

endpackage