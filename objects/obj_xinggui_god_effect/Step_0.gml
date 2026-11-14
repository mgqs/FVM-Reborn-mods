// obj_xinggui_god_effect Step 事件
// 三种模式，优先级由上到下：
//   ① 暂停 → 停帧；
//   ② 循环窗口（xg_loop_start / xg_loop_end）→ 只在「常亮段」里循环；
//   ③ 定格帧（xg_hold_frame）→ 播到该帧就锁死；
//   ④ 都没有 → 交给 sprite 自身整段循环。
//
// 🔴 2026-11-14 用户报「星轨神 5*5 范围特效和贴图一样静止（其实是有动画的）」：
//   原来光环走的是 ③，写死 `xg_hold_frame = 10`，播到第 10 帧就 image_speed = 0 —— 永久静止。
//   当时的理由是「整段循环会播到 14~16 的淡出帧和 17 的全透明帧，看起来一闪一闪」。
//   两者其实可以同时满足：这四张光环精灵的结构都是
//       0~2 淡入 / 3~13 常亮 / 14~16 淡出 / 末帧全透明，
//   而且**第 13 帧与第 3 帧像素完全相同**（四套精灵都验过 MD5：shape0 AD8E7C54、
//   shape1 EB846758、shape2 9729E34A、shape3 A0815735）——
//   所以在 [3, 13) 里循环既不会闪、又保留了常亮段内部的呼吸/旋转动画。
//   循环边界写成「左闭右开」，image_index 一到 13 就拨回 3。
if (global.is_paused)
{
    image_speed = 0;
}
else if (xg_loop_end > xg_loop_start && xg_loop_start >= 0)
{
    image_speed = xg_fx_speed;
    if (image_index < xg_loop_start || image_index >= xg_loop_end)
        image_index = xg_loop_start;
}
else if (xg_hold_frame >= 0 && image_index >= xg_hold_frame)
{
    // 一次性脉冲播完淡入段后停在常亮帧，绝不再播到后面的淡出 / 全透明帧
    image_index = xg_hold_frame;
    image_speed = 0;
}
else
{
    image_speed = xg_fx_speed;
}
