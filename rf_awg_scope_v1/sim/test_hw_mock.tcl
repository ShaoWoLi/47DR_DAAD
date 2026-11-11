# Exercise the host Tcl flow without a board. Mock only Vivado hardware APIs.
set root [file normalize [file join [file dirname [info script]] ..]]
source [file join $root scripts awg_hw.tcl]
# Use canonical integer keys, including addresses > 0x7fffffff.
set memory [dict create [expr {0x90200000}] [expr {0x41574731}] \
    [expr {0x90200004}] 4 [expr {0x9020000c}] 1 [expr {0x90200010}] 0 \
    [expr {0x90200014}] 9000000 [expr {0x90200018}] 0 [expr {0x9020001c}] 0 \
    [expr {0x90200020}] [expr {0x00020001}]]
set transactions [dict create]
set transfer_count 0
set fail_address -1
set properties [dict create]
set armed 0
set capture_poll_states {1 1 2}
set capture_poll_count 0
set last_progress {}
proc capture_progress {phase channel done total} {
    set ::last_progress [list $phase $channel $done $total]
}
proc get_hw_axis {args} {return mock_axi}
proc reset_hw_axi {args} {}
proc create_hw_axi_txn {name axi args} {
    if {$axi ne "mock_axi"} {error "Wrong AXI"}
    dict set ::transactions $name $args
    return $name
}
proc run_hw_axi {tx} {
    set args [dict get $::transactions $tx]
    set address [expr 0x[dict get $args -address]]
    incr ::transfer_count
    if {[dict get $args -type] eq "write"} {
        set value [expr 0x[dict get $args -data]]
        if {$address==0x90200008} {
            set status [dict get $::memory [expr {0x90200004}]]
            if {$value==1} {set status 4}
            if {$value==2} {set status 5}
            if {$value==8} {
                dict set ::memory [expr {0x90200028}] 2
                dict set ::memory [expr {0x9020002c}] 48
                set ::capture_pending_states $::capture_poll_states
                set ::capture_poll_count 0
            }
            dict set ::memory [expr {0x90200004}] $status
        } else {dict set ::memory $address $value}
    } else {
        if {$address>=0x91000000 && $address<0x91100000} {
            set offset [expr {$address-0x91000000}]
            set channel [expr {$offset/0x20000}]
            set word [expr {($offset%0x20000)/4}]
            set sample [expr {($word/24)*48+($word%24)*2}]
            set lo [expr {($channel*100+$sample-24)&0xffff}]
            set hi [expr {($channel*100+$sample-23)&0xffff}]
            set value [expr {$lo|($hi<<16)}]
        } elseif {$address==0x90200028 && [info exists ::capture_pending_states] && [llength $::capture_pending_states]} {
            set value [lindex $::capture_pending_states 0]
            set ::capture_pending_states [lrange $::capture_pending_states 1 end]
            incr ::capture_poll_count
        } else {
            set value [expr {[dict exists $::memory $address] ? [dict get $::memory $address] : 0}]
        }
        if {$address==$::fail_address} {set value [expr {$value^1}]}
        dict set ::transactions $tx DATA [format %08X $value]
    }
}
proc get_property {property object} {return [dict get $::transactions $object $property]}
proc delete_hw_axi_txn {tx} {dict unset ::transactions $tx}
set wave_dir [file join [file dirname [info script]] mock_waveform]
file mkdir $wave_dir
set fp [open [file join $wave_dir waveform.meta] w]
puts $fp "samples 96\nfs_hz 9000000000\nnco_hz 0\nchannel_mask 1\nsample_format 1"; close $fp
for {set ch 0} {$ch<8} {incr ch} {
    set fp [open [file join $wave_dir ch${ch}.hex] w]
    for {set n 0} {$n<48} {incr n} {puts $fp [format %08X [expr {$ch*256+$n}]]}
    close $fp
}
awg::attach
awg::load $wave_dir
if {[dict get [awg::status] channel_mask]!=1 || [dict get [awg::status] length_beats]!=3} {error "96 samples must configure three 512-bit RAM words"}
set fp [open [file join $wave_dir ch0.hex] r]
set words [split [string trim [read $fp]] \n]; close $fp
for {set n 0} {$n<48} {incr n} {
    if {[dict get $memory [expr {0x90000000+4*$n}]] != [expr 0x[lindex $words $n]]} {error "Word address/order mismatch"}
}
# A half-RAM-word record must fail before even stopping an existing stream.
set transfers_before $transfer_count
foreach invalid_samples {16 48} {
    set fp [open [file join $wave_dir waveform.meta] w]
    puts $fp "samples $invalid_samples\nfs_hz 9000000000\nnco_hz 0\nchannel_mask 1\nsample_format 1"; close $fp
    if {![catch {awg::load $wave_dir} message] || ![string match *divisible*32* $message]} {
        error "A non-32-aligned sample count was accepted: $invalid_samples"
    }
    if {$transfer_count != $transfers_before} {error "An invalid length reached hardware"}
}
set fp [open [file join $wave_dir waveform.meta] w]
puts $fp "samples 96\nfs_hz 9000000000\nnco_hz 0\nchannel_mask 1\nsample_format 1"; close $fp
awg::start
if {![dict get [awg::status] running]} {error "START failed"}
dict set memory [expr {0x90200020}] [expr {0x00020000}]
if {![catch {awg::capture [file join $root sim should_not_exist.csv] start {} 1} message] || ![string match *updated*FPGA* $message]} {
    error "Legacy ADC address layout was not rejected"
}
if {![dict get [awg::status] running]} {error "Rejecting an incompatible capture changed DAC playback"}
dict set memory [expr {0x90200020}] [expr {0x00020001}]
set capture_path [file join $root sim mock_capture.csv]
awg::capture $capture_path manual {} 1
if {$capture_poll_count!=3} {error "Capture did not wait for BUSY bit 0 to clear and DONE bit 1 to assert"}
set fp [open $capture_path r]; set first_line [gets $fp]; set last_line ""
while {[gets $fp line]>=0} {set last_line $line}; close $fp
if {$first_line ne "-24" || $last_line ne "23"} {error "ADC samples were not unpacked in chronological signed order"}
set fp [open [file rootname $capture_path].json r]; set metadata [read $fp]; close $fp
if {[string first {"format":"47dr-raw-adc-v1"} $metadata]<0} {error "Raw ADC metadata format missing"}
set awg::progress_callback capture_progress
set capture_path [file join $root sim mock_ch4.csv]
awg::capture $capture_path manual {} 16
if {[lindex $last_progress 0] ne "capture" || [lindex $last_progress 1] ne "CH4"} {
    error "ADC mask 16 must report CH4 capture progress, got $last_progress"
}
set fp [open $capture_path r]; set first_line [gets $fp]; close $fp
if {$first_line ne "376"} {error "ADC mask 16 did not export CH4 samples: $first_line"}
set fp [open [file rootname $capture_path].json r]; set metadata [read $fp]; close $fp
if {[string first {"channel_mask":16} $metadata]<0} {error "CH4 capture mask was not retained in metadata"}
set awg::progress_callback ""
set capture_path [file join $root sim mock_start.csv]
set capture_poll_states {2}
awg::capture $capture_path start {} 1
if {$capture_poll_count!=1} {error "A capture completed before the first JTAG poll was not accepted"}
# Inconsistent transitional flags must not be treated as a finished capture.
set capture_pending_states {0 1 3 2}
set capture_poll_count 0
awg::wait_capture_done 1000
if {$capture_poll_count!=4} {error "Idle/BUSY/transitional status accepted as DONE"}
foreach stuck {0 1 3} {
    dict set memory [expr {0x90200028}] $stuck
    set capture_pending_states {}
    if {![catch {awg::wait_capture_done 0} message] || ![string match *captured_samples=48* $message]} {
        error "Stalled capture was not diagnosed: state=$stuck"
    }
}
set fail_address [expr {0x90000008}]
if {![catch {awg::load $wave_dir} message] || ![string match *Readback*mismatch* $message]} {error "Readback failure was not detected"}
if {[dict get [awg::status] channel_mask]!=0 || [dict get [awg::status] running]} {error "Failed load remained startable"}
if {[dict size $transactions]!=0} {error "Leaked hardware transactions"}
puts "PASS: Mock JTAG transfer/addressing, load/readback, commands, trigger switching, capture export and failed-load interlock ($transfer_count transfers)."
exit
