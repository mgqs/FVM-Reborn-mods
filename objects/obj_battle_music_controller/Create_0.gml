battle_music = global.level_data.pre_music
new_battle_music = battle_music
// 本场是否已抽过「BOSS 随机音乐」。抽过就不再重抽，保证精英波起一直播到通关。
music_picked = false
// 本场是否真的换成了曲库里的曲子。
// 开关关闭 / 曲库为空 / 加载失败时 boss_music_resolve() 直接返回关卡自带的 elite_music，
// 这种情况 BOSS 波仍然要切回关卡自带的 boss_music，不能一直播精英段的曲子。
music_random_active = false
// 上一次对流套的音量；-1 表示需要重新套一次（切歌后重置）
music_vol_applied = -1