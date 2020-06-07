onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/CLK_PERIOD
add wave -noupdate /tb/fetch_inst/clk
add wave -noupdate /tb/fetch_inst/reset
add wave -noupdate -divider Input
add wave -noupdate /tb/fetch_inst/stall
add wave -noupdate /tb/fetch_inst/flush
add wave -noupdate /tb/fetch_inst/pcsrc
add wave -noupdate /tb/fetch_inst/pc_in
add wave -noupdate /tb/fetch_inst/mem_in
add wave -noupdate -divider Output
add wave -noupdate /tb/fetch_inst/mem_busy
add wave -noupdate /tb/fetch_inst/pc_out
add wave -noupdate /tb/fetch_inst/instr
add wave -noupdate /tb/fetch_inst/mem_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {5250 ns}
