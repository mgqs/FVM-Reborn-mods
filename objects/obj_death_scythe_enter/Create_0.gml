image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 0;        // 手动推进，因为各形态召唤段长度不同
image_index = 0;
image_alpha = 0;
grid_col = 0;
grid_row = 0;
ghost_shape = 0;
weapon_id = "death_scythe";
weapon_info = get_weapon_info(weapon_id);
ghost_shape = weapon_info.ghost_shape;

if (get_gem_index("death_scythe_gem_1") != -1)
    ghost_shape = weapon_info.ghost_shape_impact[get_gem_level("death_scythe_gem_1")];

// 出场直接播主形态精灵自带的「召唤聚合」段（appear），播完再落地成 obj_death_scythe：
//   未装备 : spr_death_scythe_00 的 0..9   （10 帧）
//   0-5    : spr_death_scythe_11 的 0..27  （28 帧）
//   6-9    : spr_death_scythe_22 的 0..27  （28 帧）
//   10-11  : spr_death_scythe_33 的 0..27  （28 帧）
//   12-13  : spr_death_scythe_44 的 0..27  （28 帧）
//   14-15  : spr_death_scythe_55 的 0..27  （28 帧）
var _will_lv = -1;
if (get_gem_index("death_scythe_gem_4") != -1)
    _will_lv = get_gem_level("death_scythe_gem_4");

enter_last_frame = -1;   // -1 表示不需要播召唤段

if (_will_lv < 0)
{
    sprite_index = spr_death_scythe_00;
    enter_last_frame = 9;
}
else if (_will_lv <= 5)
{
    sprite_index = spr_death_scythe_11;
    enter_last_frame = 27;
}
else if (_will_lv <= 9)
{
    sprite_index = spr_death_scythe_22;
    enter_last_frame = 27;
}
else if (_will_lv <= 11)
{
    sprite_index = spr_death_scythe_33;
    enter_last_frame = 27;
}
else if (_will_lv <= 13)
{
    sprite_index = spr_death_scythe_44;
    enter_last_frame = 27;
}
else
{
    sprite_index = spr_death_scythe_55;
    enter_last_frame = 27;
}
timer = 0;
