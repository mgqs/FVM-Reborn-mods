param(
    [Parameter(Mandatory=$true)][string]$Project,
    [Parameter(Mandatory=$true)][string]$Work,
    [Parameter(Mandatory=$true)][string]$Output,
    [string]$RuntimePath,
    [string]$UserDir,
    [ValidateRange(1,64)][int]$Jobs = 1
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

if (-not $RuntimePath) {
    $RuntimePath = Get-ChildItem "$env:ProgramData\GameMakerStudio2*\Cache\runtimes\runtime-*" -Directory |
        Sort-Object { [Version]($_.Name -replace '^runtime-', '') } -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $RuntimePath) { throw 'Install the GameMaker Windows runtime or supply --runtime-path.' }
$igor = Join-Path $RuntimePath 'bin\igor\windows\x64\Igor.exe'
if (-not (Test-Path -LiteralPath $igor)) { throw "Windows Igor is missing: $igor" }
if (-not (Test-Path -LiteralPath (Join-Path $RuntimePath 'windows'))) {
    throw 'The Windows target module is not installed in this runtime.'
}
$ffmpeg = Join-Path $RuntimePath 'bin\ffmpeg\windows\ffmpeg.exe'
& $ffmpeg -version *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'GameMaker FFmpeg cannot start. Install Microsoft Visual C++ 2015-2022 Redistributable (x64).'
}
$shaderTool = Join-Path $RuntimePath 'bin\Shaders\D3D11ShaderParser.exe'
if (-not (Test-Path -LiteralPath $shaderTool)) {
    throw 'The GameMaker Windows shader compiler is missing. Reinstall the Windows runtime module.'
}
if (-not $UserDir) {
    $UserDir = Get-ChildItem "$env:APPDATA\GameMakerStudio2*\*\licence.plist" -File |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty DirectoryName
}
if (-not $UserDir -or -not (Test-Path -LiteralPath (Join-Path $UserDir 'licence.plist'))) {
    throw 'Log in to GameMaker once or supply --user-dir (existing licence folder).'
}
New-Item -ItemType Directory -Path $Work -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $Output) -Force | Out-Null
$buildLog = Join-Path $Work 'build.log'
$package = Join-Path $Work ('package-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $package | Out-Null
# Igor packages the entire --of directory. Keep caches, logs, and source outside it.
$compilerOutput = Join-Path $package 'FVM_Reborn_makk.zip'
$arguments = @(
    "--project=$Project", "--rp=$RuntimePath", "--uf=$UserDir",
    "--cache=$Work\cache", "--temp=$Work\temp", "--of=$compilerOutput", "--tf=$Output",
    '--runtime=VM', '--config=Default', "-j=$Jobs", '--', 'Windows', 'PackageZip'
)
Write-Output "Building Windows x64 VM package. Log: $buildLog"
$ErrorActionPreference = 'Continue'
& $igor @arguments 2>&1 | Out-File -LiteralPath $buildLog -Encoding UTF8
$buildExit = $LASTEXITCODE
$ErrorActionPreference = 'Stop'
$failures = Select-String -LiteralPath $buildLog -SimpleMatch -Pattern @(
    'Exception during processing', 'System.IO.FileNotFoundException', 'System.DllNotFoundException', 'Error :'
)
if ($buildExit -ne 0 -or $failures -or -not (Test-Path -LiteralPath $Output)) {
    Get-Content -LiteralPath $buildLog -Tail 60
    throw "GameMaker build failed ($buildExit); see $buildLog"
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [IO.Compression.ZipFile]::OpenRead($Output)
try {
    if (-not ($archive.Entries | Where-Object { $_.FullName -eq 'data.win' })) {
        throw 'GameMaker ZIP has no data.win.'
    }
} finally { $archive.Dispose() }
Write-Output "Package: $Output"
