// obj_doumaobang Step 事件
// 前摇结束 → 召唤猫猫（从第 0 列左沿出生，二转上中下三行各 1 只）→ 本体消失（瞬发类同白羊座）。
if (global.is_paused) exit;

event_inherited();

if (spawned) exit;

windup_t++;
if (windup_t < windup_frames) exit;

spawned = true;

// 2026-11-08 用户口径：二转「召唤 3 只」= **上中下三行各 1 只**（不是本行 3 只错开发车）
var _rows = (shape >= 2) ? [grid_row - 1, grid_row, grid_row + 1] : [grid_row];

// 出生点：**第 0 列左沿**（cat_start_cells = 0，可调），出来之后沿自己那一行向右冲。
//   原来是在卡片坐标 (x, y-36) 直接生成 → 看着像猫从逗猫棒身上蹦出来，2026-11-08 改掉。
var _start_x = global.grid_offset_x + cat_start_cells * global.grid_cell_size_x;

for (var _i = 0; _i < array_length(_rows); _i++)
{
    var _r = _rows[_i];
    if (_r < 0 || _r >= global.grid_rows) continue;

    var _c = instance_create_depth(_start_x, y - cat_art_up + (_r - grid_row) * global.grid_cell_size_y,
                                   depth - 500, obj_doumaobang_cat);
    _c.grid_row      = _r;
    _c.damage        = atk;
    _c.move_speed    = 10;
    _c.target_type   = cat_target_type;
    _c.hittable_types = get_hittable_enemy_types(cat_target_type);
    _c.hit_underground = (shape >= 1);   // 1 转起「对地下有效」：鼹鼠能撞飞

    if (shape == 1)      _c.sprite_index = spr_doumaobang_cat_1;
    else if (shape == 2) _c.sprite_index = spr_doumaobang_cat_2;
}

audio_play_sound(snd_throw, 0, 0);
instance_destroy();
