set debug remote 1
target extended-remote :3333
file target/riscv32imafc-unknown-none-elf/debug/uart
monitor reset halt
