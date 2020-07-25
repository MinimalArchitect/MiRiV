		.text
		.align  2
		.globl  _start

_start:
loop:
		j loop
		addi x1, x1, 1
		addi x2, x2, 1
		addi x3, x3, 1

		.end _start
		.size _start, .-_start
