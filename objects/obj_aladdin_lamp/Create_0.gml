image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 0;
atk = 0;
cycle = 0;
bullet_amount = 0;
bullet_trace = 0;
bullet_shape = 0;
ghost_shape = 0;
splash_ratio = 0;
grid_col = 2;
grid_row = -2;
var pos = get_world_position_from_grid(grid_row, grid_col);
x = pos.x + 5;
y = pos.y;
flash_speed = 5;
attack_anim = 13;
idle_anim = 16;
timer = 0;
state = CARD_STATE.IDLE;
attack_timer = 0;
is_attacking = false;
cooldown = 0;
fire_dir = 0;
fire_phase = 0;
fire_wave = 0;
weapon_id = "aladdin_lamp";
weapon_info = get_weapon_info(weapon_id);
atk = weapon_info.atk;
cycle = weapon_info.cycle;
bullet_amount = weapon_info.bullet_amount;
bullet_shape = weapon_info.bullet_shape;
ghost_shape = weapon_info.ghost_shape;
target_enemy = -4;

if (get_gem_index("aladdin_lamp_gem_5") != -1)
{
    atk = weapon_info.atk_impact_enhanced[get_gem_level("aladdin_lamp_gem_5")];
    ghost_shape = weapon_info.ghost_shape_impact[get_gem_level("aladdin_lamp_gem_5")];
}
else if (get_gem_index("aladdin_lamp_gem_1") != -1)
{
    atk = weapon_info.atk_impact[get_gem_level("aladdin_lamp_gem_1")];
    ghost_shape = weapon_info.ghost_shape_impact[get_gem_level("aladdin_lamp_gem_1")];
}

if (get_gem_index("aladdin_lamp_gem_2") != -1)
    cycle = weapon_info.cycle_impact[get_gem_level("aladdin_lamp_gem_2")];

if (get_gem_index("aladdin_lamp_gem_3") != -1)
{
    bullet_amount = weapon_info.bullet_amount_impact[get_gem_level("aladdin_lamp_gem_3")];
    bullet_trace = weapon_info.bullet_trace_impact[get_gem_level("aladdin_lamp_gem_3")];
}

if (get_gem_index("aladdin_lamp_gem_4") != -1)
{
    bullet_shape = weapon_info.bullet_shape_impact[get_gem_level("aladdin_lamp_gem_4")];
    splash_ratio = weapon_info.splash_ratio_impact[get_gem_level("aladdin_lamp_gem_4")];
}

switch (ghost_shape)
{
    case 0:
        sprite_index = spr_aladdin_lamp;
        break;
    
    case 1:
        sprite_index = spr_aladdin_lamp_1;
        break;
    
    case 2:
        sprite_index = spr_aladdin_lamp_2;
        break;
}

