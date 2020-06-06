		.text
		.align  2
		.globl  _start

_start:
		addi x5, x0, 0
		nop
		nop
loop:
		addi x5, x5, 1
		nop
		nop
		sw x5, 16(x0)
		jal x0, loop
		nop
		nop
		nop

		.end _start
		.size _start, .-_start
