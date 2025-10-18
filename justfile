build-sram project:
    cargo build -p {{project}} --release

    cd target/riscv32imafc-unknown-none-elf/release/ \
    && riscv32-unknown-elf-objcopy -O binary {{project}} {{project}}.bin \
    && xxd -p -c4 {{project}}.bin | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > {{project}}.mem

    cp target/riscv32imafc-unknown-none-elf/release/{{project}}.mem crates/blink/sram.mem
