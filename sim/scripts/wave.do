onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/dut/clk
add wave -noupdate /tb_cpu/dut/reset
add wave -noupdate -divider -height 40 fetch
add wave -noupdate -expand -group fetch /tb_cpu/dut/fetch_inst/stall
add wave -noupdate -expand -group fetch /tb_cpu/dut/fetch_inst/flush
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/fetch_inst/pc_in
add wave -noupdate -expand -group fetch /tb_cpu/dut/fetch_inst/pcsrc
add wave -noupdate -expand -group fetch -childformat {{/tb_cpu/dut/fetch_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/fetch_inst/mem_in.rddata {-radix hexadecimal}} /tb_cpu/dut/fetch_inst/mem_in
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/fetch_inst/instr
add wave -noupdate -expand -group fetch /tb_cpu/dut/fetch_inst/mem_busy
add wave -noupdate -expand -group fetch -radix hexadecimal /tb_cpu/dut/fetch_inst/pc_out
add wave -noupdate -expand -group fetch -childformat {{/tb_cpu/dut/fetch_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/fetch_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/fetch_inst/mem_out.address {-radix hexadecimal} /tb_cpu/dut/fetch_inst/mem_out.wrdata {-radix hexadecimal}} /tb_cpu/dut/fetch_inst/mem_out
add wave -noupdate -divider -height 40 decode
add wave -noupdate -expand -group decode /tb_cpu/dut/decode_inst/stall
add wave -noupdate -expand -group decode /tb_cpu/dut/decode_inst/flush
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/decode_inst/instr
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/decode_inst/pc_in
add wave -noupdate -expand -group decode -childformat {{/tb_cpu/dut/decode_inst/reg_write.reg -radix unsigned} {/tb_cpu/dut/decode_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/decode_inst/reg_write.reg {-radix unsigned} /tb_cpu/dut/decode_inst/reg_write.data {-radix hexadecimal}} /tb_cpu/dut/decode_inst/reg_write
add wave -noupdate -expand -group decode -childformat {{/tb_cpu/dut/decode_inst/exec_op.rs1 -radix unsigned} {/tb_cpu/dut/decode_inst/exec_op.rs2 -radix unsigned} {/tb_cpu/dut/decode_inst/exec_op.readdata1 -radix hexadecimal} {/tb_cpu/dut/decode_inst/exec_op.readdata2 -radix hexadecimal} {/tb_cpu/dut/decode_inst/exec_op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/decode_inst/exec_op.rs1 {-radix unsigned} /tb_cpu/dut/decode_inst/exec_op.rs2 {-radix unsigned} /tb_cpu/dut/decode_inst/exec_op.readdata1 {-radix hexadecimal} /tb_cpu/dut/decode_inst/exec_op.readdata2 {-radix hexadecimal} /tb_cpu/dut/decode_inst/exec_op.imm {-radix hexadecimal}} /tb_cpu/dut/decode_inst/exec_op
add wave -noupdate -expand -group decode -expand /tb_cpu/dut/decode_inst/mem_op
add wave -noupdate -expand -group decode -expand /tb_cpu/dut/decode_inst/wb_op
add wave -noupdate -expand -group decode -radix hexadecimal /tb_cpu/dut/decode_inst/pc_out
add wave -noupdate -expand -group decode /tb_cpu/dut/decode_inst/exc_dec
add wave -noupdate -divider -height 40 exec
add wave -noupdate -expand -group exec /tb_cpu/dut/exec_inst/stall
add wave -noupdate -expand -group exec /tb_cpu/dut/exec_inst/flush
add wave -noupdate -expand -group exec -childformat {{/tb_cpu/dut/exec_inst/op.rs1 -radix unsigned} {/tb_cpu/dut/exec_inst/op.rs2 -radix unsigned} {/tb_cpu/dut/exec_inst/op.readdata1 -radix hexadecimal} {/tb_cpu/dut/exec_inst/op.readdata2 -radix hexadecimal} {/tb_cpu/dut/exec_inst/op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/exec_inst/op.rs1 {-radix unsigned} /tb_cpu/dut/exec_inst/op.rs2 {-radix unsigned} /tb_cpu/dut/exec_inst/op.readdata1 {-radix hexadecimal} /tb_cpu/dut/exec_inst/op.readdata2 {-radix hexadecimal} /tb_cpu/dut/exec_inst/op.imm {-radix hexadecimal}} /tb_cpu/dut/exec_inst/op
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/exec_inst/pc_in
add wave -noupdate -expand -group exec -childformat {{/tb_cpu/dut/exec_inst/reg_write_mem.reg -radix unsigned} {/tb_cpu/dut/exec_inst/reg_write_mem.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/exec_inst/reg_write_mem.reg {-radix unsigned} /tb_cpu/dut/exec_inst/reg_write_mem.data {-radix hexadecimal}} /tb_cpu/dut/exec_inst/reg_write_mem
add wave -noupdate -expand -group exec /tb_cpu/dut/exec_inst/reg_write_wr
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/exec_inst/pc_new_out
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/exec_inst/pc_old_out
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/exec_inst/aluresult
add wave -noupdate -expand -group exec /tb_cpu/dut/exec_inst/zero
add wave -noupdate -expand -group exec -radix hexadecimal /tb_cpu/dut/exec_inst/wrdata
add wave -noupdate -divider -height 40 mem
add wave -noupdate -expand -group mem /tb_cpu/dut/mem_inst/stall
add wave -noupdate -expand -group mem /tb_cpu/dut/mem_inst/flush
add wave -noupdate -expand -group mem /tb_cpu/dut/mem_inst/mem_op
add wave -noupdate -expand -group mem /tb_cpu/dut/mem_inst/zero
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/mem_inst/wrdata
add wave -noupdate -expand -group mem /tb_cpu/dut/mem_inst/mem_busy
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/mem_inst/memresult
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/mem_inst/pc_new_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/mem_inst/pc_new_out
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/mem_inst/pc_old_in
add wave -noupdate -expand -group mem -radix hexadecimal /tb_cpu/dut/mem_inst/pc_old_out
add wave -noupdate -expand -group mem /tb_cpu/dut/mem_inst/pcsrc
add wave -noupdate -expand -group mem /tb_cpu/dut/mem_inst/reg_write
add wave -noupdate -expand -group mem -childformat {{/tb_cpu/dut/mem_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/mem_inst/mem_in.rddata {-radix hexadecimal}} /tb_cpu/dut/mem_inst/mem_in
add wave -noupdate -expand -group mem -childformat {{/tb_cpu/dut/mem_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/mem_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/mem_inst/mem_out.address {-radix hexadecimal} /tb_cpu/dut/mem_inst/mem_out.wrdata {-radix hexadecimal}} /tb_cpu/dut/mem_inst/mem_out
add wave -noupdate -divider -height 40 wb
add wave -noupdate -expand -group wb /tb_cpu/dut/wb_inst/stall
add wave -noupdate -expand -group wb /tb_cpu/dut/wb_inst/flush
add wave -noupdate -expand -group wb /tb_cpu/dut/wb_inst/op
add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/wb_inst/aluresult
add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/wb_inst/memresult
add wave -noupdate -expand -group wb -radix hexadecimal /tb_cpu/dut/wb_inst/pc_old_in
add wave -noupdate -expand -group wb -childformat {{/tb_cpu/dut/wb_inst/reg_write.reg -radix unsigned} {/tb_cpu/dut/wb_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/wb_inst/reg_write.reg {-radix unsigned} /tb_cpu/dut/wb_inst/reg_write.data {-radix hexadecimal}} /tb_cpu/dut/wb_inst/reg_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {988255000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 227
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
configure wave -timelineunits us
update
WaveRestoreZoom {987804685 ps} {992609888 ps}
