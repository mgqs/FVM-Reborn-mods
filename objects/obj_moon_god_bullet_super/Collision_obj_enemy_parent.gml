if (other.hp > 0 && target_enemy == other.id && can_hit(target_type, other.target_type))
{
    with (other)
    {
        audio_play_sound(hit_sound, 0, 0);
        damage_amount = other.damage;
        damage_type = other.damage_type;
        event_user(0);
    }
    
    instance_create_depth(x, y, depth, obj_takoyaki_bullet_effect);
    var _x = x;
    var _y = y;
    var _range = 250;
    var splash_ratio = 0.75;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && point_distance(x, y, _x, _y) < _range && can_hit(other.target_type, target_type))
        {
            damage_amount = other.damage * splash_ratio;
            damage_type = other.damage_type;
            event_user(0);
        }
    }
    
    instance_destroy();
}
