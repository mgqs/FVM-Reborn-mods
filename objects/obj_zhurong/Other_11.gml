var inst = instance_create_depth(x + 20, y - 105, depth - 45, obj_zhurong_bullet);
audio_play_sound(snd_throw, 0, 0);
inst.damage = atk;
inst.row = grid_row;
inst.thrower_y = y;
var _max = (shape >= 1) ? 5 : 4;

if (target_instance != -4 && instance_exists(target_instance))
{
    var target_col = target_instance.grid_col;
    var max_col = grid_col + _max;
    var final_col = min(target_col, max_col);
    var grid_pos = get_world_position_from_grid(final_col, grid_row);
    var target_x = grid_pos.x;
    var target_y = grid_pos.y;
    var distance_x = target_x - inst.x;
    var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
    var total_distance_x = distance_x;
    var total_distance_y = 600;
    inst.move_speed = total_distance_x / flight_time;
    inst.cgravity = (2 * total_distance_y) / (flight_time * flight_time);
    inst.cvspeed = total_distance_y / flight_time;
    inst.target_col = final_col;
    inst.target_x = target_x;
    inst.target_y = target_y;
    inst.has_target = true;
}
else
{
    var final_col = min(grid_col + _max, 9);
    var grid_pos = get_world_position_from_grid(final_col, grid_row);
    var target_x = grid_pos.x;
    var target_y = grid_pos.y;
    var distance_x = target_x - inst.x;
    var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
    var total_distance_x = distance_x;
    var total_distance_y = 600;
    inst.move_speed = total_distance_x / flight_time;
    inst.cgravity = (2 * total_distance_y) / (flight_time * flight_time);
    inst.cvspeed = total_distance_y / flight_time;
    inst.target_col = final_col;
    inst.target_x = target_x;
    inst.target_y = target_y;
    inst.has_target = true;
}

inst.hit_enemy = false;
inst.shape = shape;

if (shape == 1)
    inst.sprite_index = spr_zhurong_bullet_1;
else if (shape == 2)
    inst.sprite_index = spr_zhurong_bullet_2;
else if (shape == 3)
    inst.sprite_index = spr_zhurong_bullet_3;
