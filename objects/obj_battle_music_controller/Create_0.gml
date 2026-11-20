battle_music = global.level_data.pre_music
new_battle_music = battle_music
// 「切 BOSS 曲之前正在播的那一首」，BOSS 阵亡后还原到它。
// 注意不能拿 pre_music 当初值就了事：精英段会把曲子换成 elite_music（或随机曲），
// 所以必须在真正切 BOSS 曲的那一刻现记（见 obj_battle/Step_2）。
music_restore_sound = battle_music
// 是否正在播「关卡自带 BOSS 曲」。
// 只在随机 BOSS 音乐关闭时置 true —— 开启时一路播随机曲，BOSS 出现 / 死亡都不切，
// 保持改动前的行为（用户口径 2026-11-20）。
music_boss_phase = false
// 本场是否已抽过「BOSS 随机音乐」。抽过就不再重抽，保证精英波起一直播到通关。
music_picked = false
// 本场是否真的换成了曲库里的曲子。
// 开关关闭 / 曲库为空 / 加载失败时 boss_music_resolve() 直接返回关卡自带的 elite_music，
// 这种情况 BOSS 波仍然要切回关卡自带的 boss_music，不能一直播精英段的曲子。
music_random_active = false
// 上一次对流套的音量；-1 表示需要重新套一次（切歌后重置）
music_vol_applied = -1