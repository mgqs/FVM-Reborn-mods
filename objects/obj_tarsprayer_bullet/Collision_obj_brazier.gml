// 焦油喷壶「过火」：火盆 / 金牛 / 火神 三个热源同一套口径
//   · 同排、同一热源只点一次（brazier_list 由子弹 Create 重建，池复用天然复位）
//   · 喷头动画（前 12 帧）播完才点燃，避免刚出枪口就变火弹
//   · 点燃后换成火焰贴图并放大一圈，与火盆的视觉一致
if (ds_exists(brazier_list, ds_type_list) && ds_list_find_index(brazier_list, other.id) == -1
    && burnt == 0 && row == other.grid_row && timer >= 4 * 3 && !disabled)
{
    burnt += 1;
    damage = round(damage * other.atk);
    ds_list_add(brazier_list, other.id);
    audio_play_sound(snd_bullet_burnt, 0, 0);
    sprite_index = spr_fire_tarsprayer_bullet;
    image_xscale = 1.8;
    image_yscale = 1.8;
}
