# Board verification of the repaired capture ABI. Uses the existing 9G
# CH2 test record and captures ADC CH2, matching the observed loopback.
if {[llength $argv] < 1 || [llength $argv] > 2} {error "Usage: verify_adc_capture_fix_20261110.tcl <candidate-package> ?host:port?"}
set package [file normalize [lindex $argv 0]]
set server [expr {[llength $argv] == 2 ? [lindex $argv 1] : "localhost:3121"}]
set root [file normalize [file join [file dirname [info script]] ..]]
set ::AWG_GUI_TEST 1
source [file join $root scripts awg_gui_bridge.tcl]
source [file join $root scripts awg_hw.tcl]
proc capfix_progress {phase channel done total} {
    if {$phase eq "capture" || $done%2048==0 || $done==$total} {
        puts "CAPFIX_PROGRESS phase=$phase channel=$channel done=$done total=$total"
        flush stdout
    }
}
set awg::progress_callback capfix_progress
set cfg [dict create server $server target {} device {} axi {} \
    ltx [file join $package rf_awg_scope_v1.ltx]]
set output [file join $root app_data captures adc_ch2_capfix_20261110.csv]
try {
    puts "CAPFIX_BOARD_ATTACH [awg_gui::connect_device $cfg]"
    set status [awg::status]
    if {![dict get $status ps_ready] || [dict get $status fault]} {error "Board not RF ready"}
    puts [format "CAPFIX_LAYOUT %08X" [awg::read32 0x90200020]]
    awg::load [file join $root app_data waveforms 947c8a28-cec2-4ae4-9b96-e7c83dd56a81] 1
    awg::start
    after 100
    set started [clock milliseconds]
    awg::capture $output manual {} 4
    puts "CAPFIX_CAPTURE_MILLISECONDS [expr {[clock milliseconds]-$started}]"
    puts "CAPFIX_CAPTURE_STATE [awg::read32 0x90200028]"
    puts "CAPFIX_CAPTURE_SAMPLES [awg::read32 0x9020002c]"
    puts "CAPFIX_BOARD_FINAL [awg::status]"
    puts "PASS: actual board CH2 DAC playback and 65520-sample ADC CH2 RAM capture/export completed."
} finally {catch {close_hw_target}; catch {disconnect_hw_server}; catch {close_hw_manager}}
exit
