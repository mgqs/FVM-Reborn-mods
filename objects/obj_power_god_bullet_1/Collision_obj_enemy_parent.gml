if (other.hp > 0 && target_enemy == other.id && can_hit(target_type, other.target_type))
{
    with (other)
    {
        audio_play_sound(hit_sound, 0, 0);
        
        if (hp > other.damage)
        {
            hp -= other.damage;
            event_user(0);
        }
        else
        {
            if (special_ash)
            {
                var inst = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                inst.special_ash = true;
                inst.sprite_index = sprite_index;
                inst.image_index = image_index;
            }
            else
            {
                instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
            }
            
            instance_destroy();
        }
    }
    
    var stun_chance = (bullet_shape == 0) ? 15 : 30;
    
    if (random(100) < stun_chance)
    {
        if (other.stun_timer < 240)
            other.stun_timer = 240;
    }
    
    instance_create_depth(x, y, depth, obj_power_god_bullet_effect);
    instance_destroy();
}
