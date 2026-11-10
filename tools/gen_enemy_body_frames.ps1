# gen_enemy_body_frames.ps1
# 重新生成 scripts/enemy_body/enemy_body.gml 的判定框数据段。
# 旧版只扫「站立首帧」，对帧间位移大的敌人（潜水鼠、冰渣球）框严重偏小。
# 新版逐帧扫描，按以下规则输出：
#   - 各帧框与全帧并集的偏差都在阈值内 -> 存并集单框（省内存）
#   - 偏差超阈值                        -> 存逐帧框表（精确命中）
# 用法: powershell -NoProfile -ExecutionPolicy Bypass -File tools\gen_enemy_body_frames.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $root 'FVM_Reborn_makk.yyp'))) { $root = $PSScriptRoot }
$eb = Join-Path $root 'scripts\enemy_body\enemy_body.gml'
if (-not (Test-Path $eb)) { throw "找不到 $eb" }

# 逐帧容差：某帧的四条边与并集相差超过这么多像素，就认为需要逐帧表
$TOLERANCE = 12
# alpha 阈值
$ALPHA_MIN = 40

Add-Type -AssemblyName System.Drawing
if (-not ('PxScan' -as [type])) {
    Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class PxScan {
    // 返回 [minX, maxX, minY, maxY, ok]
    public static int[] Scan(string path, int alphaMin) {
        using (var bmp = new Bitmap(path)) {
            int w = bmp.Width, h = bmp.Height;
            var d = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            var buf = new byte[d.Stride * h];
            Marshal.Copy(d.Scan0, buf, 0, buf.Length);
            bmp.UnlockBits(d);
            int minX = w, maxX = -1, minY = h, maxY = -1;
            for (int y = 0; y < h; y++) {
                int row = y * d.Stride;
                for (int x = 0; x < w; x++) {
                    if (buf[row + x * 4 + 3] > alphaMin) {
                        if (x < minX) minX = x;
                        if (x > maxX) maxX = x;
                        if (y < minY) minY = y;
                        if (y > maxY) maxY = y;
                    }
                }
            }
            if (maxX < 0) return new int[] { 0, 0, 0, 0, 0 };
            return new int[] { minX, maxX, minY, maxY, 1 };
        }
    }
}
'@
}

# ---------- 1. 从现有 gml 取出所有 sprite 名 ----------
$src = [System.IO.File]::ReadAllText($eb, [System.Text.Encoding]::UTF8)
$reRow = [regex]'\["(spr_[^"]+)"'
$names = @()
foreach ($m in $reRow.Matches($src)) {
    $n = $m.Groups[1].Value
    if (-not ($names -contains $n)) { $names += $n }
}
$names = $names | Sort-Object
Write-Host "表中 sprite 数: $($names.Count)"

# ---------- 2. 逐 sprite 逐帧扫描 ----------
$rows = New-Object System.Collections.Generic.List[string]
$statPerFrame = 0
$statSingle = 0
$statMissing = 0
$idx = 0

