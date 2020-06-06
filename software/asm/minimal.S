		.text
		.align  2
		.globl  _start

_start:
		nop
		lw x0, 4(x0)
		nop
		nop
		sw x0, 8(x0)
		nop
		nop

		.end _start
		.size _start, .-_start
