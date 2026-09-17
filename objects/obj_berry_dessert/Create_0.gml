event_inherited();
plant_id = "berry_dessert";
event_user(0);
sprite_index = spr_berry_dessert;

if (shape == 1)
    sprite_index = spr_berry_dessert_1;
else if (shape == 2)
    sprite_index = spr_berry_dessert_2;

attack_anim = 0;
idle_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
buffer_type = "tracker";
buff_value = atk / 100;
buff_shape = (shape >= 1) ? "5x5" : "3x3";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;
ds_list_add(global.buff_sources, id);
global.buff_dirty = true;
