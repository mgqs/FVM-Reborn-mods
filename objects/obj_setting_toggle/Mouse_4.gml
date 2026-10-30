// 切换状态
state = !state;
global.audio.play(snd_button,0,0)

// ══════════ 玩法模式（抽卡 / 欧皇 / 随机礼盒 / 海克斯）：四选一，严格互斥 ══════════
// 任一模式被打开时，其余三个开关一律关掉；关掉当前模式则回到 0（普通）。
// 全局只有一个 global.play_mode，所有读写都走 play_mode_apply()，不会再出现
// 「两个开关同时亮、只有后点的那个生效」的情况。
var _mode_num = play_mode_of_key(config_key);
if (_mode_num > 0) {
    if (state) {
        with (obj_setting_toggle) {
            if (id != other.id && play_mode_of_key(config_key) > 0) state = false;
        }
        play_mode_apply(_mode_num);
    } else {
        // 关掉当前模式 = 回到普通玩法；顺手把可能残留亮着的同类开关一起关掉
        with (obj_setting_toggle) {
            if (play_mode_of_key(config_key) > 0) state = false;
        }
        play_mode_apply(0);
    }
    exit;   // 玩法键到此结束，后面的通用开关逻辑不适用
}

// 保存到配置文件（非玩法开关）
if (config_key != "") {
    ini_open("config.ini");
    ini_write_real("settings", config_key, state);
    ini_close();
}

// 应用设置（如果需要立即生效）
if (config_key == "screen_shake") {
    global.screen_shake = state;
} else if (config_key == "screen_flash") {
    global.screen_flash = state;
}
else if (config_key == "fullscreen") {
    global.fullscreen = state;
	window_set_fullscreen(global.fullscreen)
}
else if (config_key == "replace_placement"){
	global.replace_placement = state
}
else if (config_key == "quick_placement"){
	global.quick_placement = state
}
else if (config_key == "card_hpbar"){
	global.card_hpbar = state
}
else if (config_key == "enemy_hpbar"){
	global.enemy_hpbar = state
}
else if (config_key == "tex_fliter"){
	global.tex_fliter = state
	gpu_set_tex_filter(global.tex_fliter)
}
else if (config_key == "difficulty"){
	global.difficulty = state
}
else if (config_key == "borderless_window"){
	global.borderless_window = state
	window_enable_borderless_fullscreen(global.borderless_window)
}
else if (config_key == "lose_focus_pause"){
	global.lose_focus_pause = state
}
else if (config_key == "ui_anim"){
	global.ui_anim = state ? 1 : 0
}
