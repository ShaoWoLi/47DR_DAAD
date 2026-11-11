# adc_capture.capture_fifo is a dual-clock FIFO with Gray pointers. A RAM
# entry cannot be consumed until wr_gray crosses two ram_clk synchronizers
# and empty_reg deasserts. It cannot be overwritten until rd_gray crosses
# the two writer synchronizers. Thus a write-to-read storage path is NOT
# a one-adc_clk-cycle synchronous transfer (even with related clocks).
# Bound its physical settling time to one 9.6 ns reader period. The
# rd_bin-to-memory-read-to-BRAM path remains timed at the reader period.
# No clock groups or broad false paths are introduced here.
set cap_fifo_storage [get_pins -hier -filter {NAME =~ adc_capture_i/capture_fifo/mem_reg*/CLK && REF_PIN_NAME == CLK}]
set cap_ram_data [get_pins -hier -filter {NAME =~ adc_capture_i/channel_memory*.mem_reg*/DIN*}]
set cap_fifo_wr_clock [get_clocks -of_objects $cap_fifo_storage]
set cap_ram_wr_clock [get_clocks -quiet adc_capture_ram_clk]
if {[llength $cap_fifo_storage] == 0 || [llength $cap_ram_data] == 0 || \
    [llength $cap_fifo_wr_clock] != 1 || [llength $cap_ram_wr_clock] != 1} {
    error "ADC capture FIFO CDC storage endpoints were not found"
}
if {abs([get_property PERIOD $cap_fifo_wr_clock] - 2.400) > 0.001 || \
    abs([get_property PERIOD $cap_ram_wr_clock] - 9.600) > 0.001} {
    error "Review ADC FIFO CDC bounds for the changed ADC/RAM clock periods"
}
# Cover every RAMD32 subprimitive (A/B/... LUT outputs). Retain a physical
# delay bound instead of dropping this FIFO data path from delay analysis.
set_max_delay -reset_path -datapath_only 9.600 -from $cap_fifo_storage -to $cap_ram_data

# Keep Gray-bus inter-bit skew within the faster source pointer period.
# Constrain only the first synchronizer stage; the second stage retains
# normal destination-clock setup/hold analysis.
foreach {cap_ptr cap_bound} {wr 2.400 rd 9.600} {
    set cap_sync [get_pins -hier -filter "NAME =~ adc_capture_i/capture_fifo/${cap_ptr}_gray_sync1_reg*/D"]
    # Synthesis may merge the binary and Gray MSB registers (they are equal).
    set cap_gray [all_fanin -flat -startpoints_only -to $cap_sync]
    if {[llength $cap_gray] != 4 || [llength $cap_sync] != 4} {
        error "ADC capture FIFO $cap_ptr Gray pointer endpoints changed"
    }
    set_max_delay -datapath_only $cap_bound -from $cap_gray -to $cap_sync
    set_bus_skew $cap_bound -from $cap_gray -to $cap_sync
}
