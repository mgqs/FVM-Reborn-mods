// obj_xinggui_god_effect Step 事件
// 暂停 → 停帧；常驻光环（xg_hold_frame >= 0）→ 播到常亮帧就锁定；
// 其余（终转四角装饰）→ 交给 sprite 自身循环。
if (global.is_paused)
{
    image_speed = 0;
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
