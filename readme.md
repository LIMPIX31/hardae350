# AE350 SoC Bare Metal Rust Examples
Everything in this repository is designed for the [Sipeed Tang Mega 138K Pro](https://wiki.sipeed.com/hardware/en/tang/tang-mega-138k/mega-138k-pro.html) board featuring the [Gowin GW5AST](https://www.gowinsemi.com/en/product/detail/76/) chip along with the on-chip [AndesTech AE350 A25 SoC](https://www.andestech.com/en/products-solutions/andeshape-platforms/ae350-axi-based-platform-pre-integrated-with-n25f-nx25f-a25-ax25/).

### Blink
Blinks the **J14** led.

#### Features
* Using the **hard** AE350 IP instead of a soft one
* No **DDR3** for simplicity and faster memory access
* **ROM** and **Stack** memory sections placed on SRAM
* **AHB** <=> **SRAM** speed: **200 Mhz**
* **100%** Rust

Compile the example with [just](https://github.com/casey/just#readme):
```bash
# Compile sram initialization file
just build-sram blink
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
