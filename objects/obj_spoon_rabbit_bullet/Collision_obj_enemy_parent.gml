if (!hit_enemy)
{
    if (other.hp > 0 && row == other.grid_row && can_hit(target_type, other.target_type))
    {
        with (other)
        {
            audio_play_sound(snd_spoon_rabbit, 0, 0);
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
        
        instance_create_depth(other.x, other.y - 75, depth, obj_spoon_rabbit_bullet_effect);
        hit_enemy = true;
        hitted_enemy = other.id;
        instance_destroy();
    }
}
