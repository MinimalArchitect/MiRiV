.PHONY: all clean compile sim sim_gui

all: compile

clean:
	rm -fr work
	rm -f transcript
	rm -f *.wlf
	rm -f modelsim.ini

compile:
	@vsim -c -do "do scripts/compile.do;quit -f"

sim:
	@vsim -c -t ps work.tb -quiet -do "run 5us;quit -f" | grep "\*\*"

sim_gui:
	@vsim -t ps work.tb -quiet -do "do scripts/wave.do;run 500ns;wave zoom full"
