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
add wave -noupdate -divider Registerfile
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/regfile_inst/regfile

add wave -noupdate -divider Fetch_INPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/fetch_inst/pcsrc
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/fetch_inst/pc_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/fetch_inst/mem_in
add wave -noupdate -divider Fetch_OUTPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/fetch_inst/mem_busy
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/fetch_inst/pc_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/fetch_inst/instr
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/fetch_inst/mem_out

add wave -noupdate -divider Decode_INPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/pc_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/instr
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/reg_write
add wave -noupdate -divider Decode_OUTPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/pc_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/exec_op
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/mem_op
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/wb_op
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/decode_inst/exc_dec

add wave -noupdate -divider Execute_INPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/op
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/pc_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/memop_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/wbop_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/reg_write_mem
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/reg_write_wr
add wave -noupdate -divider Execute_OUTPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/pc_old_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/pc_new_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/aluresult
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/wrdata
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/zero
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/memop_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/wbop_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/exec_inst/exec_op

add wave -noupdate -divider Memory_INPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/mem_op
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/wbop_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/pc_new_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/pc_old_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/aluresult_in
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/wrdata
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/zero
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/mem_in
add wave -noupdate -divider Memory_OUTPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/mem_busy
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/reg_write
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/pc_new_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/pcsrc
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/wbop_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/pc_old_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/aluresult_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/memresult
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/mem_out
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/exc_load
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/mem_inst/exc_store

add wave -noupdate -divider Writeback_INPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/wb_inst/op
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/wb_inst/aluresult
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/wb_inst/memresult
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/wb_inst/pc_old_in
add wave -noupdate -divider Writeback_OUTPUT
add wave -noupdate -radix hexadecimal /tb/pipeline_inst/wb_inst/reg_write

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
