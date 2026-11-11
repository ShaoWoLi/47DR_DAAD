# Source in an already connected Vivado Hardware Manager Tcl console.
# This file never programs a device or changes RF clocks.
namespace eval awg {
    variable axi ""
    variable regs 0x90200000
    variable ram 0x90000000
    variable transaction 0
    variable progress_callback ""
}
proc awg::progress {phase channel done total} {
    variable progress_callback
    if {$progress_callback ne ""} {catch {{*}$progress_callback $phase $channel $done $total}}
}
proc awg::attach {{axi_name ""}} {
    variable axi
    if {$axi_name eq ""} {
        set candidates [get_hw_axis -quiet]
        if {[llength $candidates]!=1} {error "Specify the AWG JTAG AXI name; candidates: $candidates"}
        set axi [lindex $candidates 0]
    } else {
        set axi [get_hw_axis $axi_name]
        if {[llength $axi]!=1} {error "Expected one JTAG AXI master"}
    }
    reset_hw_axi $axi
    variable regs
    if {[read32 $regs] != 0x41574731} {error "AWG1 identification mismatch: wrong bitstream or AXI master"}
    puts "Attached AWG1: $axi"
    return [status]
}
proc awg::transfer {kind address {value 0}} {
    variable axi
    variable transaction
    if {$axi eq ""} {error "Run awg::attach first"}
    set name awg_tx_[incr transaction]
    set args [list $name $axi -type $kind -address [format %08X $address] -len 1]
    if {$kind eq "write"} {lappend args -data [format %08X [expr {$value & 0xffffffff}]]}
    set tx [create_hw_axi_txn {*}$args]
    try {
        run_hw_axi $tx
        if {$kind eq "read"} {
            set data [string map {" " "" "_" "" "0x" ""} [get_property DATA $tx]]
            if {![regexp {^[0-9a-fA-F]{1,8}$} $data]} {error "Unexpected JTAG read data: $data"}
            return [expr 0x$data]
        }
    } finally {delete_hw_axi_txn $tx}
}
proc awg::read32 {address} {return [transfer read $address]}
proc awg::write32 {address value} {transfer write $address $value}
proc awg::status {} {
    variable regs
    set s [read32 [expr {$regs+4}]]
    # The JTAG AXI master cannot reach the PS-only UP_AXI address window.
    # Do not report a fabricated zero as an initialization stage.
    set init_stage unavailable
    set result [dict create running [expr {$s&1}] busy [expr {($s>>1)&1}] \
        ps_ready [expr {($s>>2)&1}] fault [expr {($s>>3)&1}] command_result [expr {($s>>4)&3}] \
        init_stage $init_stage \
        fault_channels [read32 [expr {$regs+28}]] length_beats [read32 [expr {$regs+12}]] \
        channel_mask [read32 [expr {$regs+16}]]]
    return $result
}
proc awg::command {value {timeout_ms 5000}} {
    variable regs
    set before [read32 [expr {$regs+4}]]
    if {$before&2} {error "Previous command is still busy"}
    if {!($before&4)} {error "PS not ready: run the matching RF initialization ELF first"}
    write32 [expr {$regs+8}] $value
    set deadline [expr {[clock milliseconds]+$timeout_ms}]
    while {1} {
        set s [read32 [expr {$regs+4}]]
        if {!($s&2)} {
            if {($s>>4)&3} {error "RF command failed: [status]"}
            return
        }
        if {[clock milliseconds]>$deadline} {error "RF command timed out: [status]"}
        after 5
    }
}
proc awg::stop {} {command 1; return [status]}
proc awg::clear {} {command 4; return [status]}
proc awg::start {} {command 2; return [status]}
proc awg::load {directory {verify 1}} {
    variable regs
    variable ram
    set directory [file normalize $directory]
    set fp [open [file join $directory waveform.meta] r]
    try {set text [read $fp]} finally {close $fp}
    set meta [dict create]
    foreach line [split $text \n] {
        if {[string trim $line] eq ""} continue
        if {![regexp {^([a-z_]+) ([0-9]+)$} [string trim $line] -> key value]} {error "Invalid waveform.meta line"}
        dict set meta $key $value
    }
    foreach key {samples fs_hz nco_hz channel_mask sample_format} {
        if {![dict exists $meta $key]} {error "Missing metadata: $key"}
    }
    set n [dict get $meta samples]
    set mask [dict get $meta channel_mask]
    if {$n<32 || $n>65536 || $n%32 || $mask<1 || $mask>255 ||
        [dict get $meta sample_format] != 1 || [dict get $meta nco_hz] != 0} {
        error "Invalid No-DUC real-sample count (32..65536, divisible by 32), format or channel mask"
    }
    if {[dict get $meta fs_hz] != 9000000000 || [dict get $meta fs_hz] != [read32 [expr {$regs+20}]]*1000 ||
        [dict get $meta nco_hz] != [read32 [expr {$regs+24}]]} {error "Waveform Fs/NCO does not match this V1 build"}
    # Validate all input files before the first hardware mutation.
    set waves [dict create]
    for {set ch 0} {$ch<8} {incr ch} {
        if {!($mask & (1<<$ch))} continue
        set fp [open [file join $directory ch${ch}.hex] r]
        try {set words [split [string trim [read $fp]] \n]} finally {close $fp}
        if {[llength $words]!=$n/2} {error "CH$ch has the wrong number of packed sample pairs"}
        set clean {}
        foreach word $words {
            set word [string trim $word]
            if {![regexp {^[0-9a-fA-F]{8}$} $word]} {error "Invalid packed pair of signed 16-bit samples in CH$ch"}
            lappend clean $word
        }
        dict set waves $ch $clean
    }
    stop
    clear
    # Disable START until every requested channel is loaded and checked.
    write32 [expr {$regs+16}] 0
    dict for {ch words} $waves {
        set base [expr {$ram + $ch*0x20000}]
        set nword 0
        foreach word $words {
            write32 [expr {$base+4*$nword}] [expr 0x$word]
            incr nword
            if {$nword%128==0 || $nword==$n/2} {progress write $ch [expr {$nword*2}] $n}
        }
        if {$verify} {
            set nword 0
            foreach word $words {
                set actual [read32 [expr {$base+4*$nword}]]
                if {$actual != [expr 0x$word]} {error "Readback mismatch CH$ch sample $nword"}
                incr nword
                if {$nword%128==0 || $nword==$n/2} {progress verify $ch [expr {$nword*2}] $n}
            }
        }
        puts "CH$ch: $n real samples loaded; readback verify=$verify"
    }
    # The published 9G player counts complete 512-bit RAM words (32 int16
    # samples), not 256-bit RFDC beats or the old 1024-bit RAM words.
    write32 [expr {$regs+12}] [expr {$n/32}]
    write32 [expr {$regs+16}] $mask
    puts "Loaded, stopped. Run awg::start to enable playback."
    return [status]
}
proc awg::wait_capture_done {{timeout_ms 10000}} {
    variable regs
    set deadline [expr {[clock milliseconds]+$timeout_ms}]
    while {1} {
        set state [read32 [expr {$regs+40}]]
        # awg_control exposes {done,busy}: bit 1 is DONE, bit 0 is BUSY.
        # A fast capture may finish before the first JTAG status read.
        if {($state&2) && !($state&1)} {return $state}
        if {[clock milliseconds]>=$deadline} {
            set samples [read32 [expr {$regs+44}]]
            error "ADC RAM capture timed out: state=$state (busy=[expr {$state&1}], done=[expr {($state>>1)&1}], captured_samples=$samples)"
        }
        after 10
    }
}
proc awg::capture {csv_path {trigger "manual"} {ila_name ""} {channel_mask 255}} {
    variable regs
    if {$trigger ni {manual start}} {error "Trigger must be manual or start"}
    if {$channel_mask<1 || $channel_mask>255} {error "Capture channel mask must be 1..255"}
    set layout [read32 [expr {$regs+32}]]
    if {$layout!=0x00020001} {
        error [format "ADC RAM layout 0x%08X requires the updated FPGA bitstream (0x00020001); initialize the board using the current hardware package." $layout]
    }
    if {$trigger eq "start"} {stop}
    command 8
    if {$trigger eq "start"} {after 10; start}
    wait_capture_done
    set samples [read32 [expr {$regs+44}]]
    if {$samples<1 || $samples>65520 || $samples%12} {error "Invalid ADC captured sample count: $samples"}
    set progress_channels {}
    for {set ch 0} {$ch<8} {incr ch} {
        if {$channel_mask & (1<<$ch)} {lappend progress_channels "CH$ch"}
    }
    set progress_channel [join $progress_channels ,]
    set csv_path [file normalize $csv_path]
    file mkdir [file dirname $csv_path]
    set fp [open $csv_path w]
    try {
        set first 1
        for {set sample 0} {$sample<$samples} {incr sample} {
            set row {}
            for {set ch 0} {$ch<8} {incr ch} {
                if {!($channel_mask & (1<<$ch))} continue
                if {$sample==0 || $sample%48==0} {
                    set entry [expr {$sample/48}]
                    set base [expr {0x91000000 + $ch*0x20000 + $entry*24*4}]
                    set entry_words {}
                    for {set w 0} {$w<24} {incr w} {lappend entry_words [read32 [expr {$base+4*$w}]]}
                    set cache($ch) $entry_words
                }
                set slot [expr {$sample%48}]
                set packed [lindex $cache($ch) [expr {$slot/2}]]
                set code [expr {($packed >> (16*($slot%2))) & 0xffff}]
                if {$code>=32768} {incr code -65536}
                lappend row $code
            }
            puts $fp [join $row ,]
            if {$sample%4096==0 || $sample==$samples-1} {progress capture $progress_channel $sample $samples}
        }
    } finally {close $fp}
    set fp [open [file rootname $csv_path].json w]
    try {
        puts $fp "{\"format\":\"47dr-raw-adc-v1\",\"fs_hz\":5000000000,\"channel_mask\":$channel_mask,\"samples\":$samples,\"sample_bits\":16,\"signed\":true,\"trigger\":\"$trigger\"}"
    } finally {close $fp}
    puts "Raw ADC capture exported: $csv_path ($samples samples/channel, mask=$channel_mask)"
    return $csv_path
}
