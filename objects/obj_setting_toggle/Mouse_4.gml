// 切换状态
state = !state;
global.audio.play(snd_button,0,0)

// 抽卡版和欧皇版互斥，并统一保存为 play_mode。
if (config_key == "play_mode_gacha" && state) {
    with (obj_setting_toggle) {
        if (config_key == "play_mode_lucky" || config_key == "play_mode_gift") state = false;
    }
}
if (config_key == "play_mode_lucky" && state) {
    with (obj_setting_toggle) {
        if (config_key == "play_mode_gacha" || config_key == "play_mode_gift") state = false;
    }
}
if (config_key == "play_mode_gift" && state) {
    with (obj_setting_toggle) {
        if (config_key == "play_mode_gacha" || config_key == "play_mode_lucky") state = false;
    }
}
// 海克斯模式与其它三种玩法互斥（v0.5：海克斯玩法只在该模式存在）
if (config_key == "play_mode_hex" && state) {
    with (obj_setting_toggle) {
        if (config_key == "play_mode_gacha" || config_key == "play_mode_lucky" || config_key == "play_mode_gift") state = false;
    }
}
// 保存到配置文件
if (config_key != "") {
    ini_open("config.ini");
    if (config_key == "play_mode_gacha" || config_key == "play_mode_lucky" || config_key == "play_mode_gift" || config_key == "play_mode_hex") {
        // 模式号：抽卡 1 / 欧皇 2 / 礼盒 3 / 海克斯 4，关掉写 0
        var _mode_num = 0;
        if (config_key == "play_mode_gacha") _mode_num = 1;
        else if (config_key == "play_mode_lucky") _mode_num = 2;
        else if (config_key == "play_mode_gift") _mode_num = 3;
        else if (config_key == "play_mode_hex") _mode_num = 4;

        if (state) ini_write_real("settings", "play_mode", _mode_num);
        else ini_write_real("settings", "play_mode", 0);
    } else {
        ini_write_real("settings", config_key, state);
    }
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
else if (config_key == "play_mode_gacha"){
    global.play_mode = state ? 1 : 0;
}
else if (config_key == "play_mode_lucky"){
    global.play_mode = state ? 2 : 0;
}
else if (config_key == "play_mode_gift"){
    global.play_mode = state ? 3 : 0;
}
else if (config_key == "play_mode_hex"){
    // 进出海克斯模式：本局词条一律作废（docs 1.2.2）
    global.play_mode = state ? 4 : 0;
    hex_reset_run();
}
if (config_key == "play_mode_gift" || config_key == "play_mode_gacha" || config_key == "play_mode_lucky") {
    random_gift_sync_unlock();
    // 切换玩法模式后同步整理卡组（确保礼盒卡的增减立即生效）
    if (variable_global_exists("selected_deck") && ds_exists(global.selected_deck, ds_type_list)) {
        random_gift_prepare_selected_deck();
    }
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
