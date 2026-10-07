// 开火：八方向射击
// shape0 / shape1：八方向各一发子弹，无反弹
// shape2：八方向基础 + 前后行各追加左右水平子弹
//   - 中路（八方向）子弹：可经 brazier / fire_god / jinniu 增幅（shape>=2 且同一行）
//   - 前后行追加子弹：不能穿火增幅（行号不同，碰撞条件不满足）

var _hittable = ["normal", "air", "invisible"];

var _bullet_spr = spr_youyu_god_bullet;
if (shape == 1) _bullet_spr = spr_youyu_god_bullet_1;
else if (shape >= 2) _bullet_spr = spr_youyu_god_bullet_2;

var _my_row = 0;
if (variable_instance_exists(self, "grid_row")) _my_row = grid_row;

var _muzzle_x = x + 35;
var _muzzle_y = y - 20;

// ===== 八方向各一发子弹（shape0/1/2 共有）=====
for (var _n = 0; _n < 8; _n++)
{
    var _angle = _n * 45;
    var _b = instance_create_depth(_muzzle_x, _muzzle_y, depth - 20, obj_youyu_god_bullet);
    _b.damage = atk;
    _b.base_atk = atk;
    _b.shape = shape;
    _b.target_id = noone;
    _b.hittable_types = _hittable;
    _b.move_x = lengthdir_x(_b.move_speed, _angle);
    _b.move_y = lengthdir_y(_b.move_speed, _angle);
    _b.image_angle = _angle;
    _b.sprite_index = _bullet_spr;
    _b.row = _my_row;
}

// ===== shape2：前后路各追加左右两发水平子弹 =====
if (shape >= 2)
{
    var _grid_size_y = 64;
    if (variable_global_exists("grid_cell_size_y")) _grid_size_y = global.grid_cell_size_y;

    // 前路（上一行）向右
    var _b_fr = instance_create_depth(_muzzle_x, _muzzle_y - _grid_size_y, depth - 20, obj_youyu_god_bullet);
    _b_fr.damage = atk;
    _b_fr.base_atk = atk;
    _b_fr.shape = shape;
    _b_fr.target_id = noone;
    _b_fr.hittable_types = _hittable;
    _b_fr.move_x = _b_fr.move_speed;
    _b_fr.move_y = 0;
    _b_fr.image_angle = 0;
    _b_fr.sprite_index = _bullet_spr;
    _b_fr.row = _my_row - 1;

    // 前路（上一行）向左
    var _b_fl = instance_create_depth(_muzzle_x, _muzzle_y - _grid_size_y, depth - 20, obj_youyu_god_bullet);
    _b_fl.damage = atk;
    _b_fl.base_atk = atk;
    _b_fl.shape = shape;
    _b_fl.target_id = noone;
    _b_fl.hittable_types = _hittable;
    _b_fl.move_x = -_b_fl.move_speed;
    _b_fl.move_y = 0;
    _b_fl.image_angle = 180;
    _b_fl.sprite_index = _bullet_spr;
    _b_fl.row = _my_row - 1;

    // 后路（下一行）向右
    var _b_br = instance_create_depth(_muzzle_x, _muzzle_y + _grid_size_y, depth - 20, obj_youyu_god_bullet);
    _b_br.damage = atk;
    _b_br.base_atk = atk;
    _b_br.shape = shape;
    _b_br.target_id = noone;
    _b_br.hittable_types = _hittable;
    _b_br.move_x = _b_br.move_speed;
    _b_br.move_y = 0;
    _b_br.image_angle = 0;
    _b_br.sprite_index = _bullet_spr;
    _b_br.row = _my_row + 1;

    // 后路（下一行）向左
    var _b_bl = instance_create_depth(_muzzle_x, _muzzle_y + _grid_size_y, depth - 20, obj_youyu_god_bullet);
    _b_bl.damage = atk;
    _b_bl.base_atk = atk;
    _b_bl.shape = shape;
    _b_bl.target_id = noone;
    _b_bl.hittable_types = _hittable;
    _b_bl.move_x = -_b_bl.move_speed;
    _b_bl.move_y = 0;
    _b_bl.image_angle = 180;
    _b_bl.sprite_index = _bullet_spr;
    _b_bl.row = _my_row + 1;
}

audio_play_sound(snd_shot, 0, 0);
