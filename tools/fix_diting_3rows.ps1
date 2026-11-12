$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$p = Join-Path $root "objects\obj_ly_boss_diting\Create_0.gml"

# 备份
$bk = Join-Path $root ".workbuddy\backup\diting_soundwave_20261112"
New-Item -ItemType Directory -Force -Path $bk | Out-Null
Copy-Item $p (Join-Path $bk "Create_0.gml.3rows.bak") -Force

$raw = [System.IO.File]::ReadAllText($p)
if ($raw.Contains("`r`n")) { $nl = "`r`n" } else { $nl = "`n" }
$lines = [System.IO.File]::ReadAllLines($p)
$before = $lines.Count

if ($lines[129].Trim() -ne 'if (timer == 20) {') { throw "L130 基准不符: $($lines[129])" }
if ($lines[151].Trim() -ne 'if (longyuan_clip_done(timer, ly_anim_rate)) { timer = 0; state = BOSS_STATE.DISAPPEAR; }') { throw "L152 基准不符: $($lines[151])" }

$body = @'
            if (timer == 20) {
                // 技能2 音波：本行及上下相邻行（共 3 行）各生成一条向左扫过的音波。
                // 贴边时（BOSS 在第 0 行或最后一行）向上/向下越界的行夹回边界会重复，
                // 因此用"去重 + 向内补齐"保证始终恰好 3 行，且不会同一行放两条（伤害翻倍）。
                var _rows = [];
                var _n = 0;
                var _r, _probe, _dup, _k, _j;
                for (_k = 0; _k < 3; ++_k) {
                    _r = grid_row - 1 + _k;
                    if (_r < 0) _r = 0;
                    if (_r > global.grid_rows - 1) _r = global.grid_rows - 1;
                    _dup = false;
                    for (_j = 0; _j < _n; ++_j) { if (_rows[_j] == _r) { _dup = true; break; } }
                    if (!_dup) { _rows[_n] = _r; ++_n; }
                }
                _probe = global.grid_rows - 1;
                while (_n < 3 && _probe >= 0) {
                    _dup = false;
                    for (_j = 0; _j < _n; ++_j) { if (_rows[_j] == _probe) { _dup = true; break; } }
                    if (!_dup) { _rows[_n] = _probe; ++_n; }
                    --_probe;
                }
                _probe = 0;
                while (_n < 3 && _probe <= global.grid_rows - 1) {
                    _dup = false;
                    for (_j = 0; _j < _n; ++_j) { if (_rows[_j] == _probe) { _dup = true; break; } }
                    if (!_dup) { _rows[_n] = _probe; ++_n; }
                    ++_probe;
                }

                var _pos, _wave, _rr, _i;
                for (_i = 0; _i < _n; ++_i) {
                    _rr = _rows[_i];
                    _pos = get_world_position_from_grid(global.grid_cols - 1, _rr);
                    _wave = instance_create_depth(_pos.x, _pos.y, -1300, obj_ly_boss_fx);
                    longyuan_boss_fx_start(_wave, "diting_soundwave", "待机", true, 5);
                    _wave.fx_kind = "diting_soundwave_live";
                    _wave.fx_row = _rr; _wave.fx_direction = -1; _wave.fx_speed = 6;
                    _wave.fx_life = 0; _wave.fx_damage_timer = 0; _wave.fx_stuck = false;
                    _wave.fx_col_prev = global.grid_cols; // 尚未扫过任何列，首帧结算出生列
                    _wave.fx_damage = LY_DITING_SOUNDWAVE_DPS;
                }
            }
'@ -split "`r?`n"

$out = New-Object System.Collections.Generic.List[string]
for ($i = 0; $i -le 128; ++$i) { $out.Add($lines[$i]) }
foreach ($ln in $body) { $out.Add($ln) }
for ($i = 151; $i -lt $lines.Count; ++$i) { $out.Add($lines[$i]) }

[System.IO.File]::WriteAllText($p, ($out -join $nl), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("lines: {0} -> {1}" -f $before, $out.Count)
