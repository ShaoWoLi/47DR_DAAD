set project_root [file normalize [file join [file dirname [info script]] ..]]
set candidate_xsa [file join $project_root hardware dac9g_opt1 rf_awg_scope_v1.xsa]
if {[llength $argv] < 1 || [llength $argv] > 2} {
    error "Usage: xsct build_9g_candidate.tcl <build-root> ?candidate-xsa?"
}
set build_root [file normalize [lindex $argv 0]]
if {[llength $argv] == 2} {
    set candidate_xsa [file normalize [lindex $argv 1]]
}
set platform_dir [file join $build_root platform]

if {![file exists $candidate_xsa]} {
    error "Missing 9 GS/s candidate XSA: $candidate_xsa"
}
if {[file exists $platform_dir]} {
    error "Build output already exists; preserve it and choose a fresh build directory: $platform_dir"
}
file mkdir $build_root
platform create -name dac9g_opt1_platform -hw $candidate_xsa \
    -proc psu_cortexa53_0 -os standalone -arch 64-bit -out $platform_dir
domain active standalone_domain
bsp setlib -name libmetal
platform generate
puts "Generated standalone BSP from candidate XSA: $platform_dir"
