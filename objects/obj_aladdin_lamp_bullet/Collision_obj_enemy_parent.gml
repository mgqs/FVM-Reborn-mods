if (ds_list_find_index(hitted_enemy, other.id) == -1)
{
    if (other.hp > 0)
    {
        with (other)
        {
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
            audio_play_sound(snd_fire_hit, 0, 0);
        }
        
        ds_list_add(hitted_enemy, other.id);
        
        if (splash_ratio > 0)
        {
            hit_row = other.grid_row;
            hit_col = other.grid_col;
            var _sd = round(damage * splash_ratio);
            
            with (obj_enemy_parent)
            {
                if (hp > 0 && ds_list_find_index(other.hitted_enemy, id) == -1 && grid_row >= (other.hit_row - 1) && grid_row <= (other.hit_row + 1) && grid_col >= (other.hit_col - 1) && grid_col <= (other.hit_col + 1))
                {
                    damage_amount = _sd;
                    damage_type = other.damage_type;
                    event_user(0);
                    audio_play_sound(snd_fire_hit, 0, 0);
                    ds_list_add(other.hitted_enemy, id);
                }
            }
        }
    }
}
