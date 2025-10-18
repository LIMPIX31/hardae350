`timescale 1ns / 1ps

module top
( input  logic i_ref_clk
, input  logic i_rst_n

, output logic [5:0] o_led_n

, input  logic i_tck
, input  logic i_tms
, input  logic i_trst
, input  logic i_tdi
, output logic o_tdo
);

    logic rst_n;

    logic core_clk;
    logic bus_clk;
    logic ddr_clk;
    logic rtc_clk;

    logic [31:0] ram_haddr;
    logic [ 2:0] ram_hburst;
    logic [ 2:0] ram_hsize;
    logic [ 3:0] ram_hprot;
    logic [ 1:0] ram_htrans;
    logic [63:0] ram_hwdata;
    logic [ 0:0] ram_hwrite;
    logic [63:0] ram_hrdata;
    logic [ 0:0] ram_hready;
    logic [ 0:0] ram_hresp;

    logic [31:0] rom_haddr;
    logic [31:0] rom_hrdata;
    logic [ 0:0] rom_hresp;
    logic [ 0:0] rom_hready;

    logic [5:0]  led_gpio;
    logic [25:0] unused_gpio;

    assign o_led_n = ~led_gpio;

    input_debounce u_debounce
    ( .clk(i_ref_clk)
    , .rst(1'b0)
    , .i  (i_rst_n)
    , .o  (rst_n)
    );

    soc_pll u_soc_pll
    ( .i_clk_50m(i_ref_clk)

    , .i_rst(~rst_n)
    , .o_lock()

    , .o_core_clk_800m(core_clk)
    , .o_bus_clk_200m(bus_clk)
    , .o_ddr_clk_50m(ddr_clk)
    , .o_rtc_clk_10m(rtc_clk)
    );

    mem_rom #
    ( .WORDS(512)
    ) u_rom
    ( .i_clk(bus_clk)

    , .i_haddr(rom_haddr)
    , .o_hrdata(rom_hrdata)
    , .o_hresp(rom_hresp)
    , .o_hready(rom_hready)
    );

    mem_sram #
    ( .WORDS(4096)
    ) u_sram
    ( .i_clk(bus_clk)

    , .i_haddr(ram_haddr)
    , .i_hburst(ram_hburst)
    , .i_hsize(ram_hsize)
    , .i_hprot(ram_hprot)
    , .i_htrans(ram_htrans)
    , .i_hwdata(ram_hwdata)
    , .i_hwrite(ram_hwrite)

    , .o_hrdata(ram_hrdata)
    , .o_hresp(ram_hresp)
    , .o_hready(ram_hready)
    );

    hard_ae350 u_soc
    ( .i_rst_n(rst_n)

    , .i_core_clk(core_clk)
    , .i_bus_clk(bus_clk)
    , .i_ddr_clk(ddr_clk)
    , .i_rtc_clk(rtc_clk)

    , .o_ahb_rst_n()
    , .o_apb_rst_n()
    , .o_ddr_rst_n()

    , .i_tck(i_tck)
    , .i_tms(i_tms)
    , .i_trst(i_trst)
    , .i_tdi(i_tdi)
    , .o_tdo(o_tdo)

    , .o_ram_haddr(ram_haddr)
    , .o_ram_hburst(ram_hburst)
    , .o_ram_hsize(ram_hsize)
    , .o_ram_hprot(ram_hprot)
    , .o_ram_htrans(ram_htrans)
    , .o_ram_hwdata(ram_hwdata)
    , .o_ram_hwrite(ram_hwrite)
    , .i_ram_hrdata(ram_hrdata)
    , .i_ram_hresp(ram_hresp)
    , .i_ram_hready(ram_hready)

    , .o_rom_haddr(rom_haddr)
    , .o_rom_htrans()
    , .o_rom_hwrite()
    , .i_rom_hrdata(rom_hrdata)
    , .i_rom_hresp(rom_hresp)
    , .i_rom_hready(rom_hready)

    , .i_gpio(32'h0000_0000)
    , .o_gpio_oe()
    , .o_gpio({unused_gpio, led_gpio})
    );

endmodule : top
