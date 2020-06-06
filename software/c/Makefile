PREFIX=riscv32-unknown-elf

AS=${PREFIX}-as
CC=${PREFIX}-gcc -march=rv32i
LD=${PREFIX}-gcc -march=rv32i -nostartfiles -Wl,-N,-e,_start,-Ttext=0x40000000,--section-start,.rodata=4
AR=${PREFIX}-ar
OBJCOPY=${PREFIX}-objcopy

CFLAGS=-O2

all: helloworld md5

helloworld: helloworld.imem.mif helloworld.dmem.mif
md5: md5.imem.mif md5.dmem.mif

helloworld.elf: libc.a crt0.o helloworld.o
	${LD} $^ -L. -lc -o $@

md5.elf: libc.a crt0.o md5.o md5main.o
	${LD} $^ -L. -lc -o $@

%.elf : libc.a crt0.o  %.o
	${LD} $^ -L. -lc -o $@

lib: libc.a

libc.a: util.o
	${AR} rc $@ $^

%.imem.hex : %.elf
	${OBJCOPY} -j .text -O ihex $< $@

%.dmem.hex : %.elf
	${OBJCOPY} -R .text -O ihex $< $@

%.mif : %.hex
	./hex2mif.pl < $< > $@

clean:
	rm -rf libc.a *.s *.o *.elf *.hex *.mif

.PHONY: all lib helloworld md5
