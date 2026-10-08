// 开火：八方向射击
// shape0 / shape1：八方向各一发子弹，无反弹
// shape2：八方向基础 + 前后行各追加左右水平子弹（共12发）
// shape3：进一步追加前前行/后后行水平+垂直子弹 + 前后行斜向子弹（共22发）
//   - 中路（八方向）子弹：可经 brazier / fire_god / jinniu 增幅（shape>=2 且同一行）
//   - 其余行子弹：不能穿火增幅（行号不同，碰撞条件不满足）

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

// ===== shape3：追加10发子弹，总计22发 =====
// shape2已有12发，追加：
//   前行斜向2发（右上45°、左上135°）
//   后行斜向2发（右下315°、左下225°）
//   前前行3发（右0°、左180°、上90°）
//   后后行3发（右0°、左180°、下270°）
if (shape >= 3)
{
    var _gy = _grid_size_y;
    var _gy2 = _grid_size_y * 2;

    // --- 前行斜向（y - 1行）---
    var _b_fur = instance_create_depth(_muzzle_x, _muzzle_y - _gy, depth - 20, obj_youyu_god_bullet);
    _b_fur.damage = atk;
    _b_fur.base_atk = atk;
    _b_fur.shape = shape;
    _b_fur.target_id = noone;
    _b_fur.hittable_types = _hittable;
    _b_fur.move_x = lengthdir_x(_b_fur.move_speed, 45);
    _b_fur.move_y = lengthdir_y(_b_fur.move_speed, 45);
    _b_fur.image_angle = 45;
    _b_fur.sprite_index = _bullet_spr;
    _b_fur.row = _my_row - 1;

    var _b_ful = instance_create_depth(_muzzle_x, _muzzle_y - _gy, depth - 20, obj_youyu_god_bullet);
    _b_ful.damage = atk;
    _b_ful.base_atk = atk;
    _b_ful.shape = shape;
    _b_ful.target_id = noone;
    _b_ful.hittable_types = _hittable;
    _b_ful.move_x = lengthdir_x(_b_ful.move_speed, 135);
    _b_ful.move_y = lengthdir_y(_b_ful.move_speed, 135);
    _b_ful.image_angle = 135;
    _b_ful.sprite_index = _bullet_spr;
    _b_ful.row = _my_row - 1;

    // --- 后行斜向（y + 1行）---
    var _b_bdr = instance_create_depth(_muzzle_x, _muzzle_y + _gy, depth - 20, obj_youyu_god_bullet);
    _b_bdr.damage = atk;
    _b_bdr.base_atk = atk;
    _b_bdr.shape = shape;
    _b_bdr.target_id = noone;
    _b_bdr.hittable_types = _hittable;
    _b_bdr.move_x = lengthdir_x(_b_bdr.move_speed, 315);
    _b_bdr.move_y = lengthdir_y(_b_bdr.move_speed, 315);
    _b_bdr.image_angle = 315;
    _b_bdr.sprite_index = _bullet_spr;
    _b_bdr.row = _my_row + 1;

    var _b_bdl = instance_create_depth(_muzzle_x, _muzzle_y + _gy, depth - 20, obj_youyu_god_bullet);
    _b_bdl.damage = atk;
    _b_bdl.base_atk = atk;
    _b_bdl.shape = shape;
    _b_bdl.target_id = noone;
    _b_bdl.hittable_types = _hittable;
    _b_bdl.move_x = lengthdir_x(_b_bdl.move_speed, 225);
    _b_bdl.move_y = lengthdir_y(_b_bdl.move_speed, 225);
    _b_bdl.image_angle = 225;
    _b_bdl.sprite_index = _bullet_spr;
    _b_bdl.row = _my_row + 1;

    // --- 前前行（y - 2行）：右、左、上 ---
    var _b_ffr = instance_create_depth(_muzzle_x, _muzzle_y - _gy2, depth - 20, obj_youyu_god_bullet);
    _b_ffr.damage = atk;
    _b_ffr.base_atk = atk;
    _b_ffr.shape = shape;
    _b_ffr.target_id = noone;
    _b_ffr.hittable_types = _hittable;
    _b_ffr.move_x = _b_ffr.move_speed;
    _b_ffr.move_y = 0;
    _b_ffr.image_angle = 0;
    _b_ffr.sprite_index = _bullet_spr;
    _b_ffr.row = _my_row - 2;

    var _b_ffl = instance_create_depth(_muzzle_x, _muzzle_y - _gy2, depth - 20, obj_youyu_god_bullet);
    _b_ffl.damage = atk;
    _b_ffl.base_atk = atk;
    _b_ffl.shape = shape;
    _b_ffl.target_id = noone;
    _b_ffl.hittable_types = _hittable;
    _b_ffl.move_x = -_b_ffl.move_speed;
    _b_ffl.move_y = 0;
    _b_ffl.image_angle = 180;
    _b_ffl.sprite_index = _bullet_spr;
    _b_ffl.row = _my_row - 2;

    var _b_ffu = instance_create_depth(_muzzle_x, _muzzle_y - _gy2, depth - 20, obj_youyu_god_bullet);
    _b_ffu.damage = atk;
    _b_ffu.base_atk = atk;
    _b_ffu.shape = shape;
    _b_ffu.target_id = noone;
    _b_ffu.hittable_types = _hittable;
    _b_ffu.move_x = 0;
    _b_ffu.move_y = -_b_ffu.move_speed;
    _b_ffu.image_angle = 90;
    _b_ffu.sprite_index = _bullet_spr;
    _b_ffu.row = _my_row - 2;

    // --- 后后行（y + 2行）：右、左、下 ---
    var _b_bbr = instance_create_depth(_muzzle_x, _muzzle_y + _gy2, depth - 20, obj_youyu_god_bullet);
    _b_bbr.damage = atk;
    _b_bbr.base_atk = atk;
    _b_bbr.shape = shape;
    _b_bbr.target_id = noone;
    _b_bbr.hittable_types = _hittable;
    _b_bbr.move_x = _b_bbr.move_speed;
    _b_bbr.move_y = 0;
    _b_bbr.image_angle = 0;
    _b_bbr.sprite_index = _bullet_spr;
    _b_bbr.row = _my_row + 2;

    var _b_bbl = instance_create_depth(_muzzle_x, _muzzle_y + _gy2, depth - 20, obj_youyu_god_bullet);
    _b_bbl.damage = atk;
    _b_bbl.base_atk = atk;
    _b_bbl.shape = shape;
    _b_bbl.target_id = noone;
    _b_bbl.hittable_types = _hittable;
    _b_bbl.move_x = -_b_bbl.move_speed;
    _b_bbl.move_y = 0;
    _b_bbl.image_angle = 180;
    _b_bbl.sprite_index = _bullet_spr;
    _b_bbl.row = _my_row + 2;

    var _b_bbd = instance_create_depth(_muzzle_x, _muzzle_y + _gy2, depth - 20, obj_youyu_god_bullet);
    _b_bbd.damage = atk;
    _b_bbd.base_atk = atk;
    _b_bbd.shape = shape;
    _b_bbd.target_id = noone;
    _b_bbd.hittable_types = _hittable;
    _b_bbd.move_x = 0;
    _b_bbd.move_y = _b_bbd.move_speed;
    _b_bbd.image_angle = 270;
    _b_bbd.sprite_index = _bullet_spr;
    _b_bbd.row = _my_row + 2;
}

audio_play_sound(snd_shot, 0, 0);
