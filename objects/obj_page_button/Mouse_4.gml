// 执行按钮动作
if (action == "prev_page") {
    with (obj_config_menu) {
        keybind_page = max(0, keybind_page - 1);
        current_settings = noone; // 强制重建页面
    }
} else if (action == "next_page") {
    with (obj_config_menu) {
        keybind_page = min(total_keybind_pages - 1, keybind_page + 1);
        current_settings = noone; // 强制重建页面
    }
}
audio_play_sound(snd_button,0,0)