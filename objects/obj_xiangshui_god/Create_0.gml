event_inherited();
plant_id = "xiangshui_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_xiangshui_god;
else if (shape == 1)
    sprite_index = spr_xiangshui_god_1;
else if (shape == 2)
    sprite_index = spr_xiangshui_god_2;
else if (shape == 3)
    sprite_index = spr_xiangshui_god_2;

attack_anim = 0;
idle_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
buffer_type = "tracker";
buff_value = atk / 100;

if (shape < 2)
{
    buff_shape = "3x3";
}
else if (shape < 3)
{
    buff_shape = "5x5";
}
else
{
    buff_shape = "5x5";
}

buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;

ds_list_add(global.buff_sources, id);
global.buff_dirty = true;
