image_speed = 0;
image_index = 10;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.8;
image_yscale = 1.8;

shape = 0;
grid_col = -1;
grid_row = -1;

boom_damage = 500;
boom_cross  = false;
boom_type   = "ash";

burn_total  = 50;
burn_cross  = false;
burn_type   = "physical";

drunk_time = 0;
drunk_mult = 1.5;

t = 0;
fired = false;

if (shape == 1) sprite_index = spr_guihuajiu_1;
else if (shape >= 2) sprite_index = spr_guihuajiu_2;
else sprite_index = spr_guihuajiu;
