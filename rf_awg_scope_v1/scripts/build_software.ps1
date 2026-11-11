param([string]$GnuBin='E:\AMDDesignTools\2025.2\Vitis\gnu\aarch64\nt\aarch64-none\bin')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path $PSScriptRoot -Parent
$referenceBsp=[IO.Path]::GetFullPath((Join-Path $projectRoot '..\rf_adda_demo\Prj\vitis\adaloop_top\psu_cortexa53_0\standalone_psu_cortexa53_0\bsp\psu_cortexa53_0'))
$compiler=Join-Path $GnuBin 'aarch64-none-elf-gcc.exe'
$outputPath=Join-Path $projectRoot 'output'
$objectPath=Join-Path $projectRoot 'software\objects'
New-Item -ItemType Directory -Force $outputPath,$objectPath | Out-Null
$includePaths=@((Join-Path $referenceBsp 'include'),(Join-Path $projectRoot 'software\src\devices'),(Join-Path $projectRoot 'software\src\rfsoc'))
$compileArgs=@('-Wall','-O0','-g3','-D__BAREMETAL__','-mcpu=cortex-a53')
foreach($includePath in $includePaths){$compileArgs+=('-I'+$includePath)}
$objectFiles=@()
foreach($sourceFile in (Get-ChildItem (Join-Path $projectRoot 'software\src') -Recurse -Filter '*.c')) {
    $relativeName=$sourceFile.FullName.Substring((Join-Path $projectRoot 'software\src').Length+1).Replace('\','_')
    $objectFile=Join-Path $objectPath ($relativeName+'.o')
    & $compiler @compileArgs -c $sourceFile.FullName -o $objectFile
    if($LASTEXITCODE -ne 0){throw "Compile failed: $($sourceFile.Name)"}
    $objectFiles+=$objectFile
}
$elf=Join-Path $outputPath 'rf_awg_init.elf'
$linkArgs=@('-mcpu=cortex-a53',('-Wl,-T,'+(Join-Path $projectRoot 'software\src\lscript.ld')),('-L'+(Join-Path $referenceBsp 'lib')),'-o',$elf)
& $compiler @linkArgs @objectFiles '-Wl,--start-group' '-lxil' '-lmetal' '-lm' '-lgcc' '-lc' '-Wl,--end-group'
if($LASTEXITCODE -ne 0){throw 'ELF link failed'}
& (Join-Path $GnuBin 'aarch64-none-elf-size.exe') $elf
Write-Output "Built $elf using the supplied reference BSP. PS addresses and RFDC configuration are unchanged."
