#
# First compile TB and DUT with:
#   make compile
#
# Then run Test with:
#   make sim IMEM=imem.mif DMEM=dmem.mif
#

FILE_OPT:=

ifndef TIME
TIME = 1ms
endif

ifdef IMEM
FILE_OPT += -G IMEM_FILE=$(IMEM)
endif

ifdef DMEM
FILE_OPT += -G DMEM_FILE=$(DMEM)
endif

all: compile

clean:
	rm -fr work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini
	rm -f output.txt

compile:
	@vsim -c -do "do scripts/compile.do;quit -f"

sim:
	@vsim -c $(FILE_OPT) -t ps work.tb_cpu -quiet -do "run $(TIME);quit -f" | grep "\*\*"
	@cat output.txt

sim_gui:
	@vsim $(FILE_OPT) -t ps work.tb_cpu -quiet -do "do scripts/wave.do;run 5us;wave zoom full"


.PHONY: all clean compile sim sim_gui
