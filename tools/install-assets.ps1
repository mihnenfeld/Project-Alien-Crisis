param(
    [string]$Downloads = (Join-Path $env:USERPROFILE 'Downloads'),
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot)
)
$ErrorActionPreference = 'Stop'
$zip = Join-Path $Downloads 'Alien_Crisis_Asset_Pack_01.zip'
if (!(Test-Path -LiteralPath $zip -PathType Leaf)) {
    throw "Asset-ZIP fehlt: $zip. Bitte ZIP im Downloads-Ordner belassen."
}
$destination = Join-Path $ProjectRoot 'assets\materials\pack01'
$staging = Join-Path ([System.IO.Path]::GetTempPath()) ('ac-assets-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $staging -Force | Out-Null
try {
    Expand-Archive -LiteralPath $zip -DestinationPath $staging -Force
    $source = Join-Path $staging 'Alien_Crisis_Asset_Pack_01'
    $names = @('floor','wall','bulkhead','elevator','evac')
    foreach ($name in $names) {
        $folder = Join-Path $source $name
        if (!(Test-Path -LiteralPath $folder -PathType Container)) { throw "Fehlender Asset-Ordner: $name" }
        foreach ($map in @('albedo','normal','roughness','height','alpha','ao','metallic','emissive')) {
            if (!(Test-Path -LiteralPath (Join-Path $folder "$name`_$map.png") -PathType Leaf)) {
                throw "Fehlende Map: $name`_$map.png"
            }
        }
    }
    if (Test-Path -LiteralPath $destination) {
        Write-Host "Asset-Paket bereits vorhanden: $destination (keine Dateien ueberschrieben)." -ForegroundColor Yellow
        return
    }
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    foreach ($name in $names) {
        Copy-Item -LiteralPath (Join-Path $source $name) -Destination $destination -Recurse
    }
    Copy-Item -LiteralPath (Join-Path $source 'README.txt') -Destination $destination
    Write-Host "Asset-Paket installiert: $destination" -ForegroundColor Green
}
finally {
    Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
}
