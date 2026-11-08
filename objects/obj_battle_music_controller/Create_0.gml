battle_music = global.level_data.pre_music
new_battle_music = battle_music
// 本场是否已抽过「BOSS 随机音乐」。抽过就不再重抽，保证精英波起一直播到通关。
music_picked = false
// 上一次对流套的音量；-1 表示需要重新套一次（切歌后重置）
music_vol_applied = -1