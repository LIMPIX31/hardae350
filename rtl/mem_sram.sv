module mem_sram #
( parameter int unsigned WORDS = 4096
)
( input logic i_clk

, input  logic [31:0] i_haddr
, input  logic [ 2:0] i_hburst
, input  logic [ 2:0] i_hsize
, input  logic [ 3:0] i_hprot
, input  logic [ 1:0] i_htrans
, input  logic [63:0] i_hwdata
, input  logic [ 0:0] i_hwrite
, output logic [63:0] o_hrdata
, output logic [ 0:0] o_hresp
, output logic [ 0:0] o_hready
);

    localparam int unsigned AddrWidth = $clog2(WORDS);

    logic [31:0] mem [WORDS];
    logic [AddrWidth-1:0] addr;
    logic write;

    assign o_hready = 1'b1;
    assign o_hresp  = 1'b0;

    assign addr = i_haddr[AddrWidth+1:2];

    always_ff @(posedge i_clk) begin
        if (i_hwrite && i_htrans == 2'd2) begin
            write <= 1'b1;
        end else begin
            write <= 1'b0;
            o_hrdata <= {mem[addr], mem[addr]};
        end
    end

    always_ff @(posedge i_clk) begin
        if (write) begin
            mem[addr] <= i_hwdata[31:0];
        end
    end

endmodule : mem_sram
