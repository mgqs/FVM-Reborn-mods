$ErrorActionPreference = 'Stop'

$SRC = 'C:\Users\18203\Desktop\mod97\code'
$P   = 'D:\gameProject\FVM-Reborn-mod'

$UTF8BOM = New-Object System.Text.UTF8Encoding($true)
$UTF8NOB = New-Object System.Text.UTF8Encoding($false)

function Write-BOM([string]$path, [string]$text) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($path, $text, $UTF8BOM)
}
function Write-NOBOM([string]$path, [string]$text) {
    $dir = Split-Path -Parent $path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($path, $text, $UTF8NOB)
}

# ---------- 源文件清理 ----------
function Clean-Source([string]$text, [string]$objName, [switch]$Bullet, [switch]$GemStep) {

    # 1) 删掉 enum UnknownEnum 定义块（源里只定义了 Value_0，Step 却用了 Value_1）
    $text = [regex]::Replace($text, '(?sm)^[ \t]*enum\s+UnknownEnum\s*\{.*?\}[ \t]*\r?\n?', '')

    # 1b) UnknownEnum.Value_N -> 裸数字（项目 obj_hades_scythe 就是 0 = IDLE / 1 = ATTACK）
    $text = $text -replace 'UnknownEnum\.Value_0', '0'
    $text = $text -replace 'UnknownEnum\.Value_1', '1'

    # 2) speed -> move_speed（仅子弹对象，避免误伤 speed 关键字以外的东西）
    if ($Bullet) {
        $text = [regex]::Replace($text, '(?<![\w.])speed\b', 'move_speed')
    }

    # 3) 宝石 Step 里硬编码找 hades_scythe -> 改成自己的武器对象
    if ($GemStep) {
        $text = $text -replace 'instance_find\(obj_hades_scythe', 'instance_find(obj_death_scythe'
    }

    return $text
}

# ---------- 事件类型映射 ----------
function Get-EventMeta([string]$fname) {
    switch -CaseSensitive ($fname) {
        'Create_0.gml'                      { return @{ t = 0; n = 0;  c = $null } }
        'Step_0.gml'                        { return @{ t = 3; n = 0;  c = $null } }
        'Draw_0.gml'                        { return @{ t = 8; n = 0;  c = $null } }
        'Other_11.gml'                      { return @{ t = 7; n = 11; c = $null } }
        'Other_21.gml'                      { return @{ t = 7; n = 21; c = $null } }
        'Mouse_10.gml'                      { return @{ t = 6; n = 10; c = $null } }
        'Mouse_11.gml'                      { return @{ t = 6; n = 11; c = $null } }
        'Collision_obj_enemy_parent.gml'    { return @{ t = 4; n = 0;  c = 'obj_enemy_parent' } }
    }
    return $null
}

# ---------- 生成 .yy ----------
function New-ObjYy([string]$name, [string]$sprite, [array]$events, [string]$parentObj) {

    $evLines = @()
    foreach ($e in $events) {
        $m = Get-EventMeta $e
        if (-not $m) { throw "未知事件文件: $e" }
        if ($m.c) {
            $cid = '{' + "`n" + '      "name":"' + $m.c + '",' + "`n" + '      "path":"objects/' + $m.c + '/' + $m.c + '.yy",' + "`n" + '    }'
        } else {
            $cid = 'null'
        }
        $evLines += '    {"$GMEvent":"v1","%Name":"","collisionObjectId":' + $cid + ',"eventNum":' + $m.n + ',"eventType":' + $m.t + ',"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},'
    }

    if ($parentObj) {
        $poid = '{' + "`n" + '    "name":"' + $parentObj + '",' + "`n" + '    "path":"objects/' + $parentObj + '/' + $parentObj + '.yy",' + "`n" + '  }'
    } else {
        $poid = 'null'
    }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('{')
    [void]$sb.AppendLine('  "$GMObject":"",')
    [void]$sb.AppendLine('  "%Name":"' + $name + '",')
    [void]$sb.AppendLine('  "eventList":[')
    foreach ($l in $evLines) { [void]$sb.AppendLine($l) }
    [void]$sb.AppendLine('  ],')
    [void]$sb.AppendLine('  "managed":true,')
    [void]$sb.AppendLine('  "name":"' + $name + '",')
    [void]$sb.AppendLine('  "overriddenProperties":[],')
    [void]$sb.AppendLine('  "parent":{')
    [void]$sb.AppendLine('    "name":"germ",')
    [void]$sb.AppendLine('    "path":"folders/物体/mod/germ.yy",')
    [void]$sb.AppendLine('  },')
    [void]$sb.AppendLine('  "parentObjectId":' + $poid + ',')
    [void]$sb.AppendLine('  "persistent":false,')
    [void]$sb.AppendLine('  "physicsAngularDamping":0.1,')
    [void]$sb.AppendLine('  "physicsDensity":0.5,')
    [void]$sb.AppendLine('  "physicsFriction":0.2,')
    [void]$sb.AppendLine('  "physicsGroup":0,')
    [void]$sb.AppendLine('  "physicsKinematic":false,')
    [void]$sb.AppendLine('  "physicsLinearDamping":0.1,')
    [void]$sb.AppendLine('  "physicsObject":false,')
    [void]$sb.AppendLine('  "physicsRestitution":0.1,')
    [void]$sb.AppendLine('  "physicsSensor":false,')
    [void]$sb.AppendLine('  "physicsShape":0,')
    [void]$sb.AppendLine('  "physicsShapePoints":[],')
    [void]$sb.AppendLine('  "physicsStartAwake":true,')
    [void]$sb.AppendLine('  "properties":[],')
    [void]$sb.AppendLine('  "resourceType":"GMObject",')
    [void]$sb.AppendLine('  "resourceVersion":"2.0",')
    [void]$sb.AppendLine('  "solid":false,')
    [void]$sb.AppendLine('  "spriteId":{')
    [void]$sb.AppendLine('    "name":"' + $sprite + '",')
    [void]$sb.AppendLine('    "path":"sprites/' + $sprite + '/' + $sprite + '.yy",')
    [void]$sb.AppendLine('  },')
    [void]$sb.AppendLine('  "spriteMaskId":null,')
    [void]$sb.AppendLine('  "visible":true,')
    [void]$sb.AppendLine('}')
    return $sb.ToString()
}

