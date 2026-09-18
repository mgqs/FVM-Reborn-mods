if (ds_list_find_index(hitted_enemy, other.id) == -1)
{
    if (other.hp > 0 && can_hit(target_type, other.target_type))
    {
        with (other)
        {
            audio_play_sound(hit_sound, 0, 0);

            if (ice_timer < 600)
                ice_timer = 600;

            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }

        ds_list_add(hitted_enemy, other.id);
    }
}
