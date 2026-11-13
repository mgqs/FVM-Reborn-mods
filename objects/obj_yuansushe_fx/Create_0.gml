// obj_yuansushe_fx（元素蛇状态小特效：暴击闪、眩晕星、冰晶）
// 一次性播完就销毁；精灵由生成方当场指定（spr_yuansushe_fx_crit / _dizzy / _froze / _poison / _slow）。
image_speed = 1;
fx_timer = 0;
fx_life  = 90;      // 兜底寿命（帧），防止某个精灵帧数异常时特效不消失
