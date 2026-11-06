// obj_tunshilong_boom（吞噬龙 · 一转起死亡爆炸）Create 事件
// 本体实例 hp 归零被销毁后接过来：只负责把**本体素材尾部的爆炸段**播完。
//   素材 63 帧：待机 0~11（编辑器 1~12 帧）/ 吞噬消化 26~52（27~53 帧）/ 爆炸 53~62（54~63 帧）
//   sprite_index 由 obj_tunshilong 的 Destroy_0 按形态写入（spr_tunshilong / _1 / _2）
image_speed = 0;
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
// 卡牌本体在 obj_card_parent/Draw_0 里是按 1.8 倍画的，爆炸对象必须同比例，否则会「突然变小」
image_xscale = 1.8;
image_yscale = 1.8;

boom_first = 53;    // 爆炸段首帧（编辑器第 54 帧，绿色爆点）
boom_last  = 62;    // 爆炸段末帧（编辑器第 63 帧）
flash_speed = 3;    // 每 3 帧换一张 → 10 帧 ≈ 0.5 秒
t = 0;

hit_index = boom_first + 2;   // 播到第 3 张（视觉炸开）才结算伤害
hit_done  = false;
