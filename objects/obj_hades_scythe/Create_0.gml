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
flash_speed = 5;
attack_anim = 16;
idle_anim = 20;
timer = 0;
state = 0;
attack_timer = 0;
is_attacking = false;
cooldown = 0;
weapon_id = "hades_scythe";
weapon_info = get_weapon_info(weapon_id);
atk = weapon_info.atk;
cycle = weapon_info.cycle;
bullet_amount = weapon_info.bullet_amount;
bullet_shape = weapon_info.bullet_shape;
ghost_shape = weapon_info.ghost_shape;
target_enemy = -4;

if (get_gem_index("ghost_strike_gem") != -1)
{
    atk = weapon_info.atk_impact[get_gem_level("ghost_strike_gem")];
    bullet_shape = weapon_info.bullet_shape_impact[get_gem_level("ghost_strike_gem")];
    ghost_shape = weapon_info.ghost_shape_impact[get_gem_level("ghost_strike_gem")];
}

if (get_gem_index("ghost_pact_gem") != -1)
    bullet_amount = weapon_info.bullet_amount_impact[get_gem_level("ghost_pact_gem")];

if (get_gem_index("ghost_spark_gem") != -1)
    cycle = weapon_info.cycle_impact[get_gem_level("ghost_spark_gem")];

switch (ghost_shape)
{
    case 0:
        sprite_index = spr_hades_scythe;
        break;
    
    case 1:
        sprite_index = spr_hades_scythe_1;
        break;
    
    case 2:
        sprite_index = spr_hades_scythe_2;
        break;
}

