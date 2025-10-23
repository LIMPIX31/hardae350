# AE350 SoC Bare Metal Rust Examples
Everything in this repository is designed for the [Sipeed Tang Mega 138K Pro](https://wiki.sipeed.com/hardware/en/tang/tang-mega-138k/mega-138k-pro.html) board featuring the [Gowin GW5AST](https://www.gowinsemi.com/en/product/detail/76/) chip along with the on-chip [AndesTech AE350 A25 SoC](https://www.andestech.com/en/products-solutions/andeshape-platforms/ae350-axi-based-platform-pre-integrated-with-n25f-nx25f-a25-ax25/).

## Blink
Blinks the **N23** led.

#### Features
* Using the **hard** AE350 IP instead of a soft one
* No **DDR3** for simplicity and faster memory access
* **ROM** and **Stack** memory sections placed on SRAM
* **AHB** <=> **SRAM** speed: **200 Mhz**
* **100%** Rust

Compile the example with [just](https://github.com/casey/just#readme):
```bash
# Build the project
cargo build -p blink --release
# Write the SRAM init file
just sram blink release
```
Then open the project in [Gowin EDA](https://www.gowinsemi.com/en/support/home/) and do syn, pnr, flash as usual. Or use [Gowiners](https://crates.io/crates/gowiners):
```bash
# Change dir
cd crates/blink
# Define Gowin EDA location
echo "/home/limpix/gowin" > .gowin
# Run implementation
gowiners impl
# Flash to SRAM
gowiners flash sram
```

## Debug
Demo project to examine on-chip debugging with openocd and gdb
> [!WARNING]
> Do NOT burn SPI flash, as debugging requires “JTAG as regular I/O,” which means you CANNOT reconfigure the FPGA while it is configured using a bitstream with this option.
#### 1. Build the project for debug
```bash
# Build the project with the debug profile
cargo build -p blink
# Write the SRAM init file
just sram blink debug
```
Then open Gowin EDA and do syn, pnr and flash as usual.

#### 2. Run openocd
Flash the bitstream to the board and run openocd
```bash
openocd -f crates/dbg/openocd.cfg
```

#### 3. Launch a debugging session
Common gdb session
```bash
# Launch remote gdb session
riscv32-unknown-elf-gdb -x debug/ae350.gdb
# Add breakpoint
hbreak blink::external_interrupt
continue
# ...
```

## Uart
*WiP*
