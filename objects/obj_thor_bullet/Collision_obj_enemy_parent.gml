if (!hit_enemy)
{
    if (other.hp > 0 && row == other.grid_row && can_hit(target_type, other.target_type))
    {
        with (other)
        {
            audio_play_sound(snd_egg_bullet, 0, 0);
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
            
            if (ice_timer < 600)
                ice_timer = 600;
        }
        
        instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);
        hit_enemy = true;
        hitted_enemy = other.id;
        instance_destroy();
        
        var inst;
        if (sprite_index == spr_thor_bullet_2_s)
            inst = instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);
        else if (sprite_index == spr_thor_bullet_3_s)
            instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);
        else
            inst = instance_create_depth(x, y, depth, obj_thor_bullet_effect_1);
        
        var distance_x = other.x + global.grid_cell_size_x;
        var flight_time = 30;
        var total_distance_x = distance_x - x;
        var total_distance_y = 300;
        move_speed = total_distance_x / flight_time;
        cgravity = (2 * total_distance_y) / (flight_time * flight_time);
        cvspeed = (total_distance_y - (0 * cgravity * flight_time * flight_time)) / flight_time;
    }
}
