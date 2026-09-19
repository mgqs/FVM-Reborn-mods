if (other.hp > 0)
{
    if (ds_list_find_index(hit_enemies, other.id) == -1)
    {
        ds_list_add(hit_enemies, other.id);
        
        with (other)
        {
            audio_play_sound(hit_sound, 0, 0);
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
        }
    }
}
