/// @description 切换音乐
if battle_music != new_battle_music{
audio_stop_sound(battle_music)
battle_music = new_battle_music
music_vol_applied = -1      // 新流要重新套一次音量
audio_play_sound(battle_music, 0, true)
}