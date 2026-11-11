# Test-only backend: hardware APIs are all mocked before the production loop.
set ::AWG_GUI_TEST 1
set root [file normalize [file join [file dirname [info script]] ..]]
source [file join $root scripts awg_gui_bridge.tcl]
set f [open [file join $root sim test_hw_mock.tcl] r]
set fixture [read $f]; close $f
# Reuse only the mock API definitions, not the old test execution or exit.
set end [string first "\nawg::attach\n" $fixture]
if {$end<0} {error "Cannot find hardware mock fixture boundary"}
eval [string range $fixture 0 $end]
rename get_property mock_tx_property
proc get_property {property object} {
    if {$property eq "PART"} {return xczu47dr}
    return [mock_tx_property $property $object]
}
proc open_hw_manager {} {}
proc connect_hw_server {args} {}
proc get_hw_targets {args} {return mock_target}
proc open_hw_target {args} {}
proc get_hw_devices {args} {return mock_device}
proc current_hw_device {args} {return mock_device}
proc refresh_hw_device {args} {}
proc awg_gui::associate_ltx {device ltx} {}
proc close_hw_target {} {}
proc disconnect_hw_server {} {}
proc close_hw_manager {} {}
proc write_hw_ila_data {args} {
    set path [lindex $args end-1]
    file copy -force [file join $::root sim demo capture.csv] $path
}
rename awg_gui::dispatch awg_gui::real_dispatch
proc awg_gui::dispatch {request} {
    set result [real_dispatch $request]
    if {[dict exists $result capture]} {
        set path [file rootname [dict get $result capture]].json
        set f [open $path r]; set text [read $f]; close $f
        set text [string map [list {"format":"47dr-raw-adc-v1"} {"format":"47dr-raw-adc-v1","synthetic":true}] $text]
        set f [open $path w]; puts $f $text; close $f
    }
    return $result
}
awg_gui::main [file normalize [lindex $argv 0]]
exit
