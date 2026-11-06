// obj_dangdanghu 投出糕饼（event_user(1)）
var _col = min(grid_col + range, global.grid_cols);
if (target_instance != noone && instance_exists(target_instance)) _col = target_instance.grid_col;
var _cell = get_world_position_from_grid(_col, grid_row);

var _b = instance_create_depth(x + 10, y - 60, depth - 500, obj_dangdanghu_bullet);
_b.sx = x + 10;
_b.sy = y - 60;
_b.tx = _cell.x;
_b.ty = _cell.y;
_b.row = grid_row;
_b.col = _col;
_b.damage = atk;
_b.shape = shape;
_b.T = clamp(round(24 + abs(_cell.x - x) / 12), 20, 50);
_b.arc = 110;
_b.tick_gap = round(tick_seconds * 60);
_b.tick_count = tick_count;
if (shape == 1)      _b.sprite_index = spr_dangdanghu_bullet_1;
else if (shape == 2) _b.sprite_index = spr_dangdanghu_bullet_2;

global.audio.play(snd_throw, 0, 0);
