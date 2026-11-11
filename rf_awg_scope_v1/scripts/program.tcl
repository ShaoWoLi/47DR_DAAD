# Run explicitly in XSCT. Optional: -server <host:3121> for remote hardware.
# xsct scripts/program.tcl -server localhost:3121
# Initialize PS/LMK first, program PL with stable clocks, then initialize RFDC.
set root [file normalize [file join [file dirname [info script]] ..]]
set server ""
set package [file join $root hardware dac9g_opt1]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-server"} {
        incr i
        if {$i >= [llength $argv]} {error "-server requires host:port"}
        set server [string trim [lindex $argv $i]]
    } elseif {$arg eq "-package"} {
        incr i
        if {$i >= [llength $argv]} {error "-package requires a candidate directory"}
        set package [file normalize [lindex $argv $i]]
    } else {error "Unknown program.tcl option: $arg"}
}
set bit [file join $package rf_awg_scope_v1.bit]
set elf [file join $package rf_awg_init.elf]
set init [file join $package psu_init.tcl]
set protocol_file [file join $package init_protocol.txt]
foreach path [list $bit $elf $init $protocol_file] {if {![file exists $path]} {error "Missing build output: $path"}}
set fp [open $protocol_file r]
try {set protocol_text [read $fp]} finally {close $fp}
set protocol [dict create]
foreach line [split $protocol_text \n] {
    set line [string trim $line]
    if {$line eq ""} continue
    if {![regexp {^([a-z_]+) (0x[0-9a-fA-F]+|[0-9]+)$} $line -> key value]} {
        error "Invalid initialization protocol metadata"
    }
    dict set protocol $key $value
}
foreach key {protocol_version awg_clock_ready awg_pl_program_ack} {
    if {![dict exists $protocol $key]} {error "Missing initialization protocol field: $key"}
}
if {[dict get $protocol protocol_version] != 1} {error "Unsupported initialization protocol"}
if {$server eq ""} {
    connect
} else {
    if {![string match -nocase "tcp:*" $server]} {set server "tcp:$server"}
    connect -url $server
}
set devices [targets -filter {name =~ "PSU"}]
if {[llength $devices]==0} {error "No Zynq UltraScale+ PSU found"}
targets -set -filter {name =~ "PSU"}
rst -system
after 1000
source $init
psu_init
targets -set -filter {name =~ "Cortex-A53 #0"}
rst -processor
dow $elf
# A system reset does not clear DDR. Clear the previous run's flags while
# A53 is stopped, before polling a freshly started initializer.
set ready_addr [dict get $protocol awg_clock_ready]
set ack_addr [dict get $protocol awg_pl_program_ack]
mwr -force $ready_addr 0
mwr -force $ack_addr 0
if {[mrd -force -value $ready_addr] != 0 || [mrd -force -value $ack_addr] != 0} {
    error "Could not clear stale initialization handshake flags"
}
con
set deadline [expr {[clock milliseconds]+45000}]
while {1} {
    set ready [mrd -force -value $ready_addr]
    if {$ready == 0x434c4b31} break
    if {[clock milliseconds] > $deadline} {
        catch {stop}
        error "PS clock preparation timed out; PL was not programmed. Check PS UART/init trace."
    }
    after 100
}
stop
puts "LMK clocks are stable; programming the matching PL before RFDC initialization."
fpga -file $bit
psu_ps_pl_isolation_removal
psu_ps_pl_reset_config
if {[llength [info procs psu_post_config]]} {psu_post_config}
targets -set -filter {name =~ "Cortex-A53 #0"}
mwr -force $ack_addr 0x504c4f4b
if {[mrd -force -value $ack_addr] != 0x504c4f4b} {
    error "PL programming acknowledgement read-back failed"
}
con
puts "RF initializer is running. Wait for AWG READY on PS UART before JTAG wave commands."
