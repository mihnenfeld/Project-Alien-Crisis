param(
    [ValidateSet('all','play','check','update')]
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
    Check-Godot
    if (!(Test-Path (Join-Path $Root 'scenes\demo_base_hub.tscn'))) {
        throw 'Demo-Szene fehlt.'
    }
    & $Godot --path $Root $Scene
    if ($LASTEXITCODE -ne 0) { throw "Godot beendete sich mit Fehlercode $LASTEXITCODE." }
}
switch ($Action) {
    'check' { Check-Godot }
    'update' { Update-Project }
    'play' { Start-Demo }
    'all' { Update-Project; Start-Demo }
}
