onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/CLK_PERIOD
add wave -noupdate -divider Input
add wave -noupdate /tb/alu_inst/op
add wave -noupdate /tb/alu_inst/A
add wave -noupdate /tb/alu_inst/B
add wave -noupdate -divider Output
add wave -noupdate /tb/alu_inst/R
add wave -noupdate /tb/alu_inst/Z
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
