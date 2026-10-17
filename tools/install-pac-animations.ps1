param(
    [string]$ZipPath = (Join-Path $env:USERPROFILE 'Downloads/Universal Animation Library[Standard].zip')
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Target = Join-Path $Root 'assets/library/animations/quaternius_ual_standard'
if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) { throw "ZIP nicht gefunden: $ZipPath" }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$Archive = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
    $Required = @('UAL1_Standard.glb','UAL1_Standard_RM.glb','License.txt','README.txt')
    foreach ($Name in $Required) {
        if (-not ($Archive.Entries | Where-Object { $_.Name -ceq $Name })) { throw "Erforderliche Datei fehlt im ZIP: $Name" }
    }
    $LicenseEntry = $Archive.Entries | Where-Object { $_.Name -ceq 'License.txt' } | Select-Object -First 1
    $Stream = $LicenseEntry.Open()
    try {
        $Reader = New-Object System.IO.StreamReader($Stream)
        try { $License = $Reader.ReadToEnd() } finally { $Reader.Dispose() }
    } finally { $Stream.Dispose() }
    if ($License -notmatch 'CC0 1.0') { throw 'Lizenz ist nicht als CC0 bestätigt.' }
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
    foreach ($Name in $Required) {
        $Entry = $Archive.Entries | Where-Object { $_.Name -ceq $Name } | Select-Object -First 1
        $Output = Join-Path $Target $Name
        $InputStream = $Entry.Open()
        try {
            $OutputStream = [System.IO.File]::Create($Output)
            try { $InputStream.CopyTo($OutputStream) } finally { $OutputStream.Dispose() }
        } finally { $InputStream.Dispose() }
    }
    Write-Host 'PAC UAL: 43 Animationen (GLB, normal und Root Motion) installiert.' -ForegroundColor Green
    Write-Host "Ziel: $Target"
    Write-Host 'Empfehlung: Standarddatei ohne Root Motion für den bestehenden CharacterBody3D verwenden.'
} finally { $Archive.Dispose() }
