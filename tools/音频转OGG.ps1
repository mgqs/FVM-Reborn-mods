<#
  音频转 OGG（Vorbis）转换器
  ------------------------------------------------------------
  用法一（推荐）：把 mp3 / flac / wav / m4a / aac / wma / ape 文件
                  直接拖到「音频转OGG.bat」图标上，松手即转换。
  用法二：双击「音频转OGG.bat」，转换 bat 所在目录下的所有音频。
  用法三（命令行）：
      powershell -ExecutionPolicy Bypass -File 音频转OGG.ps1 "歌1.mp3","歌2.flac"
      powershell -ExecutionPolicy Bypass -File 音频转OGG.ps1 -OutDir "D:\music" -Quality 8
  ------------------------------------------------------------
  输出：与源文件同目录，扩展名换成 .ogg；重名自动加 _2 _3。
  可选：-OutDir 指定输出目录、-Quality 0..10（默认 6，越大越好听）、-Overwrite 覆盖同名。
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Arguments
)

$ErrorActionPreference = "Stop"

# ---------- 手动解析参数 ----------
# 为什么要手写：拖放多个文件时，powershell -File 会把第一个位置参数绑给 param 里
# 第一个非 switch 参数（以前是 $OutDir），路径就被当成输出目录了。
# 统一从 $Arguments 里拆，路径/选项都能正确落在该落的地方。
$Source = New-Object System.Collections.ArrayList
$OutDir = ""
$Quality = 6
$Overwrite = $false
$NoPause = $false

$ai = 0
while ($ai -lt $Arguments.Count) {
    $a = [string]$Arguments[$ai]
    switch ($a) {
        "-OutDir"    { $ai++; $OutDir = [string]$Arguments[$ai] }
        "-Out"       { $ai++; $OutDir = [string]$Arguments[$ai] }
        "-Quality"   { $ai++; $Quality = [int]$Arguments[$ai] }
        "-q"         { $ai++; $Quality = [int]$Arguments[$ai] }
        "-Overwrite" { $Overwrite = $true }
        "-NoPause"   { $NoPause = $true }
        default {
            if (-not [string]::IsNullOrWhiteSpace($a)) { [void]$Source.Add($a) }
        }
    }
    $ai++
}
$AudioExt = @(".mp3", ".flac", ".wav", ".m4a", ".aac", ".wma", ".ape", ".aiff", ".aif", ".mp2", ".mpga")

function Write-Title([string]$t) {
    Write-Host ""
    Write-Host ("=" * 62) -ForegroundColor DarkCyan
    Write-Host ("  " + $t) -ForegroundColor Cyan
    Write-Host ("=" * 62) -ForegroundColor DarkCyan
}

function Find-FFmpeg {
    $candidates = New-Object System.Collections.ArrayList

    # 1) GameMaker 自带 ffmpeg（本机一定有，不需要额外安装）
    foreach ($root in @("C:\ProgramData\GameMakerStudio2-LTS2026\Cache\runtimes",
                        "C:\ProgramData\GameMakerStudio2\Cache\runtimes")) {
        if (Test-Path $root) {
            Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue |
                Sort-Object Name -Descending |
                ForEach-Object {
                    $p = Join-Path $_.FullName "bin\ffmpeg\windows\ffmpeg.exe"
                    if (Test-Path $p) { [void]$candidates.Add($p) }
                }
        }
    }

    # 2) 脚本目录旁的 ffmpeg.exe
    $local = Join-Path $PSScriptRoot "ffmpeg.exe"
    if (Test-Path $local) { [void]$candidates.Add($local) }

    # 3) PATH 里的 ffmpeg
    $cmd = Get-Command "ffmpeg.exe" -ErrorAction SilentlyContinue
    if ($cmd) { [void]$candidates.Add($cmd.Source) }

    foreach ($c in $candidates) {
        try {
            $null = & $c -hide_banner -version 2>&1
            if ($LASTEXITCODE -eq 0) { return $c }
        } catch { }
    }
    return $null
}

function Get-UniquePath([string]$dir, [string]$baseName) {
    $target = Join-Path $dir ($baseName + ".ogg")
    if ($Overwrite -or -not (Test-Path $target)) { return $target }
    $i = 2
    while ($true) {
        $target = Join-Path $dir ($baseName + "_" + $i + ".ogg")
        if (-not (Test-Path $target)) { return $target }
        $i++
    }
}

# ---------- 收集待转换文件 ----------
Write-Title "音频转 OGG（Vorbis）转换器"

$files = New-Object System.Collections.ArrayList
if ($Source -and $Source.Count -gt 0) {
    foreach ($s in $Source) {
        if ([string]::IsNullOrWhiteSpace($s)) { continue }
        $p = $s.Trim('"')
        if (Test-Path -LiteralPath $p -PathType Leaf) {
            [void]$files.Add((Get-Item -LiteralPath $p))
        } elseif (Test-Path -LiteralPath $p -PathType Container) {
            Get-ChildItem -LiteralPath $p -File | Where-Object { $AudioExt -contains $_.Extension.ToLower() } |
                ForEach-Object { [void]$files.Add($_) }
        } else {
            Write-Host "  跳过（不存在）：$p" -ForegroundColor DarkYellow
        }
    }
} else {
    Write-Host "  未收到文件参数，改为转换本目录：" -ForegroundColor DarkGray
    Write-Host "  $PSScriptRoot" -ForegroundColor DarkGray
    Get-ChildItem -LiteralPath $PSScriptRoot -File |
        Where-Object { $AudioExt -contains $_.Extension.ToLower() } |
        ForEach-Object { [void]$files.Add($_) }
}

