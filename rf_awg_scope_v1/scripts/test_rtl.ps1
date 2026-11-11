param([string]$VivadoBin = 'E:\AMDDesignTools\2025.2\Vivado\bin')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path $PSScriptRoot -Parent
$simulationPath=Join-Path $projectRoot 'sim\work'
New-Item -ItemType Directory -Force $simulationPath | Out-Null
Push-Location $simulationPath
try {
    & (Join-Path $VivadoBin 'xvlog.bat') --sv `
        ../../rtl/axis_register_slice.sv ../../rtl/axis_wide_gearbox.sv ../../rtl/awg_wave_bank.sv ../../rtl/awg_player.sv `
        ../../rtl/awg_control.sv ../../rtl/awg_subsystem.sv ../tb_awg.sv
    if($LASTEXITCODE -ne 0){throw 'RTL compile failed'}
    & (Join-Path $VivadoBin 'xelab.bat') tb_awg -s tb_awg_sim
    if($LASTEXITCODE -ne 0){throw 'RTL elaboration failed'}
    & (Join-Path $VivadoBin 'xsim.bat') tb_awg_sim -runall -log simulation.log
    if($LASTEXITCODE -ne 0){throw 'RTL simulation failed'}
    $simulationLog=Get-Content simulation.log -Raw
    if($simulationLog -notmatch 'PASS: AXI' -or $simulationLog -match 'Fatal:|Error:'){throw 'Simulation did not pass'}
    & (Join-Path $VivadoBin 'xvlog.bat') --sv ../../rtl/adc_capture.sv ../tb_adc_capture.sv
    if($LASTEXITCODE -ne 0){throw 'ADC capture RTL compile failed'}
    & (Join-Path $VivadoBin 'xelab.bat') tb_adc_capture -s tb_adc_capture_sim
    if($LASTEXITCODE -ne 0){throw 'ADC capture RTL elaboration failed'}
    & (Join-Path $VivadoBin 'xsim.bat') tb_adc_capture_sim -runall -log adc_capture_simulation.log
    if($LASTEXITCODE -ne 0){throw 'ADC capture RTL simulation failed'}
    $captureLog=Get-Content adc_capture_simulation.log -Raw
    if($captureLog -notmatch 'PASS: ADC four-beat packing' -or $captureLog -match 'Fatal:|Error:'){throw 'ADC capture simulation did not pass'}
    & (Join-Path $VivadoBin 'xvlog.bat') --sv ../../rtl/adc_capture.sv ../tb_adc_capture_full.sv
    if($LASTEXITCODE -ne 0){throw 'Full-depth ADC compile failed'}
    & (Join-Path $VivadoBin 'xelab.bat') tb_adc_capture_full -s tb_adc_capture_full_sim
    if($LASTEXITCODE -ne 0){throw 'Full-depth ADC elaboration failed'}
    & (Join-Path $VivadoBin 'xsim.bat') tb_adc_capture_full_sim -runall -log adc_capture_full_simulation.log
    if($LASTEXITCODE -ne 0){throw 'Full-depth ADC simulation failed'}
    $fullLog=Get-Content adc_capture_full_simulation.log -Raw
    if($fullLog -notmatch 'PASS: production ADC 65520' -or $fullLog -match 'Fatal:|Error:'){throw 'Full-depth ADC simulation did not pass'}
} finally { Pop-Location }
