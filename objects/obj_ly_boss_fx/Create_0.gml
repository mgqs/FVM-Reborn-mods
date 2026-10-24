// 通用龙渊 BOSS 特效/演出播放器：由创建者调用 longyuan_boss_fx_start() 启动
ly_kind = "";
ly_anims = {};
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_hit = false;
fx_kind = "";
fx_rate = 5;
fx_loop = false;
fx_loop_after = true;
fx_next_action = "";
fx_ready = false;
image_speed = 0;  // 动画完全由 longyuan_clip_* 驱动
timer = 0;
