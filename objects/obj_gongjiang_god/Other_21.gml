// 鲁班神使 - 用户事件2（备用开火，与用户事件1一致）
// 最右列只扫第 10 列（敌人出生点 / BOSS 站位），不再生成第 9 列轨迹。详见 Other_11 的说明。
var _top_row = 0;
var _mid_row = clamp(3, 0, global.grid_rows - 1);
var _bot_row = clamp(6, 0, global.grid_rows - 1);

var _right_cols = [combat_max_col()];
var _inst = noone;
var _inst2 = noone;

var _bullet_spr = spr_gongjiang_god_bullet;
if (shape == 1) _bullet_spr = spr_gongjiang_god_bullet_1;
else if (shape == 2) _bullet_spr = spr_gongjiang_god_bullet_2;
else if (shape == 3) _bullet_spr = spr_gongjiang_god_bullet_3;

var _dmg_mul = (shape >= 2) ? 5 : 4;

var _poison_spr = -1;
var _poison_chance = 0;
if (shape == 1) { _poison_spr = spr_gongjiang_god_effect_1_1; _poison_chance = 0.25; }
else if (shape == 2) { _poison_spr = spr_gongjiang_god_effect_2_2; _poison_chance = 0.25; }
else if (shape == 3) { _poison_spr = spr_gongjiang_god_effect_3_2; _poison_chance = 0.30; }

var _pin_chance = (shape >= 1) ? pin_chance : 0;

for (var _ci = 0; _ci < array_length(_right_cols); _ci++)
{
    var _right_col = _right_cols[_ci];
    if (_ci > 0 && _right_col == _right_cols[0]) continue;   // grid_cols 异常时不重复生成

    var _wp_top = get_world_position_from_grid(_right_col, _top_row);
    // 第1行路径点位于该格中心线的上顶点，而不是格子中心。
    _wp_top.y -= global.grid_cell_size_y / 2;
    var _wp_mid = get_world_position_from_grid(_right_col, _mid_row);
    var _wp_bot = get_world_position_from_grid(_right_col, _bot_row);

    if (fire_dir1)
    {
        _inst = instance_create_depth(x, y, depth - 500, obj_gongjiang_god_bullet_horizontal);
        _inst.damage = atk * _dmg_mul;
        _inst.move_speed = bullet_speed;
        _inst.damage_type = "normal";
        _inst.target_type = "all";
        _inst.hittable_types = get_hittable_enemy_types("all");
        _inst.shape = shape;
        _inst.origin_card_id = id;
        _inst.start_x = x;
        _inst.start_y = y;
        _inst.wp1_x = _wp_top.x;
        _inst.wp1_y = _wp_top.y;
        _inst.wp2_x = _wp_mid.x;
        _inst.wp2_y = _wp_mid.y;
        _inst.sprite_index = _bullet_spr;
        _inst.pin_chance = _pin_chance;
        _inst.pin_duration = pin_duration;
        _inst.poison_chance = _poison_chance;
        _inst.poison_spr = _poison_spr;
    }

    if (fire_dir2)
    {
        _inst2 = instance_create_depth(x, y, depth - 500, obj_gongjiang_god_bullet_horizontal);
        _inst2.damage = atk * _dmg_mul;
        _inst2.move_speed = bullet_speed;
        _inst2.damage_type = "normal";
        _inst2.target_type = "all";
        _inst2.hittable_types = get_hittable_enemy_types("all");
        _inst2.shape = shape;
        _inst2.origin_card_id = id;
        _inst2.start_x = x;
        _inst2.start_y = y;
        _inst2.wp1_x = _wp_bot.x;
        _inst2.wp1_y = _wp_bot.y;
        _inst2.wp2_x = _wp_mid.x;
        _inst2.wp2_y = _wp_mid.y;
        _inst2.sprite_index = _bullet_spr;
        _inst2.pin_chance = _pin_chance;
        _inst2.pin_duration = pin_duration;
        _inst2.poison_chance = _poison_chance;
        _inst2.poison_spr = _poison_spr;
    }
}

if (shape == 3)
{
    for (var _c = 0; _c <= 1; _c++)
    {
        var _col_pos = get_world_position_from_grid(_c, _mid_row);

        var _up = instance_create_depth(_col_pos.x, _col_pos.y, depth - 500, obj_gongjiang_god_bullet_vertical);
        _up.damage = atk * _dmg_mul;
        _up.move_speed = bullet_speed;
        _up.vertical_dir = -1;
        _up.col = _c;
        _up.shape = shape;
        _up.damage_type = "normal";
        _up.target_type = "all";
        _up.hittable_types = get_hittable_enemy_types("all");
        _up.sprite_index = _bullet_spr;
        _up.image_angle = 90;
        _up.pin_chance = _pin_chance;
        _up.pin_duration = pin_duration;
        _up.poison_chance = _poison_chance;
        _up.poison_spr = _poison_spr;

        var _down = instance_create_depth(_col_pos.x, _col_pos.y, depth - 500, obj_gongjiang_god_bullet_vertical);
        _down.damage = atk * _dmg_mul;
        _down.move_speed = bullet_speed;
        _down.vertical_dir = 1;
        _down.col = _c;
        _down.shape = shape;
        _down.damage_type = "normal";
        _down.target_type = "all";
        _down.hittable_types = get_hittable_enemy_types("all");
        _down.sprite_index = _bullet_spr;
        _down.image_angle = 270;
        _down.pin_chance = _pin_chance;
        _down.pin_duration = pin_duration;
        _down.poison_chance = _poison_chance;
        _down.poison_spr = _poison_spr;
    }
}

if (fire_dir1 || fire_dir2) audio_play_sound(snd_shot, 0, 0);
