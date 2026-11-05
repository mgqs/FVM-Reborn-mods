// obj_zhuzhuliaoliji_bullet 普通火盆（obj_brazier）过火 —— 子弹侧碰撞
// 2026-11-06 补：原来只挂了融合火盆（Collision_obj_ronghehuopen），普通火盆过不了火。
//   门禁与融合火盆一致：**只有「正后」那一发能过火**（can_burn 由 Other_11 按方向设），
//   同一座火盆只算一次（brazier_list 记 id），已点燃的（burnt != 0）不再重复。
if (!can_burn) exit;
if (ds_list_find_index(brazier_list, other.id) == -1 && burnt == 0 && row == other.grid_row)
{
    burnt += 1;
    damage = round(damage * other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
    image_xscale = 1.8;
    image_yscale = 1.8;
}
