// obj_xinggui_god_effect Create 事件
// 两种用法（同一个对象）：
//   ① 常驻光环（obj_xinggui_god 的 xg_halo）：spr_xinggui_god_effect / _1 / _2 / _3
//      —— 这四张精灵是「淡入 → 常亮 → 淡出 → 末帧全透明」的一次性脉冲，**不能循环**，
//         否则每播完一遍就整片消失再淡入 = 用户报的「消失又出现」。
//         由调用方写 xg_hold_frame = 10，播到第 10 帧（常亮段）就停住，特效一直亮着。
//   ② 终转四角装饰：spr_xinggui_god_effect_3_full —— 10 帧全在常亮区间、没有空帧，正常循环呼吸。
// 位置由 obj_xinggui_god 每帧写入（四角装饰创建后不再移动）。
// 缩放不要在这里写死：光环本体按「5*5 ÷ 精灵尺寸」换算，四角装饰按翻转后的 ±2.2 缩放。
xg_fx_speed   = 0.5;   // 播放速度（暂停时 Step 置 0，恢复时回到这个值）
xg_hold_frame = -1;    // >= 0：播到该帧就停住、不再循环（常驻光环用）；-1 = 正常循环
image_speed = xg_fx_speed;
