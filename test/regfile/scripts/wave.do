onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/regfile_inst/clk
add wave -noupdate /tb/regfile_inst/reset
add wave -noupdate -divider Input
add wave -noupdate -radix unsigned /tb/regfile_inst/rdaddr1
add wave -noupdate -radix unsigned /tb/regfile_inst/rdaddr2
add wave -noupdate /tb/regfile_inst/regwrite
add wave -noupdate /tb/regfile_inst/stall
add wave -noupdate -radix unsigned /tb/regfile_inst/wraddr
add wave -noupdate -radix hexadecimal /tb/regfile_inst/wrdata
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/regfile_inst/rddata1
add wave -noupdate -radix hexadecimal /tb/regfile_inst/rddata2
add wave -noupdate -divider Other
add wave -noupdate -radix hexadecimal /tb/regfile_inst/regfile
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
