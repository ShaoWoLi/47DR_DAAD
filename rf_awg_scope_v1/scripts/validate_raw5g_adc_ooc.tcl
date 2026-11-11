# Run RFDC out-of-context synthesis for a previously generated raw ADC probe.
# Usage: vivado -mode batch -source scripts/validate_raw5g_adc_ooc.tcl -tclargs <probe.xpr>
if {[llength $argv] != 1} {
    error "Pass the raw ADC probe .xpr path"
}
set xpr [file normalize [lindex $argv 0]]
if {![file exists $xpr]} {error "Probe project not found: $xpr"}
open_project $xpr
set xci [get_files -quiet -all *system_usp_rf_data_converter_0_0.xci]
if {![llength $xci]} {error "No RFDC XCI found in probe project"}
create_ip_run $xci
set runs [get_runs -quiet -filter {NAME =~ *usp_rf_data_converter*}]
if {![llength $runs]} {error "Could not create RFDC synthesis run"}
foreach run $runs {
    if {[get_property IS_SYNTHESIS $run]} {
        launch_runs $run -jobs 4
        wait_on_run $run
        if {[get_property PROGRESS $run] ne "100%"} {
            error "RFDC OOC synthesis did not complete: $run ([get_property STATUS $run])"
        }
        set run_dir [get_property DIRECTORY $run]
        set report [file join [file dirname $xpr] effective_parameters.txt]
        set fp [open $report a]
        puts $fp "RFDC_OOC_SYNTHESIS=PASS"
        puts $fp "RFDC_OOC_RUN=$run"
        close $fp
    }
}
close_project
exit
