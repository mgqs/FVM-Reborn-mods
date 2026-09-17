var t_mid = -4;
var t_up = -4;
var t_down = -4;
var mx_mid = 99999;
var mx_up = 99999;
var mx_down = 99999;
var is_top_edge = grid_row == 0;
var is_bottom_edge = grid_row == (global.grid_rows - 1);

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

var px_mid = -1;
var px_up = -1;
var px_down = -1;

if (t_mid != -4)
{
    var e_spd = variable_instance_exists(t_mid, "move_speed") ? t_mid.move_speed : 0;
    var dist = t_mid.x - x;
    var ft = clamp(30 + ((dist / 1000) * 45), 30, 75);
    px_mid = t_mid.x - (e_spd * ft) - 50;
    
    if (px_mid < x)
        px_mid = x;
}

if (t_up != -4)
{
    var e_spd = variable_instance_exists(t_up, "move_speed") ? t_up.move_speed : 0;
    var dist = t_up.x - x;
    var ft = clamp(30 + ((dist / 1000) * 45), 30, 75);
    px_up = t_up.x - (e_spd * ft) - 50;
    
    if (px_up < x)
        px_up = x;
}

if (t_down != -4)
{
    var e_spd = variable_instance_exists(t_down, "move_speed") ? t_down.move_speed : 0;
    var dist = t_down.x - x;
    var ft = clamp(30 + ((dist / 1000) * 45), 30, 75);
    px_down = t_down.x - (e_spd * ft) - 50;
    
    if (px_down < x)
        px_down = x;
}

var fallback_x = x + 300;

if (px_mid != -1)
    fallback_x = px_mid;
else if (px_up != -1)
    fallback_x = px_up;
else if (px_down != -1)
    fallback_x = px_down;

var _lane_h = 110;

if (fire_mid)
{
    var final_x = (px_mid != -1) ? px_mid : fallback_x;
    scr_launch_bullet(x + 40, y - 75, y, grid_row, final_x, t_mid);
}

if (fire_up)
{
    if (is_top_edge)
    {
        var final_x = (px_mid != -1) ? px_mid : fallback_x;
        scr_launch_bullet(x + 20, y - 75, y, grid_row, final_x, t_mid);
    }
    else
    {
        var final_x = (px_up != -1) ? px_up : fallback_x;
        scr_launch_bullet(x + 40, y - 75 - _lane_h, y - _lane_h, grid_row - 1, final_x, t_up);
    }
}

if (fire_down)
{
    if (is_bottom_edge)
    {
        var final_x = (px_mid != -1) ? px_mid : fallback_x;
        scr_launch_bullet(x + 60, y - 75, y, grid_row, final_x, t_mid);
    }
    else
    {
        var final_x = (px_down != -1) ? px_down : fallback_x;
        scr_launch_bullet(x + 40, (y - 75) + _lane_h, y + _lane_h, grid_row + 1, final_x, t_down);
    }
}

audio_play_sound(snd_throw, 0, 0);

function scr_launch_bullet(arg0, arg1, arg2, arg3, arg4, arg5)
{
    var ft = clamp(30 + (((arg4 - x) / 1000) * 45), 30, 75);
    var inst = instance_create_depth(arg0, arg1, depth - 500, obj_ymir_bullet);
    
    if (shape == 1)
        inst.sprite_index = spr_ymir_bullet_1;
    
    if (shape == 2)
        inst.sprite_index = spr_ymir_bullet_2;
    
    if (shape == 3)
        inst.sprite_index = spr_ymir_bullet_3;
    
    inst.thrower_y = arg2;
    inst.row = arg3;
    inst.damage = atk;
    inst.shape = shape;
    inst.target_enemy = arg5;
    inst.has_target = arg5 != -4;
    var dist_x = arg4 - inst.x;
    var dist_y = 600;
    inst.move_speed = dist_x / ft;
    inst.cgravity = (2 * dist_y) / (ft * ft);
    inst.cvspeed = dist_y / ft;
}
