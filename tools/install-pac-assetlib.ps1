param(
    [string]$ZipPath = (Join-Path (Join-Path $env:USERPROFILE 'Downloads') 'Modular SciFi MegaKit[Standard].zip')
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Destination = Join-Path $ProjectRoot 'assets\library\packs\quaternius_scifi_standard'
if (-not (Test-Path -LiteralPath $ZipPath)) {
    throw "MegaKit ZIP nicht gefunden: $ZipPath. Gib den Pfad mit -ZipPath an."
}
$TempDir = Join-Path ([IO.Path]::GetTempPath()) ('pac_scifi_import_' + [guid]::NewGuid().ToString('N'))
try {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $TempDir -Force
    $Pack = Get-ChildItem -LiteralPath $TempDir -Directory | Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'glTF') } | Select-Object -First 1
    if ($null -eq $Pack) { throw 'Das ZIP enthält keinen glTF-Ordner.' }
    $License = Join-Path $Pack.FullName 'License_Standard.txt'
    if (-not (Test-Path -LiteralPath $License)) { throw 'Lizenzdatei fehlt; Import abgebrochen.' }
    $LicenseText = Get-Content -LiteralPath $License -Raw
    if ($LicenseText -notmatch 'CC0 1.0') { throw 'CC0-Lizenz konnte nicht nachgewiesen werden.' }
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $Pack.FullName 'glTF') -Destination $Destination -Recurse -Force
    Copy-Item -LiteralPath (Join-Path $Pack.FullName 'Textures') -Destination $Destination -Recurse -Force
    Copy-Item -LiteralPath $License -Destination (Join-Path $Destination 'License_Standard.txt') -Force
    $GltfFiles = Get-ChildItem -LiteralPath (Join-Path $Destination 'glTF') -Filter '*.gltf' -Recurse -File
    foreach ($File in $GltfFiles) {
        # Source glTF references textures by filename alone. Each model is one
        # directory under glTF, so ../../Textures/ resolves to shared assets.
        $Content = [IO.File]::ReadAllText($File.FullName)
        $Updated = [regex]::Replace($Content, '("uri"\s*:\s*")([^"/\\]+\.png)(")', '$1../../Textures/$2$3')
        if ($Updated -ne $Content) {
            [IO.File]::WriteAllText($File.FullName, $Updated, (New-Object System.Text.UTF8Encoding($false)))
        }
    }
    Write-Host ("PAC AssetLib: {0} Modelle installiert." -f $GltfFiles.Count) -ForegroundColor Green
    Write-Host "Asset-Verzeichnis: $Destination"
    Write-Host 'Godot importiert die glTF-Dateien beim nächsten Öffnen des Projekts.'
    Write-Host 'Hinweis: Die 3D-Modelle sind noch nicht als PAC-ready geprüft.'
}
finally {
    if (Test-Path -LiteralPath $TempDir) { Remove-Item -LiteralPath $TempDir -Recurse -Force }
}
