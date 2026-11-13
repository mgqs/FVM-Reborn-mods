// obj_shiliu_ash_fx —— 老鼠被石榴碾死时的碎冰特效
// 素材 spr_shiliu_ash_effect：15 帧、89x133、原点 (46,100)。
// 要求（用户口径）：老鼠死亡后**只播这一张**，不播老鼠自己的死亡动画、也不叠加其它灰烬特效。
//
// 用独立对象而不是复用 obj_mouse_ash_death：后者是「灰烬」的完整生命周期
// （life 90 → image_index 14 定格 → 淡出），它的 `special_ash` / `timer` 逻辑会把动画冻在末帧，
// 石榴要的是完整播一遍碎冰。
image_speed   = 0;
image_index   = 0;
frame_timer   = 0;
frame_speed   = 4;                 // 每 4 tick 一帧 → 15 帧共 60 tick（1 秒）
image_xscale  = 1.4;
image_yscale  = 1.4;

if (!sprite_exists(sprite_index)) instance_destroy();
