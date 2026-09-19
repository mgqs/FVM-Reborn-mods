audio_play_sound(snd_throw, 0, 0);

for (var i = 0; i < 2; i++)
{
    var spawn_x = x + (i == 0 ? -60 : -20);
    var spawn_y = y + (i == 0 ? -145 : -105);
    var inst = instance_create_depth(spawn_x, spawn_y, depth - 500, obj_shuangyu_bullet);
    inst.damage = atk;
    inst.original_damage = atk;
    inst.row = grid_row;
    inst.thrower_y = y;
    
    if (target_instance != -4 && instance_exists(target_instance))
    {
        var enemy_x = target_instance.x;
        var enemy_y = target_instance.y;
        var enemy_speed = target_instance.move_speed;
        var distance_x = enemy_x - inst.x;
        var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
        var predicted_x = enemy_x - (enemy_speed * flight_time) - 50;
        
        if (predicted_x < x)
            predicted_x = x;
        
        var total_distance_x = predicted_x - inst.x;
        var total_distance_y = 600;
        inst.move_speed = total_distance_x / flight_time;
        inst.cgravity = (2 * total_distance_y) / (flight_time * flight_time);
        inst.cvspeed = (total_distance_y - (0 * inst.cgravity * flight_time * flight_time)) / flight_time;
        inst.target_enemy = target_instance;
        inst.has_target = true;
    }
    else
    {
        inst.move_speed = 8;
        inst.cvspeed = 6;
        inst.cgravity = 0.2;
        inst.has_target = false;
        inst.target_enemy = -4;
    }
    
    inst.hit_enemy = false;
    inst.splashed = false;
    inst.shape = shape;
}
