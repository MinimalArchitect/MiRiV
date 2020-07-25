		.text
		.align  2
		.globl  _start

_start:
		addi x1, x0, 7
		addi x2, x0, 5
		and x1, x2, x1
		nop
		nop

		.end _start
		.size _start, .-_start
