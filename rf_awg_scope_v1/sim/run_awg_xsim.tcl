set root [file normalize [file join [file dirname [info script]] ..]]
cd $root
xvlog -sv rtl/awg_wave_bank.sv rtl/awg_player.sv rtl/awg_control.sv rtl/awg_subsystem.sv sim/tb_awg.sv
xelab tb_awg -s tb_awg_snapshot
xsim tb_awg_snapshot -runall
exit
