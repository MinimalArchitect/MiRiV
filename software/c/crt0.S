	.section .text.startup
	.org 0x00
	.align	2
	.globl	_start

_start:
	nop
.option push
.option norelax
1:auipc gp, %pcrel_hi(__global_pointer$)
  addi  gp, gp, %pcrel_lo(1b)
.option pop
	la		sp,0x1000
	jal		main
	nop

loop:
	j		loop
	nop
	nop
	nop

	.end	_start
	.size	_start, .-_start
