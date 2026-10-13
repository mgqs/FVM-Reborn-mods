if (kind == "fire" && ds_list_find_index(brazier_list, other.id) == -1
    && !burnt && center_row == other.grid_row)
{
    burnt = true;
    damage = round(damage * other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
}
