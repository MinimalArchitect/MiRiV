onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/CLK_PERIOD
add wave -noupdate /tb/decode_inst/clk
add wave -noupdate /tb/decode_inst/reset
add wave -noupdate -divider Input
add wave -noupdate /tb/decode_inst/stall
add wave -noupdate /tb/decode_inst/flush
add wave -noupdate -radix hexadecimal /tb/decode_inst/pc_in
add wave -noupdate -radix hexadecimal /tb/decode_inst/instr
add wave -noupdate -radix hexadecimal /tb/decode_inst/reg_write
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/decode_inst/pc_out
add wave -noupdate -radix hexadecimal /tb/decode_inst/exec_op
add wave -noupdate -radix hexadecimal /tb/decode_inst/mem_op
add wave -noupdate /tb/decode_inst/wb_op
add wave -noupdate /tb/decode_inst/exc_dec
add wave -noupdate -divider Other
add wave -noupdate /tb/decode_inst/instruction
add wave -noupdate /tb/decode_inst/program_counter
add wave -noupdate /tb/decode_inst/instruction_format
add wave -noupdate /tb/decode_inst/funct7
add wave -noupdate /tb/decode_inst/funct3
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
