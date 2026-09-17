// 切换静音状态
if (volume_type == "music") {
    if (global.music_volume > 0) {
        // 保存当前音量用于恢复
        global.music_volume_before_mute = global.music_volume;
        global.music_volume = 0;
    } else {
        // 恢复音量，默认为0.7
        global.music_volume = global.music_volume_before_mute > 0 ? global.music_volume_before_mute : 0.7;
    }
    
    // 应用音量
    audio_group_set_gain(music,global.music_volume,0)
	audio_group_set_gain(sound,global.sound_volume,0)
    
    // 保存设置
    ini_open("config.ini");
    ini_write_real("settings", "music_volume", global.music_volume);
    ini_close();
    
} else if (volume_type == "sound") {
    if (global.sound_volume > 0) {
        global.sound_volume_before_mute = global.sound_volume;
        global.sound_volume = 0;
    } else {
        global.sound_volume = global.sound_volume_before_mute > 0 ? global.sound_volume_before_mute : 0.7;
    }
	
	audio_group_set_gain(music,global.music_volume,0)
	audio_group_set_gain(sound,global.sound_volume,0)
    
    ini_open("config.ini");
    ini_write_real("settings", "sound_volume", global.sound_volume);
    ini_close();
}
audio_play_sound(snd_button,0,0)


