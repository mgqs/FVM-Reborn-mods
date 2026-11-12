# 修正变异轰隆隆 技能3（坐压）冲击波特效：原点对齐 4x4 判定区中心 + 放大到红圈范围
# 用法: powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\fix_honglonglong_skill3_fx.ps1
# 说明: 全部按行定位改写，不使用多行锚点，避免 CRLF / 缩进导致的锚点未命中

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$utf8 = New-Object System.Text.UTF8Encoding($false)

$bossStepPath = Join-Path $root "objects\obj_honglonglong\Step_0.gml"
$fxCreatePath = Join-Path $root "objects\obj_honglonglong_skill_3_effect\Create_0.gml"
$fxStepPath   = Join-Path $root "objects\obj_honglonglong_skill_3_effect\Step_0.gml"

# ============ 1. BOSS Step_0 : 行级改写 ============
$lines = New-Object System.Collections.Generic.List[string]
[System.IO.File]::ReadAllLines($bossStepPath) | ForEach-Object { $lines.Add($_) }

# 1a. 删掉上一版临时加的 skill3_fx / skill3_fy 赋值（改由创建处自带）
$removed = 0
for ($i = $lines.Count - 1; $i -ge 0; $i--) {
    $tr = $lines[$i].Trim()
    if ($tr -like "skill3_fx = global.grid_offset_x*" -or $tr -like "skill3_fy = global.grid_offset_y*") {
        $lines.RemoveAt($i); $removed++
    }
}

# 1b. 把「直接用 BOSS (x,y) 创建特效」改成「用 4x4 判定区几何中心创建」
$idx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq "instance_create_depth(x, y, depth - 1, obj_honglonglong_skill_3_effect)") { $idx = $i; break }
}
if ($idx -lt 0) { throw "未找到特效创建行: $bossStepPath" }

$base = $lines[$idx]
$ind = $base.Substring(0, $base.Length - $base.TrimStart().Length)
$newBlock = @(
    ($ind + "// 圆心必须是 4x4 判定区的几何中心，不是 BOSS 脚底的 (x, y)"),
    ($ind + "// 判定区 行[_center_row-2, _center_row+1] 列[_center_col-2, _center_col+1]"),
    ($ind + "// 其中点正好落在网格线上：offset + row * cell / offset + col * cell"),
    ($ind + "// BOSS 的 y 比判定区中心低 88px（格心 +30），所以旧写法冲击波整体偏右下"),
    ($ind + "var _fx_grid = get_grid_position_from_world(x, y)"),
    ($ind + "var _fx_x = global.grid_offset_x + _fx_grid.col * global.grid_cell_size_x"),
    ($ind + "var _fx_y = global.grid_offset_y + _fx_grid.row * global.grid_cell_size_y"),
    ($ind + "instance_create_depth(_fx_x, _fx_y, depth - 1, obj_honglonglong_skill_3_effect)")
)
$lines.RemoveAt($idx)
$lines.InsertRange($idx, [string[]]$newBlock)

[System.IO.File]::WriteAllLines($bossStepPath, $lines, $utf8)

# ============ 2. 特效 Create_0 : 全量写（<200 行）============
$fxCreateText = @'
/// 变异轰隆隆 技能3（坐压）落地特效
/// 由 obj_honglonglong 的 SKILL3 分支在 spr_honglonglong_skill_3 第 15 帧时创建
/// 创建点 = 4x4 判定区几何中心（BOSS 所在格的左上角网格交点），不是 BOSS 脚下的 (x, y)
///
/// 缩放依据（实测 alpha 半径）：
///   贴图 278x262，origin 居中 (139,131)
///   光环可见半径 r98：帧0约 95px、帧1约 119px、帧2~帧4约 100px
///   4x4 判定区半径 = 2 格 = 214px(横) / 232px(纵)，需要放大 214/100 ≈ 2.1 倍
///   1.8 倍只有 171~214px，正好差一圈，就是「范围有点小」的原因
image_xscale = 2.1
image_yscale = 2.1
image_speed = 0
image_index = 0
image_alpha = 1

// 盖在 BOSS 本体之上、弹幕之下
depth = -1

timer = 0
'@.Replace("`r`n", "`n")
[System.IO.File]::WriteAllText($fxCreatePath, $fxCreateText, $utf8)

# ============ 3. 特效 Step_0 : 全量写（<200 行）============
$fxStepText = @'
if global.is_paused{
	exit
}

timer++

// 17 帧特效，每帧 4 tick
// 放大到 2.1 倍后直径约 4 格，播放太快会糊成一团，4 tick/帧 让冲击波推出去的过程看得清
var _last = sprite_get_number(sprite_index) - 1
image_index = floor(timer/4)
if image_index >= _last{
	image_index = _last
	instance_destroy()
}
'@.Replace("`r`n", "`n")
[System.IO.File]::WriteAllText($fxStepPath, $fxStepText, $utf8)

# ============ 4. 断言 ============
$b  = [System.IO.File]::ReadAllText($bossStepPath, [System.Text.Encoding]::UTF8)
$fc = [System.IO.File]::ReadAllText($fxCreatePath, [System.Text.Encoding]::UTF8)
$fs = [System.IO.File]::ReadAllText($fxStepPath, [System.Text.Encoding]::UTF8)

"removed skill3_fx lines : $removed"
"new create call         : " + (($b -match "instance_create_depth\(_fx_x, _fx_y, depth - 1, obj_honglonglong_skill_3_effect\)"))
"old create call gone    : " + (-not ($b -match "instance_create_depth\(x, y, depth - 1, obj_honglonglong_skill_3_effect\)"))
"4x4 judge intact       : " + (($b -match "_center_row - 2 && grid_row <= _center_row \+ 1") -and ($b -match "_center_col - 2 && grid_col <= _center_col \+ 1"))
"fx xscale / yscale      : " + ([regex]::Match($fc, "image_xscale = ([\d.]+)")).Groups[1].Value + " / " + ([regex]::Match($fc, "image_yscale = ([\d.]+)")).Groups[1].Value
"fx tick per frame       : " + ([regex]::Match($fs, "floor\(timer/(\d+)\)")).Groups[1].Value
"boss Step lines         : " + ([System.IO.File]::ReadAllLines($bossStepPath)).Count
