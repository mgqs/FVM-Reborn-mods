audio_stop_sound(battle_music)
// 回收本场战斗创建的 BOSS 随机音乐流（audio_create_stream 建的流必须显式销毁）
boss_music_stream_free_all()