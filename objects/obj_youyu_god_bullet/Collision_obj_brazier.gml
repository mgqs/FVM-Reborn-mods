// 火盆增幅：shape2及以上的中路子弹可被点燃
// 条件：shape >= 2、未燃烧过、同一行、同一火盆只增幅一次
if (shape >= 2 && ds_list_find_index(brazier_list, other.id) == -1 && burnt == 0 && row == other.grid_row)
{
    burnt += 1;
    damage = round(damage * other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
}
