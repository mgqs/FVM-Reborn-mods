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
    // ===== 跨服·水火之间（入口：spr_mod_cs_level_choose 第 4 帧，8~15 星门槛）=====
    // 奖励走 cross_server_reward()（shuihuo_ 分支未给档位表，暂落入古堡同档兜底），rewards 留空。
    register_map("cross_server_water_fire",
    {
        map_name: "水火之间",
        map_sprite: spr_mod_cs_bg,
        levels_data: [
        {
            id: "shuihuo_0",
            name: "水火相遇",
            level_file: "cross/shuihuo_0.json",
            hard_level_file: "cross/shuihuo_0.json",
            level_sprite: spr_shuihuozhijian_0,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "none",
            rewards: []
        },
        {
            id: "shuihuo_1",
            name: "水火相融",
            level_file: "cross/shuihuo_1.json",
            hard_level_file: "cross/shuihuo_1.json",
            level_sprite: spr_shuihuozhijian_0,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "shuihuo_0",
            rewards: []
        },
        {
            id: "shuihuo_2",
            name: "水火相拦",
            level_file: "cross/shuihuo_2.json",
            hard_level_file: "cross/shuihuo_2.json",
            level_sprite: spr_shuihuozhijian_0,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "shuihuo_1",
            rewards: []
        },
        {
            id: "shuihuo_3",
            name: "水火相斥",
            level_file: "cross/shuihuo_3.json",
            hard_level_file: "cross/shuihuo_3.json",
            level_sprite: spr_shuihuozhijian_0,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "shuihuo_2",
            rewards: []
        },
        {
            id: "shuihuo_4",
            name: "水火相位",
            level_file: "cross/shuihuo_4.json",
            hard_level_file: "cross/shuihuo_4.json",
            level_sprite: spr_shuihuozhijian_1,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "shuihuo_3",
            rewards: []
        },
        {
            id: "shuihuo_5",
            name: "水火相争",
            level_file: "cross/shuihuo_5.json",
            hard_level_file: "cross/shuihuo_5.json",
            level_sprite: spr_shuihuozhijian_1,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "shuihuo_4",
            rewards: []
        },
        {
            id: "shuihuo_6",
            name: "水火相噬",
            level_file: "cross/shuihuo_6.json",
            hard_level_file: "cross/shuihuo_6.json",
            level_sprite: spr_shuihuozhijian_1,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "shuihuo_5",
            rewards: []
        },
        {
            id: "shuihuo_7",
            name: "水火相灭",
            level_file: "cross/shuihuo_7.json",
            hard_level_file: "cross/shuihuo_7.json",
            level_sprite: spr_shuihuozhijian_1,
            pre_music: mus_cross_server_day,
            elite_music: mus_cross_server_day,
            boss_music: mus_cross_server_day_boss,
            pre_level: "shuihuo_6",
            rewards: []
        }
        ]
    });
    // ===== 跨服·巫毒研究所（入口：spr_mod_cs_level_choose 第 5 帧，8~15 星门槛）=====
    // 奖励走 cross_server_reward()（wudu_ 分支未给档位表，暂落入古堡同档兜底），rewards 留空。
    register_map("cross_server_voodoo_lab",
    {
        map_name: "巫毒研究所",
        map_sprite: spr_mod_cs_bg,
        levels_data: [
        {
            id: "wudu_0",
            name: "五毒入口",
            level_file: "cross/wudu_0.json",
            hard_level_file: "cross/wudu_0.json",
            level_sprite: spr_wuduyanjiusuo_0,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "none",
            rewards: []
        },
        {
            id: "wudu_1",
            name: "巫毒走道",
            level_file: "cross/wudu_1.json",
            hard_level_file: "cross/wudu_1.json",
            level_sprite: spr_wuduyanjiusuo_1,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "wudu_0",
            rewards: []
        },
        {
            id: "wudu_2",
            name: "巫毒一室",
            level_file: "cross/wudu_2.json",
            hard_level_file: "cross/wudu_2.json",
            level_sprite: spr_wuduyanjiusuo_2,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "wudu_1",
            rewards: []
        },
        {
            id: "wudu_3",
            name: "巫毒二室",
            level_file: "cross/wudu_3.json",
            hard_level_file: "cross/wudu_3.json",
            level_sprite: spr_wuduyanjiusuo_3,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "wudu_2",
            rewards: []
        },
        {
            id: "wudu_4",
            name: "巫毒回廊",
            level_file: "cross/wudu_4.json",
            hard_level_file: "cross/wudu_4.json",
            level_sprite: spr_wuduyanjiusuo_4,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "wudu_3",
            rewards: []
        },
        {
            id: "wudu_5",
            name: "巫毒暗道",
            level_file: "cross/wudu_5.json",
            hard_level_file: "cross/wudu_5.json",
            level_sprite: spr_wuduyanjiusuo_5,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "wudu_4",
            rewards: []
        },
        {
            id: "wudu_6",
            name: "巫毒密室",
            level_file: "cross/wudu_6.json",
            hard_level_file: "cross/wudu_6.json",
            level_sprite: spr_wuduyanjiusuo_6,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "wudu_5",
            rewards: []
        },
        {
            id: "wudu_7",
            name: "巫毒核心",
            level_file: "cross/wudu_7.json",
            hard_level_file: "cross/wudu_7.json",
            level_sprite: spr_wuduyanjiusuo_7,
            pre_music: mus_cross_server_night,
            elite_music: mus_cross_server_night,
            boss_music: mus_cross_server_night_boss,
            pre_level: "wudu_6",
            rewards: []
        }
        ]
    });
}
