# Generates tools/level_editor/data.js from the GameMaker project.
# ASCII-only on purpose: Windows PowerShell 5.1 decodes BOM-less .ps1 as ANSI,
# so all Chinese text is read from the game sources / docs (UTF-8) instead.
$ErrorActionPreference = "Stop"

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = (Resolve-Path (Join-Path $here "..\..")).Path
$sprRoot = Join-Path $root "sprites"
$objRoot = Join-Path $root "objects"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Text([string]$p) {
    if (Test-Path $p) { return [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }
    return ""
}

# Parses every  head("id", { ... })  call, brace- and string-aware, so
# multi-line registrations are handled too.
function Get-Calls([string]$text, [string]$head) {
    $res = New-Object System.Collections.ArrayList
    $rx = [regex]::Matches($text, [regex]::Escape($head) + '\s*\(\s*"([^"]+)"\s*,\s*\{')
    foreach ($m in $rx) {
        $id = $m.Groups[1].Value
        $i = $m.Index + $m.Length
        $depth = 1
        $inStr = $false
        $sb = New-Object System.Text.StringBuilder
        while ($i -lt $text.Length -and $depth -gt 0) {
            $ch = $text[$i]
            if ($inStr) {
                if ($ch -eq '\') {
                    [void]$sb.Append($ch)
                    $i++
                    if ($i -lt $text.Length) { [void]$sb.Append($text[$i]) }
                    $i++
                    continue
                }
                if ($ch -eq '"') { $inStr = $false }
                [void]$sb.Append($ch)
                $i++
                continue
            }
            if ($ch -eq '"') { $inStr = $true; [void]$sb.Append($ch); $i++; continue }
            if ($ch -eq '{') { $depth++ }
            elseif ($ch -eq '}') { $depth--; if ($depth -eq 0) { break } }
            [void]$sb.Append($ch)
            $i++
        }
        [void]$res.Add([pscustomobject]@{ id = $id; body = $sb.ToString() })
    }
    return $res
}

function Resolve-Sprite([string]$name) {
    if (-not $name) { return $null }
    $dir = Join-Path $sprRoot $name
    if (-not (Test-Path $dir)) { return $null }
    $yy = Join-Path $dir ($name + ".yy")
    $frame = $null; $w = 0; $h = 0
    if (Test-Path $yy) {
        $t = [IO.File]::ReadAllText($yy, [Text.Encoding]::UTF8)
        $mw = [regex]::Match($t, '"width"\s*:\s*(\d+)'); if ($mw.Success) { $w = [int]$mw.Groups[1].Value }
        $mh = [regex]::Match($t, '"height"\s*:\s*(\d+)'); if ($mh.Success) { $h = [int]$mh.Groups[1].Value }
        $mf = [regex]::Match($t, '"frames"\s*:\s*\[(.*?)\]', [Text.RegularExpressions.RegexOptions]::Singleline)
        if ($mf.Success) {
            $g = [regex]::Match($mf.Groups[1].Value, '"name"\s*:\s*"([0-9a-fA-F\-]{36})"')
            if ($g.Success) { $frame = $g.Groups[1].Value }
        }
    }
    if (-not $frame) {
        $png = Get-ChildItem $dir -Filter *.png -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($png) { $frame = $png.BaseName }
    }
    if (-not $frame) { return $null }
    return [pscustomobject]@{ name = $name; url = ("sprites/" + $name + "/" + $frame + ".png"); w = $w; h = $h }
}

function Resolve-ObjectSprite([string]$obj) {
    if (-not $obj) { return $null }
    $yy = Join-Path $objRoot ($obj + "\" + $obj + ".yy")
    if (-not (Test-Path $yy)) { return $null }
    $t = [IO.File]::ReadAllText($yy, [Text.Encoding]::UTF8)
    $m = [regex]::Match($t, '"spriteId"\s*:\s*\{[^}]*?"name"\s*:\s*"([^"]+)"')
    if ($m.Success) { return $m.Groups[1].Value }
    return $null
}

# ---------------------------------------------------------------- cards
$cardIds = New-Object System.Collections.ArrayList
$cardObj = @{}
foreach ($f in @("scripts\slots_init\slots_init.gml", "scripts\mod_slots_init\mod_slots_init.gml")) {
    $t = Read-Text (Join-Path $root $f)
    foreach ($m in [regex]::Matches($t, 'register_card\(\s*"([^"]+)"\s*,\s*([A-Za-z0-9_]+)')) {
        $id = $m.Groups[1].Value
        if (-not $cardObj.ContainsKey($id)) {
            [void]$cardIds.Add($id)
            $cardObj[$id] = $m.Groups[2].Value
        }
    }
}

# locate the card index doc by content (its name is non-ASCII)
$doc = ""
$docCandidates = Get-ChildItem (Join-Path $root "docs") -Filter *.md -File -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending
foreach ($f in $docCandidates) {
    $t = [IO.File]::ReadAllText($f.FullName, [Text.Encoding]::UTF8)
    if ($t.Contains("plant_type") -and $t.Contains("feature_type")) { $doc = $t; break }
}

$cardMeta = @{}
if ($doc) {
    foreach ($m in [regex]::Matches($doc, '(?m)^\|\s*\d+\s*\|\s*`([A-Za-z0-9_]+)`\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|')) {
        $id = $m.Groups[1].Value
        if ($cardObj.ContainsKey($id) -and -not $cardMeta.ContainsKey($id)) {
            $cardMeta[$id] = @{ name = $m.Groups[2].Value.Trim(); cat = $m.Groups[3].Value.Trim() }
        }
    }
}

function Get-CardBodies([string]$text) {
    $map = @{}
    $rx = [regex]::Matches($text, 'register_card\(\s*"([^"]+)"')
    foreach ($m in $rx) {
        $id = $m.Groups[1].Value
        $i = $m.Index + $m.Length
        $depth = 1
        $inStr = $false
        $sb = New-Object System.Text.StringBuilder
        while ($i -lt $text.Length -and $depth -gt 0) {
            $ch = $text[$i]
            if ($inStr) {
                if ($ch -eq '\') {
                    $i++
                    if ($i -lt $text.Length) { [void]$sb.Append($text[$i]) }
                    $i++
                    continue
                }
                if ($ch -eq '"') { $inStr = $false }
                [void]$sb.Append($ch)
                $i++
                continue
            }
            if ($ch -eq '"') { $inStr = $true; [void]$sb.Append($ch); $i++; continue }
            if ($ch -eq '(') { $depth++ }
            elseif ($ch -eq ')') { $depth--; if ($depth -eq 0) { break } }
            [void]$sb.Append($ch)
            $i++
        }
        if (-not $map.ContainsKey($id)) { $map[$id] = $sb.ToString() }
    }
    return $map
}

$cards = New-Object System.Collections.ArrayList
$allCardSrc = (Read-Text (Join-Path $root "scripts\slots_init\slots_init.gml")) + "`n" +
              (Read-Text (Join-Path $root "scripts\mod_slots_init\mod_slots_init.gml"))
$cardBodies = Get-CardBodies $allCardSrc
# secondary source: cards_init.gml stores { "name": ... } per card id
$extraNames = @{}
$ciTxt = Read-Text (Join-Path $root "scripts\cards_init\cards_init.gml")
foreach ($m in [regex]::Matches($ciTxt, '"([A-Za-z0-9_]+)"\s*,\s*\[\s*\{\s*"name"\s*:\s*"([^"]*)"')) {
    if (-not $extraNames.ContainsKey($m.Groups[1].Value)) { $extraNames[$m.Groups[1].Value] = $m.Groups[2].Value }
}
$sepChars = @([char]0xFF1A, [char]0x003A)
foreach ($id in $cardIds) {
    $sprName = $null
    foreach ($cand in @($id, ($id + "_icon"))) {
        if (Test-Path (Join-Path $sprRoot ("spr_" + $cand))) { $sprName = "spr_" + $cand; break }
    }
    if (-not $sprName) { $sprName = Resolve-ObjectSprite $cardObj[$id] }
    $spr = Resolve-Sprite $sprName
    $body = ""
    if ($cardBodies.ContainsKey($id)) { $body = $cardBodies[$id] }
    $cName = ""; $cCat = ""
    if ($cardMeta.ContainsKey($id)) {
        if ($cardMeta[$id].name) { $cName = $cardMeta[$id].name }
        $cCat = $cardMeta[$id].cat
    }
    # fallback: take the text before the first colon of the first shape description
    if ($body -and (-not $cName -or $cName -eq $id)) {
        $dm = [regex]::Match($body, 'description\s*:\s*"([^"]*)"')
        if ($dm.Success) {
            $desc = $dm.Groups[1].Value
            $cut = $desc.IndexOfAny($sepChars)
            if ($cut -gt 0) { $cName = $desc.Substring(0, $cut).Trim() } else { $cName = $desc.Trim() }
        }
    }
    if ($extraNames.ContainsKey($id) -and (-not $cName -or $cName -eq $id)) { $cName = $extraNames[$id] }
    if (-not $cName) { $cName = $id }
    if (-not $cCat -and $body) {
        if ($body -match 'is_fusion\s*:\s*1') { $cCat = "fusion" }
        elseif ($body -match 'is_gold\s*:\s*1') { $cCat = "gold" }
        else { $cCat = "normal" }
    }
    $entry = [ordered]@{ id = $id; name = $cName; cat = $cCat; spr = ""; url = "" }
    if ($spr) { $entry.spr = $spr.name; $entry.url = $spr.url }
    [void]$cards.Add($entry)
}

# ---------------------------------------------------------------- enemies
$enemyFiles = @(
    @{ path = "scripts\enemy_init\enemy_init.gml";                     series = "main" },
    @{ path = "scripts\mod_enemy_init\mod_enemy_init.gml";             series = "mod" },
    @{ path = "scripts\longyuan_enemy_init\longyuan_enemy_init.gml";   series = "longyuan" },
    @{ path = "scripts\zhuore_enemy_init\zhuore_enemy_init.gml";       series = "zhuore" },
    @{ path = "scripts\zhuore_boss_init\zhuore_boss_init.gml";         series = "zhuore" }
)
$enemies = New-Object System.Collections.ArrayList
$seen = @{}
foreach ($ef in $enemyFiles) {
    $t = Read-Text (Join-Path $root $ef.path)
    foreach ($call in (Get-Calls $t "register_enemy")) {
        $id = $call.id
        if ($seen.ContainsKey($id)) { continue }
        $body = $call.body
        $seen[$id] = $true
        $nName = [regex]::Match($body, '\bname"?\s*:\s*"([^"]*)"')
        $nSpr  = [regex]::Match($body, '\bspr"?\s*:\s*([A-Za-z0-9_]+)')
        $nFeat = [regex]::Match($body, '\bfeature"?\s*:\s*"([^"]*)"')
        $nHp   = [regex]::Match($body, '\bhp"?\s*:\s*(-?\d+)')
        $nDesc = [regex]::Match($body, '\bdescription"?\s*:\s*"([^"]*)"')
        $eName = $id
        if ($nName.Success) { $eName = $nName.Groups[1].Value }
        $desc = ""
        if ($nDesc.Success) { $desc = $nDesc.Groups[1].Value }
        $feat = "land"
        if ($nFeat.Success) { $feat = $nFeat.Groups[1].Value }
        $hp = 0
        if ($nHp.Success) { $hp = [int64]$nHp.Groups[1].Value }
        $spr = $null
        if ($nSpr.Success) { $spr = Resolve-Sprite $nSpr.Groups[1].Value }
        $series = $ef.series
        if ($id -like "kuafu_*") { $series = "cross" }
        elseif ($id -like "longyuan_*") { $series = "longyuan" }
        elseif ($id -like "zhuore_*") { $series = "zhuore" }
        $isBoss = $false
        if (($desc -match "BOSS|Boss|boss") -or ($eName -match "BOSS|Boss|boss") -or ($id -match "boss")) { $isBoss = $true }
        $entry = [ordered]@{
            id = $id; name = $eName; series = $series; feature = $feat; hp = $hp
            boss = $isBoss; desc = $desc; spr = ""; url = ""
        }
        if ($spr) { $entry.spr = $spr.name; $entry.url = $spr.url }
        [void]$enemies.Add($entry)
    }
}

# ---------------------------------------------------------------- sounds
$musics = New-Object System.Collections.ArrayList
Get-ChildItem (Join-Path $root "sounds") -Directory | ForEach-Object {
    if ($_.Name -notlike "snd_*" -and $_.Name -notlike "se_*") { [void]$musics.Add($_.Name) }
}
$musics = @($musics | Sort-Object)

# ---------------------------------------------------------------- map sprites
$spriteCount = @{}
Get-ChildItem (Join-Path $root "datafiles\level_data") -Recurse -Filter *.json | ForEach-Object {
    $j = $null
    try { $j = [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8) | ConvertFrom-Json } catch { return }
    $ms = "$($j.map_sprite)"
    if (-not $ms) { return }
    if (-not $spriteCount.ContainsKey($ms)) { $spriteCount[$ms] = @{} }
    $dn = "$($j.display_name)"
    if ($dn) {
        if (-not $spriteCount[$ms].ContainsKey($dn)) { $spriteCount[$ms][$dn] = 0 }
        $spriteCount[$ms][$dn]++
    }
}
$maps = New-Object System.Collections.ArrayList
foreach ($key in ($spriteCount.Keys | Sort-Object)) {
    $best = ""; $bestN = -1
    foreach ($kv in $spriteCount[$key].GetEnumerator()) {
        if ($kv.Value -gt $bestN) { $bestN = $kv.Value; $best = $kv.Key }
    }
    $spr = Resolve-Sprite $key
    $label = $key
    if ($best) { $label = $best }
    $w = 0; $h = 0; $url = ""
    if ($spr) { $w = $spr.w; $h = $spr.h; $url = $spr.url }
    [void]$maps.Add([ordered]@{ id = $key; label = $label; w = $w; h = $h; url = $url })
}

# ---------------------------------------------------------------- map objects
$objects = New-Object System.Collections.ArrayList
$moTxt = Read-Text (Join-Path $root "scripts\map_object_init\map_object_init.gml")
foreach ($line in ($moTxt -split "`r?`n")) {
    $m = [regex]::Match($line, 'register_map_object\(\s*"([^"]+)"\s*,\s*\{(.*)\}\s*\)')
    if (-not $m.Success) { continue }
    $id = $m.Groups[1].Value
    $body = $m.Groups[2].Value
    $nName = [regex]::Match($body, '"name"\s*:\s*"([^"]*)"')
    $nObj  = [regex]::Match($body, '"_obj"\s*:\s*([A-Za-z0-9_]+)')
    $nKind = [regex]::Match($body, '"longzhu_kind"\s*:\s*"([^"]*)"')
    $kind = ""
    if ($nKind.Success) { $kind = $nKind.Groups[1].Value }
    $sprName = $null
    if ($kind) { $sprName = "spr_longzhu_" + $kind }
    elseif ($nObj.Success) { $sprName = Resolve-ObjectSprite $nObj.Groups[1].Value }
    $spr = Resolve-Sprite $sprName
    $iconName = $sprName
    if ($kind) { $iconName = "spr_longzhu_" + $kind + "_icon" }
    $icon = Resolve-Sprite $iconName
    $oName = $id
    if ($nName.Success) { $oName = $nName.Groups[1].Value }
    $url = ""; if ($spr) { $url = $spr.url }
    $iconUrl = $url; if ($icon) { $iconUrl = $icon.url }
    [void]$objects.Add([ordered]@{ id = $id; name = $oName; kind = $kind; url = $url; icon = $iconUrl })
}

# ---------------------------------------------------------------- object thumbs
# Longzhu icon sprites carry a lot of transparent padding (art is ~1/4 of the
# canvas), so drawing them in a 56px cell makes them look like a dot.
# Crop every object icon to its alpha bounding box and save a thumbnail.
Add-Type -AssemblyName System.Drawing
$thumbDir = Join-Path $here "thumbs"
if (-not (Test-Path -LiteralPath $thumbDir)) { New-Item -ItemType Directory -Path $thumbDir | Out-Null }

function Crop-Alpha([string]$srcRel, [string]$dstName) {
    $src = Join-Path $root ($srcRel -replace '/', '\')
    if (-not (Test-Path -LiteralPath $src)) { return $null }
    try {
        $img = [System.Drawing.Image]::FromFile($src)
    } catch { return $null }
    try {
        $bmp = New-Object System.Drawing.Bitmap $img
        $minX = $bmp.Width; $minY = $bmp.Height; $maxX = -1; $maxY = -1
        for ($y = 0; $y -lt $bmp.Height; $y++) {
            for ($x = 0; $x -lt $bmp.Width; $x++) {
                if ($bmp.GetPixel($x, $y).A -gt 8) {
                    if ($x -lt $minX) { $minX = $x }
                    if ($x -gt $maxX) { $maxX = $x }
                    if ($y -lt $minY) { $minY = $y }
                    if ($y -gt $maxY) { $maxY = $y }
                }
            }
        }
        if ($maxX -lt 0) { return $null }
        $pad = 2
        $minX = [Math]::Max(0, $minX - $pad); $minY = [Math]::Max(0, $minY - $pad)
        $maxX = [Math]::Min($bmp.Width - 1, $maxX + $pad); $maxY = [Math]::Min($bmp.Height - 1, $maxY + $pad)
        $rect = New-Object System.Drawing.Rectangle $minX, $minY, ($maxX - $minX + 1), ($maxY - $minY + 1)
        $crop = $bmp.Clone($rect, $bmp.PixelFormat)
        $dst = Join-Path $thumbDir ($dstName + ".png")
        $crop.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        $crop.Dispose()
        return ("tools/level_editor/thumbs/" + $dstName + ".png")
    } catch {
        return $null
    } finally {
        $img.Dispose()
    }
}

foreach ($o in $objects) {
    if (-not $o.icon) { continue }
    $safe = ($o.id -replace '[^A-Za-z0-9_]', '_')
    $thumb = Crop-Alpha $o.icon ("obj_" + $safe)
    if ($thumb) { $o.icon = $thumb }
}

# ---------------------------------------------------------------- write

$data = [ordered]@{
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    cards   = @($cards)
    enemies = @($enemies)
    musics  = @($musics)
    maps    = @($maps)
    objects = @($objects)
}
$json = $data | ConvertTo-Json -Depth 8 -Compress
$outPath = Join-Path $here "data.js"
$payload = "// auto-generated by gen_data.ps1 - do not edit by hand`nwindow.FVM_DATA = " + $json + ";`n"
[IO.File]::WriteAllText($outPath, $payload, $utf8NoBom)

Write-Host ("cards   : " + $cards.Count)
Write-Host ("enemies : " + $enemies.Count)
Write-Host ("musics  : " + $musics.Count)
Write-Host ("maps    : " + $maps.Count)
Write-Host ("objects : " + $objects.Count)
Write-Host ("written : " + $outPath)
