#![no_std]
#![no_main]

extern crate panic_halt;

use core::arch::asm;

use anders::hal::{
	gpio,
	plic::{self, PlicVolatile},
	rtc, smu,
};
use riscv::{
	asm,
	interrupt::{self, Interrupt},
};
use riscv_rt::{core_interrupt, entry};

#[entry]
fn main() -> ! {
	interrupt::disable();

	// I have absolutely no idea what the following unsafe code does,
	// but it is what official ae350 hal written in C from AndesTech
	// does on reset
	unsafe {
		smu::hart0_reset_vector().write(0x8000_0000);
		let mmisc: usize;
		asm!("csrrw {}, 0x7d0, {}", out(reg) mmisc, in(reg) (1 << 8) | (1 << 6));

		let plic_feature = plic::hw::feature();

		if mmisc & (1 << 1) > 0 {
			plic_feature.write(0b11);
		} else {
			plic_feature.write(0b01);
		}
	}

	// Enable RTC interrupt
	unsafe {
		plic::hw::priority(1).write(1);
		plic::hw::interrupt(1).write(1 << 1);
	}

	// Wait until RTC is ready
	while rtc::status().read() >> 16 & 1 == 0 {}

	// Enable RTC and interrupt every second
	unsafe {
		rtc::control().write(0b01000001);
		rtc::status().modify(|it| it | 0b11111100);
	}

	// Initialize GPIO
	unsafe {
		gpio::intr_en().write(0);
		gpio::intr_status().write(0xFFFF_FFFF);
	}

	// Enable external machine interrupts
	unsafe {
		interrupt::enable();
		interrupt::enable_interrupt(Interrupt::MachineExternal);
	}

	loop {
		asm::wfi();
	}
}

static mut BLINK: bool = false;

#[core_interrupt(Interrupt::MachineExternal)]
fn external_interrupt() {
	let source = plic::hw::status().read();

	match source {
		// RTC period
		1 => {
			// Load RTC status
			let status = rtc::status().read() & 0b1111000;
			// Clear interrupt status
			unsafe {
				rtc::status().write(status);
			}

			// Blink every second
			if status >> 6 & 1 == 1 {
				unsafe {
					if BLINK {
						gpio::dout_set().write(1);
					} else {
						gpio::dout_clear().write(1);
					}

					BLINK = !BLINK;
				}
			}
		}
		_ => {
			// Handle any other interrupts
		}
	}

	unsafe {
		plic::hw::status().write(source);
	}
}
