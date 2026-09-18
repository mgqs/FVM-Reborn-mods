var t_mid = -4;
var t_up = -4;
var t_down = -4;
var mx_mid = 99999;
var mx_up = 99999;
var mx_down = 99999;

with (obj_enemy_parent)
{
    if (hp > 0 && can_target_on(other.target_type, target_type))
    {
        if (grid_row == other.grid_row && x < mx_mid)
        {
            mx_mid = x;
            t_mid = id;
        }
        else if (grid_row == (other.grid_row - 1) && x < mx_up)
        {
            mx_up = x;
            t_up = id;
        }
        else if (grid_row == (other.grid_row + 1) && x < mx_down)
        {
            mx_down = x;
            t_down = id;
        }
    }
}

var spr = spr_spoon_rabbit_bullet;
if (shape == 1)
    spr = spr_spoon_rabbit_bullet_1;
else if (shape >= 2)
    spr = spr_spoon_rabbit_bullet_2;

var _lane_h = global.grid_cell_size_y;

if (t_mid != -4)
{
    var enemy_x = t_mid.x;
    var enemy_speed = variable_instance_exists(t_mid, "move_speed") ? t_mid.move_speed : 0;
    var distance_x = enemy_x - x;
    var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
    var predicted_x = enemy_x - (enemy_speed * flight_time) - 70;
    if (predicted_x < x)
        predicted_x = x;

    var total_distance_x = predicted_x - x;
    var total_distance_y = 400;
    var ms = total_distance_x / flight_time;
    var cg = (2 * total_distance_y) / (flight_time * flight_time);
    var cv = total_distance_y / flight_time;

    var inst_mid = instance_create_depth(x, y - 160, depth - 45, obj_spoon_rabbit_bullet);
    inst_mid.damage = atk;
    inst_mid.row = grid_row;
    inst_mid.thrower_y = y;
    inst_mid.sprite_index = spr;
    inst_mid.move_speed = ms;
    inst_mid.cgravity = cg;
    inst_mid.cvspeed = cv;
    inst_mid.hit_enemy = false;
}

if (t_up != -4)
{
    var enemy_x = t_up.x;
    var enemy_speed = variable_instance_exists(t_up, "move_speed") ? t_up.move_speed : 0;
    var distance_x = enemy_x - x;
    var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
    var predicted_x = enemy_x - (enemy_speed * flight_time) - 70;
    if (predicted_x < x)
        predicted_x = x;

    var total_distance_x = predicted_x - x;
    var total_distance_y = 400;
    var ms = total_distance_x / flight_time;
    var cg = (2 * total_distance_y) / (flight_time * flight_time);
    var cv = total_distance_y / flight_time;

    var inst_up = instance_create_depth(x, y - 160 - _lane_h, depth, obj_spoon_rabbit_bullet);
    inst_up.damage = atk;
    inst_up.row = grid_row - 1;
    inst_up.thrower_y = y - _lane_h;
    inst_up.sprite_index = spr;
    inst_up.move_speed = ms;
    inst_up.cgravity = cg;
    inst_up.cvspeed = cv;
    inst_up.hit_enemy = false;
}

if (t_down != -4)
{
    var enemy_x = t_down.x;
    var enemy_speed = variable_instance_exists(t_down, "move_speed") ? t_down.move_speed : 0;
    var distance_x = enemy_x - x;
    var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
    var predicted_x = enemy_x - (enemy_speed * flight_time) - 70;
    if (predicted_x < x)
        predicted_x = x;

    var total_distance_x = predicted_x - x;
    var total_distance_y = 400;
    var ms = total_distance_x / flight_time;
    var cg = (2 * total_distance_y) / (flight_time * flight_time);
    var cv = total_distance_y / flight_time;

    var inst_down = instance_create_depth(x, (y - 160) + _lane_h, depth - 90, obj_spoon_rabbit_bullet);
    inst_down.damage = atk;
    inst_down.row = grid_row + 1;
    inst_down.thrower_y = y + _lane_h;
    inst_down.sprite_index = spr;
    inst_down.move_speed = ms;
    inst_down.cgravity = cg;
    inst_down.cvspeed = cv;
    inst_down.hit_enemy = false;
}
