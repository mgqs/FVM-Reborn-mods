// obj_xinggui_god_effect Create 事件
// 两种用法（同一个对象）：
//   ① 常驻光环（obj_xinggui_god 的 xg_halo）：spr_xinggui_god_effect / _1 / _2 / _3
//      —— 这四张精灵是「淡入 → 常亮 → 淡出 → 末帧全透明」的一次性脉冲，
//         **整段循环**会播到淡出段与全透明帧 = 用户 2026-11-13 报的「消失又出现」。
//         但**整段定格**又会让范围框彻底静止（2026-11-14 用户报的另一半）。
//         正解是「只在常亮段里循环」：调用方写
//             xg_loop_start = 3; xg_loop_end = 13;
//         第 13 帧与第 3 帧像素完全相同（四套精灵 MD5 全验过），右开区间循环不会跳帧。
//   ② 终转四角装饰：spr_xinggui_god_effect_3_full —— 10 帧全在常亮区间、没有空帧，整段循环即可
//         （调用方不写 xg_loop_* / xg_hold_frame，走 else 分支的整段循环）。
// 位置由 obj_xinggui_god 每帧写入（四角装饰创建后不再移动）。
// 缩放不要在这里写死：光环本体按「5*5 ÷ 精灵视觉框」换算，四角装饰按翻转后的 ±1.0 缩放。
xg_fx_speed   = 0.5;   // 播放速度（暂停时 Step 置 0，恢复时回到这个值）
xg_hold_frame = -1;    // >= 0：播到该帧就停住、不再循环（留给「真·一次性脉冲」用）
xg_loop_start = -1;    // 常亮段循环左界（含）；< 0 = 不启用
xg_loop_end   = -1;    // 常亮段循环右界（不含）；必须 > xg_loop_start
image_speed = xg_fx_speed;
