#![no_std]
#![no_main]

extern crate panic_halt;

use core::arch::asm;

use riscv::{
	asm,
	interrupt::{self, Interrupt},
};
use riscv_rt::{core_interrupt, entry};
use volatile_register::{RO, RW, WO};

const SMU_BASE: usize = 0xF010_0000;
const PLIC_BASE: usize = 0xE400_0000;
const RTC_BASE: usize = 0xF060_0000;
const GPIO_BASE: usize = 0xF070_0000;

#[entry]
fn main() -> ! {
	interrupt::disable();

	// I have absolutely no idea what the following unsafe code does,
	// but it is what official ae350 hal written in C from AndesTech
	// does on reset
	unsafe {
		volatile!(WO, SMU_BASE).write(0x8000_0000);
		let mmisc: usize;
		asm!("csrrw {}, 0x7d0, {}", out(reg) mmisc, in(reg) (1 << 8) | (1 << 6));

		let plic_feature = volatile!(WO, PLIC_BASE);

		if mmisc & (1 << 1) > 0 {
			plic_feature.write(0b11);
		} else {
			plic_feature.write(0b01);
		}
	}

	// Enable RTC interrupt
	plic_set_priority(1, 1);
	plic_enable_interrupt(1);

	let rtc = Rtc::new();

	// Wait until RTC is ready
	while rtc.status.read() >> 16 & 1 == 0 {}

	// Enable RTC and interrupt every second
	unsafe {
		rtc.ctrl.write(0b01000001);
		rtc.status.modify(|it| it | 0b11111100);
	}

	let gpio = Gpio::new();

	// Initialize GPIO
	unsafe {
		gpio.intr_en.write(0);
		gpio.intr_status.write(0xFFFF_FFFF);
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
	let source = plic_claim_interrupt();

	match source {
		// RTC period
		1 => {
			let rtc = Rtc::new();
			// Load RTC status
			let status = rtc.status.read() & 0b1111000;
			// Clear interrupt status
			unsafe {
				rtc.status.write(status);
			}

			let gpio = Gpio::new();

			// Blink every second
			if status >> 6 & 1 == 1 {
				unsafe {
					if BLINK {
						gpio.dout_set.write(1);
					} else {
						gpio.dout_clear.write(1);
					}

					BLINK = !BLINK;
				}
			}
		}
		_ => {
			// Handle any other interrupts
		}
	}

	plic_complete_interrupt(source);
}

#[repr(C)]
struct Rtc {
	idrev:    RO<usize>,  // 0x00 ID and Revision Register
	reserved: [usize; 3], // 0x04~0x0C Reserved
	cntr:     RW<usize>,  // 0x10 Counter Register
	alarm:    RW<usize>,  // 0x14 Alarm Register
	ctrl:     RW<usize>,  // 0x18 Control Register
	status:   RW<usize>,  // 0x1C Status Register
	trim:     RW<usize>,  // 0x20 Digit Trimming Register
}

impl Rtc {
	#[inline]
	fn new<'a>() -> &'a Self {
		unsafe { &*(RTC_BASE as *const Self) }
	}
}

#[repr(C)]
pub struct Gpio {
	idrev:         RO<usize>,
	reserved0:     [usize; 3],
	cfg:           RO<usize>,
	reserved1:     [usize; 3],
	data_in:       RO<usize>,
	data_out:      RW<usize>,
	channel_dir:   RW<usize>,
	dout_clear:    WO<usize>,
	dout_set:      WO<usize>,
	reserved2:     [usize; 3],
	pull_en:       RW<usize>,
	pull_type:     RW<usize>,
	reserved3:     [usize; 2],
	intr_en:       RW<usize>,
	intr_mode0:    RW<usize>,
	intr_mode1:    RW<usize>,
	intr_mode2:    RW<usize>,
	intr_mode3:    RW<usize>,
	intr_status:   RW<usize>,
	reserved4:     [usize; 2],
	debounce_en:   RW<usize>,
	debounce_ctrl: RW<usize>,
	reserved5:     [usize; 2],
}

impl Gpio {
	#[inline]
	fn new<'a>() -> &'a Self {
		unsafe { &*(GPIO_BASE as *const Self) }
	}
}

#[inline]
fn plic_set_priority(source: usize, priority: usize) {
	let addr = PLIC_BASE + 0x0000_0000 + (source << 2);

	unsafe {
		volatile!(WO, addr).write(priority);
	}
}

#[inline]
fn plic_enable_interrupt(source: usize) {
	let addr = PLIC_BASE + 0x0000_2000 + ((source >> 5) << 2);

	unsafe {
		volatile!(RW, addr).modify(|it| it | (1 << (source & 0x1F)));
	}
}

#[inline]
fn plic_claim_interrupt() -> usize {
	unsafe { volatile!(RO, PLIC_BASE + 0x0020_0004).read() }
}

#[inline]
fn plic_complete_interrupt(source: usize) {
	unsafe {
		volatile!(WO, PLIC_BASE + 0x0020_0004).write(source);
	};
}

#[macro_export]
macro_rules! volatile {
	($access:ident, $addr:expr) => {
		&*($addr as *const ::volatile_register::$access<usize>)
	};
}
