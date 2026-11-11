# Persistent, single-owner Vivado hardware session for the MATLAB application.
# Requests are data (UTF-8 hex fields), never evaluated as Tcl source.
namespace eval awg_gui { variable quit 0 }
proc awg_gui::read_fields {path} {
    set f [open $path r]; try {set lines [split [read $f] \n]} finally {close $f}
    set result [dict create]
    foreach line $lines {
        if {[string trim $line] eq ""} continue
        if {![regexp {^([a-z_]+) ([0-9a-fA-F]*)$} [string trimright $line \r] -> key value]} {
            error "Malformed bridge field"
        }
        if {[string length $value]%2} {error "Malformed UTF-8 hex value"}
        dict set result $key [encoding convertfrom utf-8 [binary format H* $value]]
    }
    return $result
}
proc awg_gui::write_fields {path fields} {
    set f [open ${path}.tmp w]
    try {
        dict for {key value} $fields {
            puts $f "$key [binary encode hex [encoding convertto utf-8 $value]]"
        }
    } finally {close $f}
    file rename -force ${path}.tmp $path
}
proc awg_gui::choose {objects requested label} {
    if {$requested ne ""} {
        if {[lsearch -exact $objects $requested]<0} {error "$label not found: $requested; available: $objects"}
        return $requested
    }
    if {[llength $objects]!=1} {error "Choose exactly one $label in connection settings; available: $objects"}
    return [lindex $objects 0]
}
proc awg_gui::associate_ltx {device ltx} {set_property PROBES.FILE $ltx $device}
proc awg_gui::connect_device {cfg} {
    open_hw_manager
    connect_hw_server -url [dict get $cfg server]
    set target [choose [get_hw_targets -quiet] [dict get $cfg target] "JTAG target"]
    open_hw_target $target
    set devices {}
    foreach d [get_hw_devices -quiet] {
        if {[string match -nocase *zu47dr* [get_property PART $d]]} {lappend devices $d}
    }
    set dev [choose $devices [dict get $cfg device] "47DR device"]
    current_hw_device $dev
    set ltx [dict get $cfg ltx]
    if {![file exists $ltx]} {error "Missing matching LTX: $ltx"}
    associate_ltx $dev $ltx
    refresh_hw_device $dev
    awg::attach [dict get $cfg axi]
    return [dict merge [awg::status] [dict create device $dev target $target]]
}
proc awg_gui::dispatch {request} {
    variable quit
    set action [dict get $request action]
    switch -- $action {
        status {return [awg::status]}
        start {return [awg::start]}
        stop {return [awg::stop]}
        clear {return [awg::clear]}
        load {return [awg::load [dict get $request directory] 1]}
        capture {
            set path [awg::capture [dict get $request capture] [dict get $request trigger] {} [dict get $request mask]]
            return [dict merge [awg::status] [dict create capture $path]]
        }
        run {
            awg::load [dict get $request directory] 1
            if {[dict get $request trigger] eq "manual"} {awg::start; after 100}
            set path [awg::capture [dict get $request capture] [dict get $request trigger] {} [dict get $request mask]]
            return [dict merge [awg::status] [dict create capture $path]]
        }
        disconnect {set quit 1; return [dict create disconnected 1]}
        default {error "Unsupported application action: $action"}
    }
}
proc awg_gui::progress {session phase channel done total} {
    write_fields [file join $session progress.txt] [dict create phase $phase channel $channel done $done total $total]
}
proc awg_gui::main {session} {
    variable quit
    set root [file normalize [file join [file dirname [info script]] ..]]
    # info script inside a proc is inherited from this top-level script.
    source [file join $root scripts awg_hw.tcl]
    set awg::progress_callback [list awg_gui::progress $session]
    if {[catch {set cfg [read_fields [file join $session config.txt]]; set result [connect_device $cfg]} msg opts]} {
        write_fields [file join $session hello.res] [dict create ok 0 message $msg]
        puts stderr [dict get $opts -errorinfo]
        return
    }
    write_fields [file join $session hello.res] [dict merge [dict create ok 1 message "JTAG connected"] $result]
    while {!$quit} {
        foreach path [lsort [glob -nocomplain -directory $session *.req]] {
            set response [file rootname $path].res
            if {[catch {set request [read_fields $path]; set result [dispatch $request]} msg opts]} {
                set result [dict create ok 0 message $msg]
                # An operation may have changed playback before failing. Always
                # try to return the latest hardware state; MATLAB invalidates upload.
                catch {set result [dict merge $result [awg::status]]}
                puts stderr [dict get $opts -errorinfo]
            } else {set result [dict merge [dict create ok 1 message "Completed"] $result]}
            write_fields $response $result
            file delete $path
            if {$quit} break
        }
        after 100
        # MATLAB sends a heartbeat even during long transfers. Abandoned idle
        # sessions release JTAG. Existing DAC playback is unaffected.
        set hb [file join $session heartbeat]
        if {[file exists $hb] && [clock seconds]-[file mtime $hb]>120} {set quit 1}
    }
    catch {close_hw_target}
    catch {disconnect_hw_server}
    catch {close_hw_manager}
}
if {![info exists ::AWG_GUI_TEST]} {
    if {[llength $argv]!=1} {error "Expected a MATLAB session directory"}
    awg_gui::main [file normalize [lindex $argv 0]]
    exit
}
