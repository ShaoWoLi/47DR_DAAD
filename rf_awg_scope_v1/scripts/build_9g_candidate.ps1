param(
    [string]$VitisBin = 'E:\AMDDesignTools\2025.2\Vitis\bin',
    [string]$GnuBin = 'E:\AMDDesignTools\2025.2\Vitis\gnu\aarch64\nt\aarch64-none\bin',
    [string]$BuildTag = (Get-Date -Format 'yyyyMMdd_HHmmss'),
    [string]$BuildRoot = '',
    [string]$CandidateXsa = '',
    [string]$OutputElf = '',
    [string]$ExistingPlatform = ''
)
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path $PSScriptRoot -Parent
if ([string]::IsNullOrWhiteSpace($BuildRoot)) {
    $BuildRoot = Join-Path $projectRoot "build\dac9g_opt1_$BuildTag"
}
$buildRoot = [System.IO.Path]::GetFullPath($BuildRoot)
$platformDir = Join-Path $buildRoot 'platform'
$sourceRoot = Join-Path $projectRoot 'software\src'
$elfBuild = Join-Path $buildRoot 'rf_awg_init.elf'
$defaultXsa = Join-Path $projectRoot 'hardware\dac9g_opt1\rf_awg_scope_v1.xsa'
if ([string]::IsNullOrWhiteSpace($CandidateXsa)) { $CandidateXsa = $defaultXsa }
if ([string]::IsNullOrWhiteSpace($OutputElf)) {
    $OutputElf = Join-Path $projectRoot 'hardware\dac9g_opt1\rf_awg_init.elf'
}
$CandidateXsa = (Resolve-Path -LiteralPath $CandidateXsa).Path
$elfPackage = [System.IO.Path]::GetFullPath($OutputElf)
$xsct = Join-Path $VitisBin 'xsct.bat'
$compiler = Join-Path $GnuBin 'aarch64-none-elf-gcc.exe'
$readelf = Join-Path $GnuBin 'aarch64-none-elf-readelf.exe'
$size = Join-Path $GnuBin 'aarch64-none-elf-size.exe'

foreach ($path in @($xsct, $compiler, $readelf, $size)) {
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required tool not found: $path" }
}
if (Test-Path -LiteralPath $buildRoot) {
    throw "Build directory already exists; preserve it and choose a fresh build directory: $buildRoot"
}

if ([string]::IsNullOrWhiteSpace($ExistingPlatform)) {
    & $xsct (Join-Path $PSScriptRoot 'build_9g_candidate.tcl') $buildRoot $CandidateXsa
    if ($LASTEXITCODE -ne 0) { throw "XSCT candidate platform generation failed: exit $LASTEXITCODE" }
    $platformRoot = Join-Path $platformDir 'dac9g_opt1_platform'
} else {
    $platformRoot = (Resolve-Path -LiteralPath $ExistingPlatform).Path
    $platformXsa = Join-Path $platformRoot 'hw\rf_awg_scope_v1.xsa'
    if (!(Test-Path -LiteralPath $platformXsa) -or
        (Get-FileHash -LiteralPath $platformXsa).Hash -ne
        (Get-FileHash -LiteralPath $CandidateXsa).Hash) {
        throw 'Existing platform XSA does not match the candidate XSA; regenerate the BSP.'
    }
    New-Item -ItemType Directory -Path $buildRoot | Out-Null
}

$applicationBsp = Join-Path $platformRoot 'psu_cortexa53_0\standalone_domain\bsp\psu_cortexa53_0'
$xparameters = Get-Item -LiteralPath (Join-Path $applicationBsp 'include\xparameters.h') -ErrorAction SilentlyContinue
$xilLib = Get-Item -LiteralPath (Join-Path $applicationBsp 'lib\libxil.a') -ErrorAction SilentlyContinue
if (!$xparameters -or !$xilLib) { throw 'Candidate BSP generation did not produce xparameters.h and libxil.a' }
$bspRoot = Split-Path (Split-Path $xparameters.FullName -Parent) -Parent
$bspLib = Split-Path $xilLib.FullName -Parent
if (!(Test-Path (Join-Path $bspLib 'libmetal.a'))) { throw "Candidate BSP is missing libmetal.a: $bspLib" }

