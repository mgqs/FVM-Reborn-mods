if (other.hp > 0 && row == other.grid_row && can_hit(target_type, other.target_type))
{
    instance_create_depth(x, y, depth, obj_tianxie_bullet_effect);
    var _hit_x = x;
    var _row = row;
    var _damage = damage;
    var _damage_type = damage_type;
    
    with (obj_enemy_parent)
    {
        if (hp > 0 && grid_row == _row)
        {
            if (x >= (_hit_x - 30) && x <= (_hit_x + 400))
            {
                damage_amount = _damage;
                damage_type = _damage_type;
                event_user(0);
                audio_play_sound(hit_sound, 0, 0);
            }
        }
    }
    
    instance_destroy();
}
