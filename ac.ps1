param(
    [ValidateSet('all','play','check','update')]
    [string]$Action = 'all'
)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Godot = 'C:\Users\Malte\Downloads\Godot_v4.7.2-stable_win64.exe'
$Scene = 'res://scenes/demo_outpost.tscn'
function Check-Godot {
    if (!(Test-Path -LiteralPath $Godot)) {
        throw "Godot nicht gefunden: $Godot"
    }
    & $Godot --version
    if ($LASTEXITCODE -ne 0) { throw "Godot konnte nicht ausgefuehrt werden." }
}
function Update-Project {
    Push-Location $Root
    try {
        $dirty = @(git status --porcelain)
        if ($LASTEXITCODE -ne 0) { throw 'Git-Status fehlgeschlagen.' }
        if ($dirty.Count -gt 0) { throw 'Lokale Aenderungen vorhanden. Git-Update aus Sicherheitsgruenden abgebrochen.' }
        git pull --ff-only
        if ($LASTEXITCODE -ne 0) { throw 'Git-Update fehlgeschlagen.' }
    }
    finally { Pop-Location }
}
function Start-Demo {
    Check-Godot
    if (!(Test-Path (Join-Path $Root 'scenes\demo_outpost.tscn'))) {
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
