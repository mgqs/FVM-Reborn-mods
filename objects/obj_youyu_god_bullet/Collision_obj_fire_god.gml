// 火神增幅
if (can_burn && ds_list_find_index(brazier_list, other.id) == -1 && burnt == 0 && row == other.grid_row)
{
    burnt += 1;
    damage = round(damage * other.atk);
    bullet_fire_mult_up(id, other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
}
