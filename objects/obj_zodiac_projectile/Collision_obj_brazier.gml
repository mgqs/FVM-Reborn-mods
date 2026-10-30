if ((kind == "fire" || (kind == "star" && abs(move_y) < 0.001)) && ds_list_find_index(brazier_list, other.id) == -1
    && !burnt && center_row == other.grid_row)
{
    burnt = true;
    damage = round(damage * other.atk);
    // 焚寂马分裂波按 base_damage 生成，必须同步增幅，否则过火后的实际伤害没有提升
    if (kind == "fire") base_damage = round(base_damage * other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
}
