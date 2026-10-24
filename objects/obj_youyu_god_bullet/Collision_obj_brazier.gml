// 火盆增幅：只有中路（0°/180°）子弹可被点燃（shape1 起）
// 条件：子弹自身 can_burn、未燃烧过、同一行、同一火盆只增幅一次
if (can_burn && ds_list_find_index(brazier_list, other.id) == -1 && burnt == 0 && row == other.grid_row)
{
    burnt += 1;
    damage = round(damage * other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
}
