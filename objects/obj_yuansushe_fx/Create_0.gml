// obj_yuansushe_fx（元素蛇状态小特效：暴击闪、眩晕星、冰晶、中毒）
// 一次性播完就销毁；精灵由生成方当场指定（spr_yuansushe_fx_crit / _dizzy / _froze / _poison）。
//
// 🔴 image_speed 必须是 0，帧由本对象按 fx_frame_ticks 手动推：
//   这几张素材帧数差很多（crit 5 帧 / froze 6 帧 / dizzy 与 poison 20 帧），
//   用 image_speed = 1 播，5~6 帧的暴击闪和冰晶只有 0.08~0.1 秒，肉眼几乎看不到，
//   玩家就会以为「这次命中没出效果」。按帧数算停留时间才能让每种特效都看清。
image_speed = 0;
fx_timer = 0;
fx_frame_ticks = 3;   // 每帧停留多少 tick；生成方按特效类型覆盖（见 obj_yuansushe_bullet/Step_0）
fx_life = 0;          // 0 = 首次 Step 时按「精灵帧数 × fx_frame_ticks」自动算
fx_max_index = 0;
