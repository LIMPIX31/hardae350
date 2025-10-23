#![no_std]
#![no_main]

extern crate panic_halt;

use anders::hal::{
	dma,
	plic::{self, PlicVolatile},
	uart,
};
use riscv::{
	asm,
	interrupt::{self, Interrupt},
};
use riscv_rt::{core_interrupt, entry};

#[entry]
fn main() -> ! {
	interrupt::disable();

	let baudrate = 115_200;
	let data = b"Hello, world! I hope...";

	let div = (200_000_000 + 8 * baudrate) / (16 * baudrate);

	unsafe {
		uart::ier().write(0);
		uart::fcr().write(0x01 | 0x08);

		uart::lcr().write(0);
		uart::lcr().write(3);
		uart::lcr().modify(|it| it | 0x80);
		uart::dll().write((div >> 0) & 0xff);
		uart::dlm().write((div >> 8) & 0xff);
		// Reset DLAB bit
		uart::lcr().modify(|it| it & !0x80);

		plic::hw::priority(8).write(1);
		plic::hw::interrupt(8).write(1 << 8);

		interrupt::enable();
		interrupt::enable_interrupt(Interrupt::MachineExternal);

		dma::control().write(0);

		for channel in dma::channels() {
			channel.control.write(0);
			channel.src_addr_h.write(0);
			channel.dst_addr_h.write(0);
			channel.llp_l.write(0);
			channel.llp_h.write(0);
		}

		dma::status().write(0xFFFFFF);

		plic::hw::priority(10).write(1);
		plic::hw::interrupt(10).write(1 << 10);

		let channel = dma::channel(0);

		channel.transize.write(data.len() as u32);
		channel.src_addr_l.write(data.as_ptr() as u32);
		channel.dst_addr_l.write(uart::thr() as *const _ as u32);

		channel.control.write(0b11_0_0000_000_000_01_00_10_0000_0100_1111);
	}

	loop {
		asm::wfi();
	}
}

#[core_interrupt(Interrupt::MachineExternal)]
fn machine_interrupt() {
	let source = plic::hw::status().read();

	asm::nop();

	unsafe {
		plic::hw::status().write(source);
	}
}
