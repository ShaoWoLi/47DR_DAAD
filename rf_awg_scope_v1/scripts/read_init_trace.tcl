# Read the running initializer transcript through PS JTAG without taking UART.
# Arguments: server log-address length-address stage-address output-file
if {[llength $argv] != 5} {
    error "Usage: read_init_trace.tcl <host:3121> <log-address> <length-address> <stage-address> <output-file>"
}
lassign $argv server logaddr lengthaddr stageaddr logfile
if {![string match -nocase "tcp:*" $server]} {set server "tcp:$server"}
connect -url $server
targets -set -filter {name =~ "Cortex-A53 #0"}
stop
try {
    puts "INIT_STAGE_FULL=[mrd -force -value $stageaddr]"
    puts "CONFIG_DONE=[mrd -force -value 0x8001001c]"
    puts "A53_PC=[rrd pc]"
    set length [mrd -force -value $lengthaddr]
    puts "LOG_BYTES=$length"
    if {$length > 0 && $length < 65536} {
        mrd -force -bin -file $logfile $logaddr [expr {($length+3)/4}]
    }
} finally {con}
disconnect
exit
