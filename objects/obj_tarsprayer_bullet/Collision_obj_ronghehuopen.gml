// obj_tarsprayer_bullet · 融合火盆过火（判定 / 增幅 / 冰化都在 scripts/ronghehuopen_pass_fire）
ronghehuopen_pass_fire(id, other);
// 点燃后与火盆 / 金牛 / 火神 表现统一：换成火焰贴图（2 转冰化由脚本自己换冰弹，这里不覆盖）
if (burnt == 1 && other.shape < 2 && sprite_index != spr_ronghehuopen_ice_bullet) {
    sprite_index = spr_fire_tarsprayer_bullet;
}
