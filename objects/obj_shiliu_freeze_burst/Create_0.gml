// 石榴爆爆冰 —— 冰冻破裂特效（6 帧）
// 复用 spr_shiliu_freeze_effect；obj_unfreeze_effect 只播 5 帧（1..5），会漏掉末帧，
// 所以这里单独写一个按 sprite_get_number 全帧播放的对象。
image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 0;
timer = 0;
frame_speed = 4;   // 每 4 tick 换一帧
total_frames = sprite_get_number(sprite_index);
