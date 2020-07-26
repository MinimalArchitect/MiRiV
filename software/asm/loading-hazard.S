		.text
		.align  2
		.globl  _start

_start:
		nop
		lw x1, 4(x0)
		nop
		nop
		addi x1, x1, 10
		nop
		nop
		nop
		nop

		.end _start
		.size _start, .-_start
