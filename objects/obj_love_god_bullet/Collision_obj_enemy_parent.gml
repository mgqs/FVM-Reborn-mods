var _damage = damage;

if (other.hp > 0 && row == other.grid_row && can_hit(target_type, other.target_type))
{
    with (other)
    {
        if (other.burnt == 1)
            audio_play_sound(snd_fire_hit, 0, 0);
        else
            audio_play_sound(hit_sound, 0, 0);
        
        damage_amount = other.damage;
        damage_type = other.damage_type;
        event_user(0);
    }
    
    if (burnt == 0)
    {
        var inst = instance_create_depth(x, y, depth, obj_coffeecup_bullet_effect);
        inst.sprite_index = spr_love_god_bullet_0s;
    }
    else if (burnt == 1)
    {
        var inst = instance_create_depth(x + 25, y, depth, obj_fire_bullet_effect);
        inst.sprite_index = spr_love_god_bullet_3s;
    }
    
    instance_destroy();
}
