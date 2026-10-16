if (global.is_paused) exit;
if (!fx_ready) exit;  // 未启动前不播放

// 按本地计时器驱动当前动作的子图帧
longyuan_clip_frame(timer, fx_rate, fx_loop);

// 非循环动作播完：切换到后续动作，或销毁
if (!fx_loop && longyuan_clip_done(timer, fx_rate)) {
    if (fx_next_action != "") {
        var _na = fx_next_action;
        fx_next_action = "";
        longyuan_clip_set(_na);
        timer = 0;
        fx_loop = fx_loop_after;
    }
    else {
        instance_destroy();
        exit;
    }
}

timer++;
