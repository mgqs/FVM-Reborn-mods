function mod_slots_init()
{
    register_card("chunsun", obj_chunsun, [
    { shape: 0, sprite: spr_chunsun_icon, cost: 210, cooldown: 420, description: "泡椒春笋：准备一段时间后长出穿刺老鼠的春笋，攻击范围内陆、地鼠军", plant_type: "gridless", feature_type: "normal", target_card: "none", place_preview: spr_chunsun },
    { shape: 1, sprite: spr_chunsun_1_icon, cost: 210, cooldown: 420, description: "火辣泡椒笋：准备一段时间后长出穿刺老鼠的春笋，笋子存在时间延长", plant_type: "gridless", feature_type: "normal", target_card: "none", place_preview: spr_chunsun_1 },
    { shape: 2, sprite: spr_chunsun_2_icon, cost: 210, cooldown: 420, description: "望乡泡椒笋：准备一段时间后长出穿刺老鼠的春笋，生长范围扩大到3*5", plant_type: "gridless", feature_type: "normal", target_card: "none", place_preview: spr_chunsun_2 }]);

    register_card("mixian", obj_mixian, [
    { shape: 0, sprite: spr_mixian, cost: 200, cooldown: 900, description: "桥头米线：连接5*5范围内最近的一根龙柱，1张即可封印，2张连接同一根龙柱可净化，同时以5*5范围攻击老鼠", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_mixian },
    { shape: 1, sprite: spr_mixian_1, cost: 200, cooldown: 900, description: "灵泉桥头米线：连接5*5范围内最近的一根龙柱，1张即可封印，2张连接同一根龙柱可净化；被老鼠啃咬时反伤", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_mixian_1 },
    { shape: 2, sprite: spr_mixian_2, cost: 200, cooldown: 900, description: "金汤桥头米线：连接5*5范围内最近的一根龙柱，1张即可封印，2张连接同一根龙柱可净化，攻击力更高", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_mixian_2 }]);

    // 生肖卡注册（共12张，每张3个形态）
    register_card("yanyantu", obj_yanyantu, [
    { shape: 0, sprite: spr_yanyantu, cost: 200, cooldown: 2400, description: "炎焱兔：3*3范围内火炉类卡片提升产能数量", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yanyantu },
    { shape: 1, sprite: spr_yanyantu_1, cost: 200, cooldown: 2400, description: "火火炎焱兔：3*3范围内火炉类卡片提升产能数量", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yanyantu_1 },
    { shape: 2, sprite: spr_yanyantu_2, cost: 200, cooldown: 2400, description: "焱焱炎焱兔：5*5范围内火炉类卡片提升产能数量", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yanyantu_2 }]);
    register_card("wugushe", obj_wugushe, [
    { shape: 0, sprite: spr_wugushe, cost: 275, cooldown: 900, description: "巫蛊蛇：3*3范围穿透攻击，10%概率造成百分比伤害（有上限）", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_wugushe },
    { shape: 1, sprite: spr_wugushe_1, cost: 275, cooldown: 900, description: "暗黑巫蛊蛇：3*3范围穿透攻击，15%概率造成百分比伤害（有上限）", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_wugushe_1 },
    { shape: 2, sprite: spr_wugushe_2, cost: 275, cooldown: 900, description: "秘术巫蛊蛇：5*5范围穿透攻击，15%概率造成百分比伤害（有上限）", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_wugushe_2 }]);
    register_card("kuileima", obj_kuileima, [
    { shape: 0, sprite: spr_kuileima, cost: 390, cooldown: 2700, description: "傀儡马：化作傀儡，将伤害按比例转移给场上血量最高的1只老鼠", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_kuileima },
    { shape: 1, sprite: spr_kuileima_1, cost: 390, cooldown: 2700, description: "机关傀儡马：化作傀儡，将伤害按比例转移给场上血量最高的1只老鼠，傀儡消失产生5*5范围爆炸", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_kuileima_1 },
    { shape: 2, sprite: spr_kuileima_2, cost: 390, cooldown: 2700, description: "灵枢傀儡马：化作傀儡，将伤害按比例转移给场上血量最高的1只老鼠，傀儡消失产生5*5范围爆炸", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_kuileima_2 }]);
    register_card("yufengma", obj_yufengma, [
    { shape: 0, sprite: spr_yufengma, cost: 280, cooldown: 900, description: "御风马：召唤1个贯穿攻击本行的龙卷风，可击退，与扇类卡片联动", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yufengma },
    { shape: 1, sprite: spr_yufengma_1, cost: 280, cooldown: 900, description: "净化御风马：召唤1个贯穿攻击本行的龙卷风，可击退和吹飞，与扇类卡片联动", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yufengma_1 },
    { shape: 2, sprite: spr_yufengma_2, cost: 280, cooldown: 900, description: "菩提御风马：召唤2个贯穿攻击本行的龙卷风，可击退和吹飞，秒杀特定老鼠，与扇类卡片联动", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yufengma_2 }]);
    register_card("fenjima", obj_fenjima, [
    { shape: 0, sprite: spr_fenjima, cost: 320, cooldown: 900, description: "焚寂马：向前发射1发直线子弹，击中老鼠后分裂成3向穿透冲击波", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_fenjima },
    { shape: 1, sprite: spr_fenjima_1, cost: 320, cooldown: 900, description: "星火焚寂马：向前发射1发直线子弹，击中老鼠后分裂成3向穿透冲击波", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_fenjima_1 },
    { shape: 2, sprite: spr_fenjima_2, cost: 320, cooldown: 900, description: "烈日焚寂马：向前发射1发直线子弹，击中老鼠后分裂成5向穿透冲击波", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_fenjima_2 }]);
    register_card("guiyuanma", obj_guiyuanma, [
    { shape: 0, sprite: spr_guiyuanma, cost: 375, cooldown: 900, description: "归元马：将前方3行范围内距离最近的普通老鼠送回起点并初始还原，斩杀低血量百分比精英", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_guiyuanma },
    { shape: 1, sprite: spr_guiyuanma_1, cost: 375, cooldown: 900, description: "时空归元马：将前方3行范围内距离最近的普通老鼠送回起点并初始还原，斩杀低血量百分比精英", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_guiyuanma_1 },
    { shape: 2, sprite: spr_guiyuanma_2, cost: 375, cooldown: 900, description: "幻境归元马：将前方5行范围内2只距离最近的普通老鼠送回起点并初始还原，斩杀中等血量百分比精英", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_guiyuanma_2 }]);
    // 灯影花糕：固定轨迹类，召唤魂虫向左右两侧飞出攻击上中下三行陆军（松露大厅（夜）首通奖励本体）
    register_card("huagao", obj_huagao, [
    { shape: 0, sprite: spr_huagao, cost: 300, cooldown: 900, description: "灯影花糕：召唤魂虫从场地两侧对向飞入，攻击沿途上中下3行陆军，中路2次、上下各1次；命中魂系老鼠使其现形", plant_type: "normal", feature_type: "lava", target_card: "none", is_gold: 0, place_preview: spr_huagao },
    { shape: 1, sprite: spr_huagao_1, cost: 300, cooldown: 900, description: "初见灯影花糕：召唤魂虫从场地两侧对向飞入，攻击沿途上中下3行陆军；场上≥10张时，攻击力最高的1张每5秒召唤1枚竖向魂虫攻击第8~9列", plant_type: "normal", feature_type: "lava", target_card: "none", is_gold: 0, place_preview: spr_huagao_1 },
    { shape: 2, sprite: spr_huagao_2, cost: 300, cooldown: 900, description: "梦境灯影花糕：召唤魂虫从场地两侧对向飞入，攻击沿途上中下3行陆军，中路4次、上下各2次；攻击力大幅提高，横向魂虫+1", plant_type: "normal", feature_type: "lava", target_card: "none", is_gold: 0, place_preview: spr_huagao_2 }]);
    register_card("yanhuangma", obj_yanhuangma, [
    { shape: 0, sprite: spr_yanhuangma, cost: 320, cooldown: 900, description: "炎凰马：召唤2只火凤凰沿着交互式固定轨迹攻击沿途鼠军", plant_type: "normal", feature_type: "lava", target_card: "none", is_gold: 0, place_preview: spr_yanhuangma },
    { shape: 1, sprite: spr_yanhuangma_1, cost: 320, cooldown: 900, description: "白炽炎凰马：召唤2只火凤凰沿着交互式固定轨迹攻击沿途鼠军，卡片数量≥7时，额外增加1条轨迹", plant_type: "normal", feature_type: "lava", target_card: "none", is_gold: 0, place_preview: spr_yanhuangma_1 },
    { shape: 2, sprite: spr_yanhuangma_2, cost: 320, cooldown: 900, description: "焚天炎凰马：召唤2只火凤凰沿着交互式固定轨迹攻击沿途鼠军，卡片数量≥7时，额外增加1条轨迹", plant_type: "normal", feature_type: "lava", target_card: "none", is_gold: 0, place_preview: spr_yanhuangma_2 }]);
    register_card("yinhema", obj_yinhema, [
    { shape: 0, sprite: spr_yinhema, cost: 320, cooldown: 2700, description: "音盒马：为3*3范围内固定轨迹类卡片提高攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yinhema },
    { shape: 1, sprite: spr_yinhema_1, cost: 320, cooldown: 2700, description: "叮咚音盒马：为5*5范围内固定轨迹类卡片提高攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yinhema_1 },
    { shape: 2, sprite: spr_yinhema_2, cost: 320, cooldown: 2700, description: "玲珑音盒马：为5*5范围内固定轨迹类卡片提高攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yinhema_2 }]);
    // 浮生茶：固定轨迹类范围增幅（本体为松露大厅（夜）首通奖励）
    register_card("fushengcha", obj_fushengcha, [
    { shape: 0, sprite: spr_fushengcha, cost: 265, cooldown: 3000, description: "浮生茶：为3*3范围内固定轨迹类卡片提高攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_fushengcha },
    { shape: 1, sprite: spr_fushengcha_1, cost: 265, cooldown: 3000, description: "清心浮生茶：为5*5范围内固定轨迹类卡片提高攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_fushengcha_1 },
    { shape: 2, sprite: spr_fushengcha_2, cost: 265, cooldown: 3000, description: "忘忧浮生茶：为5*5范围内固定轨迹类卡片大幅提高攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_fushengcha_2 }]);
    register_card("xiandima", obj_xiandima, [
    { shape: 0, sprite: spr_xiandima_icon, cost: 335, cooldown: 900, description: "仙笛马：不占格子，吹奏仙乐引导3只小飞马攻击精英鼠军", plant_type: "gridless", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_xiandima },
    { shape: 1, sprite: spr_xiandima_icon1, cost: 335, cooldown: 900, description: "悠扬仙笛马：不占格子，吹奏仙乐引导3只小飞马攻击精英鼠军，对BOSS伤害增加", plant_type: "gridless", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_xiandima_1 },
    { shape: 2, sprite: spr_xiandima_icon2, cost: 335, cooldown: 900, description: "天籁仙笛马：不占格子，吹奏仙乐引导6只小飞马攻击精英鼠军，对BOSS伤害增加", plant_type: "gridless", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_xiandima_2 }]);
    register_card("xingqiongma", obj_xingqiongma, [
    { shape: 0, sprite: spr_xingqiongma, cost: 350, cooldown: 3600, description: "星穹马：复活5*5范围内1张死亡的卡片", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_xingqiongma },
    { shape: 1, sprite: spr_xingqiongma_1, cost: 350, cooldown: 3600, description: "璀璨星穹马：复活5*5范围内1张死亡的卡片，并为范围内卡牌施加减伤", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_xingqiongma_1 },
    { shape: 2, sprite: spr_xingqiongma_2, cost: 350, cooldown: 3600, description: "浩瀚星穹马：复活5*5范围内至多3张死亡的卡片，并为范围内卡牌施加减伤", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_xingqiongma_2 }]);
    register_card("starrabbit", obj_starrabbit, [
    { shape: 0, sprite: spr_starrabbit, cost: 225, cooldown: 420, description: "星星兔：向前方5方向各发射1个星星子弹", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_starrabbit },
    { shape: 1, sprite: spr_starrabbit_1, cost: 225, cooldown: 420, description: "科技星星兔：五个方向各发射1发星弹，伤害提升至2倍。", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_starrabbit_1 },
    { shape: 2, sprite: spr_starrabbit_2, cost: 225, cooldown: 420, description: "宇宙星星兔：五个方向各发射1发星弹，伤害提升至3倍。", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_starrabbit_2 }]);
    register_card("yinghuoshe", obj_yinghuoshe, [
    { shape: 0, sprite: sp_yinghuoshe, cost: 75, cooldown: 1800, description: "萤火蛇：产火并照亮全场，伤害3*3范围内老鼠", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: sp_yinghuoshe },
    { shape: 1, sprite: sp_yinghuoshe_1, cost: 75, cooldown: 1800, description: "星辉萤火蛇：产火并照亮全场，伤害3*3范围内老鼠。", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: sp_yinghuoshe_1 },
    { shape: 2, sprite: sp_yinghuoshe_2, cost: 75, cooldown: 1800, description: "皓月萤火蛇：产火并照亮全场，伤害3*3范围内老鼠。", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: sp_yinghuoshe_2 }]);
    // 随机礼盒：固定50火苗、10秒冷却，只能放置在陆地。
    register_card("lihe", obj_lihe, [
    {
        shape: 0,
        sprite: spr_lihe,
        cost: 50,
        cooldown: 600,
        description: "随机礼盒：随机生成一张卡片，生成卡片继承礼盒星级",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);

    register_card("gaia", obj_gaia, [
    {
        shape: 0,
        sprite: spr_gaia,
        cost: 350,
        cooldown: 2100,
        description: "盖亚神使：双连发射3*3范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_gaia_1,
        cost: 350,
        cooldown: 2100,
        description: "盖亚圣神：双连发射3*3范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_gaia_2,
        cost: 350,
        cooldown: 2100,
        description: "大地女神·盖亚：三连发射3*3范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_gaia_3,
        cost: 350,
        cooldown: 2100,
        description: "至尊大地女神：三连发射5*5范围爆炸的毁灭巨石",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("aurora", obj_aurora, [
    {
        shape: 0,
        sprite: spr_aurora_icon,
        cost: 190,
        cooldown: 1800,
        description: "欧若拉神使：为本行投掷类卡片增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora
    },
    {
        shape: 1,
        sprite: spr_aurora_icon_1,
        cost: 190,
        cooldown: 1800,
        description: "欧若拉圣神：为本行投掷类卡片增伤，死亡后爆炸",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora_1
    },
    {
        shape: 2,
        sprite: spr_aurora_icon_2,
        cost: 190,
        cooldown: 1800,
        description: "曙光女神·欧若拉：为本行投掷类卡片增伤，死亡后爆炸",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora_2
    },
    {
        shape: 3,
        sprite: spr_aurora_icon_3,
        cost: 190,
        cooldown: 1800,
        description: "至尊曙光女神：为本行及相邻行投掷类卡片增伤，死亡后爆炸",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_aurora_3
    }]);
    register_card("zhurong", obj_zhurong, [
    {
        shape: 0,
        sprite: spr_zhurong,
        cost: 245,
        cooldown: 420,
        description: "祝融神使：点燃前方3x3区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_zhurong_1,
        cost: 245,
        cooldown: 420,
        description: "祝融圣神：点燃前方3x3区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_zhurong_2,
        cost: 245,
        cooldown: 420,
        description: "赤帝·祝融：点燃前方5x5区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_zhurong_3,
        cost: 245,
        cooldown: 420,
        description: "至尊赤帝：点燃前方7x5区域，持续灼烧敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("rig", obj_rig, [
    {
        shape: 0,
        sprite: spr_rig,
        cost: 185,
        cooldown: 420,
        description: "里格神使：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_rig_1,
        cost: 260,
        cooldown: 420,
        description: "里格圣神：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_rig_2,
        cost: 260,
        cooldown: 420,
        description: "守护神·里格：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_rig_3,
        cost: 260,
        cooldown: 420,
        description: "至尊守护神：前方5方向发射穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("brahma", obj_brahma, [
    {
        shape: 0,
        sprite: spr_brahma_icon,
        cost: 325,
        cooldown: 3300,
        description: "梵天神使：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma
    },
    {
        shape: 1,
        sprite: spr_brahma_icon_1,
        cost: 325,
        cooldown: 3300,
        description: "梵天圣神：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma_1
    },
    {
        shape: 2,
        sprite: spr_brahma_icon_2,
        cost: 325,
        cooldown: 3300,
        description: "创造神·梵天：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma_2
    },
    {
        shape: 3,
        sprite: spr_brahma_icon_3,
        cost: 325,
        cooldown: 3300,
        description: "至尊创造神：变身出多个上一次种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_brahma_3
    }]);
    register_card("baibianshe", obj_baibianshe, [
    {
        shape: 0,
        sprite: spr_baibianshe,
        cost: 375,
        cooldown: 3300,
        description: "百变蛇：变身出5*5范围内上一张种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_baibianshe
    },
    {
        shape: 1,
        sprite: spr_baibianshe_1,
        cost: 375,
        cooldown: 3300,
        description: "孪生百变蛇：变身出全屏范围内上一张种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_baibianshe_1
    },
    {
        shape: 2,
        sprite: spr_baibianshe_2,
        cost: 375,
        cooldown: 3300,
        description: "双子百变蛇：变身出3张全屏范围内上一张种下的卡片",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_baibianshe_2
    }]);
    register_card("mozhang", obj_mozhang, [
    {
        shape: 0,
        sprite: spr_mozhang,
        cost: 310,
        cooldown: 2520,
        description: "魔杖蛇：为周围5*5范围旋转攻击卡片和本行直线喷射类卡片提高攻击力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_mozhang
    },
    {
        shape: 1,
        sprite: spr_mozhang_1,
        cost: 310,
        cooldown: 2520,
        description: "青木魔杖蛇：为周围5*5范围旋转攻击卡片和本行直线喷射类卡片提高攻击力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_mozhang_1
    },
    {
        shape: 2,
        sprite: spr_mozhang_2,
        cost: 310,
        cooldown: 2520,
        description: "凤羽魔杖蛇：为周围5*5范围旋转攻击卡片和本行直线喷射类卡片提高攻击力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_mozhang_2
    }]);
    register_card("clotho", obj_clotho, [
    {
        shape: 0,
        sprite: spr_clotho_icon,
        cost: 400,
        cooldown: 3600,
        description: "克洛托神使：随机增加或降低3*3范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho
    },
    {
        shape: 1,
        sprite: spr_clotho_icon_1,
        cost: 400,
        cooldown: 3600,
        description: "克洛托圣神：随机增加3*3范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho_1
    },
    {
        shape: 2,
        sprite: spr_clotho_icon_2,
        cost: 400,
        cooldown: 3600,
        description: "命运女神·克洛托：随机增加5*5范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho_2
    },
    {
        shape: 3,
        sprite: spr_clotho_icon_3,
        cost: 400,
        cooldown: 3600,
        description: "至尊命运女神：随机增加5*7范围内卡片星级，一段时间后恢复",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_clotho_3
    }]);
    register_card("time_god", obj_time_god, [
    {
        shape: 0,
        sprite: spr_time_god,
        cost: 370,
        cooldown: 3600,
        description: "柯罗诺斯神使：持续给3*3范围内卡片缩短冷却时间",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god
    },
    {
        shape: 1,
        sprite: spr_time_god_1,
        cost: 370,
        cooldown: 3600,
        description: "柯罗诺斯圣神：持续给3*3范围内卡片缩短冷却时间",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god_1
    },
    {
        shape: 2,
        sprite: spr_time_god_2,
        cost: 370,
        cooldown: 3600,
        description: "时间神·柯罗诺斯：持续给5*5范围内卡片缩短冷却时间",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god_2
    },
    {
        shape: 3,
        sprite: spr_time_god_3,
        cost: 370,
        cooldown: 3600,
        description: "至尊时间神：持续给全屏范围内卡片缩短冷却时间",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_time_god_3
    }]);
    register_card("firework_dragon_real", obj_firework_dragon_real, [
    {
        shape: 0,
        sprite: spr_firework_dragon,
        cost: 150,
        cooldown: 420,
        description: "真·花火龙：释放产生大量火苗的烟花",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_firework_dragon_1,
        cost: 150,
        cooldown: 420,
        description: "真·灼灼花火龙：释放产生大量火苗的烟花",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_firework_dragon_icon_2,
        cost: 150,
        cooldown: 420,
        description: "真·炽焰花火龙：释放产生大量火苗的烟花",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_firework_dragon_2
    }]);
    register_card("sun_god", obj_sun_god, [
    {
        shape: 0,
        sprite: spr_sun_god,
        cost: 200,
        cooldown: 1800,
        description: "阿波罗神使：一次生产六朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_sun_god_1,
        cost: 150,
        cooldown: 1500,
        description: "阿波罗圣神：一次生产八朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_sun_god_2,
        cost: 100,
        cooldown: 1200,
        description: "太阳神·阿波罗：一次生产十朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_sun_god_3_icon,
        cost: 25,
        cooldown: 600,
        description: "至尊太阳神：一次生产十二朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sun_god_3
    }]);
    register_card("war_god", obj_war1_god, [
    {
        shape: 0,
        sprite: spr_war_god,
        cost: 150,
        cooldown: 420,
        description: "阿瑞斯神使：向前后两个方向发射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_war_god_1,
        cost: 150,
        cooldown: 420,
        description: "阿瑞斯圣神：向前后两个方向发射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_war_god_2,
        cost: 150,
        cooldown: 420,
        description: "战神·阿瑞斯：向前后两个方向发射子弹，每4轮额外向前发射一枚超级子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_war_god_3,
        cost: 150,
        cooldown: 420,
        description: "至尊战神：向前后两个方向发射子弹，每4轮额外发射一枚超级子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("love_god", obj_love_god, [
    {
        shape: 0,
        sprite: spr_love_god,
        cost: 300,
        cooldown: 420,
        description: "丘比特神使：向前方三行射出6发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_love_god_1,
        cost: 300,
        cooldown: 420,
        description: "丘比特圣神：向前方三行各射出2发强力子弹，中路子弹增加",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_love_god_2,
        cost: 300,
        cooldown: 420,
        description: "爱神·丘比特：向前方三行各射出3发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_love_god_3,
        cost: 300,
        cooldown: 420,
        description: "至尊爱神：向前方三行各射出3发强力子弹，每4轮额外发射3发超级子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("thor", obj_thor, [
    {
        shape: 0,
        sprite: spr_thor_icon,
        cost: 200,
        cooldown: 420,
        description: "索尔神使：连续发出2发冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor,
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_thor_icon_1,
        cost: 200,
        cooldown: 420,
        description: "索尔圣神：连续发出3发冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor_1,
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_thor_icon_2,
        cost: 200,
        cooldown: 420,
        description: "雷神·索尔：连续发出3发冰锤，每3轮额外发出1发超级冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor_2,
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_thor_icon_3,
        cost: 200,
        cooldown: 420,
        description: "至尊雷神：连续发出3发冰锤，其中1发为超级冰锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_thor_3,
        is_gold: 1
    }]);
    register_card("moon_god", obj_moon_god, [
    {
        shape: 0,
        sprite: spr_moon_god,
        cost: 225,
        cooldown: 3000,
        description: "狄安娜神使：甩出六发追踪子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_moon_god_1,
        cost: 225,
        cooldown: 3000,
        description: "狄安娜圣神：甩出七发追踪子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_moon_god_2,
        cost: 225,
        cooldown: 3000,
        description: "月神·狄安娜：甩出七发追踪子弹，首发为超级子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_moon_god_3,
        cost: 225,
        cooldown: 3000,
        description: "至尊月神：甩出八发追踪子弹，首发为超级子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("poseidon", obj_poseidon, [
    {
        shape: 0,
        sprite: spr_poseidon,
        cost: 275,
        cooldown: 1800,
        description: "波塞冬神使：5*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_poseidon_1,
        cost: 275,
        cooldown: 1800,
        description: "波塞冬圣神：5*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_poseidon_2,
        cost: 275,
        cooldown: 1200,
        description: "海神·波塞冬：5*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_poseidon_3,
        cost: 275,
        cooldown: 1200,
        description: "至尊海神：7*5范围穿透攻击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("odin", obj_odin, [
    {
        shape: 0,
        sprite: spr_odin,
        cost: 230,
        cooldown: 420,
        description: "奥丁神使：发射冈格尼尔穿透攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_odin_1,
        cost: 230,
        cooldown: 420,
        description: "奥丁圣神：发射冈格尼尔穿透攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_odin_2,
        cost: 230,
        cooldown: 420,
        description: "主神·奥丁：发射冈格尼尔穿透攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_odin_3,
        cost: 230,
        cooldown: 420,
        description: "至尊主神：发射冈格尼尔穿透攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("zeus", obj_zeus, [
    {
        shape: 0,
        sprite: spr_zeus,
        cost: 375,
        cooldown: 1200,
        description: "宙斯神使：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_zeus_1,
        cost: 375,
        cooldown: 1200,
        description: "宙斯圣神：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_zeus_2,
        cost: 375,
        cooldown: 1200,
        description: "天神·宙斯：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_zeus_3,
        cost: 375,
        cooldown: 1200,
        description: "至尊天神：全屏轰击，造成5×5范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("ice_god", obj_ice_god, [
    {
        shape: 0,
        sprite: spr_ice_god,
        cost: 325,
        cooldown: 900,
        description: "典伊神使：召唤8颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_ice_god_1,
        cost: 225,
        cooldown: 900,
        description: "典伊圣神：召唤8颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_ice_god_2,
        cost: 225,
        cooldown: 900,
        description: "冰神·典伊：召唤10颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_ice_god_3,
        cost: 225,
        cooldown: 900,
        description: "至尊冰神：召唤12颗冰晶轰击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("ghost_god", obj_ghost_god, [
    {
        shape: 0,
        sprite: spr_ghost_god,
        cost: 225,
        cooldown: 3000,
        description: "哈迪斯神使：向五个方向发射子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_ghost_god_1,
        cost: 225,
        cooldown: 3000,
        description: "哈迪斯圣神：向五个方向发射子弹和减速穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_ghost_god_2,
        cost: 225,
        cooldown: 3000,
        description: "冥神·哈迪斯：向五个方向发射子弹和减速穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_ghost_god_3,
        cost: 225,
        cooldown: 3000,
        description: "至尊冥神：向五个方向发射2枚减速穿透子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("hera", obj_hera, [
    {
        shape: 0,
        sprite: spr_hera_icon_1,
        cost: 125,
        cooldown: 1800,
        description: "赫拉神使：保护被罩住的卡片",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_outer_1,
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_hera_icon_2,
        cost: 125,
        cooldown: 1800,
        description: "赫拉圣神：保护被罩住的卡片并反伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_1_outer_1,
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_hera_icon_3,
        cost: 125,
        cooldown: 1800,
        description: "天后·赫拉：保护被罩住的卡片并反伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_2_outer_1,
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_hera_icon_4,
        cost: 125,
        cooldown: 1800,
        description: "至尊天后：保护被罩住的卡片并反伤",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_hera_3_outer_1,
        is_gold: 1
    }]);
    register_card("fire_god", obj_fire_god, [
    {
        shape: 0,
        sprite: spr_fire_god,
        cost: 225,
        cooldown: 420,
        description: "洛基神使：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_fire_god_1,
        cost: 175,
        cooldown: 420,
        description: "洛基圣神：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_fire_god_2,
        cost: 175,
        cooldown: 420,
        description: "火神·洛基：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_fire_god_3,
        cost: 100,
        cooldown: 420,
        description: "至尊火神：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("water_god", obj_water_god, [
    {
        shape: 0,
        sprite: spr_water_god,
        cost: 150,
        cooldown: 420,
        description: "忒提丝神使：反弹子弹并附加伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
    sprite: spr_water_god_1,
    cost: 150,
        cooldown: 420,
        description: "忒提丝圣神：反弹子弹并附加伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
    sprite: spr_water_god_2_icon,
    cost: 150,
        cooldown: 420,
        description: "水神·忒提丝：反弹子弹并附加伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_water_god_2
    },
    {
        shape: 3,
    sprite: spr_water_god_3_icon,
    cost: 150,
        cooldown: 420,
        description: "至尊水神：反弹子弹并附加双倍伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_water_god_3
    }]);
    register_card("power_god", obj_power_god, [
    {
        shape: 0,
        sprite: spr_power_god,
        cost: 275,
        cooldown: 420,
        description: "赫丘利神使：发射两发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_power_god_1,
        cost: 275,
        cooldown: 420,
        description: "赫丘利圣神：发射两发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_power_god_2,
        cost: 275,
        cooldown: 420,
        description: "大力神·赫丘利：发射三发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_power_god_3,
        cost: 275,
        cooldown: 420,
        description: "至尊大力神：发射四发强力子弹追踪攻击空中鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    }]);
    register_card("sheng_huo", obj_sh, [
    {
        shape: 0,
        sprite: spr_sh,
        cost: 320,
        cooldown: 420,
        description: "赫斯提亚神使：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_sh_icon_1,
        cost: 320,
        cooldown: 420,
        description: "赫斯提亚圣神：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sh_1
    },
    {
        shape: 2,
        sprite: spr_sh_icon_2,
        cost: 320,
        cooldown: 420,
        description: "圣火女神·赫斯提亚：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sh_2
    },
    {
        shape: 3,
        sprite: spr_sh_icon_3,
        cost: 320,
        cooldown: 420,
        description: "至尊圣火女神：施展火焰术，向前方3行释放神圣穿透型火焰，灼烧沿途鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_sh_3
    }]);
    register_card("save_god", obj_save_god, [
    {
        shape: 0,
        sprite: spr_save_god_0,
        cost: 375,
        cooldown: 1800,
        description: "灵鱼摩羯神使：化身为4条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_save_god_1,
        cost: 375,
        cooldown: 1800,
        description: "灵鱼摩羯圣神：化身为4条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_save_god_2_icon,
        cost: 375,
        cooldown: 1800,
        description: "救世神·灵鱼摩羯：化身为5条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_save_god_2
    },
    {
        shape: 3,
        sprite: spr_save_god_3_icon,
        cost: 375,
        cooldown: 1800,
        description: "至尊救世神：化身为7条灵鱼，冲撞沿途遇到的老鼠",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_save_god_3
    }]);
    register_card("ymir", obj_ymir, [
    {
        shape: 0,
        sprite: spr_ymir_icon,
        cost: 380,
        cooldown: 420,
        description: "尤弥尔神使：向前方三行投出共6发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir,
        is_gold: 1
    },
    {
        shape: 1,
        sprite: spr_ymir_icon_1,
        cost: 380,
        cooldown: 420,
        description: "尤弥尔圣神：向前方三行投出共7发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir_1,
        is_gold: 1
    },
    {
        shape: 2,
        sprite: spr_ymir_icon_2,
        cost: 380,
        cooldown: 420,
        description: "巨神·尤弥尔：向前方三行投出共9发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir_2,
        is_gold: 1
    },
    {
        shape: 3,
        sprite: spr_ymir_icon_3,
        cost: 380,
        cooldown: 420,
        description: "至尊巨神：向前方三行投出共12发巨锤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_ymir_3,
        is_gold: 1
    }]);
    register_card("joker", obj_joker, [
    {
        shape: 0,
        sprite: spr_joker_icon,
        cost: 275,
        cooldown: 420,
        description: "埃罗斯神使：连续发射3发溅射子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_0
    },
    {
        shape: 1,
        sprite: spr_joker_icon_1,
        cost: 275,
        cooldown: 420,
        description: "埃罗斯圣神：连续发射3发溅射子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_1
    },
    {
        shape: 2,
        sprite: spr_joker_icon_2,
        cost: 275,
        cooldown: 420,
        description: "恶作剧神·埃罗斯：连续发射4发溅射子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_2
    },
    {
        shape: 3,
        sprite: spr_joker_icon_3,
        cost: 275,
        cooldown: 420,
        description: "至尊恶作剧神：连续发射4发溅射子弹，先后攻击本行空、地、水陆老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_joker_3
    }]);
    register_card("athena", obj_athena, [
    {
        shape: 0,
        sprite: spr_athena,
        cost: 375,
        cooldown: 1200,
        description: "雅典娜守护：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_athena_1,
        cost: 375,
        cooldown: 1200,
        description: "雅典娜圣衣：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_athena_2,
        cost: 375,
        cooldown: 1200,
        description: "雅典娜光辉：全屏轰击，造成3×3范围伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("shuangzi", obj_shuangzi, [
    {
        shape: 0,
        sprite: spr_shuangzi,
        cost: 200,
        cooldown: 3000,
        description: "双子座精灵：一次性产出4朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_shuangzi_1,
        cost: 200,
        cooldown: 1800,
        description: "双子座战将：一次性产出4朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_shuangzi_2,
        cost: 200,
        cooldown: 1200,
        description: "双子座星宿：一次性产出6朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("sheshou", obj_sheshou, [
    {
        shape: 0,
        sprite: spr_sheshou,
        cost: 300,
        cooldown: 420,
        description: "射手座精灵：向前方三行射出4发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_sheshou_1,
        cost: 300,
        cooldown: 420,
        description: "射手座战将：向前方三行射出4发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_sheshou_2,
        cost: 300,
        cooldown: 420,
        description: "射手座星宿：向前方三行射出6发强力子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("tiancheng", obj_tiancheng, [
    {
        shape: 0,
        sprite: spr_tiancheng,
        cost: 150,
        cooldown: 420,
        description: "天秤座精灵：向前后各射出3发比较强力的子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_tiancheng_1,
        cost: 150,
        cooldown: 420,
        description: "天秤座战将：向前后各射出3发比较强力的子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_tiancheng_2,
        cost: 150,
        cooldown: 420,
        description: "天秤座星宿：向前后各射出4发比较强力的子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("shuangyu", obj_shuangyu, [
    {
        shape: 0,
        sprite: spr_shuangyu_icon,
        cost: 200,
        cooldown: 420,
        description: "双鱼座精灵：投掷两颗带有减速的冰鱼",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_shuangyu
    },
    {
        shape: 1,
        sprite: spr_shuangyu_1_icon,
        cost: 200,
        cooldown: 420,
        description: "双鱼座战将：投掷两颗带有减速的冰鱼",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_shuangyu_1
    },
    {
        shape: 2,
        sprite: spr_shuangyu_2_icon,
        cost: 200,
        cooldown: 420,
        description: "双鱼座星宿：投掷两颗带有减速的强力冰鱼",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_shuangyu_2
    }]);
    register_card("juxie", obj_juxie, [
    {
        shape: 0,
        sprite: spr_juxie,
        cost: 225,
        cooldown: 1800,
        description: "巨蟹座精灵：发射4发强力钳子，全屏跟踪，海陆两栖",
        plant_type: "normal",
        feature_type: "amphi",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_juxie_1,
        cost: 225,
        cooldown: 1200,
        description: "巨蟹座战将：发射4发强力钳子，全屏跟踪，海陆两栖",
        plant_type: "normal",
        feature_type: "amphi",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_juxie_2,
        cost: 225,
        cooldown: 900,
        description: "巨蟹座星宿：发射6发强力钳子，全屏跟踪，海陆两栖",
        plant_type: "normal",
        feature_type: "amphi",
        target_card: "none"
    }]);
    register_card("shizi", obj_shizi, [
    {
        shape: 0,
        sprite: spr_shizi,
        cost: 275,
        cooldown: 1800,
        description: "狮子座精灵：5×5范围穿透打击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_shizi_1,
        cost: 275,
        cooldown: 1200,
        description: "狮子座战将：5×5范围穿透打击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_shizi_2,
        cost: 275,
        cooldown: 900,
        description: "狮子座星宿：5×5范围两次穿透打击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("jinniu", obj_jinniu, [
    {
        shape: 0,
        sprite: spr_jinniu,
        cost: 225,
        cooldown: 420,
        description: "金牛座精灵：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_jinniu_1,
        cost: 175,
        cooldown: 420,
        description: "金牛座战将：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_jinniu_2,
        cost: 175,
        cooldown: 420,
        description: "金牛座星宿：点燃子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("chunv", obj_chunv, [
    {
        shape: 0,
        sprite: spr_chunv_0_3,
        cost: 175,
        cooldown: 1800,
        description: "处女座精灵：保护卡牌，并反弹伤害",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_chunv_1_4,
        cost: 200,
        cooldown: 1800,
        description: "处女座战将：保护卡牌，并反弹伤害",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_chunv_2_4,
        cost: 225,
        cooldown: 1800,
        description: "处女座星宿：保护卡牌，并反弹伤害",
        plant_type: "shield_outer",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("baiyang", obj_baiyang, [
    {
        shape: 0,
        sprite: spr_baiyang_icon,
        cost: 300,
        cooldown: 3000,
        description: "白羊座精灵：冲撞清除一行鼠军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_baiyang
    },
    {
        shape: 1,
        sprite: spr_baiyang_icon,
        cost: 200,
        cooldown: 3000,
        description: "白羊座战将：冲撞清除一行鼠军，且无需格子放置",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_baiyang
    },
    {
        shape: 2,
        sprite: spr_baiyang_icon,
        cost: 200,
        cooldown: 3000,
        description: "白羊座星宿：冲撞清除三行鼠军，且无需格子放置",
        plant_type: "coffee",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_baiyang
    }]);
    register_card("mojie", obj_mojie, [
    {
        shape: 0,
        sprite: spr_mojie,
        cost: 300,
        cooldown: 3000,
        description: "摩羯座精灵：3×3范围内持续伤害并减速",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_mojie_1,
        cost: 300,
        cooldown: 3000,
        description: "摩羯座战将：3×3范围内持续伤害并减速",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_mojie_2,
        cost: 300,
        cooldown: 3000,
        description: "摩羯座星宿：5×5范围内持续伤害并减速",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("corn_shooter", obj_corn_shooter, [
    {
        shape: 0,
        sprite: spr_corn_shooter,
        cost: 250,
        cooldown: 3000,
        description: "玉蜀黍：发射三颗玉米",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_corn_shooter_1,
        cost: 250,
        cooldown: 3000,
        description: "奶油玉米机枪：发射六颗玉米",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_corn_shooter_2,
        cost: 250,
        cooldown: 3000,
        description: "加农玉米机枪：发射六颗玉米",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("warm_birds", obj_warm_birds, [
    {
        shape: 0,
        sprite: spr_warm_birds,
        cost: 125,
        cooldown: 1800,
        description: "暖暖鸡：一次生产3朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_warm_birds_1,
        cost: 125,
        cooldown: 1800,
        description: "焰羽暖暖鸡：一次生产4朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_warm_birds_2,
        cost: 125,
        cooldown: 900,
        description: "日耀暖暖鸡：一次生产5朵火苗",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    // 已移除 sea_star（不需要的卡片）
    // 已移除 tanghulu（对象未创建）
    register_card("cold_drew", obj_cold_drew, [
    {
        shape: 0,
        sprite: spr_cold_drew_machine_icon,
        cost: 295,
        cooldown: 900,
        description: "冰块冷萃机：对全屏敌人发射至多4颗追踪冰块",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_cold_drew_machine
    },
    {
        shape: 1,
        sprite: spr_cold_drew_machine_icon_1,
        cost: 295,
        cooldown: 900,
        description: "低温冷萃机：对全屏敌人发射至多5颗追踪冰块",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_cold_drew_machine_1
    },
    {
        shape: 2,
        sprite: spr_cold_drew_machine_icon_2,
        cost: 295,
        cooldown: 900,
        description: "迅捷冷萃机：对全屏敌人发射6颗追踪冰块，可集火",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_cold_drew_machine_2
    }]);
    register_card("berry_dessert", obj_berry_dessert, [
    {
        shape: 0,
        sprite: spr_berry_dessert_icon,
        cost: 260,
        cooldown: 2400,
        description: "莓果点心：为3x3范围内追踪类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_berry_dessert_icon_1,
        cost: 260,
        cooldown: 2400,
        description: "薄荷莓果点心：为5x5范围内追踪类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_berry_dessert_icon_2,
        cost: 260,
        cooldown: 2400,
        description: "流心莓果点心：为5x5范围内追踪类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("grilled_lizard_pult", obj_grilled_lizard_pult, [
    {
        shape: 0,
        sprite: spr_grilled_lizard_pult,
        cost: 275,
        cooldown: 420,
        description: "烤蜥蜴投手：向前投掷配料爆弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_grilled_lizard_pult_1,
        cost: 275,
        cooldown: 420,
        description: "坚果蜥蜴投手：向前投掷配料爆弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_grilled_lizard_pult_2,
        cost: 275,
        cooldown: 420,
        description: "花椒蜥蜴投手：向前投掷2发配料爆弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("blueberry_tower", obj_blueberry_tower, [
    {
        shape: 0,
        sprite: spr_blueberry_tower,
        cost: 160,
        cooldown: 2100,
        description: "蓝莓信号塔塔：为本行投掷卡片增加攻击力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);
    register_card("zhuzhujiaqiang", obj_zhuzhujiaqiang, [
    {
        shape: 0,
        sprite: spr_zhuzhujiaqiang,
        cost: 175,
        cooldown: 2100,
        description: "猪猪加强器：为本行投掷类卡片增加攻击力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_zhuzhujiaqiang
    },
    {
        shape: 1,
        sprite: spr_zhuzhujiaqiang_1,
        cost: 175,
        cooldown: 2100,
        description: "猪猪信号塔：为本行投掷类卡片增加攻击力，体力翻倍",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_zhuzhujiaqiang_1
    },
    {
        shape: 2,
        sprite: spr_zhuzhujiaqiang_2,
        cost: 175,
        cooldown: 2100,
        description: "猪猪发射站：为本行投掷类卡片大幅增加攻击力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_zhuzhujiaqiang_2
    }]);
    register_card("donut", obj_donut, [
    {
        shape: 0,
        sprite: spr_donut_3,
        cost: 200,
        cooldown: 420,
        description: "梦幻多拿滋：连续攻击本行鼠军，优先空军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_donut
    },
    {
        shape: 1,
        sprite: spr_donut_4,
        cost: 200,
        cooldown: 420,
        description: "仙女多拿滋：连续攻击本行鼠军，优先空军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_donut_1
    },
    {
        shape: 2,
        sprite: spr_donut_5,
        cost: 200,
        cooldown: 420,
        description: "女王多拿滋：连续攻击2次本行鼠军，优先空军",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_donut_2
    }]);
    register_card("spoon_rabbit", obj_spoon_rabbit, [
    {
        shape: 0,
        sprite: spr_spoon_rabbit_icon,
        cost: 300,
        cooldown: 420,
        description: "勺勺兔：向前方3行投掷子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_spoon_rabbit
    },
    {
        shape: 1,
        sprite: spr_spoon_rabbit_icon_1,
        cost: 300,
        cooldown: 420,
        description: "增强勺勺兔：向前方3行投掷子弹，中路子弹增加",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_spoon_rabbit_1
    },
    {
        shape: 2,
        sprite: spr_spoon_rabbit_icon_2,
        cost: 300,
        cooldown: 420,
        description: "盖世勺勺兔：向前方3行各投掷2发子弹",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_spoon_rabbit_2
    }]);
    register_card("hspeed_juicer", obj_hspeed_juicer, [
    {
        shape: 0,
        sprite: spr_hspeed_juicer,
        cost: 260,
        cooldown: 2700,
        description: "加速榨汁机：为3x3范围内喷壶类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 1,
        sprite: spr_hspeed_juicer_1,
        cost: 260,
        cooldown: 2700,
        description: "苹果榨汁机：为3x3范围内喷壶类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    },
    {
        shape: 2,
        sprite: spr_hspeed_juicer_2,
        cost: 260,
        cooldown: 2700,
        description: "大菠萝榨汁机：为5x5范围内喷壶类卡片提供增伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none"
    }]);

register_card("xiangshui_god", obj_xiangshui_god, [
{
    shape: 0,
    sprite: spr_xiangshui_god,
    cost: 260,
    cooldown: 2400,
    description: "塔利亚神使：为5*5范围内追踪卡片增加攻击力",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_xiangshui_god
},
{
    shape: 1,
    sprite: spr_xiangshui_god_1,
    cost: 260,
    cooldown: 2400,
    description: "塔利亚圣神：为5*5范围内追踪卡片增加攻击力",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_xiangshui_god_1
},
{
    shape: 2,
    sprite: spr_xiangshui_god_2,
    cost: 260,
    cooldown: 2400,
    description: "宴飨女神·塔利亚：为5*5范围内追踪卡片增加攻击力",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_xiangshui_god_2
},
{
    shape: 3,
    sprite: spr_xiangshui_god_3,
    cost: 260,
    cooldown: 2400,
    description: "至尊宴飨女神：为5*7范围内追踪卡片增加攻击力",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_xiangshui_god_3
}]);

register_card("fengrao_god", obj_fengrao_god, [
{
    shape: 0,
    sprite: spr_fengrao_god,
    cost: 300,
    cooldown: 2100,
    description: "弗雷神使：为5*5范围内五向类卡片增加攻击力，同类卡片效果不叠加",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_fengrao_god
},
{
    shape: 1,
    sprite: spr_fengrao_god_1,
    cost: 300,
    cooldown: 2100,
    description: "弗雷圣神：为5*5范围内五向及多向类卡片增加攻击力",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_fengrao_god_1
},
{
    shape: 2,
    sprite: spr_fengrao_god_2,
    cost: 300,
    cooldown: 2100,
    description: "丰饶神·弗雷：为5*5范围内五向及多向类卡片增加攻击力",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_fengrao_god_2
},
{
    shape: 3,
    sprite: spr_fengrao_god_3,
    cost: 300,
    cooldown: 2100,
    description: "至尊丰饶神：为5*5范围内五向及多向类卡片增加攻击力，同类卡片效果可叠加2次",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_fengrao_god_3
}]);

register_card("houyi_god", obj_houyi_god, [
{
    shape: 0,
    sprite: spr_houyi_god,
    cost: 385,
    cooldown: 420,
    description: "后羿神使：向前方3路共发射9发穿透箭矢，几率产生三昧真火灼烧鼠军",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_houyi_god
},
{
    shape: 1,
    sprite: spr_houyi_god_1,
    cost: 385,
    cooldown: 420,
    description: "后羿圣神：向前方3路各发射3发穿透箭矢，中路子弹增加，几率产生三昧真火灼烧鼠军",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_houyi_god_1
},
{
    shape: 2,
    sprite: spr_houyi_god_2,
    cost: 385,
    cooldown: 420,
    description: "宗布神·后羿：向前方3路各发射4发穿透箭矢，几率产生三昧真火灼烧鼠军",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_houyi_god_2
},
{
    shape: 3,
    sprite: spr_houyi_god_3,
    cost: 385,
    cooldown: 420,
    description: "至尊宗布神：向前方3路各发射5发穿透箭矢，几率产生三昧真火灼烧鼠军",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_houyi_god_3
}]);

register_card("gongjiang_god", obj_gongjiang_god, [
{
    shape: 0,
    sprite: spr_gongjiang_god,
    cost: 385,
    cooldown: 420,
    description: "鲁班神使：发射1发河豚子弹沿固定轨迹往返",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_gongjiang_god
},
{
    shape: 1,
    sprite: spr_gongjiang_god_1,
    cost: 385,
    cooldown: 420,
    description: "鲁班圣神：发射1发河豚子弹沿固定轨迹往返",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_gongjiang_god_1
},
{
    shape: 2,
    sprite: spr_gongjiang_god_2,
    cost: 385,
    cooldown: 420,
    description: "工匠神·鲁班：发射1发河豚子弹沿固定轨迹往返",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_gongjiang_god_2
},
{
    shape: 3,
    sprite: spr_gongjiang_god_3,
    cost: 385,
    cooldown: 420,
    description: "至尊工匠神：发射3发河豚子弹沿各自的固定轨迹往返",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_gongjiang_god_3
}]);

register_card("heian_god",obj_heian_god,[
	    {"shape":0, "sprite":spr_dark_god, "cost":330, "cooldown":60*60, "description":"霍德尔神使:对5*5范围内的鼠军产生大量伤害，持续一段时间后消失","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1},
	    {"shape":1, "sprite":spr_dark_god_1, "cost":330, "cooldown":60*60, "description":"霍德尔圣神:对5*5范围内的鼠军产生大量伤害，持续一段时间后消失","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1},
		{"shape":2, "sprite":spr_dark_god_2, "cost":330, "cooldown":60*60, "description":"黑暗神·霍德尔:对5*7范围内的鼠军产生大量伤害，持续一段时间后消失","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1},
		{"shape":3, "sprite":spr_dark_god_4, "cost":330, "cooldown":60*60, "description":"至尊黑暗神:对5*7范围内的鼠军产生大量伤害，持续一段时间后消失","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1,"place_preview":spr_dark_god_3}
	]);

register_card("hundun_god", obj_hundun_god, [
{
    shape: 0,
    sprite: spr_hundun_god,
    cost: 205,
    cooldown: 1800,
    description: "混沌神使：吞噬自身右侧为中心5*5范围内的普通敌人，对精英造成大量伤害，死亡时产生3*3爆炸",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hundun_god
},
{
    shape: 1,
    sprite: spr_hundun_god_1,
    cost: 205,
    cooldown: 1800,
    description: "混沌圣神：吞噬自身右侧为中心5*5范围内的普通敌人，对精英造成大量伤害，死亡时产生5*5爆炸",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hundun_god_1
},
{
    shape: 2,
    sprite: spr_hundun_god_2,
    cost: 205,
    cooldown: 1800,
    description: "上古神·混沌：吞噬自身右侧为中心5*7范围内的普通敌人，对精英造成大量伤害，死亡时产生5*5爆炸",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hundun_god_2
},
{
    shape: 3,
    sprite: spr_hundun_god_3,
    cost: 205,
    cooldown: 1800,
    description: "至尊上古神：吞噬自身右侧为中心5*7范围内的普通敌人，对精英造成大量伤害，死亡时产生5*5爆炸",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hundun_god_3
}]);

register_card("guangming_god",obj_guangming_god,[
	    {"shape":0, "sprite":spr_light_god, "cost":395, "cooldown":60*60, "description":"巴德尔神使:巴德尔神使：每隔一段时间在自身周围召唤5*5格圣光攻击范围内鼠军","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1},
	    {"shape":1, "sprite":spr_light_god_1, "cost":395, "cooldown":60*60, "description":"巴德尔圣神:巴德尔圣神：每隔一段时间在自身周围召唤5*5格圣光攻击范围内鼠军","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1},
		{"shape":2, "sprite":spr_light_god_2, "cost":395, "cooldown":60*60, "description":"光明神·巴德尔:光明神·巴德尔：每隔一段时间在自身周围召唤5*5格圣光攻击范围内鼠军","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1},
		{"shape":3, "sprite":spr_light_god_3, "cost":395, "cooldown":60*60, "description":"至尊光明神:至尊光明神：每隔一段时间在自身周围召唤5*7格圣光攻击范围内鼠军","plant_type":"normal","feature_type":"normal","target_card":"none","is_gold":1}
	]);

register_card("lingrong_god", obj_lingrong_god, [
{
    shape: 0,
    sprite: spr_lingrong_god,
    cost: 25,
    cooldown: 420,
    description: "魔导士软糖：三合一承载卡片，可在海底、陆地、水面、岩浆上承载卡片并填补空洞",
    plant_type: "coffee",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_lingrong_god
},
{
    shape: 1,
    sprite: spr_lingrong_god_1,
    cost: 0,
    cooldown: 420,
    description: "彩虹棉花软糖：竖向生成三张，三合一承载卡片",
    plant_type: "coffee",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_lingrong_god_1
},
{
    shape: 2,
    sprite: spr_lingrong_god_2,
    cost: 0,
    cooldown: 420,
    description: "无敌猫猫软糖：直接生成九张，三合一承载卡片",
    plant_type: "coffee",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_lingrong_god_2
}]);

    register_card("panduola_god", obj_panduola_god, [
{
    shape: 0,
    sprite: spr_panduola_god,
    cost: 255,
    cooldown: 2400,
    description: "潘多拉：放下立即产生3*3范围爆炸，并在本行留下毒气",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_panduola_god
},
{
    shape: 1,
    sprite: spr_panduola_god_1,
    cost: 255,
    cooldown: 2400,
    description: "潘多拉魔盒：放下立即产生3*3范围爆炸，并在本行留下毒气",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_panduola_god_1
},
{
    shape: 2,
    sprite: spr_panduola_god_2,
    cost: 255,
    cooldown: 2400,
    description: "疫神·潘多拉：放下立即产生3*3范围爆炸，并在本行和本列留下毒气，在爆炸范围内留下鼠疫",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_panduola_god_2
},
{
    shape: 3,
    sprite: spr_panduola_god_3,
    cost: 255,
    cooldown: 2400,
    description: "至尊疫神：放下立即产生全屏范围爆炸，并在本行和本列留下毒气，在爆炸范围内留下鼠疫",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_panduola_god_3
}]);

    register_card("12yinliao", obj_12yinliao, [
    {
        shape: 0,
        sprite: spr_12yinliao,
        cost: 200,
        cooldown: 4800,
        description: "12饮料精灵：释放全屏美食，立即回满体力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_12yinliao
    }]);

    register_card("anranxiaohunfan", obj_anranxiaohunfan, [
    {
        shape: 0,
        sprite: spr_anranxiaohunfan,
        cost: 325,
        cooldown: 3600,
        description: "黯然销魂饭：复活3*3范围内1个死亡的美食",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_anranxiaohunfan
    },
    {
        shape: 1,
        sprite: spr_anranxiaohunfan_1,
        cost: 275,
        cooldown: 3600,
        description: "培根香肠饭：复活3*3范围内1个死亡的美食",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_anranxiaohunfan_1
    },
    {
        shape: 2,
        sprite: spr_anranxiaohunfan_2,
        cost: 275,
        cooldown: 3600,
        description: "天妇罗盖饭：复活3*3范围内2个死亡的美食",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_anranxiaohunfan_2
    }]);

    register_card("dandantu", obj_dandantu, [
    {
        shape: 0,
        sprite: spr_dandantu,
        cost: 325,
        cooldown: 90 * 60,
        description: "蛋蛋兔：储存3x3范围内子弹伤害，死亡时在本行爆炸释放",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_dandantu
    },
    {
        shape: 1,
        sprite: spr_dandantu_1,
        cost: 325,
        cooldown: 90 * 60,
        description: "智能蛋蛋兔：储存3x3范围内子弹伤害，死亡时在本行爆炸释放",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_dandantu_1
    },
    {
        shape: 2,
        sprite: spr_dandantu_2,
        cost: 325,
        cooldown: 90 * 60,
        description: "外星蛋蛋兔：储存3x3范围内子弹伤害，死亡时在3行爆炸释放",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        place_preview: spr_dandantu_2
    }]);
    register_card("laipishe", obj_laipishe, [
    {
        shape: 0,
        sprite: spr_laipishe,
        cost: 365,
        cooldown: 2100,
        description: "赖皮蛇：召唤沿固定轨迹飞行的海胆子弹攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_laipishe
    },
    {
        shape: 1,
        sprite: spr_laipishe_1,
        cost: 365,
        cooldown: 2100,
        description: "宝石赖皮蛇：召唤沿固定轨迹飞行的海胆子弹攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_laipishe_1
    },
    {
        shape: 2,
        sprite: spr_laipishe_2,
        cost: 365,
        cooldown: 2100,
        description: "大王赖皮蛇：召唤沿固定轨迹飞行的海胆子弹攻击敌人",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_laipishe_2
    }]);

register_card("nizhuanniu", obj_nizhuanniu, [
    {
        shape: 0,
        sprite: spr_nizhuanniu,
        cost: 150,
        cooldown: 3000,
        description: "逆转牛：将3*3范围内普通老鼠逆转到其所在行的出生位置",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_nizhuanniu
    },
    {
        shape: 1,
        sprite: spr_nizhuanniu_1,
        cost: 150,
        cooldown: 3000,
        description: "匀速逆转牛：将3*3范围内普通老鼠逆转到其所在行的出生位置，并造成伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_nizhuanniu_1
    },
    {
        shape: 2,
        sprite: spr_nizhuanniu_2,
        cost: 150,
        cooldown: 3000,
        description: "光速逆转牛：将5*5范围内普通老鼠逆转到其所在行的出生位置，并造成伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_nizhuanniu_2
    }]);

register_card("liehuohu", obj_liehuohu, [
    {
        shape: 0,
        sprite: spr_liehuohu,
        cost: 85,
        cooldown: 3300,
        description: "烈火虎：生产1朵火苗并将一部分产火存储于自身，死亡时释放",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_liehuohu
    },
    {
        shape: 1,
        sprite: spr_liehuohu_1,
        cost: 85,
        cooldown: 3300,
        description: "煤气烈火虎：生产2朵火苗并将一部分产火存储于自身，死亡时释放",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_liehuohu_1
    },
    {
        shape: 2,
        sprite: spr_liehuohu_2,
        cost: 85,
        cooldown: 3300,
        description: "燃油烈火虎：生产2朵火苗并将一部分产火存储于自身，死亡时释放",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_liehuohu_2
    }]);
    register_card("shegengbao", obj_shegengbao, [
    {
        shape: 0,
        sprite: spr_shegengbao,
        cost: 25,
        cooldown: 2880,
        description: "蛇羹煲：无需格子，回收目标格全部卡片的火苗能量",
        plant_type: "shegengbao",
        feature_type: "shegengbao",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_shegengbao
    },
    {
        shape: 1,
        sprite: spr_shegengbao_1,
        cost: 0,
        cooldown: 2880,
        description: "厨圣蛇羹煲：无需格子，回收目标格全部卡片的火苗能量",
        plant_type: "shegengbao",
        feature_type: "shegengbao",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_shegengbao_1
    },
    {
        shape: 2,
        sprite: spr_shegengbao_2,
        cost: 0,
        cooldown: 2880,
        description: "帝王蛇羹煲：无需格子，回收目标格全部卡片的火苗能量，返还翻倍",
        plant_type: "shegengbao",
        feature_type: "shegengbao",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_shegengbao_2
    }]);

    // ============================================
    // 顽皮龙 - 生肖卡·龙年卡
    // 辅助型防御卡，二段选点移动卡片/角色
    // 技能强化：不支持
    // ============================================
    register_card("wanpilong", obj_wanpilong, [
    {
        shape: 0,
        sprite: spr_wanpilong,
        cost: 100,
        cooldown: 3300,
        description: "顽皮龙：选择一张己方卡片，将其移动到周围5x5范围内的空格",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_wanpilong
    },
    {
        shape: 1,
        sprite: spr_wanpilong_1,
        cost: 100,
        cooldown: 3300,
        description: "捣蛋顽皮龙：选择一张己方卡片，将其移动到全屏范围任意空格",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_wanpilong_1
    },
    {
        shape: 2,
        sprite: spr_wanpilong_2,
        cost: 100,
        cooldown: 3300,
        description: "神奇顽皮龙：选择一张己方卡片或角色，将其移动到全屏范围任意空格",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_wanpilong_2
    }]);

    register_card("double_blade_snake", obj_double_blade_snake, [
    {
        shape: 0,
        sprite: spr_shuangrenshe,
        cost: 260,
        cooldown: 420,
        description: "双刃蛇：向前发射2发穿透剑气子弹，斩杀较低血量百分比的普通老鼠，斩杀对精英造成大量伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_shuangrenshe
    },
    {
        shape: 1,
        sprite: spr_shuangrenshe_1,
        cost: 260,
        cooldown: 420,
        description: "武士双刃蛇：向前发射3发穿透剑气子弹，斩杀较低血量百分比的普通老鼠，斩杀对精英造成大量伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_shuangrenshe_1
    },
    {
        shape: 2,
        sprite: spr_shuangrenshe_2,
        cost: 260,
        cooldown: 420,
        description: "游侠双刃蛇：向前发射4发穿透剑气子弹，斩杀低血量百分比的普通老鼠，斩杀对精英造成大量伤害",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_shuangrenshe_2
    }]);

    register_card("zhiyumiao", obj_zhiyumiao, [
    {
        shape: 0,
        sprite: spr_zhiyumiao,
        cost: 75,
        cooldown: 47000,
        description: "治愈喵：为5*5范围内卡片和玩家恢复50点体力",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    },
    {
        shape: 1,
        sprite: spr_zhiyumiao_1,
        cost: 75,
        cooldown: 47000,
        description: "武装治愈喵：为5*5范围内卡片和玩家恢复80点体力，并持续恢复3秒",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    },
    {
        shape: 2,
        sprite: spr_zhiyumiao_2,
        cost: 75,
        cooldown: 47000,
        description: "全能治愈喵：为全屏范围内卡片和玩家恢复80点体力，并持续恢复3秒",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    }]);
    register_card("baobaoji", obj_baobaoji, [
    {
        shape: 0,
        sprite: spr_baobaoji,
        cost: 275,
        cooldown: 2400,
        description: "爆爆鸡：部署时清除3×3范围内的路障、梯子和鼠洞",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    },
    {
        shape: 1,
        sprite: spr_baobaoji_1,
        cost: 225,
        cooldown: 2400,
        description: "疯狂爆爆鸡：清除3*3范围内的路障、梯子和鼠洞",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    },
    {
        shape: 2,
        sprite: spr_baobaoji_2,
        cost: 225,
        cooldown: 2400,
        description: "酷炫爆爆鸡：清除5*5范围内的路障、梯子和鼠洞",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    }]);

register_card("xuanfengniu", obj_xuanfengniu, [
    {
        shape: 0,
        sprite: spr_xuanfengniu,
        cost: 300,
        cooldown: 2400,
        description: "旋风牛：吹走全屏特定空中老鼠",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_xuanfengniu
    },
    {
        shape: 1,
        sprite: spr_xuanfengniu_1,
        cost: 300,
        cooldown: 2400,
        description: "强压旋风牛：吹走全屏特定空中老鼠和产生的障碍物",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_xuanfengniu_1
    },
    {
        shape: 2,
        sprite: spr_xuanfengniu_2,
        cost: 300,
        cooldown: 2400,
        description: "极速旋风牛：吹走全屏特定空中老鼠和产生的障碍物，无需格子",
        plant_type: "gridless",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0,
        place_preview: spr_xuanfengniu_2
    }]);

    register_card("qingse_shishi", obj_qingse_shishi, [
    {
        shape: 0,
        sprite: spr_shishi,
        cost: 140,
        cooldown: 1800,
        description: "青涩柿柿：向前方一定范围内的老鼠发起重击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    },
    {
        shape: 1,
        sprite: spr_shishi_1,
        cost: 140,
        cooldown: 1800,
        description: "成熟柿柿：召唤三个柿子向前方一定范围内的老鼠发起重击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    },
    {
        shape: 2,
        sprite: spr_shishi_2,
        cost: 140,
        cooldown: 1800,
        description: "柿柿如意：召唤五个柿子向前方一定范围内的老鼠发起重击",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 0
    }]);

    register_card("chongsheng_god", obj_chongsheng_god, [
    {
        shape: 0,
        sprite: spr_chongsheng_god,
        cost: 400,
        cooldown: 1800,
        description: "奥西里斯神使：持续复活5*5范围内至多4张死亡的卡片，首次触发时为范围内卡片施加减伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_chongsheng_god
    },
    {
        shape: 1,
        sprite: spr_chongsheng_god_1,
        cost: 400,
        cooldown: 1800,
        description: "奥西里斯圣神：持续复活5*5范围内至多6张死亡的卡片，首次触发时为范围内卡片施加减伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_chongsheng_god_1
    },
    {
        shape: 2,
        sprite: spr_chongsheng_god_2,
        cost: 400,
        cooldown: 1800,
        description: "重生神·奥西里斯：持续复活5*5范围内至多6张死亡的卡片，首次触发时为范围内卡片施加减伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_chongsheng_god_2
    },
    {
        shape: 3,
        sprite: spr_chongsheng_god_3,
        cost: 400,
        cooldown: 1800,
        description: "至尊重生神：持续复活5*7范围内至多12张死亡的卡片，首次触发时为范围内卡片施加减伤",
        plant_type: "normal",
        feature_type: "normal",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_chongsheng_god_3
    }]);

    register_card("zhanqima", obj_zhanqima, [
    { shape: 0, sprite: spr_zhanqima, cost: 380, cooldown: 2700, description: "战旗马：5*5范围内卡片提高基础攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_zhanqima },
    { shape: 1, sprite: spr_zhanqima_1, cost: 380, cooldown: 2700, description: "飞天战旗马：5*5范围内卡片提高基础攻击力，无需格子", plant_type: "gridless", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_zhanqima_1 },
    { shape: 2, sprite: spr_zhanqima_2, cost: 380, cooldown: 2700, description: "燎原战旗马：全屏范围内卡片提高基础攻击力，无需格子", plant_type: "gridless", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_zhanqima_2 }]);
    register_card("haiyang_god", obj_haiyang_god, [
    {
        shape: 0,
        sprite: spr_haiyang_god,
        cost: 360,
        cooldown: 2400,
        description: "塔拉萨神使：为5*5范围旋转攻击卡片和本行直线喷射类卡片提高攻击力",
        plant_type: "normal",
        feature_type: "haiyang_obstacle",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_haiyang_god
    },
    {
        shape: 1,
        sprite: spr_haiyang_god_1,
        cost: 360,
        cooldown: 2400,
        description: "塔拉萨圣神：为5*5范围旋转攻击卡片和本行直线喷射类卡片提高攻击力，不占用格子",
        plant_type: "gridless",
        feature_type: "haiyang_obstacle",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_haiyang_god_1
    },
    {
        shape: 2,
        sprite: spr_haiyang_god_2,
        cost: 360,
        cooldown: 2400,
        description: "海洋女神塔拉萨：为5*5范围旋转攻击卡片和本行直线喷射类卡片提高攻击力，不占用格子",
        plant_type: "gridless",
        feature_type: "haiyang_obstacle",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_haiyang_god_2
    },
    {
        shape: 3,
        sprite: spr_haiyang_god_3,
        cost: 360,
        cooldown: 2400,
        description: "至尊海洋女神：为5*5范围旋转攻击卡片和本行直线喷射类卡片提高攻击力，不占用格子，放置4张时变为全屏范围内增幅",
        plant_type: "gridless",
        feature_type: "haiyang_obstacle",
        target_card: "none",
        is_gold: 1,
        place_preview: spr_haiyang_god_3
    }]);

register_card("hufa_god", obj_hufa_god, [
{
    shape: 0,
    sprite: spr_hufa_god,
    cost: 300,
    cooldown: 420,
    description: "俱吠罗神使：喷射全屏索敌追踪穿透弹，秒杀非精英鼠，概率定身",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hufa_god
},
{
    shape: 1,
    sprite: spr_hufa_god_1,
    cost: 300,
    cooldown: 420,
    description: "俱吠罗圣神：喷射全屏索敌追踪穿透弹，秒杀非精英鼠，对魂系老鼠伤害增加，概率定身",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hufa_god_1
},
{
    shape: 2,
    sprite: spr_hufa_god_2,
    cost: 300,
    cooldown: 420,
    description: "护法神·俱吠罗：喷射全屏索敌追踪穿透弹，秒杀非精英鼠，对魂系老鼠伤害增加，可攻击地鼠，概率定身",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hufa_god_2
},
{
    shape: 3,
    sprite: spr_hufa_god_3,
    cost: 300,
    cooldown: 420,
    description: "至尊护法神：喷射全屏索敌追踪穿透弹，秒杀非精英鼠，对魂系老鼠和Boss伤害增加，可攻击地鼠，概率定身",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_hufa_god_3
}]);

register_card("shennong_god", obj_shennong_god, [
{
    shape: 0,
    sprite: spr_shennong_god,
    cost: 320,
    cooldown: 420,
    description: "神农氏神使：召唤固定轨迹穿透神焰攻击敌人",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_shennong_god
},
{
    shape: 1,
    sprite: spr_shennong_god_1,
    cost: 320,
    cooldown: 420,
    description: "神农氏圣神：召唤固定轨迹穿透神焰攻击敌人",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_shennong_god_1
},
{
    shape: 2,
    sprite: spr_shennong_god_2,
    cost: 320,
    cooldown: 420,
    description: "炎帝·神农氏：召唤固定轨迹穿透神焰攻击敌人",
    plant_type: "normal",
    feature_type: "normal",
    target_card: "none",
    is_gold: 1,
    place_preview: spr_shennong_god_2
}]);
register_card("hongliukaochuan", obj_hongliukaochuan, [
{ shape: 0, sprite: spr_hongliukaochuan, cost: 230, cooldown: 420, description: "红柳烤串机：喷射全屏索敌追踪穿透弹", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_hongliukaochuan },
{ shape: 1, sprite: spr_hongliukaochuan_1, cost: 230, cooldown: 420, description: "茴香红柳烤串机：喷射全屏索敌追踪穿透弹", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_hongliukaochuan_1 },
{ shape: 2, sprite: spr_hongliukaochuan_2, cost: 230, cooldown: 420, description: "星火红柳烤串机：喷射全屏索敌追踪穿透弹，子弹数量+1", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_hongliukaochuan_2 }
]);

register_card("shuanggu", obj_shuanggu, [
{shape:0,sprite:spr_shuanggu,cost:255,cooldown:420,description: "蚝油双菇：同时向前方发射2发对陆子弹和2发对空子弹",plant_type:"normal",feature_type:"normal",target_card:"none",place_preview:spr_shuanggu},
{shape:1,sprite:spr_shuanggu_1,cost:255,cooldown:420,description: "伯爵蚝油双菇：同时向前方发射2发对陆子弹和3发对空子弹",plant_type:"normal",feature_type:"normal",target_card:"none",place_preview:spr_shuanggu_1},
{shape:2,sprite:spr_shuanggu_2,cost:255,cooldown:420,description: "皇家蚝油双菇：同时向前方发射3发对陆子弹和3发对空子弹",plant_type:"normal",feature_type:"normal",target_card:"none",place_preview:spr_shuanggu_2}
]);

// 融合卡：普卡两转（形态 0/1/2），不写 is_gold（缺键读作 undefined，在 == 1 判断下等同 0）；卡底由 is_fusion 类别标记决定（spr_slot_2），不再逐界面硬编码名单。
register_card("lizi_god", obj_lizi_god, [
{shape:0,sprite:spr_lizi_god,cost:160,cooldown:420,description: "酱香锅烤栗子：投掷栗子造成3*3范围灼烧",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_lizi_god},
{shape:1,sprite:spr_lizi_god_1,cost:160,cooldown:420,description: "可乐香烤栗子：投掷栗子造成3*3范围灼烧，周期性追加爆炸",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_lizi_god_1},
{shape:2,sprite:spr_lizi_god_2,cost:160,cooldown:420,description: "如意香烤栗子：向前方3行投掷栗子造成3*3范围灼烧，周期性追加爆炸",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_lizi_god_2}
]);
register_card("youyu_god", obj_youyu_god, [
{shape:0,sprite:spr_youyu_god,cost:155,cooldown:420,description: "火影怪味鱿鱼：向8个方向各发射2发鱿鱼弹",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_youyu_god},
{shape:1,sprite:spr_youyu_god_1,cost:155,cooldown:420,description: "合金怪味鱿鱼：向8个方向各发射2发鱿鱼弹，前后方子弹增加，中路子弹可过火",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_youyu_god_1},
{shape:2,sprite:spr_youyu_god_2,cost:155,cooldown:420,description: "松香怪味鱿鱼：向10个方向各发射2发鱿鱼弹，前后方子弹增加，中路子弹可过火",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_youyu_god_2}
]);
register_card("ronghehaixing", obj_ronghehaixing, [
{shape:0,sprite:spr_ronghehaixing,cost:175,cooldown:420,description: "仙人球海星刺身：向五个方向发射2枚子弹，后方子弹增加",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghehaixing},
{shape:1,sprite:spr_ronghehaixing_1,cost:175,cooldown:420,description: "奶油海星刺身：向五个方向发射2枚溅射子弹，后方子弹增加",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghehaixing_1},
{shape:2,sprite:spr_ronghehaixing_2,cost:175,cooldown:420,description: "王冠海星刺身：向五个方向发射2枚溅射子弹，后方子弹增加，斜向子弹碰上下边框后转为追踪弹",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghehaixing_2}
]);
register_card("ronghedan_god", obj_ronghedan_god, [
{shape:0,sprite:spr_ronghedan_god,cost:250,cooldown:420,description: "雪芭煮蛋器：投掷2个溅射鸡蛋，概率定身",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghedan_god},
{shape:1,sprite:spr_ronghedan_god_1,cost:250,cooldown:420,description: "臭豆腐煮蛋器：投掷2个溅射毒气鸡蛋，概率定身",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghedan_god_1},
{shape:2,sprite:spr_ronghedan_god_2,cost:250,cooldown:420,description: "终结者煮蛋器：向前方3行投掷2个溅射毒气鸡蛋，概率定身",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghedan_god_2}
]);
register_card("ronghehuopen", obj_ronghehuopen, [
{shape:0,sprite:spr_ronghehuopen,cost:175,cooldown:420,description: "刺梨烧烤盘：穿过它的弹药都会提高伤害，啃咬它的老鼠受到等量反伤",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghehuopen},
{shape:1,sprite:spr_ronghehuopen_1,cost:175,cooldown:420,description: "冰榴莲烤盘：穿过它的弹药都会提高伤害，定期在周围5*5范围召唤寒冰之气攻击鼠军",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghehuopen_1},
{shape:2,sprite:spr_ronghehuopen_2,cost:175,cooldown:420,description: "缤纷杂果冰盘：穿过它的弹药提高伤害并变为冰弹，定期召唤寒冰之气",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghehuopen_2}
]);
register_card("ronghesanxian", obj_ronghesanxian, [
{shape:0,sprite:spr_ronghesanxian,cost:325,cooldown:420,description: "子母三线酒架：向前方三行各发射2发葡萄酒弹，命中后概率附加燃烧",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghesanxian},
{shape:1,sprite:spr_ronghesanxian_1,cost:325,cooldown:420,description: "仙人掌花酒架：向前方三行各发射3发葡萄酒弹，命中后概率附加燃烧",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghesanxian_1},
{shape:2,sprite:spr_ronghesanxian_2,cost:325,cooldown:420,description: "烤灯笼鱼酒架：向前方三行各发射3发可穿透的葡萄酒弹，命中后概率附加燃烧",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghesanxian_2}
]);

register_card("ronghedapao", obj_ronghedapao, [
{shape:0,sprite:spr_ronghedapao,cost:300,cooldown:1500,description: "脆心死神大炮：向本行投下2枚巧克力炸弹，3*3范围爆炸",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghedapao},
{shape:1,sprite:spr_ronghedapao_1,cost:300,cooldown:1500,description: "霸王死神大炮：向本行投下2枚巧克力炸弹，爆炸范围扩大至3*5",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghedapao_1},
{shape:2,sprite:spr_ronghedapao_2,cost:225,cooldown:1500,description: "乾坤死神大炮：向本行投下2枚巧克力炸弹，爆炸改为碾压秒杀",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghedapao_2}
]);

register_card("ronghekafei", obj_ronghekafei, [
{shape:0,sprite:spr_ronghekafei,cost:0,cooldown:420,description: "机枪咖啡杯：向前方连续发射3发咖啡弹，不需要火苗就能使用",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghekafei},
{shape:1,sprite:spr_ronghekafei_1,cost:0,cooldown:420,description: "喷壶咖啡杯：向前方发射1发浓缩咖啡弹，可穿透老鼠与障碍",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghekafei_1},
{shape:2,sprite:spr_ronghekafei_2,cost:0,cooldown:420,description: "三叠咖啡杯：三个杯子各吐1发浓缩咖啡弹，可穿透老鼠与障碍",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_ronghekafei_2}
]);

register_card("rongheshuanggu", obj_rongheshuanggu, [
{shape:0,sprite:spr_rongheshuanggu,cost:255,cooldown:420,description: "热狗蚝油双菇：同时向前方发射4发对陆子弹和4发对空子弹",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_rongheshuanggu},
{shape:1,sprite:spr_rongheshuanggu_1,cost:255,cooldown:420,description: "喷壶蚝油双菇：对陆子弹变为无限穿透，对空4发不变",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_rongheshuanggu_1},
{shape:2,sprite:spr_rongheshuanggu_2,cost:255,cooldown:420,description: "糖葫芦蚝油双菇：对空子弹变为全屏追踪，对地穿透不变",plant_type:"normal",feature_type:"normal",target_card:"none",is_fusion:1,place_preview:spr_rongheshuanggu_2}
]);

    register_card("pufferfish", obj_pufferfish, [
    {shape: 0, sprite: spr_pufferfish, cost: 325, cooldown: 3300, description: "爆辣河豚：种卡后清除全屏老鼠，或清除部分卡片", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_pufferfish},
    {shape: 1, sprite: spr_pufferfish_1, cost: 325, cooldown: 3300, description: "朝天椒河豚：种卡后清除全屏老鼠，或清除部分卡片", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_pufferfish_1},
    {shape: 2, sprite: spr_pufferfish_2, cost: 325, cooldown: 3300, description: "青芥末河豚：种卡后清除全屏老鼠，或清除部分卡片", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_pufferfish_2}
    ]);

    register_card("yeziguo", obj_yeziguo, [
    {shape: 0, sprite: spr_yeziguo, cost: 75, cooldown: 1800, description: "椰子果：跳起碾压前方鼠军", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yeziguo},
    {shape: 1, sprite: spr_yeziguo_1, cost: 75, cooldown: 1800, description: "浓香椰子果：跳起碾压前方3*3范围鼠军", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yeziguo_1},
    {shape: 2, sprite: spr_yeziguo_2, cost: 75, cooldown: 1800, description: "金丝椰子果：跳起连续碾压3次前方3*3范围鼠军", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_yeziguo_2}
    ]);

    register_card("niuyouguo", obj_niuyouguo, [
    {shape:0,sprite:spr_niuyouguo,cost:210,cooldown:1800,description: "邪恶牛油果：向前方三个方向各发射1发穿透飞镖",plant_type:"normal",feature_type:"normal",target_card:"none",place_preview:spr_niuyouguo},
    {shape:1,sprite:spr_niuyouguo_1,cost:210,cooldown:1800,description: "沙沙牛油果：向前方三个方向各发射1发穿透飞镖，命中附加减速",plant_type:"normal",feature_type:"normal",target_card:"none",place_preview:spr_niuyouguo_1},
    {shape:2,sprite:spr_niuyouguo_2,cost:210,cooldown:1800,description: "桑巴牛油果：向前方三个方向各发射2发穿透飞镖，命中附加减速",plant_type:"normal",feature_type:"normal",target_card:"none",place_preview:spr_niuyouguo_2}
    ]);
    register_card("wuxingshe", obj_wuxingshe, [
    { shape: 0, sprite: spr_wuxingshe, cost: 280, cooldown: 2400, description: "五行蛇：为3*3范围内5方向卡片增加攻击力", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_wuxingshe },
    { shape: 1, sprite: spr_wuxingshe_1, cost: 280, cooldown: 2400, description: "通灵五行蛇：为3*3范围内5方向卡片增加攻击力，攻击力提升", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_wuxingshe_1 },
    { shape: 2, sprite: spr_wuxingshe_2, cost: 280, cooldown: 2400, description: "泰斗五行蛇：为5*5范围内5方向卡片增加攻击力，攻击力大幅提升", plant_type: "normal", feature_type: "normal", target_card: "none", is_gold: 0, place_preview: spr_wuxingshe_2 }]);
}
