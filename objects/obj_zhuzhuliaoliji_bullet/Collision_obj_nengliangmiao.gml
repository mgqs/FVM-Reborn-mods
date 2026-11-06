// obj_zhuzhuliaoliji_bullet 过火 —— 能量喵（子弹侧碰撞）
// 2026-11-06 补：工程里能让子弹「过火增伤」的来源一共 5 种，
//   融合火盆(ronghehuopen) / 普通火盆(brazier) / 火神(fire_god) / 金牛(jinniu) / 能量喵(nengliangmiao)。
//   这里补齐 能量喵，五样口径一致：
//     ① 只有「正后」那一发能过火（can_burn 由 Other_11 按方向设）
//     ② 同一座只算一次（brazier_list 记 id）、已点燃的（burnt != 0）不重复
//     ③ 同行才生效（row == other.grid_row）
if (!can_burn) exit;
if (ds_list_find_index(brazier_list, other.id) == -1 && burnt == 0 && row == other.grid_row)
{
    burnt += 1;
    damage = round(damage * other.atk / 100);
    bullet_fire_mult_up(id, other.atk / 100);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
    image_xscale = 1.8;
    image_yscale = 1.8;
}
