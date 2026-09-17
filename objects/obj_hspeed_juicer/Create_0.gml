event_inherited();
plant_id = "hspeed_juicer";
event_user(0);
sprite_index = spr_hspeed_juicer;

switch (shape)
{
    case 0:
        sprite_index = spr_hspeed_juicer;
        break;
    
    case 1:
        sprite_index = spr_hspeed_juicer_1;
        break;
    
    case 2:
        sprite_index = spr_hspeed_juicer_2;
        break;
}

attack_anim = 0;
idle_anim = 7;
flash_speed = 6;
plant_type = "normal";
is_slowdown = false;
buffer_type = "sprayer";
buff_value = atk / 100;
buff_shape = (shape >= 2) ? "5x5" : "3x3";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;
