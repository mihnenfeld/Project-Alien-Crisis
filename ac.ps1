param(
    [ValidateSet('all','play','check','update','assets','perspective','prerendered','3d','render','template')]
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
function Install-Rendered-Art {
    $Zip = Join-Path (Join-Path $env:USERPROFILE 'Downloads') 'Alien_Crisis_Commanddeck_10.zip'
    $Destination = Join-Path $Root 'assets\backgrounds'
    $Background = Join-Path $Destination 'commanddeck_render_bg.png'
    if (!(Test-Path -LiteralPath $Background)) {
        if (!(Test-Path -LiteralPath $Zip)) {
            throw "Grafikpaket fehlt. Alien_Crisis_Commanddeck_10.zip nach Downloads herunterladen und erneut starten: $Zip"
        }
        New-Item -ItemType Directory -Force -Path $Destination | Out-Null
        Expand-Archive -LiteralPath $Zip -DestinationPath $Destination -Force
        Write-Host 'Render-Kulissen installiert.' -ForegroundColor Green
    }
}
function Install-Walkmask {
    $Zip = Join-Path (Join-Path $env:USERPROFILE 'Downloads') 'Alien_Crisis_Commanddeck_Walkmask_12.zip'
    $Destination = Join-Path $Root 'assets\backgrounds'
    $Mask = Join-Path $Destination 'commanddeck_walkmask.png'
    $Stamp = Join-Path $Destination '.walkmask_v12_installed'
    if (!(Test-Path -LiteralPath $Stamp)) {
        if (!(Test-Path -LiteralPath $Zip)) {
            throw "Neue Walkmask erforderlich: Alien_Crisis_Commanddeck_Walkmask_12.zip nach Downloads laden: $Zip"
        }
        New-Item -ItemType Directory -Force -Path $Destination | Out-Null
        Expand-Archive -LiteralPath $Zip -DestinationPath $Destination -Force
        if (!(Test-Path -LiteralPath $Mask)) { throw 'Walkmask-Datei nicht im ZIP gefunden.' }
        New-Item -ItemType File -Force -Path $Stamp | Out-Null
        Write-Host 'Walkmask v1.2 installiert (vorherige Maske ersetzt).' -ForegroundColor Green
    }
}
function Install-Soldier {
    $Zip = Join-Path (Join-Path $env:USERPROFILE 'Downloads') 'Alien_Crisis_Soldier_Run_10.zip'
    $Destination = Join-Path $Root 'assets\characters\soldier'
    $Sentinel = Join-Path $Destination 'front_00.png'
    if (!(Test-Path -LiteralPath $Sentinel)) {
        if (!(Test-Path -LiteralPath $Zip)) {
            throw "Charakterpaket fehlt: Alien_Crisis_Soldier_Run_10.zip in Downloads speichern: $Zip"
        }
        New-Item -ItemType Directory -Force -Path $Destination | Out-Null
        Expand-Archive -LiteralPath $Zip -DestinationPath $Destination -Force
        if (!(Test-Path -LiteralPath $Sentinel)) { throw 'Charakter-Frames fehlen nach Entpacken.' }
        Write-Host 'Soldat mit Laufanimation installiert.' -ForegroundColor Green
    }
}
function Install-Concept {
    $Zip = Join-Path (Join-Path $env:USERPROFILE 'Downloads') 'Alien_Crisis_Concept_Camera01.zip'
    $Dest = Join-Path $Root 'assets\backgrounds'
    $Image = Join-Path $Dest 'commanddeck_concept.png'
    if (!(Test-Path -LiteralPath $Image)) {
        if (!(Test-Path -LiteralPath $Zip)) {
            Write-Warning "Optionales Konzeptgrafikpaket fehlt. F8 nicht verfuegbar: $Zip"
            return
        }
        New-Item -ItemType Directory -Force -Path $Dest | Out-Null
        Expand-Archive -LiteralPath $Zip -DestinationPath $Dest -Force
        if (!(Test-Path -LiteralPath $Image)) { throw 'Konzeptbild fehlt nach ZIP-Import.' }
        Write-Host 'Konzept-Kulisse fuer Kamera 1 installiert.' -ForegroundColor Green
    }
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
    '3d' { Start-Demo -TargetScene 'res://scenes/demo_3d.tscn' }
    'template' { Install-Concept; Start-Demo -TargetScene 'res://scenes/demo_template.tscn' }
    'render' { Install-Rendered-Art; Install-Walkmask; Install-Soldier; Start-Demo -TargetScene 'res://scenes/demo_rendered.tscn' }
    'all' { Update-Project; Install-Assets; Start-Demo }
}
