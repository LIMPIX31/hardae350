module mem_rom #
( parameter int unsigned WORDS = 512
, parameter string       INIT  = "sram.mem"
)
( input  logic i_clk

, input  logic [31:0] i_haddr
, output logic [31:0] o_hrdata
, output logic [ 0:0] o_hresp
, output logic [ 0:0] o_hready
);

    logic [31:0] mem [WORDS];

    initial $readmemh(INIT, mem);

    // Always ready for transfers
    assign o_hready = 1'b1;
    // Each transfer is infallible
    assign o_hresp  = 1'b0;

    always_ff @(posedge i_clk) begin
        // Read on every cycle as there is no reason
        // to use control signals
        o_hrdata <= mem[i_haddr[$clog2(WORDS)+1:2]];
    end

endmodule : mem_rom
