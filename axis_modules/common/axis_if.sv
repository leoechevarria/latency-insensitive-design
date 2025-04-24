// AXI4-Stream

interface axis_if
#(
    axis_pkg::axis_parameters_t AXIS_PARAMETERS = axis_pkg::AXIS_PARAMETERS_DEFAULT
)
(
    input logic ACLK,
    input logic ARESETn
);
    localparam integer unsigned TDATA_BYTES  = AXIS_PARAMETERS.TDATA_BYTES;
    localparam integer unsigned TID_WIDTH    = AXIS_PARAMETERS.TID_WIDTH;
    localparam integer unsigned TDEST_WIDTH  = AXIS_PARAMETERS.TDEST_WIDTH;
    localparam integer unsigned TUSER_WIDTH  = AXIS_PARAMETERS.TUSER_WIDTH;
    localparam integer unsigned TDATA_WIDTH  = 8*AXIS_PARAMETERS.TDATA_BYTES;

    logic                   TVALID;
    logic                   TREADY;
    logic [TDATA_WIDTH-1:0] TDATA;
    logic [TDATA_BYTES-1:0] TSTRB;
    logic [TDATA_BYTES-1:0] TKEEP;
    logic                   TLAST;
    logic [TID_WIDTH-1:0]   TID;
    logic [TDEST_WIDTH-1:0] TDEST;
    logic [TUSER_WIDTH-1:0] TUSER;

    modport tx
    (
        input  ACLK,
        input  ARESETn,
        input  TREADY,
        output TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER
    );

    modport rx
    (
        input  ACLK,
        input  ARESETn,
        output TREADY,
        input  TVALID, TDATA, TSTRB, TKEEP, TLAST, TID, TDEST, TUSER
    );

    // SystemVerilog Assertions
    // TDATA+extras stable before transferred
    property TDATA_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> $stable(TDATA);
    endproperty
    assert property (TDATA_STABLE) else $error("TDATA not stable");

    property TSTRB_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> $stable(TSTRB);
    endproperty
    assert property (TSTRB_STABLE) else $error("TSTRB not stable");

    property TKEEP_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> $stable(TKEEP);
    endproperty
    assert property (TKEEP_STABLE) else $error("TKEEP not stable");

    property TLAST_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> $stable(TLAST);
    endproperty
    assert property (TLAST_STABLE) else $error("TLAST not stable");

    property TID_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> $stable(TID);
    endproperty
    assert property (TID_STABLE) else $error("TID not stable");

    property TDEST_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> $stable(TDEST);
    endproperty
    assert property (TDEST_STABLE) else $error("TDEST not stable");

    property TUSER_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> $stable(TUSER);
    endproperty
    assert property (TUSER_STABLE) else $error("TUSER not stable");

    // TVALID must not be deasserted before transaction
    property TVALID_STABLE;
        @(posedge ACLK) (ARESETn && TVALID && !TREADY) |=> TVALID;
    endproperty
    assert property (TVALID_STABLE) else $error("TVALID not stable");

    // TVALID must be low while reset is asserted
    // (should also cover "TVALID must not be low during the cycle following a reset deassertion")
    property TVALID_LOW_RESET_ASSERTION;
        @(posedge ACLK) !ARESETn |=> !TVALID;
    endproperty
    assert property (TVALID_LOW_RESET_ASSERTION) else $error("TVALID not low during a cycle following reset assertion.");

    // TDATA must not be unknown (i.e. contain Xs) when TVALID is asserted
    // (could be applied for rest of the signals but since they are optional we would need enable parameters for each of them)
    property TDATA_NOT_UNKNOWN_WHEN_VALID;
        @(posedge ACLK) (ARESETn && TVALID) -> !$isunknown(TDATA);
    endproperty
    assert property (TDATA_NOT_UNKNOWN_WHEN_VALID) else $error("TDATA must not be unknown (i.e. contain Xs) when TVALID is asserted.");

endinterface