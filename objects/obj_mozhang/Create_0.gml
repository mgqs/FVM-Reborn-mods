event_inherited();
plant_id = "mozhang";
event_user(0);

if (shape == 0)
    sprite_index = spr_mozhang;
else if (shape == 1)
    sprite_index = spr_mozhang_1;
else if (shape == 2)
    sprite_index = spr_mozhang_2;

attack_anim = 0;
idle_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;

buffer_type = "sprayer";
buffer_type_2 = undefined;

buff_value = atk / 100;
buff_cells = [];
var radius = (shape >= 1) ? 2 : 1;
add_square(buff_cells, grid_col, grid_row, radius, buff_value);
add_row(buff_cells, grid_row, buff_value);
buff_cells_refreshed = false;

ds_list_add(global.buff_sources, id);
global.buff_dirty = true;
