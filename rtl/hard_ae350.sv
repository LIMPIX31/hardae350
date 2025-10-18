module hard_ae350
( input  logic i_rst_n

, input  logic i_core_clk
, input  logic i_bus_clk
, input  logic i_ddr_clk
, input  logic i_rtc_clk

, output logic o_ahb_rst_n
, output logic o_apb_rst_n
, output logic o_ddr_rst_n

, input  logic i_tck
, input  logic i_tms
, input  logic i_trst
, input  logic i_tdi
, output logic o_tdo

, output logic [31:0] o_ram_haddr
, output logic [ 2:0] o_ram_hburst
, output logic [ 2:0] o_ram_hsize
, output logic [ 3:0] o_ram_hprot
, output logic [ 1:0] o_ram_htrans
, output logic [63:0] o_ram_hwdata
, output logic [ 0:0] o_ram_hwrite
, input  logic [63:0] i_ram_hrdata
, input  logic [ 0:0] i_ram_hresp
, input  logic [ 0:0] i_ram_hready

, output logic [31:0] o_rom_haddr
, output logic [ 1:0] o_rom_htrans
, output logic [ 0:0] o_rom_hwrite
, input  logic [31:0] i_rom_hrdata
, input  logic [ 0:0] i_rom_hresp
, input  logic [ 0:0] i_rom_hready

, input  logic [31:0] i_gpio
, output logic [31:0] o_gpio_oe
, output logic [31:0] o_gpio
);

    AE350_SOC u_hard
    // Reset signals
    ( .POR_N  (i_rst_n)
    , .HW_RSTN(i_rst_n)

    // Clock signals
    , .CORE_CLK(i_core_clk)
    , .DDR_CLK (i_ddr_clk)
    , .AHB_CLK (i_bus_clk)
    , .APB_CLK (i_bus_clk)
    , .RTC_CLK (i_rtc_clk)

    // Clock gate signals
    , .CORE_CE(1'b1)
    , .AXI_CE(1'b1)
    , .DDR_CE(1'b1)
    , .AHB_CE(1'b1)
    , .APB_CE(8'b11111111)
    , .APB2AHB_CE(1'b1)

    // APB/AHB/DDR bus reset signals
    , .PRESETN (o_apb_rst_n)
    , .HRESETN (o_ahb_rst_n)
    , .DDR_RSTN(o_ddr_rst_n)

    // Extended Interrupt signals
    // 16 user interrupt input
    , .GP_INT(16'h0000)

    // DMA Signals
    // 8 dma requests input
    , .DMA_REQ(8'h00)
    // 8 dma ack output
    , .DMA_ACK()

    // SMU signals
    // Input to wake up CPU, 0 is wake up
    , .WAKEUP_IN(1'b0)
    // CPU going into WFI mode, posedge is WFI valid
    , .CORE0_WFI_MODE()
    // Output to wake up RTC clock, 1 is wake up
    , .RTC_WAKEUP()

    // ROM AHB bus signals
    , .ROM_HADDR (o_rom_haddr)
    , .ROM_HRDATA(i_rom_hrdata)
    , .ROM_HREADY(i_rom_hready)
    , .ROM_HRESP (i_rom_hresp)
    , .ROM_HTRANS(o_rom_htrans)
    , .ROM_HWRITE(o_rom_hwrite)

    // Extended APB slave signals
    , .APB_PADDR()
    , .APB_PENABLE()
    , .APB_PRDATA(32'h00000000)
    , .APB_PREADY(1'b0)
    , .APB_PSEL()
    , .APB_PWDATA()
    , .APB_PWRITE()
    , .APB_PSLVERR(1'b0)
    , .APB_PPROT()
    , .APB_PSTRB()

    // Extended AHB slave signals
    , .EXTS_HRDATA(32'h00000000)
    , .EXTS_HREADYIN(1'b0)
    , .EXTS_HRESP(1'b0)
    , .EXTS_HADDR()
    , .EXTS_HBURST()
    , .EXTS_HPROT()
    , .EXTS_HSEL()
    , .EXTS_HSIZE()
    , .EXTS_HTRANS()
    , .EXTS_HWDATA()
    , .EXTS_HWRITE()

    // Extended AHB master signals
    , .EXTM_HADDR(32'h00000000)
    , .EXTM_HBURST(3'b000)
    , .EXTM_HPROT(4'h0)
    , .EXTM_HRDATA()
    , .EXTM_HREADY(1'b0)
    , .EXTM_HREADYOUT()
    , .EXTM_HRESP()
    , .EXTM_HSEL(1'b0)
    , .EXTM_HSIZE(3'b000)
    , .EXTM_HTRANS(2'b00)
    , .EXTM_HWDATA(64'h0000000000000000)
    , .EXTM_HWRITE(1'b0)

    // DDR AHB bus signals
    , .DDR_HADDR (o_ram_haddr)
    , .DDR_HBURST(o_ram_hburst)
    , .DDR_HPROT (o_ram_hprot)
    , .DDR_HRDATA(i_ram_hrdata)
    , .DDR_HREADY(i_ram_hready)
    , .DDR_HRESP (i_ram_hresp)
    , .DDR_HSIZE (o_ram_hsize)
    , .DDR_HTRANS(o_ram_htrans)
    , .DDR_HWDATA(o_ram_hwdata)
    , .DDR_HWRITE(o_ram_hwrite)

    // Debug JTAG signals
    , .DBG_TCK(i_tck)
    , .TMS_IN (i_tms)
    , .TRST_IN(i_trst)
    , .TDI_IN (i_tdi)
    , .TDO_OUT(o_tdo)
    , .TDO_OE ()

    // SPI signals
    , .SPI2_HOLDN_IN(1'b0)
    , .SPI2_WPN_IN(1'b0)
    , .SPI2_CLK_IN(1'b0)
    , .SPI2_CSN_IN(1'b0)
    , .SPI2_MISO_IN(1'b0)
    , .SPI2_MOSI_IN(1'b0)
    , .SPI2_HOLDN_OUT()
    , .SPI2_HOLDN_OE()
    , .SPI2_WPN_OUT()
    , .SPI2_WPN_OE()
    , .SPI2_CLK_OUT()
    , .SPI2_CLK_OE()
    , .SPI2_CSN_OUT()
    , .SPI2_CSN_OE()
    , .SPI2_MISO_OUT()
    , .SPI2_MISO_OE()
    , .SPI2_MOSI_OUT()
    , .SPI2_MOSI_OE()

    // I2C signals
    , .I2C_SCL_IN(1'b0)
    , .I2C_SDA_IN(1'b0)
    , .I2C_SCL()
    , .I2C_SDA()

    // UART1 signals
    , .UART1_TXD  ()
    , .UART1_RTSN ()
    , .UART1_RXD  (1'b0)
    , .UART1_CTSN (1'b0)
    , .UART1_DSRN (1'b0)
    , .UART1_DCDN (1'b0)
    , .UART1_RIN  (1'b0)
    , .UART1_DTRN ()
    , .UART1_OUT1N()
    , .UART1_OUT2N()

    // UART2 signals
    , .UART2_TXD  ()
    , .UART2_RTSN ()
    , .UART2_RXD  (1'b0)
    , .UART2_CTSN (1'b0)
    , .UART2_DCDN (1'b0)
    , .UART2_DSRN (1'b0)
    , .UART2_RIN  (1'b0)
    , .UART2_DTRN ()
    , .UART2_OUT1N()
    , .UART2_OUT2N()

    // PIT/PWM signals
    , .CH0_PWM  ()
    , .CH0_PWMOE()
    , .CH1_PWM  ()
    , .CH1_PWMOE()
    , .CH2_PWM  ()
    , .CH2_PWMOE()
    , .CH3_PWM  ()
    , .CH3_PWMOE()

    // GPIO
    , .GPIO_IN (i_gpio)
    , .GPIO_OE (o_gpio_oe)
    , .GPIO_OUT(o_gpio)

    // Test signals
    // Scan test, to SPI and clock gen
    , .SCAN_TEST    (1'b0)
    // Scan enable, to SPI and clock gen
    , .SCAN_EN      (1'b0)
    // Test mode clock
    , .TEST_CLK     (1'b0)
    // Test mode, 1 is enable
    , .TEST_MODE    (1'b0)
    // Test mode resetn, 0 is reset state
    , .TEST_RSTN    (1'b1)
    // Local memory signals
    , .PGEN_CHAIN_I (1'b1)
    , .PRDYN_CHAIN_O()
    , .EMA          (3'b011)
    , .EMAW         (2'b01)
    , .EMAS         (1'b0)
    , .RET1N        (1'b1)
    , .RET2N        (1'b1)
    // MBIST signals
    , .SCAN_IN      (20'h00000)
    , .INTEG_TCK    (1'b0)
    , .INTEG_TDI    (1'b0)
    , .INTEG_TMS    (1'b0)
    // Close MBIST
    , .INTEG_TRST   (1'b0)
    , .INTEG_TDO    ()
    , .SCAN_OUT     ()
    );

endmodule : hard_ae350
