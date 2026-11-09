image_xscale = 1.6;
image_yscale = 1.6;
image_speed = 0;
parent_player = noone;
atk = 0;
cycle = 0;
grid_col = 0;
grid_row = 0;
flash_speed = 6;
attack_anim = 6;
timer = 0;
state = CARD_STATE.IDLE;
attack_timer = 0;
weapon_id = "poseidon_dart_gun";
weapon_info = get_weapon_info(weapon_id);
atk = weapon_info.atk;
cycle = weapon_info.cycle;
bullet_count = 2;
bullet_style = 0;
splash_ratio = 0;
fire_count = 0;
fire_cd = 0;

if (get_gem_index("poseidon_dart_gun_gem_1") != -1)
{
    bullet_style = weapon_info.bullet_style_impact[get_gem_level("poseidon_dart_gun_gem_1")];
    splash_ratio = get_gem_info("poseidon_dart_gun_gem_1").splash_ratio[get_gem_level("poseidon_dart_gun_gem_1")];
}

if (get_gem_index("poseidon_dart_gun_gem_2") != -1)
    atk = weapon_info.atk_impact[get_gem_level("poseidon_dart_gun_gem_2")];

if (get_gem_index("poseidon_dart_gun_gem_3") != -1)
{
    bullet_count = get_gem_info("poseidon_dart_gun_gem_3").bullet_count[get_gem_level("poseidon_dart_gun_gem_3")];
    atk += get_gem_info("poseidon_dart_gun_gem_3").atk_bonus[get_gem_level("poseidon_dart_gun_gem_3")];
}

if (get_gem_index("poseidon_dart_gun_gem_4") != -1)
    cycle = weapon_info.cycle_impact[get_gem_level("poseidon_dart_gun_gem_4")];

bullet_shape = -4;

switch (bullet_style)
{
    case 0:
        bullet_shape = spr_takoyaki_bullet;
        break;
    
    case 1:
        bullet_shape = spr_poseidon_bullet_1;
        break;
    
    case 2:
        bullet_shape = spr_poseidon_bullet_2;
        break;
    
    case 3:
        bullet_shape = spr_poseidon_bullet_3;
        break;
    
    case 4:
        bullet_shape = spr_poseidon_bullet_4;
        break;
}

