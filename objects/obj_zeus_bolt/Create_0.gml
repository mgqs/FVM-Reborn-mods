image_xscale = 1.6;
image_yscale = 1.6;
image_speed = 0;
parent_player = -4;
atk = 0;
cycle = 0;
grid_col = 0;
grid_row = 0;
flash_speed = 6;
attack_anim = 6;
timer = 0;
state = 0;
attack_timer = 0;
weapon_id = "zeus_bolt";
weapon_info = get_weapon_info(weapon_id);
atk = weapon_info.atk;
cycle = weapon_info.cycle;
bullet_amount = weapon_info.bullet_amount;
bullet_style = 0;
splash_ratio = 0;
fire_count = 0;
fire_cd = 25;

if (get_gem_index("zeus_shadow_gem") != -1)
{
    bullet_style = weapon_info.bullet_style_impact[get_gem_level("zeus_shadow_gem")];
    splash_ratio = weapon_info.splash_ratio_impact[get_gem_level("zeus_shadow_gem")] / 100;
}

if (get_gem_index("zeus_power_gem") != -1)
    atk = weapon_info.atk_impact[get_gem_level("zeus_power_gem")];

if (get_gem_index("zeus_anger_gem") != -1)
    bullet_amount = weapon_info.bullet_amount_impact[get_gem_level("zeus_anger_gem")];

bullet_shape = -4;

switch (bullet_style)
{
    case 0:
        bullet_shape = spr_zeus_bolt_bullet;
        break;
    
    case 1:
        bullet_shape = spr_zeus_bolt_bullet_1;
        break;
    
    case 2:
        bullet_shape = spr_zeus_bolt_bullet_2;
        break;
    
    case 3:
        bullet_shape = spr_zeus_bolt_bullet_3;
        break;
    
    case 4:
        bullet_shape = spr_zeus_bolt_bullet_4;
        break;
}

