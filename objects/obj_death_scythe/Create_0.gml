image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 0;
atk = 0;
cycle = 0;
bullet_amount = 0;
bullet_shape = 0;
ghost_shape = 0;
grid_col = 2;
grid_row = -2;
var pos = get_world_position_from_grid(grid_row, grid_col);
x = pos.x;
y = pos.y;
x += 5;
flash_speed = 5;

// 动画分段（默认值，会被下面的形态档位覆盖）
//   区段含义：idle 从 idle_start 起循环 idle_anim 帧
//             attack 从 attack_start 起播 attack_anim 帧
idle_start   = 0;
idle_anim    = 25;
attack_start = 25;
attack_anim  = 10;
fire_start_tick = 15;
bullet_spr = spr_death_scythe_bullet_00;

timer = 0;
state = 0;
attack_timer = 0;
is_attacking = false;
cooldown = 0;
weapon_id = "death_scythe";
weapon_info = get_weapon_info(weapon_id);
atk = weapon_info.atk;
cycle = weapon_info.cycle;
bullet_amount = weapon_info.bullet_amount;
bullet_shape = weapon_info.bullet_shape;
ghost_shape = weapon_info.ghost_shape;
target_enemy = -4;

if (get_gem_index("death_scythe_gem_1") != -1)
{
    atk = weapon_info.atk_impact[get_gem_level("death_scythe_gem_1")];
    ghost_shape = weapon_info.ghost_shape_impact[get_gem_level("death_scythe_gem_1")];
}

if (get_gem_index("death_scythe_gem_2") != -1)
    cycle = weapon_info.cycle_impact[get_gem_level("death_scythe_gem_2")];

if (get_gem_index("death_scythe_gem_3") != -1)
    bullet_amount = weapon_info.bullet_amount_impact[get_gem_level("death_scythe_gem_3")];

if (get_gem_index("death_scythe_gem_4") != -1)
{
    bullet_shape = weapon_info.bullet_shape_impact[get_gem_level("death_scythe_gem_4")];
    atk += weapon_info.atk_bonus_impact[get_gem_level("death_scythe_gem_4")];
}

// ---- 外观与子弹形态只看「死神意志」(gem_4) 的星级 ----
//   未装备    : spr_death_scythe_00 / _bullet_00   （出场特效 0..6，站立 7..23）
//   0-5  星   : spr_death_scythe_11 / _bullet_11   （出场特效 0..13，站立 14..70）
//   6-9  星   : spr_death_scythe_22 / _bullet_22   （无出场，站立 0..34）
//   10-11 星  : spr_death_scythe_33 / _bullet_33   （出场特效 0..13，站立 14..70）
//   12-13 星  : spr_death_scythe_44 / _bullet_44   （无出场，站立 0..34）
//   14-15 星  : spr_death_scythe_55 / _bullet_55   （无出场，站立 0..34）
// 出场特效段由 obj_death_scythe_enter 单独播放，所以主精灵的 idle 一律从 Standing 段开头起。
var _will_lv = -1;
if (get_gem_index("death_scythe_gem_4") != -1)
    _will_lv = get_gem_level("death_scythe_gem_4");

if (_will_lv < 0)
{
    sprite_index = spr_death_scythe_00;
    bullet_spr   = spr_death_scythe_bullet_00;
    idle_start   = 7;   idle_anim = 11;
    attack_start = 18;  attack_anim = 5;
    fire_start_tick = 5;
}
else if (_will_lv <= 5)
{
    sprite_index = spr_death_scythe_11;
    bullet_spr   = spr_death_scythe_bullet_11;
    idle_start   = 14;  idle_anim = 39;
    attack_start = 53;  attack_anim = 10;
    fire_start_tick = 15;
}
else if (_will_lv <= 9)
{
    sprite_index = spr_death_scythe_22;
    bullet_spr   = spr_death_scythe_bullet_22;
    idle_start   = 0;   idle_anim = 10;
    attack_start = 17;  attack_anim = 18;
    fire_start_tick = 30;
}
else if (_will_lv <= 11)
{
    sprite_index = spr_death_scythe_33;
    bullet_spr   = spr_death_scythe_bullet_33;
    idle_start   = 14;  idle_anim = 39;
    attack_start = 53;  attack_anim = 10;
    fire_start_tick = 15;
}
else if (_will_lv <= 13)
{
    sprite_index = spr_death_scythe_44;
    bullet_spr   = spr_death_scythe_bullet_44;
    idle_start   = 0;   idle_anim = 10;
    attack_start = 25;  attack_anim = 9;
    fire_start_tick = 14;
}
else
{
    sprite_index = spr_death_scythe_55;
    bullet_spr   = spr_death_scythe_bullet_55;
    idle_start   = 0;   idle_anim = 10;
    attack_start = 25;  attack_anim = 9;
    fire_start_tick = 14;
}

image_index = idle_start;
