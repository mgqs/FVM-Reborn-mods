if (global.menu_screen) {
    if (not audio_is_playing(menu_music)) {
        // 停止可能存在的暂停实例
        audio_stop_sound(menu_music);
        // 从头开始播放新实例
        audio_play_sound(menu_music, 0, 0);
    }
} else {
    // 离开主界面时停止音乐
    if (audio_is_playing(menu_music) or audio_is_paused(menu_music)) {
        audio_stop_sound(menu_music);
    }
}