$ErrorActionPreference = 'Stop'
$root = "D:\gameProject\FVM-Reborn-mod"
$p    = Join-Path $root "objects\obj_honglonglong\Step_0.gml"
$src  = Join-Path $root "tmp\fx_comment.txt"

$enc   = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines($p, [System.Text.Encoding]::UTF8)
$before = $lines.Length

# 1) locate the "if timer == 15 * 5{" line
$ifIdx = -1
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'if\s+timer\s*==\s*15\s*\*\s*5') { $ifIdx = $i; break }
}
if ($ifIdx -lt 0) { throw "15*5 branch not found" }

# 2) collect the contiguous // comments right after it
$cStart = $ifIdx + 1
$cEnd   = $cStart
while ($cEnd -lt $lines.Length -and $lines[$cEnd].TrimStart().StartsWith('//')) { $cEnd++ }
$removed = $cEnd - $cStart
if ($removed -le 0) { throw "no comment block after 15*5 branch" }

# 3) replacement lines come from a UTF-8 file so no code page damage
$repl = @()
foreach ($r in [System.IO.File]::ReadAllLines($src, [System.Text.Encoding]::UTF8)) {
    if ($r.Trim().Length -gt 0) { $repl += $r }
}

$new = New-Object System.Collections.ArrayList
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($i -ge $cStart -and $i -lt $cEnd) { continue }
    [void]$new.Add($lines[$i])
    if ($i -eq $ifIdx) { foreach ($r in $repl) { [void]$new.Add($r) } }
}

[System.IO.File]::WriteAllLines($p, [string[]]$new.ToArray(), $enc)

# 4) verify
$check  = [System.IO.File]::ReadAllLines($p, [System.Text.Encoding]::UTF8)
$joined = $check -join "`n"
$badLines = 0
foreach ($l in $check) {
    foreach ($c in [int[]][char[]]$l) { if ($c -eq 0xFFFD) { $badLines++; break } }
}
Write-Host ("removed comment lines : " + $removed)
Write-Host ("lines before / after  : " + $before + " / " + $check.Length)
Write-Host ("replacement inserted  : " + $joined.Contains('4x4 判定区的几何中点'))
Write-Host ("U+FFFD lines left     : " + $badLines)
Write-Host ("create call intact    : " + $joined.Contains('instance_create_depth(_fx_x, _fx_y, depth - 1, obj_honglonglong_skill_3_effect)'))
Write-Host ("4x4 judge intact      : " + $joined.Contains('grid_row >= _center_row - 2 && grid_row <= _center_row + 1'))
