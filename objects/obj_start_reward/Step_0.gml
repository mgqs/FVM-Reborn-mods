// obj_start_reward Step：悬停 + 点「领取 / 以后再说」
if (sr_done) exit;

// 创建出来先吃掉两帧：避免「点难度箭头那一下」连带把窗里的按钮也点了
if (sr_guard > 0) {
    sr_guard -= 1;
    exit;
}

var mx = mouse_x;
var my = mouse_y;

sr_hover = -1;
for (var _b = 0; _b < 2; _b++) {
    var _r = mod_tg_confirm_rect(_b);
    if (point_in_rectangle(mx, my, _r[0], _r[1], _r[2], _r[3])) sr_hover = _b;
}

if (mouse_check_button_pressed(mb_left)) {
    if (sr_hover == 0) {
        sr_done = true;
        if (difficulty_start_reward_grant(sr_diff)) {
            audio_play_sound(snd_button, 0, 0);
            // 不朽：金币 + 暖暖鸡 刚发完，紧接着弹三选一（沿用现有 obj_immortal_pick）
            if (global.play_mode == 0 && immortal_pick_pending() && !instance_exists(obj_immortal_pick)) {
                instance_create_depth(0, 0, -16000, obj_immortal_pick);
            }
        }
        instance_destroy();
    }
    else if (sr_hover == 1) {
        // 不领：一分不发，也不记「放弃」—— 下次切到这个难度还会再问
        sr_done = true;
        audio_play_sound(snd_button, 0, 0);
        instance_destroy();
    }
}
