function mod_skill_init()
{
    register_card_skill("yanyantu", "cooldown", [2400, 2220, 2040, 1860, 1680, 1500, 1320, 1140, 900]);
    register_card_skill("wugushe", "cycle", [108, 105, 102, 99, 96, 93, 90, 87, 84]);
    register_card_skill("kuileima", "cycle", [900, 960, 1020, 1080, 1200, 1320, 1440, 1680, 2100]);
    register_card_skill("yufengma", "cycle", [120, 117, 114, 111, 108, 102, 96, 90, 78]);
    register_card_skill("fenjima", "cycle", [108, 105, 102, 99, 96, 90, 84, 78, 60]);
    register_card_skill("guiyuanma", "cycle", [156, 153, 150, 147, 144, 141, 138, 132, 120]);
    register_card_skill("huagao", "cycle", [210, 207, 204, 201, 198, 192, 186, 180, 168]);
    register_card_skill("yanhuangma", "cycle", [210, 207, 204, 201, 198, 192, 186, 180, 150]);
    register_card_skill("shennong_god", "cycle", [210, 207, 204, 201, 198, 192, 186, 180, 168]);
    register_card_skill("yinhema", "cooldown", [2700, 2580, 2460, 2340, 2220, 2040, 1800, 1500, 900]);
    register_card_skill("fushengcha", "cooldown", [3000, 2880, 2760, 2640, 2400, 2100, 1800, 1500, 1080]);
    register_card_skill("yuansushe", "cycle", [150, 144, 138, 132, 126, 120, 114, 108, 90]);
    register_card_skill("galaxy_horse", "cycle", [1140, 1110, 1080, 1050, 1020, 960, 900, 840, 660]);
    register_card_skill("xinggui_god", "cooldown", [2400, 2280, 2160, 1980, 1740, 1500, 1260, 1020, 720]);
    register_card_skill("xiandima", "cycle", [900, 846, 792, 738, 648, 558, 468, 378, 270]);
    register_card_skill("xingqiongma", "zodiac_guard_duration", [900, 930, 960, 990, 1020, 1050, 1080, 1110, 1200]);
    register_card_skill("starrabbit", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("yinghuoshe", "atk", [
        [300, 350, 400, 450, 500, 550, 600, 700, 900],
        [300, 350, 400, 450, 500, 550, 600, 700, 900],
        [600, 700, 800, 900, 1000, 1100, 1200, 1400, 1800]
    ]);
    register_card_skill("gaia", "cooldown", [2100, 1920, 1740, 1560, 1380, 1200, 1020, 840, 540]);
    register_card_skill("warm_birds", "flame_produce", [25, 27, 29, 31, 34, 37, 40, 44, 48]);
    register_card_skill("aurora", "cooldown", [1800, 1680, 1560, 1380, 1200, 1020, 840, 660, 420]);
    register_card_skill("cold_drew", "cycle", [360, 348, 336, 324, 312, 300, 288, 276, 258]);
    register_card_skill("berry_dessert", "cooldown", [2400, 2220, 2040, 1860, 1680, 1500, 1320, 1140, 900]);
    register_card_skill("grilled_lizard_pult", "cycle", [132, 129, 126, 122.99999999999999, 120, 117, 114, 111, 105]);
    register_card_skill("zhurong", "cycle", [228, 222, 210, 198, 186, 174, 162, 150, 132]);
    register_card_skill("lizi_god", "cycle", [228, 222, 210, 198, 186, 174, 162, 150, 132]);
    register_card_skill("youyu_god", "cycle", [90, 87, 84, 81, 78, 75, 72, 69, 63]);
    register_card_skill("firework_dragon_real", "first_produce_delay", [480, 450, 420, 390, 360, 300, 240, 180, 60]);
    register_card_skill("brahma", "cycle", [145, 145, 145, 145, 145, 145, 145, 145, 145]);
    register_card_skill("baibianshe", "cycle", [145, 145, 145, 145, 145, 145, 145, 145, 145]);
    register_card_skill("blueberry_tower", "cooldown", [2100, 1980, 1860, 1740, 1620, 1500, 1380, 1200, 900]);
    register_card_skill("zhuzhujiaqiang", "cooldown", [2100, 1920, 1740, 1560, 1380, 1200, 960, 720, 420]);
    register_card_skill("rig", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("donut", "cycle", [84, 81, 78, 75, 72, 69, 66, 60, 54]);
    register_card_skill("clotho", "cycle", [3600, 3900, 4200, 4500, 4800, 5100, 5700, 6300, 7200]);
    register_card_skill("time_god", "cycle", [3600, 3900, 4200, 4500, 4800, 5100, 5700, 6300, 7200]);
    register_card_skill("spoon_rabbit", "cycle", [132, 129, 126, 122.99999999999999, 120, 117, 114, 111, 105]);
    register_card_skill("hspeed_juicer", "cooldown", [2700, 2520, 2340, 2160, 1980, 1800, 1620, 1440, 1080]);
    register_card_skill("joker", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("shuangzi", "flame_produce", [25, 27, 29, 31, 34, 37, 40, 44, 48]);
    register_card_skill("sheshou", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("tiancheng", "cycle", [84, 81, 78, 75, 72, 69, 66, 63, 54]);
    register_card_skill("shuangyu", "cycle", [150, 144, 138, 132, 126, 120, 114, 108, 102]);
    register_card_skill("juxie", "cycle", [180, 174, 168, 162, 153, 144, 132, 120, 102]);
    register_card_skill("shizi", "cycle", [108, 105, 102, 99, 96, 93, 90, 87, 84]);
    register_card_skill("jinniu", "cooldown", [420, 402, 384, 360, 330, 300, 270, 240, 210]);
    register_card_skill("chunv", "cooldown", [1800, 1680, 1560, 1440, 1320, 1200, 1080, 900, 720]);
    register_card_skill("baiyang", "atk", [900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300]);
    register_card_skill("mojie", "cooldown", [3000, 2820, 2640, 2400, 2160, 1920, 1620, 1320, 1080]);
    register_card_skill("athena", "cycle", [360, 348, 336, 324, 312, 300, 288, 270, 240]);
    register_card_skill("odin", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("sun_god", "flame_produce", [25, 27, 29, 31, 34, 37, 40, 44, 48]);
    // 玉蜀黍：技能影响[攻击间隔]（2026-10-30 用户定，单位秒 → 帧：
    //   1.3 / 1.25 / 1.2 / 1.15 / 1.1 / 1.05 / 1 / 0.95 / 0.9  × 60）
    register_card_skill("corn_shooter", "cycle", [78, 75, 72, 69, 66, 63, 60, 57, 54]);
    register_card_skill("moon_god", "cycle", [180, 174, 168, 162, 153, 144, 132, 120, 102]);
    register_card_skill("war_god", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("hera", "cooldown", [1800, 1680, 1560, 1440, 1320, 1200, 1080, 900, 720]);
    register_card_skill("thor", "cycle", [180, 174, 168, 162, 156, 144, 132, 120, 108]);
    register_card_skill("poseidon", "cycle", [108, 105, 102, 99, 96, 93, 90, 87, 84]);
    register_card_skill("love_god", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("fire_god", "cooldown", [420, 402, 384, 360, 330, 300, 270, 240, 210]);
    register_card_skill("water_god", "毒伤", [100, 120, 140, 160, 180, 200, 220, 250, 300]);
    register_card_skill("zeus", "cycle", [360, 348, 336, 324, 312, 300, 288, 270, 240]);
    register_card_skill("ghost_god", "cycle", [78, 75, 72, 69, 66, 63, 60, 57, 54]);
    register_card_skill("ice_god", "cycle", [360, 348, 336, 324, 312, 300, 282, 264, 240]);
    register_card_skill("power_god", "cycle", [180, 168, 156, 144, 132, 120, 108, 96, 72]);
    register_card_skill("sheng_huo", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("save_god", "atk", [900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300]);
    register_card_skill("ymir", "cycle", [126, 122.99999999999999, 120, 117, 111, 105, 99, 93, 84]);
    register_card_skill("xiangshui_god", "cooldown", [2400, 2220, 2040, 1860, 1680, 1500, 1320, 1140, 900]);
    register_card_skill("fengrao_god", "cooldown", [2100, 1980, 1860, 1740, 1620, 1500, 1320, 1080, 720]);
    register_card_skill("houyi_god", "cycle", [75, 72, 69, 66, 63, 60, 57, 54, 51]);
    register_card_skill("heian_god","cycle",[15*60,16*60,17*60,18*60,20*60,22*60,26*60,31*60,36*60]);
    register_card_skill("hundun_god", "cooldown", [2100, 1920, 1740, 1560, 1380, 1140, 900, 660, 420]);
    register_card_skill("guangming_god", "cycle", [210, 207, 204, 201, 198, 192, 186, 180, 168]);
    register_card_skill("lingrong_god", "hp", [100, 140, 180, 220, 300, 400, 520, 640, 760]);
    register_card_skill("laipishe", "cycle", [210, 204, 198, 192, 186, 180, 168, 156, 120]);
    register_card_skill("liehuohu", "cooldown", [3300, 3120, 2940, 2940, 2580, 2400, 2220, 2040, 1800]);
    register_card_skill("double_blade_snake", "cycle", [78, 75, 72, 69, 66, 63, 60, 57, 51]);
    register_card_skill("chongsheng_god", "cycle", [150, 153, 156, 159, 162, 165, 168, 180, 210]);
    register_card_skill("chongsheng_god", "chongsheng_duration", [900, 930, 960, 990, 1020, 1050, 1080, 1110, 1200]);
    register_card_skill("chongsheng_god", "chongsheng_reduction", [0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.7, 0.8]);
    register_card_skill("hufa_god", "cycle", [108, 105, 102, 99, 96, 93, 90, 84, 78]);
    register_card_skill("zhanqima", "cycle", [1200, 1260, 1380, 1500, 1620, 1740, 1920, 2100, 2700]);
    register_card_skill("starrabbit", "cycle", [78,75,72,69,66,63,60,54,48]);
    register_card_skill("hongliukaochuan", "cycle", [90, 87, 84, 81, 78, 75, 72, 69, 60]);
    register_card_skill("yeziguo", "atk", [1000, 1125, 1250, 1375, 1500, 1625, 1750, 1875, 2000]);
    register_card_skill("ronghehaixing", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("ronghedan_god", "cycle", [180, 174, 168, 162, 156, 144, 132, 120, 108]);
    register_card_skill("ronghehuopen", "hp", [250, 300, 350, 400, 450, 500, 550, 600, 650]);
    register_card_skill("ronghesanxian", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("shuanggu", "cycle", [150, 144, 138, 132, 126, 120, 114, 108, 90]);
    register_card_skill("rongheshuanggu", "cycle", [150, 144, 138, 132, 126, 120, 114, 108, 90]);
    register_card_skill("chunsun", "准备时间", [6.5, 6.3, 6.1, 5.9, 5.7, 5.5, 5.3, 5, 3.5]);
    register_card_skill("niuyouguo", "cycle", [90, 87, 84, 81, 78, 75, 72, 66, 60]);
    register_card_skill("ronghedapao", "cooldown", [1500, 1410, 1320, 1230, 1140, 1050, 960, 870, 780]);
    register_card_skill("ronghekafei", "cycle", [78, 75, 72, 69, 66, 63, 60, 57, 54]);
    register_card_skill("wuxingshe", "cooldown", [2400, 2220, 2040, 1860, 1680, 1500, 1320, 1140, 900]);
    register_card_skill("gongjiang_god", "cycle", [210, 204, 198, 192, 186, 180, 168, 144, 120]);
    // 凤羽魔杖蛇：星级影响[攻击力],技能影响[冷却时间]。星级表已恒定 2520，
    // 原星级表前 9 档即本曲线，第 9 档起用 900 封顶。
    register_card_skill("mozhang", "cooldown", [2520, 2340, 2160, 1980, 1800, 1560, 1320, 1080, 900]);
    // 海洋女神：星级影响[攻击力],技能影响[冷却时间]。星级表已恒定 2400，
    // 原表每两星一档，取 2400→720 的 9 个节点。
    register_card_skill("haiyang_god", "cooldown", [2400, 2280, 2160, 1980, 1740, 1500, 1260, 1020, 720]);
    // 桥头米线：星级影响[攻击力],技能影响[攻击间隔]。cycle 原为恒定 90 且无技能注册，
    // 导致技能等级完全无收益；基准 90，8 级降到 60（1 秒）。
    register_card_skill("mixian", "cycle", [90, 87, 84, 81, 78, 74, 70, 66, 60]);
    register_card_skill("bbq", "cycle", [84, 81, 78, 75, 72, 69, 66, 60, 54]);
    register_card_skill("eightcake", "cycle", [120, 117, 114, 111, 108, 105, 102, 99, 90]);
    register_card_skill("tangchaolizi", "cycle", [228, 222, 210, 198, 186, 174, 162, 150, 132]);
    register_card_skill("nengliangmiao", "cooldown", [480, 450, 420,390, 360, 330, 300, 270, 240]);
    register_card_skill("maiya", "cooldown", [420, 390, 360, 330, 300, 270, 240, 210, 180]);
    register_card_skill("guihuajiu", "cooldown", [3000, 2880, 2700, 2520, 2280, 2040, 1800, 1500, 1200]);
    register_card_skill("mianbao", "cooldown", [3000, 2880, 2700, 2520, 2280, 2040, 1800, 1500, 1200]);
    register_card_skill("xuanzhuan_ronghe", "cooldown", [1500, 1410, 1320, 1230, 1110, 990, 870, 720, 570]);
    register_card_skill("zhuzhuliaoliji", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("budingwang", "cooldown", [840, 780, 720, 660, 600, 540, 480, 420, 360]);
    register_card_skill("caihongshe", "cycle", [120, 117, 114, 111, 108, 105, 102, 96, 90]);
    register_card_skill("meiweijishiqi", "duration", [510, 540, 570, 600, 630, 660, 690, 720, 900]);
    // 蛋蛋兔冷却 90/87/84/81/76/71/66/61/50 秒（用户表：星级只吃攻击力，冷却只吃技能）
    register_card_skill("dandantu", "cooldown", [5400, 5220, 5040, 4860, 4560, 4260, 3960, 3660, 3000]);
    register_card_skill("dangdanghu", "cycle", [228, 222, 210, 198, 186, 174, 162, 150, 132]);
    register_card_skill("dianman", "duration", [600, 660, 720, 780, 900, 1020, 1320, 1620, 1920]);
	register_card_skill("tanchitu", "atk", [900, 950, 1000, 1050, 1100, 1150, 1200, 1250, 1300]);
    register_card_skill("tunshilong", "cooldown", [2100, 1920, 1740, 1560, 1380, 1140, 900, 660, 420]);
    register_card_skill("xiangliaohu", "cooldown", [2400, 2220, 2040, 1860, 1680, 1500, 1320, 1140, 900]);
    register_card_skill("zhuanzhuanji", "cycle", [108, 105, 102, 99, 96, 93, 90, 84, 78]);
    register_card_skill("fashishe", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("fangkongmiao", "cycle", [180, 168, 156, 144, 132, 120, 108, 96, 72]);
    register_card_skill("huojianzhu", "cycle", [360, 348, 336, 324, 312, 300, 288, 276, 261]);
    register_card_skill("honeytrap", "cycle", [900, 846, 792, 738, 648, 558, 468, 378, 270]);
    register_card_skill("huanyingshe", "cycle", [138, 135, 132, 129, 126, 123, 117, 111, 102]);
    register_card_skill("tianxie", "cycle", [90, 87, 84, 81, 78, 75, 72, 66, 60]);
    register_card_skill("jingangma", "cycle", [78, 75, 72, 69, 66, 63, 60, 57, 48]);
    register_card_skill("qiedanlong", "cycle", [132, 129, 126, 123, 120, 117, 114, 111, 105]);
    register_card_skill("qishui", "cycle", [120, 117, 114, 111, 108, 102, 96, 90, 78]);
    register_card_skill("sheshejiu", "升降持续", [45, 48, 51, 54, 57, 60, 65, 70, 80]);
    register_card_skill("snowrabbit", "cycle", [330, 318, 306, 294, 282, 270, 258, 240, 210]);
    register_card_skill("tanhuanghu", "cycle", [78, 75, 72, 69, 66, 63, 60, 54, 48]);
    register_card_skill("yuanqiniu", "cycle", [108, 105, 102, 99, 96, 93, 90, 87, 84]);
    register_card_skill("shiliu_baobao_bing", "cooldown", [3300, 3120, 2940, 2760, 2580, 2400, 2100, 1800, 1500]);
}
