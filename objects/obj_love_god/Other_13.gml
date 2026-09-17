var middle_y = y - 75;
var row_height = 100;
var inst_middle = instance_create_depth(x + 40, middle_y, depth - 500, obj_love_god_bullet_super);
inst_middle.damage = 6 * atk;
inst_middle.move_speed = 8;
inst_middle.row = grid_row;
inst_middle.target_row = grid_row;
var inst_up = instance_create_depth(x + 40, middle_y, depth - 500, obj_love_god_bullet_super);
inst_up.damage = 6 * atk;
inst_up.move_speed = 8;
inst_up.row = grid_row;

if ((grid_row - 1) >= 0)
{
    inst_up.target_row = grid_row - 1;
}
else
{
    inst_up.target_row = grid_row;
    inst_up.x -= 20;
}

inst_up.start_y = middle_y;
var inst_down = instance_create_depth(x + 40, middle_y, depth - 500, obj_love_god_bullet_super);
inst_down.damage = 6 * atk;
inst_down.move_speed = 8;
inst_down.row = grid_row;

if ((grid_row + 1) < global.grid_rows)
{
    inst_down.target_row = grid_row + 1;
}
else
{
    inst_down.target_row = grid_row;
    inst_down.x -= 20;
}

inst_down.start_y = middle_y;
