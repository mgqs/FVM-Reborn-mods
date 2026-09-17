image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 1;
image_index = 0;
image_alpha = 0;
grid_col = 0;
grid_row = 0;
ghost_shape = 0;
weapon_id = "hades_scythe";
weapon_info = get_weapon_info(weapon_id);
ghost_shape = weapon_info.ghost_shape;

if (get_gem_index("ghost_strike_gem") != -1)
    ghost_shape = weapon_info.ghost_shape_impact[get_gem_level("ghost_strike_gem")];

switch (ghost_shape)
{
    case 0:
        sprite_index = spr_hades_scythe_effect;
        break;
    
    case 1:
        sprite_index = spr_hades_scythe_effect_1;
        break;
    
    case 2:
        sprite_index = spr_hades_scythe_effect_2;
        break;
}
