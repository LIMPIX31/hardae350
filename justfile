sram project profile:
    cd target/riscv32imafc-unknown-none-elf/{{profile}}/ \
    && riscv32-unknown-elf-objcopy -O binary {{project}} {{project}}.bin \
    && xxd -p -c4 {{project}}.bin | sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > {{project}}.mem

    cp target/riscv32imafc-unknown-none-elf/{{profile}}/{{project}}.mem {{project}}/sram.mem
