if (other.hp > 0 && target_enemy == other.id && can_hit(target_type, other.target_type))
{
    with (other)
    {
        audio_play_sound(hit_sound, 0, 0);
        damage_amount = other.damage;
        damage_type = other.damage_type;
        event_user(0);
    }
    
    var stun_chance = 0;
    
    if (bullet_shape == 0)
        stun_chance = 15;
    else if (bullet_shape == 1 || bullet_shape == 2)
        stun_chance = 30;
    
    if (random(100) < stun_chance)
    {
        if (other.stun_timer < 240)
            other.stun_timer = 240;
    }
    
    instance_create_depth(x, y, depth, obj_power_god_bullet_effect);
    instance_destroy();
}
