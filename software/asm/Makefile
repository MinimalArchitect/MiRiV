PREFIX=riscv32-unknown-elf

CC=${PREFIX}-gcc
AS=${PREFIX}-as
LD=${PREFIX}-ld -N --section-start=.text=0x0 -no-relex
AR=${PREFIX}-ar
OBJCOPY=${PREFIX}-objcopy

FILES=$(wildcard *.S)

all: $(FILES:.S=.imem.mif) $(FILES:.S=.dmem.mif)

%.o: %.S
	${AS} $< -o $@

%.elf: %.o
	${LD} $^ -o $@

%.imem.hex : %.elf
	${OBJCOPY} -j .text -O ihex $< $@

%.dmem.hex : %.elf
	${OBJCOPY} -j .rodata -O ihex $< $@

%.mif : %.hex
	./hex2mif.pl < $< > $@

clean:
	rm -rf *.o *.elf *.hex *.mif

.PHONY: clean all
