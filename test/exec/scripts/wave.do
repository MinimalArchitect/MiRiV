onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/CLK_PERIOD
add wave -noupdate /tb/exec_inst/clk
add wave -noupdate /tb/exec_inst/reset
add wave -noupdate -divider Input
add wave -noupdate /tb/exec_inst/stall
add wave -noupdate /tb/exec_inst/flush
add wave -noupdate -radix hexadecimal /tb/exec_inst/op
add wave -noupdate -radix hexadecimal /tb/exec_inst/pc_in
add wave -noupdate -radix hexadecimal /tb/exec_inst/reg_write_mem
add wave -noupdate -radix hexadecimal /tb/exec_inst/reg_write_wr
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/exec_inst/pc_old_out
add wave -noupdate -radix hexadecimal /tb/exec_inst/pc_new_out
add wave -noupdate -radix hexadecimal /tb/exec_inst/aluresult
add wave -noupdate -radix hexadecimal /tb/exec_inst/zero
add wave -noupdate -radix hexadecimal /tb/exec_inst/memop_out
add wave -noupdate -radix hexadecimal /tb/exec_inst/wbop_out
add wave -noupdate -radix hexadecimal /tb/exec_inst/exec_op
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
