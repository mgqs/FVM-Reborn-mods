// obj_tangchaolizi（糖炒栗子）开火事件（event_user(1)）
// 甩一颗栗子，抛物线砸向本行最前面那只老鼠所在的格子；落地后由 obj_tangchaolizi_bullet_effect 结算灼烧。
var _tgt = tc_target;
var _has_tgt = (_tgt != noone && instance_exists(_tgt) && _tgt.hp > 0);

// 落点格：有目标就砸它那一格（跑到场外也照样砸），没目标 → 射程最远格
var _col = _has_tgt ? _tgt.grid_col : min(grid_col + range, global.grid_cols - 1);
var _row = grid_row;

// 出膛口 = 锅口：精灵原点在锅底中心，锅口中心约在精灵坐标 (+1, -42)，
//   卡片按 1.8 倍画 → 世界坐标约 (+4, -74)
var _sx = x + 4;
var _sy = y - 74;

var _cell = get_world_position_from_grid(_col, _row);
var _tx = _has_tgt ? _tgt.x : _cell.x;
var _ty = _cell.y - 36;          // 贴图格子的视觉中线（地图贴图比逻辑网格高 36px）
var _dist = point_distance(_sx, _sy, _tx, _ty);

var _b = instance_create_depth(_sx, _sy, depth - 500, obj_tangchaolizi_bullet);
if (shape >= 2)      _b.sprite_index = spr_tangchaolizi_bullet_2;
else if (shape == 1) _b.sprite_index = spr_tangchaolizi_bullet_1;
else                 _b.sprite_index = spr_tangchaolizi_bullet;

_b.shape  = shape;
_b.damage = atk;
_b.row    = _row;
_b.col    = _col;
_b.sx = _sx;
_b.sy = _sy;
_b.tx = _tx;
_b.ty = _ty;
_b.T   = clamp(round(_dist / 20), 20, 46);     // 距离越远飞得越久（与蛋糕 / 融合栗子同一口径）
_b.arc = clamp(_dist * 0.42, 80, 300);         // 拱高随距离走

audio_play_sound(snd_throw, 0, 0);
