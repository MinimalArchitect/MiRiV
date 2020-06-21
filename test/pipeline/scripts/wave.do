onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/CLK_PERIOD
add wave -noupdate /tb/pipeline_inst/clk
add wave -noupdate /tb/pipeline_inst/reset
add wave -noupdate -divider Input
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_i_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_d_in
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_i_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_d_out
add wave -noupdate -divider Other
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
