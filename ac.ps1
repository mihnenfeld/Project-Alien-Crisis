param(
    [ValidateSet('all','play','check','update','assets','perspective','prerendered')]
    [string]$Action = 'all'
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$GodotSearchRoot = Join-Path $env:USERPROFILE 'Downloads'
$Godot = $null
$preferred = Join-Path $GodotSearchRoot 'Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe'
if (Test-Path -LiteralPath $preferred -PathType Leaf) {
    $Godot = $preferred
} else {
    $found = @(Get-ChildItem -LiteralPath $GodotSearchRoot -Filter 'Godot*win64.exe' -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch 'console' } |
        Sort-Object FullName)
    if ($found.Count -gt 0) { $Godot = $found[0].FullName }
}
$Scene = 'res://scenes/demo_base_hub.tscn'
function Check-Godot {
    if (!$Godot -or !(Test-Path -LiteralPath $Godot -PathType Leaf)) {
        throw "Godot nicht gefunden: $Godot"
    }
    Write-Host "Godot: $Godot" -ForegroundColor Cyan
    & $Godot --version
    if ($LASTEXITCODE -ne 0) { throw "Godot konnte nicht ausgefuehrt werden." }
}
function Update-Project {
    Push-Location $Root
    try {
        $dirty = @(git status --porcelain)
        if ($LASTEXITCODE -ne 0) { throw 'Git-Status fehlgeschlagen.' }
        if ($dirty.Count -gt 0) {
            Write-Warning 'Lokale Aenderungen erkannt. Git-Update uebersprungen, vorhandenen Stand starten.'
            git status --short
            return
        }
        git pull --ff-only
        if ($LASTEXITCODE -ne 0) { throw 'Git-Update fehlgeschlagen.' }
    }
    finally { Pop-Location }
}
function Start-Demo {
    param([string]$TargetScene = $Scene)
    Check-Godot
    $scenePath = Join-Path $Root ($TargetScene.Replace('res://', '').Replace('/', '\'))
    if (!(Test-Path -LiteralPath $scenePath)) {
        throw 'Demo-Szene fehlt.'
    }
    & $Godot --path $Root $TargetScene
    if ($LASTEXITCODE -ne 0) { throw "Godot beendete sich mit Fehlercode $LASTEXITCODE." }
}
function Install-Assets {
    & (Join-Path $Root 'tools\install-assets.ps1') -ProjectRoot $Root
}
switch ($Action) {
    'check' { Check-Godot }
    'update' { Update-Project }
    'assets' { Install-Assets }
    'play' { Start-Demo }
    'perspective' { Start-Demo -TargetScene 'res://scenes/demo_perspective.tscn' }
    'prerendered' { Start-Demo -TargetScene 'res://scenes/demo_prerendered.tscn' }
    'all' { Update-Project; Install-Assets; Start-Demo }
}
