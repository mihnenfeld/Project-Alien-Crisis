param(
 [string]$ZipPath = (Join-Path $env:USERPROFILE 'Downloads/Universal Base Characters[Standard].zip')
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Target = Join-Path $Root 'assets/library/characters/quaternius_base_standard'
if (!(Test-Path -LiteralPath $ZipPath -PathType Leaf)) { throw "ZIP nicht gefunden: $ZipPath" }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$Archive = [IO.Compression.ZipFile]::OpenRead($ZipPath)
try {
 $Lic = @($Archive.Entries | Where-Object { $_.FullName -match '/License_Standard\.txt$' })[0]
 if ($null -eq $Lic) { throw 'Lizenzdatei fehlt.' }
 $Reader = [IO.StreamReader]::new($Lic.Open())
 try { $LicenseText = $Reader.ReadToEnd() } finally { $Reader.Dispose() }
 if ($LicenseText -notmatch 'CC0 1.0') { throw 'CC0-Lizenz fehlt.' }
 $Prefix = 'Base Characters/Godot - UE/'
 $Sources = @($Archive.Entries | Where-Object {
   $_.FullName.Contains($Prefix) -and -not [string]::IsNullOrEmpty($_.Name) -and $_.Name -match '\.(gltf|bin|png)$'
 })
 if (($Sources | Where-Object {$_.Name -eq 'Superhero_Male_FullBody.gltf'}).Count -ne 1) { throw 'Männliches Godot-Charaktermodell fehlt.' }
 New-Item -ItemType Directory -Force -Path $Target | Out-Null
 foreach ($Entry in $Sources) {
   $Destination = Join-Path $Target $Entry.Name
   $InputFile = $Entry.Open()
   try { $OutputFile = [IO.File]::Create($Destination); try { $InputFile.CopyTo($OutputFile) } finally { $OutputFile.Dispose() } } finally { $InputFile.Dispose() }
 }
 # The supplied Godot glTF references two incorrectly suffixed normal-map
 # filenames, though the actual PNGs have conventional names.
 foreach ($Name in @('T_Eye_Normal', 'T_Hair_1_Normal')) {
     $Original = Join-Path $Target ($Name + '.png')
     $Alias = Join-Path $Target ($Name + '_png.png')
     if (!(Test-Path -LiteralPath $Original)) { throw "Textur fehlt: $Original" }
     Copy-Item -LiteralPath $Original -Destination $Alias -Force
 }
 [IO.File]::WriteAllText((Join-Path $Target 'License_Standard.txt'), $LicenseText)
 Write-Host ("PAC CharacterKit: {0} Modelldateien und Texturen installiert." -f $Sources.Count) -ForegroundColor Green
 Write-Host "Ziel: $Target"
} finally { $Archive.Dispose() }
