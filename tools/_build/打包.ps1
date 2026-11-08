# 重新打包 音频转OGG.exe（改完 GUI 脚本后跑一次这个）
# 用法：右键「使用 PowerShell 运行」，或在 tools 目录执行 .\_build\打包.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$csc  = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$src  = Join-Path $root '音频转OGG-GUI.ps1'
$out  = Join-Path $root '音频转OGG.exe'
$cs   = Join-Path $PSScriptRoot 'AudioConvLauncher.cs'

if (-not (Test-Path $csc)) { throw "找不到 csc.exe：$csc" }
if (-not (Test-Path $src)) { throw "找不到 GUI 脚本：$src" }

# 保证 .cs 是 UTF-8 with BOM（csc 无 BOM 时按 ANSI 读，中文注释会乱）
$txt = [IO.File]::ReadAllText($cs, [Text.Encoding]::UTF8)
[IO.File]::WriteAllText($cs, $txt, (New-Object System.Text.UTF8Encoding($true)))

& $csc /nologo /target:winexe /optimize+ "/out:$out" "/resource:$src,conv.ps1" `
       /r:System.dll /r:System.Windows.Forms.dll $cs

if ($LASTEXITCODE -ne 0) { throw "csc 编译失败，退出码 $LASTEXITCODE" }
$len = (Get-Item $out).Length
Write-Host ("OK  {0}  ({1:N0} B)" -f $out, $len) -ForegroundColor Green
Read-Host "按回车关闭"