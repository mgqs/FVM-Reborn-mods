// 鲁班神使 - 用户事件1（开火，一次铺满整轮）
// 往前：2 条折返轨迹各 1 发，伤害直接吃注册表 atk（表里已是压缩后的单发值）
// 轨迹：① 卡片→(9,1)→(9,4)→卡片  ② 卡片→(9,7)→(9,4)→卡片
// 终转后路：第 1 列往上、第 2 列往下，各 1 发单程；每列原有 2 发压成 1 发 → damage = atk * 2 / 3
// 命中：三转起 20% 概率附加河豚毒素（= 定身 1.5 秒）
//
// 最右列只扫 **第 10 列**（combat_max_col = 敌人出生点列，也是 BOSS 常驻的格子）。
// 第 9 列（地图最右一格）不生成轨迹：那一列的老鼠由其他卡片处理，
// 双列并存会让同一只老鼠吃到两组伤害，观感上也像"多了一条莫名其妙的弹道"。
var _top_row = 0;
var _mid_row = clamp(3, 0, global.grid_rows - 1);
var _bot_row = clamp(6, 0, global.grid_rows - 1);

var _right_col = combat_max_col();

var _bullet_spr = spr_gongjiang_god_bullet;
if (shape == 1) _bullet_spr = spr_gongjiang_god_bullet_1;
else if (shape == 2) _bullet_spr = spr_gongjiang_god_bullet_2;
else if (shape == 3) _bullet_spr = spr_gongjiang_god_bullet_3;

var _pin_chance = (shape >= 1) ? pin_chance : 0;

var _wp_top = get_world_position_from_grid(_right_col, _top_row);
// 第1行路径点位于该格中心线的上顶点，而不是格子中心。
_wp_top.y -= global.grid_cell_size_y / 2;
var _wp_bot = get_world_position_from_grid(_right_col, _bot_row);
var _wp_mid = get_world_position_from_grid(_right_col, _mid_row);

// 两条折返路线：① 走第 1 行汇到中行  ② 走第 7 行汇到中行
var _routes = [[_wp_top.x, _wp_top.y], [_wp_bot.x, _wp_bot.y]];

// 出弹口 = 自身位置 + 炮口偏移（正数向右 / 向上）：贴图的炮筒在右中偏上，所以要往右上抬
var _muzzle_dx = 30;
var _muzzle_dy = -50;
var _mx = x + _muzzle_dx;
var _my = y + _muzzle_dy;

for (var _ri = 0; _ri < 2; _ri++)
{
    var _b = instance_create_depth(_mx, _my, depth - 500, obj_gongjiang_god_bullet_horizontal);
    _b.damage = atk;
    _b.move_speed = bullet_speed;
    _b.damage_type = "normal";
    _b.target_type = "air";
    _b.hittable_types = get_hittable_enemy_types("air");
    _b.shape = shape;
    _b.origin_card_id = id;
    _b.start_x = _mx;
    _b.start_y = _my;
    _b.wp1_x = _routes[_ri][0];
    _b.wp1_y = _routes[_ri][1];
    _b.wp2_x = _wp_mid.x;
    _b.wp2_y = _wp_mid.y;
    _b.sprite_index = _bullet_spr;
    _b.pin_chance = _pin_chance;
    _b.pin_duration = pin_duration;
}

// 终转：后路第 1 列往上、第 2 列往下，各 1 发单程
if (shape == 3)
{
    var _v_top = global.grid_offset_y - 40;
    var _v_bot = global.grid_offset_y + global.grid_cell_size_y * global.grid_rows + 40;

    for (var _c = 0; _c <= 1; _c++)
    {
        var _going_down = (_c == 1);
        var _vb = instance_create_depth(get_world_position_from_grid(_c, _mid_row).x,
            _going_down ? _v_top : _v_bot, depth - 500, obj_gongjiang_god_bullet_vertical);
        _vb.damage = atk * 2 / 3;
        _vb.move_speed = bullet_speed;
        _vb.vertical_dir = _going_down ? 1 : -1;
        _vb.col = _c;
        _vb.shape = shape;
        _vb.damage_type = "normal";
        _vb.target_type = "air";
        _vb.hittable_types = get_hittable_enemy_types("air");
        _vb.sprite_index = _bullet_spr;
        _vb.image_angle = _going_down ? 270 : 90;
        _vb.pin_chance = _pin_chance;
        _vb.pin_duration = pin_duration;
    }
}

audio_play_sound(snd_shot, 0, 0);
