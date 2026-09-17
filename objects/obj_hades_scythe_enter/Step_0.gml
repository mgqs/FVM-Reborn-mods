if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
grid_col = 2;
grid_row = -2;
var pos = get_world_position_from_grid(grid_row, grid_col);
x = pos.x;
y = pos.y;
image_alpha = 1;

if (image_index >= (sprite_get_number(sprite_index) - 1))
{
    var inst = instance_create_depth(x, y, depth, obj_hades_scythe);
    instance_destroy();
}
