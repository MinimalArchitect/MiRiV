global usbblaster_name
global test_device
global instance_index

set instance_index 42

proc write_data { val } {
	global instance_index

	open_port
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $instance_index -ir_value 2 -no_captured_ir_value
	foreach {word} $val {
		set word [format %08s $word]
		device_virtual_dr_shift -dr_value $word -instance_index $instance_index -length 32 -no_captured_dr_value -value_in_hex
	}
	device_virtual_ir_shift -instance_index $instance_index -ir_value 0 -no_captured_ir_value
	close_port
}

proc read_data {} {
	global instance_index

	set val [format %032s 0]

	open_port
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $instance_index -ir_value 3 -no_captured_ir_value
	set l [device_virtual_dr_shift -dr_value $val -instance_index $instance_index -length 32]
	device_virtual_ir_shift -instance_index $instance_index -ir_value 0 -no_captured_ir_value
	close_port

	puts $l
}

proc set_address { adr } {
	global instance_index

	set adr [format %03s $adr]

	open_port
	device_lock -timeout 10000
	device_virtual_ir_shift -instance_index $instance_index -ir_value 1 -no_captured_ir_value
	device_virtual_dr_shift -dr_value $adr -instance_index $instance_index -length 12 -no_captured_dr_value -value_in_hex
	device_virtual_ir_shift -instance_index $instance_index -ir_value 0 -no_captured_ir_value
	close_port
}

proc open_port {} {
	global usbblaster_name
	global test_device
	open_device -hardware_name $usbblaster_name -device_name $test_device
}

proc close_port {} {
	catch {device_unlock}
	catch {close_device}
}

proc download_file { base fname } {
	set fp [open $fname r]
	set data [read $fp]
	close $fp

	set_address $base
	write_data $data
}

proc connect_jtag {} {
	global usbblaster_name
	global test_device

	foreach hardware_name [get_hardware_names] {
		if { [string match "USB-Blaster*" $hardware_name] } {
			set usbblaster_name $hardware_name
		}
	}

	foreach device_name [get_device_names -hardware_name $usbblaster_name] {
		if { [string match "@1*" $device_name] } {
			set test_device $device_name
		}
	}
	puts "Connected: $hardware_name \n $device_name"
}

proc write_ctrl { val } {
	set_address FFF
	write_data [list $val]
}

####################################################################

if { $argc != 2} {
	puts "requires arguments: dmem.mif imem.mif"
} else {
	connect_jtag
	write_ctrl 0
	download_file 000 [lindex $argv 0]
	download_file 400 [lindex $argv 1]
	write_ctrl 1
}
