if battle_music != new_battle_music{
	audio_stop_sound(battle_music)
	battle_music = new_battle_music
}

if audio_is_paused(battle_music) and not global.is_paused{
	audio_resume_sound(battle_music)
}
if not audio_is_playing(battle_music) and not global.is_paused{
	audio_play_sound(battle_music,0,true)
}
if audio_is_playing(battle_music) and global.is_paused{
	audio_pause_sound(battle_music)
}

// audio_create_stream 建的流属于 audiogroup_default，不吃 music 组的 audio_group_set_gain，
// 必须单独跟随总音乐音量；普通音乐资源本身在 music 组，这里再设一次会二次衰减，所以只处理流。
if boss_music_is_stream(battle_music) && music_vol_applied != global.music_volume{
	audio_sound_gain(battle_music, global.music_volume, 0)
	music_vol_applied = global.music_volume
}