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
        }
        
        instance_create_depth(x, y, depth, obj_grilledlizardpult_bullet_effect);
        hit_enemy = true;
        hitted_enemy = other.id;
        instance_destroy();
    }
}