# ---------- 对象定义 ----------
$Jobs = @()

# 12 个宝石对象
$GemDefs = @(
    @{ w = 'gods_shield';       sprites = @('spr_gods_shield_gem_effect_1','spr_gods_shield_gem_effect_2','spr_gods_shield_gem_effect_3','spr_gods_shield_gem_effect_4');                     scale = 1.8 },
    @{ w = 'poseidon_dart_gun'; sprites = @('spr_poseidon_dart_gun_gem_effect_2','spr_poseidon_dart_gun_gem_effect_3','spr_poseidon_dart_gun_gem_effect_4','spr_poseidon_dart_gun_gem_effect_5'); scale = 1.8 },
    @{ w = 'death_scythe';      sprites = @('spr_death_scythe_gem_1','spr_death_scythe_gem_2','spr_death_scythe_gem_3','spr_death_scythe_gem_4');                                       scale = 0.9 }
)
foreach ($d in $GemDefs) {
    for ($i = 1; $i -le 4; $i++) {
        $Jobs += @{
            name   = "obj_$($d.w)_gem_$i"
            sprite = $d.sprites[$i - 1]
            scale  = $d.scale
            parent = $null
            events = @('Create_0.gml', 'Draw_0.gml', 'Mouse_10.gml', 'Mouse_11.gml', 'Step_0.gml')
            bullet = $false
            gemStep = ($d.w -eq 'death_scythe')
            srcPrefix = $null
        }
    }
}

# 3 个死神镰刀对象
$Jobs += @{ name = 'obj_death_scythe';        sprite = 'spr_death_scythe';        scale = 1.8; parent = $null;             events = @('Create_0.gml','Step_0.gml','Other_11.gml');                        bullet = $false; gemStep = $false; srcPrefix = $null }
$Jobs += @{ name = 'obj_death_scythe_enter';  sprite = 'spr_death_scythe_effect'; scale = 1.8; parent = $null;             events = @('Create_0.gml','Step_0.gml');                                        bullet = $false; gemStep = $false; srcPrefix = $null }
$Jobs += @{ name = 'obj_death_scythe_bullet'; sprite = 'spr_death_scythe_bullet_1'; scale = 1.0; parent = 'obj_bullet_parent'; events = @('Create_0.gml','Step_0.gml','Collision_obj_enemy_parent.gml'); bullet = $true;  gemStep = $false; srcPrefix = $null }

# ---------- 执行 ----------
$Made = @()
foreach ($j in $Jobs) {
    $objDir = Join-Path $P ('objects\' + $j.name)
    New-Item -ItemType Directory -Path $objDir -Force | Out-Null

    foreach ($ev in $j.events) {
        $srcFile = Join-Path $SRC ('gml_Object_' + $j.name + '_' + ($ev -replace '\.gml$', '') + '.gml')
        if (-not (Test-Path $srcFile)) { throw "源文件不存在: $srcFile" }

        $text = [System.IO.File]::ReadAllText($srcFile, [System.Text.Encoding]::UTF8)
        $text = Clean-Source -text $text -objName $j.name -Bullet:([bool]$j.bullet) -GemStep:([bool]$j.gemStep)

        # 宝石对象缩放修正（death_scythe 用 0.9）
        if ($j.name -match '_gem_\d$' -and $j.scale -ne 1.8 -and $ev -eq 'Create_0.gml') {
            $text = $text -replace 'image_xscale\s*=\s*[\d.]+;', ('image_xscale = ' + $j.scale + ';')
            $text = $text -replace 'image_yscale\s*=\s*[\d.]+;', ('image_yscale = ' + $j.scale + ';')
        }

        Write-BOM (Join-Path $objDir $ev) $text
    }

    $yy = New-ObjYy -name $j.name -sprite $j.sprite -events $j.events -parentObj $j.parent
    Write-BOM (Join-Path $objDir ($j.name + '.yy')) $yy

    $Made += $j.name
}

"生成对象 $($Made.Count) 个:"
$Made | ForEach-Object { "  - $_" }
