if (ds_list_find_index(brazier_list, other.id) == -1 && burnt == 0 && row == other.grid_row)
{
    burnt += 1;
    damage = round(damage * other.atk / 100);
    // 焚寂马分裂波按 base_damage 生成，必须同步增幅，否则过火后的实际伤害没有提升
    // （与 obj_brazier / 火神 / 金牛 / 融合火盆同口径；能量喵 atk 存 ×100，要 /100）
    if (kind == "fire") base_damage = round(base_damage * other.atk / 100);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
    image_xscale = 1.8;
    image_yscale = 1.8;
}