$objectRoot = Join-Path $buildRoot 'objects'
New-Item -ItemType Directory -Force $objectRoot | Out-Null
$includePaths = @(
    (Join-Path $bspRoot 'include'),
    (Join-Path $sourceRoot 'devices'),
    (Join-Path $sourceRoot 'rfsoc')
)
$compileArgs = @('-Wall', '-O0', '-g3', '-D__BAREMETAL__', '-mcpu=cortex-a53')
foreach ($includePath in $includePaths) { $compileArgs += "-I$includePath" }
$objectFiles = @()
foreach ($sourceFile in (Get-ChildItem -LiteralPath $sourceRoot -Recurse -File -Filter '*.c')) {
    $relativeName = $sourceFile.FullName.Substring($sourceRoot.Length + 1).Replace('\', '_')
    $objectFile = Join-Path $objectRoot ($relativeName + '.o')
    & $compiler @compileArgs -c $sourceFile.FullName -o $objectFile
    if ($LASTEXITCODE -ne 0) { throw "Compile failed: $($sourceFile.FullName)" }
    $objectFiles += $objectFile
}

$linkArgs = @(
    '-mcpu=cortex-a53',
    "-Wl,-T,$(Join-Path $sourceRoot 'lscript.ld')",
    "-L$bspLib",
    '-o', $elfBuild
)
& $compiler @linkArgs @objectFiles '-Wl,--start-group' '-lxil' '-lmetal' '-lm' '-lgcc' '-lc' '-Wl,--end-group'
if ($LASTEXITCODE -ne 0) { throw 'Candidate ELF link failed' }

$header = & $readelf -h $elfBuild | Out-String
if ($LASTEXITCODE -ne 0 -or $header -notmatch 'Machine:\s+AArch64') { throw 'ELF is not a valid AArch64 executable' }
$elfStrings = & (Join-Path $GnuBin 'aarch64-none-elf-strings.exe') $elfBuild | Out-String
if ($elfStrings -notmatch 'DAC=9000000000 real samples/s' -or
    $elfStrings -notmatch 'ADC=5000000000 raw samples/s' -or
    $elfStrings -match 'DAC=9850000000 real samples/s') {
    throw 'ELF embedded initialization rates do not match the 9G/5G candidate'
}
& $size $elfBuild
if ($LASTEXITCODE -ne 0) { throw 'ELF size validation failed' }

New-Item -ItemType Directory -Force (Split-Path -Parent $elfPackage) | Out-Null
if ([System.IO.Path]::GetFullPath($elfBuild) -ne $elfPackage) {
    Copy-Item -LiteralPath $elfBuild -Destination $elfPackage
}
$hash = (Get-FileHash -LiteralPath $elfPackage -Algorithm SHA256).Hash.ToLowerInvariant()
$nm = Join-Path $GnuBin 'aarch64-none-elf-nm.exe'
$symbolText = & $nm $elfBuild
if ($LASTEXITCODE -ne 0) { throw 'ELF initialization protocol symbol lookup failed' }
$symbols = @{}
foreach ($line in $symbolText) {
    if ($line -match '^([0-9a-fA-F]+)\s+\w\s+(awg_clock_ready|awg_pl_program_ack|awg_init_log|awg_init_log_length|init_stage_debug)$') {
        $symbols[$Matches[2]] = '0x' + $Matches[1]
    }
}
foreach ($name in @('awg_clock_ready','awg_pl_program_ack','awg_init_log','awg_init_log_length','init_stage_debug')) {
    if (!$symbols.ContainsKey($name)) { throw "ELF is missing initialization protocol symbol: $name" }
}
$protocol = @('protocol_version 1')
foreach ($name in @('awg_clock_ready','awg_pl_program_ack','awg_init_log','awg_init_log_length','init_stage_debug')) {
    $protocol += "$name $($symbols[$name])"
}
$protocol | Set-Content -LiteralPath (Join-Path (Split-Path -Parent $elfPackage) 'init_protocol.txt') -Encoding ascii
@{
    candidate = 'dac9g_opt1'
    xsa = (Get-FileHash -LiteralPath $CandidateXsa -Algorithm SHA256).Hash.ToLowerInvariant()
    elf = $hash
    elf_bytes = (Get-Item -LiteralPath $elfPackage).Length
    target = 'AArch64 standalone; DAC 9 GS/s; ADC 5 GS/s'
    board_tested = $false
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $buildRoot 'build_manifest.json') -Encoding utf8
Write-Output "Built and packaged candidate ELF: $elfPackage"
Write-Output "SHA256: $hash"
