# -*- coding: utf-8 -*-
<#
    从 mod97（UMT 导出目录）批量导入武器精灵到 FVM-Reborn-mod
    用法：
        pwsh -File tools/import_weapon_sprites.ps1 -Weapon gods_shield
        pwsh -File tools/import_weapon_sprites.ps1 -Weapon all
        pwsh -File tools/import_weapon_sprites.ps1 -Weapon gods_shield -DryRun

    只写 sprites/ 下的文件与 folders/ 下的 .yy，不改 .yyp。
    跑完会输出 <Weapon>_yyp.txt，里面是待粘贴进 .yyp 的两段条目。
#>
param(
    [Parameter(Mandatory=$true)][string]$Weapon,
    [string]$SrcRoot  = 'C:\Users\18203\Desktop\mod97',
    [string]$ProjRoot = 'D:\gameProject\FVM-Reborn-mod',
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# ── 武器配置：文件夹名 / 纹理组 / 原点 / 精灵列表 ────────────────────────────
# 每项：name = 精灵名（不带 spr_ 前缀也可，下面统一补）
#       origin = 4(center) / 9(bottom-center)
#       tg = 纹理组
#       scale = 可选，整图缩放（默认 1）
$CONFIG = @{
    gods_shield = @{
        Folder = 'gods_shield'
        Items  = @(
            @{ name='spr_gods_shield_icon';       origin=4; tg='cards' },
            @{ name='spr_gods_shield_effect_1';   origin=4; tg='UI' },
            @{ name='spr_gods_shield_effect_2';   origin=4; tg='UI' },
            @{ name='spr_gods_shield_effect_3';   origin=4; tg='UI' },
            @{ name='spr_gods_shield_effect_4';   origin=4; tg='UI' },
            @{ name='spr_gods_shield_gem_1';      origin=4; tg='cards' },
            @{ name='spr_gods_shield_gem_2';      origin=4; tg='cards' },
            @{ name='spr_gods_shield_gem_3';      origin=4; tg='cards' },
            @{ name='spr_gods_shield_gem_4';      origin=4; tg='cards' },
            @{ name='spr_gods_shield_gem_effect_1'; origin=4; tg='cards' },
            @{ name='spr_gods_shield_gem_effect_2'; origin=4; tg='cards' },
            @{ name='spr_gods_shield_gem_effect_3'; origin=4; tg='cards' },
            @{ name='spr_gods_shield_gem_effect_4'; origin=4; tg='cards' }
        )
    }
    poseidon_dart_gun = @{
        Folder = 'poseidon_dart_gun'
        Items  = @(
            @{ name='spr_poseidon_dart_gun_gem_1';        origin=4; tg='cards' },
            @{ name='spr_poseidon_dart_gun_gem_2';        origin=4; tg='cards' },
            @{ name='spr_poseidon_dart_gun_gem_3';        origin=4; tg='cards' },
            @{ name='spr_poseidon_dart_gun_gem_4';        origin=4; tg='cards' },
            @{ name='spr_poseidon_dart_gun_gem_effect_2'; origin=4; tg='cards' },
            @{ name='spr_poseidon_dart_gun_gem_effect_3'; origin=4; tg='cards' },
            @{ name='spr_poseidon_dart_gun_gem_effect_4'; origin=4; tg='cards' },
            @{ name='spr_poseidon_dart_gun_gem_effect_5'; origin=4; tg='cards' },
            @{ name='spr_poseidon_bullet_1';              origin=4; tg='player' },
            @{ name='spr_poseidon_bullet_2';              origin=4; tg='player' },
            @{ name='spr_poseidon_bullet_3';              origin=4; tg='player' },
            @{ name='spr_poseidon_bullet_4';              origin=4; tg='player' }
        )
    }
    death_scythe = @{
        Folder = 'death_scythe'
        Items  = @(
            @{ name='spr_death_scythe';           origin=9; tg='cards' },
            @{ name='spr_death_scythe_1';         origin=9; tg='cards' },
            @{ name='spr_death_scythe_2';         origin=9; tg='cards' },
            @{ name='spr_death_scythe_bullet_1';  origin=4; tg='player' },
            @{ name='spr_death_scythe_bullet_2';  origin=4; tg='player' },
            @{ name='spr_death_scythe_bullet_3';  origin=4; tg='player' },
            @{ name='spr_death_scythe_bullet_4';  origin=4; tg='player' },
            @{ name='spr_death_scythe_effect';    origin=9; tg='UI' },
            @{ name='spr_death_scythe_effect_1';  origin=9; tg='UI' },
            @{ name='spr_death_scythe_effect_2';  origin=9; tg='UI' },
            @{ name='spr_death_scythe_gem_1';     origin=4; tg='cards' },
            @{ name='spr_death_scythe_gem_2';     origin=4; tg='cards' },
            @{ name='spr_death_scythe_gem_3';     origin=4; tg='cards' },
            @{ name='spr_death_scythe_gem_4';     origin=4; tg='cards' },
            @{ name='spr_death_scythe_icon';      origin=4; tg='cards' }
        )
    }
}

function New-Guid32 { [guid]::NewGuid().ToString() }

function Get-SourceFrames([string]$dir) {
    $files = Get-ChildItem -LiteralPath $dir -File -Filter '*.png'
    if ($files.Count -eq 0) { return @() }
    # 按文件名数字排序（1.png 2.png ... 10.png），非数字的按字母
    return $files | Sort-Object {
        $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $n = 0
        if ([int]::TryParse($base, [ref]$n)) { $n } else { 999999 }
    }, Name
}

function New-SpriteYY {
    param(
        [string]$Name, [int]$W, [int]$H, [int]$FrameCount,
        [string[]]$FrameGuids, [string]$LayerGuid,
        [int]$Origin, [string]$TextureGroup, [string]$ParentPath
    )
    $xo = [int]($W / 2)
    $yo = if ($Origin -eq 9) { [int]($H * 0.73) } else { [int]($H / 2) }

    $frameLines = ($FrameGuids | ForEach-Object {
        '    {"$GMSpriteFrame":"v1","%Name":"' + $_ + '","name":"' + $_ + '","resourceType":"GMSpriteFrame","resourceVersion":"2.0",},'
    }) -join "`n"

    $kfLines = @()
    for ($i = 0; $i -lt $FrameCount; $i++) {
        $kfLines += '            {"$Keyframe<SpriteFrameKeyframe>":"","Channels":{' + "`n" +
                    '                "0":{"$SpriteFrameKeyframe":"","Id":{"name":"' + $FrameGuids[$i] + '","path":"sprites/' + $Name + '/' + $Name + '.yy",},"resourceType":"SpriteFrameKeyframe","resourceVersion":"2.0",},' + "`n" +
                    '              },"Disabled":false,"id":"' + (New-Guid32) + '","IsCreationKey":false,"Key":' + $i + '.0,"Length":1.0,"resourceType":"Keyframe<SpriteFrameKeyframe>","resourceVersion":"2.0","Stretch":false,},'
    }
    $kfText = $kfLines -join "`n"

    $tpl = @'
{
  "$GMSprite":"v2",
  "%Name":"__NAME__",
  "bboxMode":0,
  "bbox_bottom":__BB__,
  "bbox_left":0,
  "bbox_right":__BW__,
  "bbox_top":0,
  "collisionKind":1,
  "collisionTolerance":0,
  "DynamicTexturePage":false,
  "edgeFiltering":false,
  "For3D":false,
  "frames":[
__FRAMES__
  ],
  "gridX":0,
  "gridY":0,
  "height":__H__,
  "HTile":false,
  "layers":[
    {"$GMImageLayer":"","%Name":"__LAYER__","blendMode":0,"displayName":"default","isLocked":false,"name":"__LAYER__","opacity":100.0,"resourceType":"GMImageLayer","resourceVersion":"2.0","visible":true,},
  ],
  "name":"__NAME__",
  "nineSlice":null,
  "origin":__ORIGIN__,
  "parent":{
    "name":"__PNAME__",
    "path":"__PPATH__",
  },
  "preMultiplyAlpha":false,
  "resourceType":"GMSprite",
  "resourceVersion":"2.0",
  "sequence":{
    "$GMSequence":"v1",
    "%Name":"__NAME__",
    "autoRecord":true,
    "backdropHeight":768,
    "backdropImageOpacity":0.5,
    "backdropImagePath":"",
    "backdropWidth":1366,
    "backdropXOffset":0.0,
    "backdropYOffset":0.0,
    "events":{
      "$KeyframeStore<MessageEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MessageEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "eventStubScript":null,
    "eventToFunction":{},
    "length":__LEN__,
    "lockOrigin":false,
    "moments":{
      "$KeyframeStore<MomentsEventKeyframe>":"",
      "Keyframes":[],
      "resourceType":"KeyframeStore<MomentsEventKeyframe>",
      "resourceVersion":"2.0",
    },
    "name":"__NAME__",
    "playback":1,
    "playbackSpeed":11.0,
    "playbackSpeedType":0,
    "resourceType":"GMSequence",
    "resourceVersion":"2.0",
    "showBackdrop":true,
    "showBackdropImage":false,
    "timeUnits":1,
    "tracks":[
      {"$GMSpriteFramesTrack":"","builtinName":0,"events":[],"inheritsTrackColour":true,"interpolation":1,"isCreationTrack":false,"keyframes":{"$KeyframeStore<SpriteFrameKeyframe>":"","Keyframes":[
__KF__
          ],"resourceType":"KeyframeStore<SpriteFrameKeyframe>","resourceVersion":"2.0",},"modifiers":[],"name":"frames","resourceType":"GMSpriteFramesTrack","resourceVersion":"2.0","spriteId":null,"trackColour":0,"tracks":[],"traits":0,},
    ],
    "visibleRange":null,
    "volume":1.0,
    "xorigin":__XO__,
    "yorigin":__YO__,
  },
  "swatchColours":null,
  "swfPrecision":0.5,
  "textureGroupId":{
    "name":"__TG__",
    "path":"texturegroups/__TG__",
  },
  "type":0,
  "VTile":false,
  "width":__W__,
}
'@

    $tpl = $tpl.Replace('__NAME__', $Name)
    $tpl = $tpl.Replace('__BB__', ([int]$H - 1).ToString())
    $tpl = $tpl.Replace('__BW__', ([int]$W - 1).ToString())
    $tpl = $tpl.Replace('__H__', $H.ToString())
    $tpl = $tpl.Replace('__W__', $W.ToString())
    $tpl = $tpl.Replace('__FRAMES__', $frameLines)
    $tpl = $tpl.Replace('__LAYER__', $LayerGuid)
    $tpl = $tpl.Replace('__ORIGIN__', $Origin.ToString())
    $tpl = $tpl.Replace('__PNAME__', (Split-Path $ParentPath -Leaf).Replace('.yy',''))
    $tpl = $tpl.Replace('__PPATH__', $ParentPath)
    $tpl = $tpl.Replace('__LEN__', ([double]$FrameCount).ToString('0.0'))
    $tpl = $tpl.Replace('__KF__', $kfText)
    $tpl = $tpl.Replace('__XO__', $xo.ToString())
    $tpl = $tpl.Replace('__YO__', $yo.ToString())
    $tpl = $tpl.Replace('__TG__', $TextureGroup)
    return $tpl
}

# ── 主流程 ────────────────────────────────────────────────────────────────────
$targets = if ($Weapon -eq 'all') { $CONFIG.Keys } else { @($Weapon) }
$report = @()
$yypSprites = @()
$yypFolders = @()

foreach ($wp in $targets) {
    if (-not $CONFIG.ContainsKey($wp)) { throw "未知武器: $wp（可选: $($CONFIG.Keys -join ', ') / all）" }
    $cfg = $CONFIG[$wp]
    $folderRel = "folders/精灵/mod/germ/$($cfg.Folder)"
    $folderYY  = "$folderRel.yy"
    $parentPath = "$folderYY"

    # 1) 建虚拟文件夹
    $folderAbs = Join-Path $ProjRoot ($folderRel -replace '/', '\')
    if (-not $DryRun) {
        New-Item -ItemType Directory -Force -Path $folderAbs | Out-Null
        $folderYYContent = @"
{
  "$GMFolder":"",
  "%Name":"$($cfg.Folder)",
  "folderPath":"$folderYY",
  "name":"$($cfg.Folder)",
  "resourceType":"GMFolder",
  "resourceVersion":"2.0",
}
"@
        [System.IO.File]::WriteAllText("$folderAbs.yy", $folderYYContent, (New-Object System.Text.UTF8Encoding($false)))
    }
    $yypFolders += '    {"$GMFolder":"","%Name":"' + $cfg.Folder + '","folderPath":"' + $folderYY + '","name":"' + $cfg.Folder + '","resourceType":"GMFolder","resourceVersion":"2.0",}'

    foreach ($it in $cfg.Items) {
        $spr = $it.name
        $srcDir = Join-Path $SrcRoot $spr
        if (-not (Test-Path $srcDir)) {
            $report += [pscustomobject]@{ Sprite=$spr; Status='源缺失'; Frames=0; Size='-' }
            continue
        }
        $frames = Get-SourceFrames $srcDir
        if ($frames.Count -eq 0) {
            $report += [pscustomobject]@{ Sprite=$spr; Status='无PNG'; Frames=0; Size='-' }
            continue
        }
        $img0 = [System.Drawing.Image]::FromFile($frames[0].FullName)
        $W = $img0.Width; $H = $img0.Height
        $img0.Dispose()

        $dstDir = Join-Path $ProjRoot "sprites\$spr"
        $layerGuid = New-Guid32
        $frameGuids = @()

        if ($DryRun) {
            $report += [pscustomobject]@{ Sprite=$spr; Status='(dry)'; Frames=$frames.Count; Size="${W}x${H}" }
            continue
        }

        if (Test-Path $dstDir) { Remove-Item -LiteralPath $dstDir -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $dstDir | Out-Null

        foreach ($f in $frames) {
            $fg = New-Guid32
            $frameGuids += $fg
            $layerDir = Join-Path $dstDir "layers\$fg"
            New-Item -ItemType Directory -Force -Path $layerDir | Out-Null
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $dstDir "$fg.png") -Force
            Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $layerDir "$layerGuid.png") -Force
        }

        $yy = New-SpriteYY -Name $spr -W $W -H $H -FrameCount $frames.Count `
                           -FrameGuids $frameGuids -LayerGuid $layerGuid `
                           -Origin $it.origin -TextureGroup $it.tg -ParentPath $parentPath
        [System.IO.File]::WriteAllText((Join-Path $dstDir "$spr.yy"), $yy, (New-Object System.Text.UTF8Encoding($false)))

        $yypSprites += '    {"id":{"name":"' + $spr + '","path":"sprites/' + $spr + '/' + $spr + '.yy",},},'
        $report += [pscustomobject]@{ Sprite=$spr; Status='OK'; Frames=$frames.Count; Size="${W}x${H}" }
    }
}

$report | Format-Table -AutoSize | Out-String -Width 200 | Write-Host

if (-not $DryRun -and $yypSprites.Count -gt 0) {
    $outFile = Join-Path $ProjRoot "tools\_yyp_$Weapon`_insert.txt"
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("===== ① 插入 Folders 数组（放在 folders/精灵/mod/germ/star_wand.yy 那一行之后）=====")
    $yypFolders | ForEach-Object { [void]$sb.AppendLine($_) }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("===== ② 插入 Sprites resources（按字母序找位置）=====")
    $yypSprites | Sort-Object | ForEach-Object { [void]$sb.AppendLine($_) }
    [System.IO.File]::WriteAllText($outFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding($true)))
    Write-Host "`n待插入 .yyp 的条目已写出: $outFile" -ForegroundColor Cyan
    Write-Host "  精灵 $($yypSprites.Count) 条 / 文件夹 $($yypFolders.Count) 条" -ForegroundColor Cyan
}
