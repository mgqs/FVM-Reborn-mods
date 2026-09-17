if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

if (burnt == 1)
    sprite_index = spr_tiancheng_bullet_1;

x += move_speed;

if (target_row != -1)
{
    var target_y = global.grid_offset_y + (global.grid_cell_size_y * target_row);
    var transition_speed = 0.15;
    y = lerp(y, target_y, transition_speed);
    
    if (abs(y - target_y) < 30)
        row = target_row;
}

if (x > 2200 || y > 1200 || x < 0 || y < 0)
    instance_destroy();
