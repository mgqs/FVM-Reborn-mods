// 焚寂马 / 星星兔（五方向星弹都算）过金牛座均被强化；
// 星星兔的星弹与火盆同口径（kind == "star"）也吃金牛增幅。
// 2026-11-09 用户口径：星星兔改为**全路可过火**，不再只限水平那一发。
if ((kind == "fire" || kind == "star")
    && ds_list_find_index(brazier_list, other.id) == -1
    && !burnt && center_row == other.grid_row)
{
    burnt = true;
    damage = round(damage * other.atk);
    bullet_fire_mult_up(id, other.atk);
    // 焚寂马分裂波按 base_damage 生成，必须同步增幅，否则过火后的实际伤害没有提升
    if (kind == "fire") base_damage = round(base_damage * other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
}