foreach ($spr in $names) {
    $idx++
    if ($idx % 50 -eq 0) { Write-Host "  ... $idx / $($names.Count)" }

    $yyPath = Join-Path $root "sprites\$spr\$spr.yy"
    if (-not (Test-Path $yyPath)) {
        $statMissing++
        $rows.Add("`t`t`t`t`t[`"$spr`", 0, 0, 0, 0],")
        continue
    }
    $yy = [System.IO.File]::ReadAllText($yyPath, [System.Text.Encoding]::UTF8)
    $xo = [int]([regex]::Match($yy, '"xorigin":\s*(-?\d+)').Groups[1].Value)
    $yo = [int]([regex]::Match($yy, '"yorigin":\s*(-?\d+)').Groups[1].Value)

    # 帧顺序必须以 sequence 的 keyframes 为准（运行时按 Key 播放）
    # frames 数组只是资源定义顺序，两者可能不一致（手工调过帧序的精灵就会）
    $guids = @()
    foreach ($f in [regex]::Matches($yy, '"Channels":\s*\{\s*"0":\s*\{[^}]*?"Id":\s*\{\s*"name":"([0-9a-fA-F\-]{36})"')) {
        $guids += $f.Groups[1].Value
    }
    if ($guids.Count -eq 0) {
        # 兜底：退回 frames 数组顺序
        foreach ($m in [regex]::Matches($yy, '"frames":\s*\[(.*?)\]', 'Singleline')) {
            foreach ($f in [regex]::Matches($m.Groups[1].Value, '"%Name":"([0-9a-fA-F\-]{36})"')) {
                $guids += $f.Groups[1].Value
            }
            break
        }
    }
    if ($guids.Count -eq 0) {
        $statMissing++
        $rows.Add("`t`t`t`t`t[`"$spr`", 0, 0, 0, 0],")
        continue
    }

    $frames = New-Object System.Collections.Generic.List[int[]]
    foreach ($g in $guids) {
        $png = Join-Path $root "sprites\$spr\$g.png"
        if (-not (Test-Path $png)) { continue }
        $r = [PxScan]::Scan($png, $ALPHA_MIN)
        if ($r[4] -eq 0) { continue }
        # 转成相对 origin 的偏移，并加 2px 余量
        $frames.Add(@(($r[0] - $xo - 2), ($r[1] - $xo + 2), ($r[2] - $yo - 2), ($r[3] - $yo + 2)))
    }
    if ($frames.Count -eq 0) {
        $statMissing++
        $rows.Add("`t`t`t`t`t[`"$spr`", 0, 0, 0, 0],")
        continue
    }

    # 全帧并集
    $ul = [int]::MaxValue; $ur = [int]::MinValue; $ut = [int]::MaxValue; $ub = [int]::MinValue
    foreach ($f in $frames) {
        if ($f[0] -lt $ul) { $ul = $f[0] }
        if ($f[1] -gt $ur) { $ur = $f[1] }
        if ($f[2] -lt $ut) { $ut = $f[2] }
        if ($f[3] -gt $ub) { $ub = $f[3] }
    }

    # 判断是否需要逐帧表
    $needPerFrame = $false
    foreach ($f in $frames) {
        if ([Math]::Abs($f[0] - $ul) -gt $TOLERANCE -or [Math]::Abs($f[1] - $ur) -gt $TOLERANCE -or
            [Math]::Abs($f[2] - $ut) -gt $TOLERANCE -or [Math]::Abs($f[3] - $ub) -gt $TOLERANCE) {
            $needPerFrame = $true
            break
        }
    }

    if ($needPerFrame) {
        $statPerFrame++
        # 格式: ["spr", [[l,r,t,b], [l,r,t,b], ...]]
        $items = New-Object System.Collections.Generic.List[string]
        foreach ($f in $frames) {
            $items.Add('[' + $f[0] + ',' + $f[1] + ',' + $f[2] + ',' + $f[3] + ']')
        }
        $rows.Add("`t`t`t`t`t[`"$spr`", [" + ($items -join ',') + "]],")
    }
    else {
        $statSingle++
        $rows.Add("`t`t`t`t`t[`"$spr`", $ul, $ur, $ut, $ub],")
    }
}

Write-Host "  逐帧表: $statPerFrame   并集单框: $statSingle   缺精灵: $statMissing"

# ---------- 3. 重写 gml ----------
$header = @'
/// enemy_body —— 敌人固定判定框表（碰撞精度 B 方案）
/// 生成器：tools/gen_enemy_body_frames.ps1（重跑即可刷新，勿手改数据段）
///
/// 设计：每个敌人离线逐帧扫实心像素范围，存成相对实例原点的偏移。
///   单框格式  [spr, l, r, t, b]            各帧与并集偏差都在容差内
///   帧表格式  [spr, [[l,r,t,b], [l,r,t,b]]] 帧间位移大，按 image_index 精确取框
/// 运行时按实例 image_xscale / image_yscale 换算世界坐标，
/// 不再使用实例 bbox —— collisionKind=4 的精灵会随动作突变，
/// 导致命中时机忽早忽晚。
///
/// 退回方式：把 ENEMY_BODY_ENABLED 改成 false，全部判定恢复引擎 bbox，
/// 无需改任何调用点。

#macro ENEMY_BODY_ENABLED true

/// @func enemy_body_ensure()
/// @desc 惰性构建 sprite 索引 -> 判定框 的 ds_map，只建一次
function enemy_body_ensure() {
	static _busy = false;
	if (_busy) return;
	if (variable_global_exists("enemy_body_tbl")) return;
	_busy = true;

	var _t = ds_map_create();
	var _rows = [
'@

$footer = @'

	];

	for (var i = 0; i < array_length(_rows); i++) {
		var _r = _rows[i];
		var _payload = _r[1];
		if (is_array(_payload)) {
			// 帧表：转成 { l, r, t, b } 并用 image_index 索引
			_t[? _r[0]] = _payload;
		} else {
			_t[? _r[0]] = { l: _r[1], r: _r[2], t: _r[3], b: _r[4] };
		}
	}

	global.enemy_body_tbl = _t;
	_busy = false;
}

/// @func enemy_body_get(_e, _frame)
/// @desc 取敌人当前帧的判定框；_frame 省略时用实例的 image_index
function enemy_body_get(_e, _frame = undefined) {
	enemy_body_ensure();
	var _spr = _e.sprite_index;
	if (!ds_map_exists(global.enemy_body_tbl, _spr)) return undefined;
	var _v = global.enemy_body_tbl[? _spr];

	if (is_array(_v)) {
		var _f = is_undefined(_frame) ? floor(_e.image_index) : _frame;
		var _n = array_length(_v);
		if (_n <= 0) return undefined;
		if (_f < 0) _f = 0;
		if (_f >= _n) _f = _n - 1;
		var _a = _v[_f];
		return { l: _a[0], r: _a[1], t: _a[2], b: _a[3] };
	}
	return _v;
}

/// @func enemy_body_left(_e)
function enemy_body_left(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_left;
	return _e.x + _b.l * abs(_e.image_xscale);
}

/// @func enemy_body_right(_e)
function enemy_body_right(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_right;
	return _e.x + _b.r * abs(_e.image_xscale);
}

/// @func enemy_body_top(_e)
function enemy_body_top(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_top;
	return _e.y + _b.t * abs(_e.image_yscale);
}

/// @func enemy_body_bottom(_e)
function enemy_body_bottom(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) return _e.bbox_bottom;
	return _e.y + _b.b * abs(_e.image_yscale);
}

/// @func enemy_body_rect(_e)
/// @desc 一次性取四点，避免上面四个函数各查一次表
function enemy_body_rect(_e) {
	var _b = enemy_body_get(_e);
	if (is_undefined(_b)) {
		return { l: _e.bbox_left, r: _e.bbox_right, t: _e.bbox_top, b: _e.bbox_bottom };
	}
	var _sx = abs(_e.image_xscale);
	var _sy = abs(_e.image_yscale);
	var _neg = (_e.image_xscale < 0);
	return {
		l: _e.x + (_neg ? _b.r : _b.l) * _sx,
		r: _e.x + (_neg ? _b.l : _b.r) * _sx,
		t: _e.y + _b.t * _sy,
		b: _e.y + _b.b * _sy
	};
}

/// @func enemy_in_blast(_e, _bx, _by, _r)
/// @desc 爆炸判定：爆炸点到敌人身体矩形的最近距离 <= _r（贴视觉，只放宽不收紧）
function enemy_in_blast(_e, _bx, _by, _r) {
	if (!instance_exists(_e)) return false;
	var _rc = enemy_body_rect(_e);
	var _dx = 0;
	if (_bx < _rc.l) _dx = _rc.l - _bx;
	else if (_bx > _rc.r) _dx = _bx - _rc.r;
	var _dy = 0;
	if (_by < _rc.t) _dy = _rc.t - _by;
	else if (_by > _rc.b) _dy = _by - _rc.b;
	return (_dx * _dx + _dy * _dy) <= (_r * _r);
}

/// @func enemy_in_card_range(_cx, _cy, _e, _range_px)
/// @desc 卡片索敌辅助：卡片中心到敌人身体矩形的最近距离 <= _range_px
///       给需要像素级射程的卡用；老卡继续用整格判定不受影响
function enemy_in_card_range(_cx, _cy, _e, _range_px) {
	if (!instance_exists(_e)) return false;
	var _rc = enemy_body_rect(_e);
	var _dx = 0;
	if (_cx < _rc.l) _dx = _rc.l - _cx;
	else if (_cx > _rc.r) _dx = _cx - _rc.r;
	var _dy = 0;
	if (_cy < _rc.t) _dy = _rc.t - _cy;
	else if (_cy > _rc.b) _dy = _cy - _rc.b;
	return (_dx * _dx + _dy * _dy) <= (_range_px * _range_px);
}
'@

$body = ($rows -join "`n") -replace "`t`t`t`t`t", "`t`t"
$out = $header + "`n" + $body + "`n" + $footer
[System.IO.File]::WriteAllText($eb, $out, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "已写入 $eb  ($($out.Length) 字符)"
