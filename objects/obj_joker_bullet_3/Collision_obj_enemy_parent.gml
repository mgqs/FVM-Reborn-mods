if (other.hp > 0 && row == other.grid_row && can_hit(target_type, other.target_type))
{
    if (other.hp <= damage)
    {
        if (other.special_ash)
        {
            var inst = instance_create_depth(other.x, other.y - 20, other.depth, obj_mouse_ash_death_3);
            inst.special_ash = true;
            inst.sprite_index = other.sprite_index;
            inst.image_index = other.image_index;
        }
        else
        {
            instance_create_depth(other.x, other.y - 20, other.depth, obj_mouse_ash_death_3);
        }
        
        instance_destroy(other);
    }
    else
    {
        with (other)
        {
            audio_play_sound(hit_sound, 0, false);
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
    }
    
    hitted_enemy = other.id;
    instance_create_depth(x, y, depth, obj_joker_bullet_effect_23);
    instance_destroy();
}
