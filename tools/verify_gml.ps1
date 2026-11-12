<#
.SYNOPSIS
    GML / YY / MD 文件一键校验：BOM、括号配平、字节数、行数。

.DESCRIPTION
    对应 AGENTS.md 第 2.2 条：编辑后必跑。
    剔除行注释、块注释、字符串字面量后再数括号，避免误报。

.PARAMETER Path
    文件或目录。目录会递归扫 *.gml / *.yy / *.yyp / *.md / *.json / *.ps1。

.PARAMETER Quiet
    只输出 FAIL 行，通过的不打印。

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify_gml.ps1 scripts\gacha_random_card

.EXAMPLE
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\verify_gml.ps1 objects\obj_battle\Create_0.gml
#>
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Path,

    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Get-TargetFiles {
    param([string]$P)
    if (Test-Path -LiteralPath $P -PathType Leaf) {
        return @(Get-Item -LiteralPath $P)
    }
    if (-not (Test-Path -LiteralPath $P -PathType Container)) {
        throw "路径不存在: $P"
    }
    return @(Get-ChildItem -LiteralPath $P -Recurse -File |
        Where-Object { $_.Extension -in '.gml', '.yy', '.yyp', '.md', '.json', '.ps1' })
}

function Strip-CodeNoise {
    param([string]$Text)
    $c = [regex]::Replace($Text, '/\*.*?\*/', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    $c = [regex]::Replace($c, '//[^\n\r]*', '')
    $c = [regex]::Replace($c, '"(?:[^"\\\r\n]|\\.)*"', '""')
    return $c
}

function Test-Bom {
    param([byte[]]$Bytes)
    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) { return $true }
    return $false
}

$files = Get-TargetFiles $Path
if ($files.Count -eq 0) { throw "没有匹配的文件: $Path" }

$fail = 0
$okCount = 0
$rows = @()

foreach ($f in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $hasBom = Test-Bom $bytes
    $ext = $f.Extension.ToLowerInvariant()
    $problems = @()

    # ── BOM 规则 ──
    if ($ext -eq '.ps1') {
        if (-not $hasBom) { $problems += 'PS1 缺 BOM' }
    }
    else {
        if ($hasBom) { $problems += '不该有 BOM' }
    }

    # ── 括号配平（只对代码类文件）──
    if ($ext -in '.gml', '.ps1', '.json', '.yy', '.yyp') {
        $text = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        $clean = Strip-CodeNoise $text
        $pairs = @(
            @('{', '}'), @('(', ')'), @('[', ']')
        )
        foreach ($pair in $pairs) {
            $open  = ([regex]::Matches($clean, [regex]::Escape($pair[0]))).Count
            $close = ([regex]::Matches($clean, [regex]::Escape($pair[1]))).Count
            if ($open -ne $close) {
                $problems += "$($pair[0])$($pair[1]) $open/$close"
            }
        }
    }

    # ── 行数 ──
    $lineCount = 0
    try {
        $lineCount = ([System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)).Count
    } catch { $lineCount = -1 }

    if ($problems.Count -gt 0) {
        $fail++
        Write-Host ("FAIL  {0}  {1} B  {2} 行  ->  {3}" -f $f.Name, $bytes.Length, $lineCount, ($problems -join '; ')) -ForegroundColor Red
        $rows += [pscustomobject]@{
            File = $f.FullName; Bytes = $bytes.Length; Lines = $lineCount
            Bom = $hasBom; Problems = ($problems -join '; '); Pass = $false
        }
    }
    else {
        $okCount++
        if (-not $Quiet) {
            Write-Host ("OK    {0}  {1} B  {2} 行" -f $f.Name, $bytes.Length, $lineCount)
        }
        $rows += [pscustomobject]@{
            File = $f.FullName; Bytes = $bytes.Length; Lines = $lineCount
            Bom = $hasBom; Problems = ''; Pass = $true
        }
    }
}

Write-Host ''
Write-Host ("合计 {0} 个文件：通过 {1}，失败 {2}" -f $files.Count, $okCount, $fail)

if ($fail -gt 0) { exit 1 }
exit 0
