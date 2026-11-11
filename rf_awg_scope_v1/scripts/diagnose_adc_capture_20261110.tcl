# Read-only inspection of the already programmed board; never resets,
# arms, stops, starts, or reprograms hardware.
set root [file normalize [file join [file dirname [info script]] ..]]
source [file join $root scripts awg_hw.tcl]
if {[llength $argv] > 1} {error "Usage: diagnose_adc_capture_20261110.tcl ?host:port?"}
set server [expr {[llength $argv] ? [lindex $argv 0] : "localhost:3121"}]
open_hw_manager
try {
    connect_hw_server -url $server
    set targets [get_hw_targets -quiet]
    if {[llength $targets]!=1} {error "Expected exactly one target"}
    open_hw_target [lindex $targets 0]
    set devices {}
    foreach dev [get_hw_devices -quiet] {
        if {[string match -nocase *zu47dr* [get_property PART $dev]]} {lappend devices $dev}
    }
    if {[llength $devices]!=1} {error "Expected exactly one 47DR"}
    current_hw_device [lindex $devices 0]
    set_property PROBES.FILE [file join $root hardware dac9g_opt1 rf_awg_scope_v1.ltx] [lindex $devices 0]
    refresh_hw_device [lindex $devices 0]
    set axes [get_hw_axis -quiet]
    if {[llength $axes]!=1} {error "Expected exactly one JTAG AXI master"}
    set awg::axi [lindex $axes 0]
    puts "ADC_DIAG_STATUS [awg::status]"
    puts "ADC_DIAG_STATE [awg::read32 0x90200028]"
    puts "ADC_DIAG_SAMPLES [awg::read32 0x9020002c]"
    foreach ch {0 2} {
        foreach word {0 1 22 23 24 25 46 47 48 49 70 71 72 73 94 95 96 97} {
            set addr [expr {0x91000000+$ch*0x20000+$word*4}]
            puts [format "ADC_DIAG_RAM ch=%d word=%d data=%08X" $ch $word [awg::read32 $addr]]
        }
    }
} finally {catch {close_hw_target}; catch {disconnect_hw_server}; catch {close_hw_manager}}
exit