if ($files.Count -eq 0) {
    Write-Host ""
    Write-Host "  没有找到可转换的音频文件。" -ForegroundColor Yellow
    Write-Host ""
    if (-not $NoPause) { Read-Host "  按回车关闭" }
    exit 1
}

$ff = Find-FFmpeg
if (-not $ff) {
    Write-Host ""
    Write-Host "  找不到 ffmpeg.exe。" -ForegroundColor Red
    Write-Host "  解决办法：把 ffmpeg.exe 放到本脚本同目录，或安装 GameMaker。" -ForegroundColor Yellow
    Write-Host ""
    if (-not $NoPause) { Read-Host "  按回车关闭" }
    exit 1
}
Write-Host ("  ffmpeg : " + $ff) -ForegroundColor DarkGray
Write-Host ("  质量   : -q:a " + $Quality) -ForegroundColor DarkGray
Write-Host ("  文件数 : " + $files.Count) -ForegroundColor DarkGray

# ---------- 逐个转换 ----------
$ok = 0; $fail = 0; $skip = 0
$totalSrc = [long]0; $totalDst = [long]0
$failList = New-Object System.Collections.ArrayList
$idx = 0

foreach ($f in $files) {
    $idx++
    $name = $f.Name
    Write-Host ""
    Write-Host ("[" + $idx + "/" + $files.Count + "] " + $name) -ForegroundColor White

    if ($f.Extension.ToLower() -eq ".ogg") {
        Write-Host "       已是 ogg，跳过。" -ForegroundColor DarkGray
        $skip++; continue
    }

    $outDir = $OutDir
    if ([string]::IsNullOrWhiteSpace($outDir)) { $outDir = $f.DirectoryName }
    if (-not (Test-Path -LiteralPath $outDir)) { $null = New-Item -ItemType Directory -Path $outDir -Force }
    $dst = Get-UniquePath $outDir $f.BaseName

    # -vn：丢掉内嵌封面（ogg 容器没有 theora 编码器，带封面会直接失败）
    $argsList = @(
        "-hide_banner", "-loglevel", "error", "-nostdin", "-y",
        "-i", $f.FullName,
        "-vn",
        "-c:a", "libvorbis",
        "-q:a", "$Quality",
        "-map_metadata", "-1",
        $dst
    )

    $sw = [Diagnostics.Stopwatch]::StartNew()
    try {
        $err = & $ff @argsList 2>&1
        $code = $LASTEXITCODE
    } catch {
        $err = $_.Exception.Message
        $code = -1
    }
    $sw.Stop()

    if ($code -eq 0 -and (Test-Path -LiteralPath $dst)) {
        $srcSize = $f.Length
        $dstSize = (Get-Item -LiteralPath $dst).Length
        $totalSrc += $srcSize; $totalDst += $dstSize
        $ratio = 0
        if ($srcSize -gt 0) { $ratio = [math]::Round($dstSize * 100.0 / $srcSize, 0) }
        Write-Host ("       OK  " + [math]::Round($sw.Elapsed.TotalSeconds, 1) + "s   " +
                    [math]::Round($srcSize / 1MB, 1) + " MB -> " + [math]::Round($dstSize / 1MB, 1) +
                    " MB (" + $ratio + "%)") -ForegroundColor Green
        Write-Host ("       " + $dst) -ForegroundColor DarkGray
        $ok++
    } else {
        Write-Host "       FAIL" -ForegroundColor Red
        $msg = ($err | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($msg)) { $msg = "退出码 $code" }
        $msg = $msg -split "`r?`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -First 4
        foreach ($line in $msg) { Write-Host ("       " + $line) -ForegroundColor DarkYellow }
        [void]$failList.Add($name)
        if (Test-Path -LiteralPath $dst) { Remove-Item -LiteralPath $dst -Force -ErrorAction SilentlyContinue }
        $fail++
    }
}

# ---------- 汇总 ----------
Write-Title "完成"
Write-Host ("  成功 " + $ok + "   失败 " + $fail + "   跳过 " + $skip) -ForegroundColor White
if ($totalSrc -gt 0) {
    Write-Host ("  总体积 " + [math]::Round($totalSrc / 1MB, 1) + " MB -> " + [math]::Round($totalDst / 1MB, 1) + " MB") -ForegroundColor DarkGray
}
if ($fail -gt 0) {
    Write-Host ""
    Write-Host "  失败清单：" -ForegroundColor Red
    foreach ($n in $failList) { Write-Host ("    - " + $n) -ForegroundColor Red }
    Write-Host ""
    Write-Host "  常见原因：文件损坏 / 不是音频 / 输出目录无写入权限。" -ForegroundColor DarkYellow
}
Write-Host ""
if (-not $NoPause) { Read-Host "  按回车关闭" }