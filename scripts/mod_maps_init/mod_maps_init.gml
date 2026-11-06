function mod_maps_init()
{
    register_map("cross_server",
    {
        map_name: "跨服远征",
        map_sprite: spr_mod_cs_bg,
        levels_data: [
        {
            id: "ancient_castle_0",
            name: "古堡初探",
            level_file: "cross/castle-0.json",
            hard_level_file: "cross/castle-0.json",
            level_sprite: spr_mod_ancient_castle_0,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "none",
            rewards: []
        },
        {
            id: "ancient_castle_1",
            name: "古堡一障",
            level_file: "cross/castle-1.json",
            hard_level_file: "cross/castle-1.json",
            level_sprite: spr_mod_ancient_castle_1,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "ancient_castle_0",
            rewards: []
        },
        {
            id: "ancient_castle_2",
            name: "古堡二子",
            level_file: "cross/castle-2.json",
            hard_level_file: "cross/castle-2.json",
            level_sprite: spr_mod_ancient_castle_2,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "ancient_castle_1",
            rewards: []
        },
        {
            id: "ancient_castle_3",
            name: "古堡三轮",
            level_file: "cross/castle-3.json",
            hard_level_file: "cross/castle-3.json",
            level_sprite: spr_mod_ancient_castle_3,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "ancient_castle_2",
            rewards: []
        },
        {
            id: "ancient_castle_4",
            name: "古堡四影",
            level_file: "cross/castle-4.json",
            hard_level_file: "cross/castle-4.json",
            level_sprite: spr_mod_ancient_castle_4,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "ancient_castle_3",
            rewards: []
        },
        {
            id: "ancient_castle_5",
            name: "古堡五崩",
            level_file: "cross/castle-5.json",
            hard_level_file: "cross/castle-5.json",
            level_sprite: spr_mod_ancient_castle_5,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "ancient_castle_4",
            rewards: []
        },
        {
            id: "ancient_castle_6",
            name: "古堡六阶",
            level_file: "cross/castle-6.json",
            hard_level_file: "cross/castle-6.json",
            level_sprite: spr_mod_ancient_castle_6,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "ancient_castle_5",
            rewards: []
        },
        {
            id: "ancient_castle_7",
            name: "古堡终破",
            level_file: "cross/castle-7.json",
            hard_level_file: "cross/castle-7.json",
            level_sprite: spr_mod_ancient_castle_7,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "ancient_castle_6",
            rewards: []
        }]
    });
    // ===== 跨服·梦魇天空（入口：spr_mod_cs_level_choose 第 2 帧，8~15 星门槛）=====
    register_map("cross_server_nightmare_sky",
    {
        map_name: "梦魇天空",
        map_sprite: spr_mod_cs_bg,
        levels_data: [
        {
            id: "nightmare_sky_0",
            name: "天空静夜",
            level_file: "cross/nightmare_sky-0.json",
            hard_level_file: "cross/nightmare_sky-0.json",
            level_sprite: spr_mengyantiankong_0,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "none",
            rewards: []
        },
        {
            id: "nightmare_sky_1",
            name: "天空蒙雾",
            level_file: "cross/nightmare_sky-1.json",
            hard_level_file: "cross/nightmare_sky-1.json",
            level_sprite: spr_mengyantiankong_1,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "nightmare_sky_0",
            rewards: []
        },
        {
            id: "nightmare_sky_2",
            name: "天空薄雾",
            level_file: "cross/nightmare_sky-2.json",
            hard_level_file: "cross/nightmare_sky-2.json",
            level_sprite: spr_mengyantiankong_2,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "nightmare_sky_1",
            rewards: []
        },
        {
            id: "nightmare_sky_3",
            name: "天空迷雾",
            level_file: "cross/nightmare_sky-3.json",
            hard_level_file: "cross/nightmare_sky-3.json",
            level_sprite: spr_mengyantiankong_3,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "nightmare_sky_2",
            rewards: []
        },
        {
            id: "nightmare_sky_4",
            name: "天空浓雾",
            level_file: "cross/nightmare_sky-4.json",
            hard_level_file: "cross/nightmare_sky-4.json",
            level_sprite: spr_mengyantiankong_4,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "nightmare_sky_3",
            rewards: []
        },
        {
            id: "nightmare_sky_5",
            name: "天空重雾",
            level_file: "cross/nightmare_sky-5.json",
            hard_level_file: "cross/nightmare_sky-5.json",
            level_sprite: spr_mengyantiankong_5,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "nightmare_sky_4",
            rewards: []
        },
        {
            id: "nightmare_sky_6",
            name: "天空毒雾",
            level_file: "cross/nightmare_sky-6.json",
            hard_level_file: "cross/nightmare_sky-6.json",
            level_sprite: spr_mengyantiankong_6,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "nightmare_sky_5",
            rewards: []
        },
        {
            id: "nightmare_sky_7",
            name: "天空破雾",
            level_file: "cross/nightmare_sky-7.json",
            hard_level_file: "cross/nightmare_sky-7.json",
            level_sprite: spr_mengyantiankong_7,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "nightmare_sky_6",
            rewards: []
        }
        ]
    });
    // ===== 跨服·灼热地域（入口：spr_mod_cs_level_choose 第 3 帧，8~15 星门槛）=====
    // 8 关对应 8~15 星：zhuore_0（8星，炼狱之始）~ zhuore_7（15星，炼狱之末）。
    // 奖励走 cross_server_reward()（zhuore_ 分支），所以这里 rewards 留空。
    // 关卡图标：obj_cross_server_bg/Draw_0 对 zhuore 章节直接画 spr_zhuorediyu。
    register_map("cross_server_hot_hell",
    {
        map_name: "灼热地域",
        map_sprite: spr_mod_cs_bg,
        levels_data: [
        {
            id: "zhuore_0",
            name: "炼狱之始",
            level_file: "cross/zhuore_0.json",
            hard_level_file: "cross/zhuore_0.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "none",
            rewards: []
        },
        {
            id: "zhuore_1",
            name: "炼狱之觉",
            level_file: "cross/zhuore_1.json",
            hard_level_file: "cross/zhuore_1.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "zhuore_0",
            rewards: []
        },
        {
            id: "zhuore_2",
            name: "炼狱之风",
            level_file: "cross/zhuore_2.json",
            hard_level_file: "cross/zhuore_2.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "zhuore_1",
            rewards: []
        },
        {
            id: "zhuore_3",
            name: "炼狱之扇",
            level_file: "cross/zhuore_3.json",
            hard_level_file: "cross/zhuore_3.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "zhuore_2",
            rewards: []
        },
        {
            id: "zhuore_4",
            name: "炼狱之轮",
            level_file: "cross/zhuore_4.json",
            hard_level_file: "cross/zhuore_4.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "zhuore_3",
            rewards: []
        },
        {
            id: "zhuore_5",
            name: "炼狱之影",
            level_file: "cross/zhuore_5.json",
            hard_level_file: "cross/zhuore_5.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "zhuore_4",
            rewards: []
        },
        {
            id: "zhuore_6",
            name: "炼狱之锁",
            level_file: "cross/zhuore_6.json",
            hard_level_file: "cross/zhuore_6.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "zhuore_5",
            rewards: []
        },
        {
            id: "zhuore_7",
            name: "炼狱之末",
            level_file: "cross/zhuore_7.json",
            hard_level_file: "cross/zhuore_7.json",
            level_sprite: spr_zhuorediyu,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "zhuore_6",
            rewards: []
        }
        ]
    });
}
