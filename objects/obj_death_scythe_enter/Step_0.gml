if (global.is_paused)
    exit;

grid_col = 2;
grid_row = -2;
var pos = get_world_position_from_grid(grid_row, grid_col);
x = pos.x + 5;
y = pos.y;
image_alpha = 1;

// enter_last_frame < 0 表示该形态没有召唤段，直接落场
if (enter_last_frame < 0)
{
    instance_create_depth_define(x, y, depth, obj_death_scythe);
    instance_destroy();
    exit;
}

// 召唤段每帧停 3 tick，播完最后一帧就落地
if (timer >= (enter_last_frame + 1) * 3)
{
    instance_create_depth_define(x, y, depth, obj_death_scythe);
    instance_destroy();
    exit;
}

image_index = min(enter_last_frame, floor(timer / 3));
timer++;
