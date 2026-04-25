param(
    [string]$Output = "..\hideSceneport_module.zip"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Loader = Join-Path $Root "system\bin\hideport_loader"
$BpfObject = Join-Path $Root "system\bin\hideport.bpf.o"
if ([System.IO.Path]::IsPathRooted($Output)) {
    $OutputPath = $Output
} else {
    $OutputPath = Join-Path $Root $Output
}

if (-not (Test-Path -LiteralPath $Loader)) {
    throw "Missing executable: $Loader. Build it first."
}

if (-not (Test-Path -LiteralPath $BpfObject)) {
    throw "Missing BPF object: $BpfObject. Build it first."
}

if (Test-Path -LiteralPath $OutputPath) {
    Remove-Item -LiteralPath $OutputPath -Force
}

$items = @(
    "module.prop",
    "hideport.conf",
    "post-fs-data.sh",
    "service.sh",
    "hideport_start.sh",
    "hide_scene_port.sh",
    "customize.sh",
    "uninstall.sh",
    "service.d",
    "system"
)

$paths = $items | ForEach-Object { Join-Path $Root $_ }
Compress-Archive -LiteralPath $paths -DestinationPath $OutputPath -Force
Write-Host "Wrote $OutputPath"
