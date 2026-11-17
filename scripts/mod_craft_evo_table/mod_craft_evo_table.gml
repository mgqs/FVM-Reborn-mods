/// =============================================================================
///  mod/craft · 金卡表（合成屋 · 金卡进化，craft_top_tab == 0；融合卡在 mod_craft_fusion_table）
///  这个文件 = 金卡进化的**全部数据 + 全部规则 + 凭证绘制**，obj_craft_bg 只调它
///  卡怎么分类：卡注册数据里的 is_gold / is_fusion（**不看诸神商店卖什么**）
///
///  一、数据（要改就改这里）
///    mod_evo_table()        金卡 → cards:[ { id, slot, need } ]
///        slot   进化页的槽位：0 = 第 1 槽（星座卡）/ 1 = 第 2 槽（普通卡）
///               只有一张前置的条目，按它自己是星座还是普通来定
///        need   该前置要求的形态：0 本体 / 1 一转 / 2 二转
///               ⚠️ 一律按这张卡自己的形态上限兜底（见 mod_evo_need_of；只注册到 0 转的卡写 2 也按 0 算）
///               ⚠️ need 只给金卡进化用：抽卡只发凭证/本体，诸神商店也只判「有没有这张凭证」
///    mod_evo_credit_face()  进化凭证里那张立绘的可见区域 [左, 上, 宽, 高]
///
///  二、取数 API（对象层用，别自己扫表）
///    mod_evo_cards(target)            某张金卡的前置列表
///    mod_evo_need_of(id, need)        need 按卡的形态上限兜底
///    mod_evo_slot_need(target, slot)  该槽要求的形态（-1 = 没有这个槽）
///    mod_evo_card_name(id)            卡的本体形态名（提示文案用）
///    mod_evo_shape_word(n)            n → "一转" / "二转" …
///
///  三、规则（纯函数，状态由调用方传进来）
///    mod_evo_needed_cards()           右侧列表该有哪些卡（还没拥有的金卡所缺的前置）
///    mod_evo_pick_target(card_id)     这张卡该进哪张金卡的哪个槽
///    mod_evo_resolve(target, slot, card_id)  落槽后两个槽应该是什么（缺的记 miss）
///    mod_evo_check(target, cards, miss)      能不能进化（缺卡 / 形态不足 / 凭证不足）
///    mod_evo_reward(target)           成功落账：扣 1 张凭证 + 解锁金卡（星级从 0 起）
///    mod_evo_credit_id / mod_evo_has_credit / mod_evo_buyable_locked   凭证 id / 有没有 / 商店是否售完
///
///  四、绘制与文案
///    mod_evo_draw_credit(target, cx, cy, has, box, face_box)   金色底板 + 卡面立绘
///    mod_evo_tooltip(target, desc) / mod_evo_route_text(target)  凭证悬停提示 / 进化路线文本
///
///  改完调 mod_evo_selfcheck() 自检（空前置 / 超过两槽 / 重复 / 没注册 / need 越界 / 挤在同一个槽）
/// =============================================================================

/// @func mod_evo_table() 前置总表
function mod_evo_table(){
    return {
        // ─────────────── 金卡（39 张，金卡进化用；slot 0 = 星座槽 / 1 = 普通槽） ───────────────
        // 🔴 2026-10-27 按用户配方表重排：need = 「表里那个名字对应的形态」（名字是二转名 → 2，本体名 → 0）
        //    「XX座星宿 / XX座战将」= 星座卡 → 一律 slot 0；其余放 slot 1（整行没有星座卡时第一张占 slot 0）
        sheng_huo:               { cards:[ {id:"beef_hotpot", slot:0, need:2},
                                        {id:"spicy_pot", slot:1, need:2} ] },  // 赫斯提亚神使 ← 海鲜肥牛锅 + 酱香鱿鱼锅
        hufa_god:                { cards:[ {id:"hongliukaochuan", slot:0, need:2},
                                        {id:"jingangma", slot:1, need:2} ] },  // 俱吠罗神使 ← 星火红柳烤串机 + 梵音金刚马（2026-11-11 按官方配方：金刚马替换幻境归元马）
        gongjiang_god:           { cards:[ {id:"pizza_oven", slot:0, need:2},
                                        {id:"laipishe", slot:1, need:2} ] },  // 鲁班神使 ← 大王赖皮蛇 + 拉丝披萨炉
        brahma:                  { cards:[ {id:"magic_chicken", slot:0, need:2},
                                        {id:"baibianshe", slot:1, need:2} ] },  // 梵天神使 ← 幻幻鸡（这卡只注册到本体，need 2 会被上限兜到 0）+ 双子百变蛇
        guangming_god:           { cards:[ {id:"dragon_fruit", slot:0, need:2},
                                        {id:"dianman", slot:1, need:2} ] },  // 巴德尔神使 ← 九天皓日火龙果（主卡）+ 美味电鳗（副卡·进化，2026-11-07 用户改回）
        shennong_god:            { cards:[ {id:"yanhuangma", slot:0, need:2},
                                        {id:"huagao", slot:1, need:2} ] },  // 神农氏神使 ← 焚天炎凰马 + 梦境灯影花糕
        haiyang_god:             { cards:[ {id:"mozhang", slot:0, need:2},
                                        {id:"hspeed_juicer", slot:1, need:2} ] },  // 塔拉萨神使 ← 凤羽魔杖蛇 + 大菠萝榨汁机
        fengrao_god:             { cards:[ {id:"zhanqima", slot:0, need:2},
                                        {id:"wuxingshe", slot:1, need:2} ] },  // 弗雷神使 ← 燎原战旗马 + 泰斗五行蛇
        clotho:                  { cards:[ {id:"shiguangji", slot:0, need:2},
                                        {id:"sheshejiu", slot:1, need:2} ] },  // 克洛托神使 ← 未来时光机 + 琼浆蛇蛇酒（2026-11-11 按官方配方，原梵天神使单卡作废）
        chongsheng_god:          { cards:[ {id:"xingqiongma", slot:0, need:2},
                                        {id:"anranxiaohunfan", slot:1, need:2} ] },  // 奥西里斯神使 ← 浩瀚星穹马 + 天妇罗盖饭
        sun_god:                 { cards:[ {id:"shuangzi", slot:0, need:2},
                                        {id:"small_fire", slot:1, need:2} ] },  // 阿波罗神使 ← 双子座星宿 + 太阳能高效炉
        heian_god:               { cards:[ {id:"mojie", slot:0, need:2},
                                        {id:"durian", slot:1, need:2} ] },  // 黑暗神使 ← 摩羯座战将（星座槽）+ 冰河世纪榴莲
        aurora:                  { cards:[ {id:"zhuzhujiaqiang", slot:0, need:2},
                                        {id:"blueberry_tower", slot:1, need:2} ] },  // 欧若拉神使 ← 猪猪发射站 + 蓝莓信号塔塔（这卡只注册到本体，按上限兜底）
        houyi_god:               { cards:[ {id:"bbq", slot:0, need:2},
                                        {id:"fashishe", slot:1, need:2} ] },  // 后羿神使 ← BBQ烤肉大师 + 奥术法师蛇（2026-11-08 用户指定副卡）
        joker:                   { cards:[ {id:"donut", slot:0, need:2},
                                        {id:"tanhuanghu", slot:1, need:2} ] },  // 埃罗斯神使 ← 女王多拿滋 + 机器弹簧虎（2026-11-11 按官方配方，多拿滋留主槽）
        time_god:                { cards:[ {id:"meiweijishiqi", slot:0, need:2},
                                        {id:"zhuanlonghu", slot:1, need:2} ] },  // 柯罗诺斯神使 ← 珍馐计时器 + 巨星转龙壶（2026-11-11 按官方配方，计时器留主槽，极寒冰沙移出）
        xiangshui_god:           { cards:[ {id:"berry_dessert", slot:0, need:2},
                                        {id:"xiangliaohu", slot:1, need:2} ] },  // 塔利亚神使 ← 流心莓果点心 + 魔力香料虎（2026-11-06 用户指定副卡）
        war_god:                 { cards:[ {id:"tiancheng", slot:0, need:2},
                                        {id:"double_water_pipe", slot:1, need:2} ] },  // 阿瑞斯神使 ← 天秤座星宿 + 合金水管
        thor:                    { cards:[ {id:"shuangyu", slot:0, need:2},
                                        {id:"egg_boiler_pult", slot:1, need:2} ] },  // 索尔神使 ← 双鱼座星宿 + 强袭煮蛋器
        fire_god:                { cards:[ {id:"jinniu", slot:0, need:2},
                                        {id:"brazier", slot:1, need:2} ] },  // 洛基神使 ← 金牛座星宿 + 岩烧烤盘
        moon_god:                { cards:[ {id:"juxie", slot:0, need:2},
                                        {id:"takoyaki", slot:1, need:2} ] },  // 狄安娜神使 ← 巨蟹座星宿 + 火影章鱼烧
        power_god:               { cards:[ {id:"tang_hu_lu", slot:0, need:2},
                                        {id:"fangkongmiao", slot:1, need:2} ] },  // 赫丘利神使（大力神）← 七彩糖葫芦弹 + 狂暴防空喵（2026-11-08 用户指定：主卡是糖葫芦，不是热狗榴弹炮）
        gaia:                    { cards:[ {id:"curry_lobster_cannon", slot:0, need:2},
                                        {id:"huojianzhu", slot:1, need:2} ] },  // 盖亚神使 ← 加农龙虾炮 + 反重力火箭猪（2026-11-08 用户指定副卡）
        zhurong:                 { cards:[ {id:"pan_fried_bun", slot:0, need:2},
                                        {id:"dangdanghu", slot:1, need:2} ] },  // 祝融神使 ← 驴肉火烧锅 + 微波铛铛虎（2026-11-06 用户指定：替换糖炒栗子）
        rig:                     { cards:[ {id:"nut_frier", slot:0, need:2},
                                        {id:"starrabbit", slot:1, need:2} ] },  // 里格神使 ← 松塔爆破机（坚果爆炒机）+ 宇宙星星兔（2026-11-09 用户指定：两个前置互换槽位）
        ymir:                    { cards:[ {id:"qiedanlong", slot:0, need:2},
                                        {id:"grilled_lizard_pult", slot:1, need:2} ] },  // 尤弥尔神使 ← 钢爪窃蛋龙 + 花椒蜥蜴投手（2026-11-11 按官方配方，窃蛋龙进主槽，勺勺兔移出）
        save_god:                { cards:[ {id:"doumaobang", slot:0, need:2},
                                        {id:"tanchitu", slot:1, need:2} ] },  // 灵鱼摩蹉神使 ← 鼠鼠逗猫棒 + 暴走贪吃兔（2026-11-08 用户指定：主卡由白羊座星宿换成逗猫棒）
        poseidon:                { cards:[ {id:"shizi", slot:0, need:2},
                                        {id:"rotating_coffee_pot", slot:1, need:2} ] },  // 波塞冬神使 ← 狮子座星宿 + 原子咖啡壶
        ghost_god:               { cards:[ {id:"coal_starfish", slot:0, need:2},
                                        {id:"zhuzhuliaoliji", slot:1, need:2} ] },  // 哈迪斯神使 ← 芥末海星刺身 + 猪猪破壁机（2026-11-06 用户指定副卡）
        odin:                    { cards:[ {id:"tar_sprayer", slot:0, need:2} ] },  // 奥丁神使 ← 焦油喷壶（2026-10-29：原游侠双刃蛇被三张金卡共用，换成平射穿透类）
        water_god:               { cards:[ {id:"cherry_pudding", slot:0, need:2},
                                        {id:"budingwang", slot:1, need:2} ] },  // 忒提丝神使 ← 热量反弹布丁 + 什锦布丁汪（2026-11-06 用户指定副卡）
        hundun_god:              { cards:[ {id:"hamburger", slot:0, need:2},
                                        {id:"tunshilong", slot:1, need:2} ] },  // 混沌神使 ← 牛肉双黑汉堡 + 成年吞噬龙（2026-11-06 用户指定副卡）
        // ⚠️ 下面 4 张不在用户给的配方表里（图上没有），沿用旧前置，等补表再改
        firework_dragon_real:    { cards:[ {id:"firework_dragon", slot:0, need:2},
                                        {id:"shegengbao", slot:1, need:2} ] },  // 真·花火龙 ← 花火龙 + 蛇羹煲
        hera:                    { cards:[ {id:"chunv", slot:0, need:2},
                                        {id:"melon_shield", slot:1, need:2} ] },  // 天后 ← 处女座精灵 + 瓜皮护罩
        ice_god:                 { cards:[ {id:"cold_drew", slot:0, need:2},
                                        {id:"snowrabbit", slot:1, need:2} ] },  // 典伊神使 ← 迅捷冷萃机 + 导师雪球兔
        zeus:                    { cards:[ {id:"athena", slot:0, need:2} ] },  // 宙斯神使 ← 雅典娜守护（2026-10-28：取消第 2 槽咖喱龙虾炮，只需一张）
        love_god:                { cards:[ {id:"sheshou", slot:0, need:2},
                                        {id:"triple_wine_rack", slot:1, need:2} ] },  // 丘比特神使 ← 射手座星宿 + 终结者酒架
        panduola_god:            { cards:[ {id:"aquarius_elve", slot:0, need:2},
                                        {id:"pufferfish", slot:1, need:2} ] },  // 潘多拉 ← 水瓶座精灵（星座槽）+ 爆辣河豚（2026-10-28 改）
        // 2026-11-13 新卡：星轨神·阿斯特 ← 忘忧浮生茶（二转）+ 玲珑音盒马（二转）+ 进化凭证
        xinggui_god:             { cards:[ {id:"fushengcha", slot:0, need:2},
                                        {id:"yinhema", slot:1, need:2} ] },
        lingrong_god:            { cards:[ {id:"cotton_candy", slot:0, need:2} ] }  // 魔导士软糖 ← 棉花糖（星座槽）
    };
}

// 2026-10-27：mod_evo_flat()（老扁平表）已删除 —— 前置不再参与抽卡/诸神，没有调用点了。
//   需要「某张金卡缺哪些前置」请用 mod_evo_cards(target)；界面用 mod_evo_needed_cards()。

/// @func mod_evo_cards(target) 某张目标卡的前置列表（没有返回空数组）
function mod_evo_cards(_target){
    var _t = mod_evo_table();
    if (!variable_struct_exists(_t, _target)) return [];
    return _t[$ _target].cards;
}

/// @func mod_evo_need_of(card_id, need) 要求形态按这张卡自己的上限兜底
function mod_evo_need_of(_card_id, _need){
    var _max = card_max_available_shape(_card_id);
    if (_max < 0) return _need;         // 查不到这张卡：原样返回，别把要求抹成 0
    return min(_need, _max);
}

/// @func mod_evo_selfcheck() 表自检：返回问题描述数组（空数组 = 没问题）
function mod_evo_selfcheck(){
    var _bad = [];
    var _t = mod_evo_table();
    var _names = variable_struct_get_names(_t);
    for (var _i = 0; _i < array_length(_names); _i++){
        var _k = _names[_i];
        if (!variable_struct_exists(_t, _k)) continue;
        var _cs = _t[$ _k].cards;
        if (array_length(_cs) == 0) array_push(_bad, _k + "：没有前置卡");
        if (array_length(_cs) > 2) array_push(_bad, _k + "：前置卡超过 2 张（界面只有两个槽）");
        var _seen = {};
        for (var _j = 0; _j < array_length(_cs); _j++){
            var _c = _cs[_j];
            if (!variable_struct_exists(_seen, _c.id)) _seen[$ _c.id] = true;
            else array_push(_bad, _k + "：前置卡重复 " + _c.id);
            if (card_max_available_shape(_c.id) < 0) array_push(_bad, _k + "：前置卡没注册 " + _c.id);
            if (_c.slot != 0 && _c.slot != 1) array_push(_bad, _k + "：slot 只能是 0/1（" + _c.id + "）");
            if (_c.need < 0 || _c.need > 3) array_push(_bad, _k + "：need 越界（" + _c.id + "）");
        }
        if (array_length(_cs) == 2 && _cs[0].slot == _cs[1].slot) array_push(_bad, _k + "：两张前置挤在同一个槽");
    }
    return _bad;
}


// =============================================================================
//  进化凭证（金卡进化页第 3 槽）
//  凭证图标 = 「金色底板 + 该金卡的 0 形态立绘」现拼出来的，没有单独的美术资源
// =============================================================================

/// @func mod_evo_credit_face() 凭证里那张立绘的「可见区域」表
///   [左, 上, 宽, 高] = 描出「有像素」的矩形（图像坐标，与精灵原点无关）
///   ⚠️ 这批立绘的画布普遍带大量透明留白（黑暗神 293x336 画布 / 内容只有 77x58），
///      直接按画布比例画会又小又偏，所以按内容包围盒缩放 + 用内容中心对位
///   ⚠️ 加新金卡 / 换立绘后要重新量：把新精灵的 alpha 包围盒量出来填一行即可
///   ⚠️ 表里没有的卡会自动回落到「画布 0.5236 居中」的老画法
///   ⚠️ 2026-10-27 起**只是兜底**：金卡立绘是运行时 sprite_add 出来的，绘制优先用精灵自己的
///      运行时包围盒（见 mod_evo_draw_credit），只有 bbox 像「整张画布」时才查这张表
function mod_evo_credit_face(){
    // 绘制时每帧都会查 → 第一次建好就缓存到全局，后面直接读
    if (variable_global_exists("mod_evo_face_tbl")) return global.mod_evo_face_tbl;
    var _t = {

    // ⚠️ 圣火 spr_sh_b 是「三张并排」的大图，机械量不准 → 保留手量值
    sheng_huo: [10, 38, 77, 86],
    hufa_god: [4, 33, 85, 83],
    gongjiang_god: [13, 6, 82, 82],
    brahma: [60, 63, 72, 66],
    guangming_god: [19, 33, 93, 85],
    shennong_god: [33, 39, 70, 98],
    haiyang_god: [21, 1, 81, 86],
    fengrao_god: [0, 3, 88, 86],
    clotho: [36, 65, 63, 83],
    chongsheng_god: [4, 25, 93, 81],
    sun_god: [2, 14, 70, 107],
    heian_god: [121, 158, 74, 59],
    aurora: [2, 14, 54, 88],
    houyi_god: [15, 4, 100, 88],
    joker: [12, 49, 74, 89],
    time_god: [85, 104, 72, 92],
    xiangshui_god: [20, 10, 89, 79],
    war_god: [0, 14, 84, 93],
    thor: [23, 37, 97, 89],
    fire_god: [0, 2, 70, 48],
    moon_god: [15, 1, 82, 88],
    power_god: [16, 3, 73, 88],
    gaia: [4, 95, 75, 76],
    zhurong: [22, 11, 68, 85],
    rig: [48, 74, 79, 53],
    ymir: [30, 12, 84, 82],
    save_god: [50, 73, 70, 91],
    poseidon: [121, 143, 79, 84],
    ghost_god: [10, 4, 64, 85],
    odin: [30, 27, 93, 69],
    water_god: [3, 18, 67, 68],
    hundun_god: [108, 104, 80, 62],
    firework_dragon_real: [49, 95, 73, 72],
    hera: [0, 2, 100, 46],
    ice_god: [2, 63, 89, 88],
    xinggui_god: [3, 6, 72, 68],   // 2026-11-13 新卡：spr_xinggui_god 第 0 帧内容框
    zeus: [62, 511, 75, 69],
    love_god: [18, 0, 93, 88],
    panduola_god: [80, 73, 59, 55],
    lingrong_god: [0, 0, 107, 92]
    };
    global.mod_evo_face_tbl = _t;
    return _t;
}

/// @func mod_evo_needed_cards() 右侧列表该有哪些卡 = 「还没拥有的金卡」当前缺的前置卡（去重、按表顺序）
///   已拥有金卡的前置不会出现在这里；前置本身是金卡/融合卡时，只要还被需要就照常返回
function mod_evo_needed_cards(){
    var _t = mod_evo_table();
    var _names = variable_struct_get_names(_t);
    var _out = [], _seen = {};
    for (var _i = 0; _i < array_length(_names); _i++){
        var _k = _names[_i];
        if (is_card_unlocked(_k)) continue;
        var _cs = mod_evo_cards(_k);
        for (var _j = 0; _j < array_length(_cs); _j++){
            var _id = _cs[_j].id;
            if (variable_struct_exists(_seen, _id)) continue;
            _seen[$ _id] = true;
            array_push(_out, _id);
        }
    }
    return _out;
}

/// @func mod_evo_resolve(target, slot, card_id) 把这张卡放进槽后，两个槽应该是什么状态
///   搭档已拥有 → 直接补进另一槽；没有 → 记到 miss（界面画灰占位、不可点）
/// @return { struct } cards[2] / miss[2] / target
function mod_evo_resolve(_target, _slot, _card_id){
    var _cards = ["", ""];
    var _miss  = ["", ""];
    _cards[_slot] = _card_id;
    var _cs = mod_evo_cards(_target);
    for (var _i = 0; _i < array_length(_cs); _i++){
        var _c = _cs[_i];
        if (_c.slot == _slot) continue;
        if (is_card_unlocked(_c.id)) _cards[_c.slot] = _c.id;
        else _miss[_c.slot] = _c.id;
    }
    return { cards:_cards, miss:_miss, target:_target };
}

/// @func mod_evo_check(target, cards, miss) 进化规则判定（不看界面，只吃状态）
/// @return { struct } ok / reason
function mod_evo_check(_target, _cards, _miss){
    var _r = { ok:false, reason:"" };
    if (_target == ""){ _r.reason = "先选一张卡"; return _r; }
    if (is_card_unlocked(_target)){ _r.reason = "已经拥有这张金卡"; return _r; }
    var _cs = mod_evo_cards(_target);
    for (var _i = 0; _i < array_length(_cs); _i++){
        var _c = _cs[_i];
        if (_miss[_c.slot] != "" || _cards[_c.slot] != _c.id){
            _r.reason = "还差一张 " + mod_evo_card_name(_c.id);
            return _r;
        }
        if (!is_card_unlocked(_c.id)){ _r.reason = "还差一张 " + mod_evo_card_name(_c.id); return _r; }
        var _need = mod_evo_need_of(_c.id, _c.need);
        // 形态按存档里练到过的最高形态判（transfer_credit_card_max_shape 没拥有返回 -1）
        // ⚠️ 别用 get_card_info_simple()：卡没拥有时它返回 false，取 .max_shape 会崩
        if (transfer_credit_card_max_shape(_c.id) < _need){
            _r.reason = mod_evo_card_name(_c.id) + "还未" + mod_evo_shape_word(_need);
            return _r;
        }
    }
    if (!mod_evo_has_credit(_target)){ _r.reason = "缺少进化凭证"; return _r; }
    _r.ok = true;
    return _r;
}

/// @func mod_evo_credit_id(target) 进化凭证的材质 id（一张金卡一种）
function mod_evo_credit_id(_target){ return "evo_credit_" + string(_target); }

/// @func mod_evo_has_credit(target) 有没有这张金卡的进化凭证（debug 模式视为有，方便测试）
function mod_evo_has_credit(_target){
    if (_target == "") return false;
    if (global.debug) return true;
    return get_material_amount(mod_evo_credit_id(_target)) > 0;
}

/// @func mod_evo_buyable_locked(target) 商店里这张进化凭证是不是「售完」
///   （置灰 + 盖售罄罩 + 点不动；诸神商店 Create 与 Draw 只准调这一个，别再各写一份）
///   两条就够：① 背包里已经有一张（进化凭证只能持有 1 张）② 这张金卡已经进化出来了
///   ⚠️ 不走 mod_evo_has_credit()：它 debug 下恒真，会把整页商店置灰
function mod_evo_buyable_locked(_target){
    if (_target == "") return true;
    if (get_material_amount(mod_evo_credit_id(_target)) > 0) return true;
    if (is_card_unlocked(_target)) return true;
    return false;
}

/// @func mod_evo_card_name(card_id) 卡的本体形态名（提示文案用；查不到就用 id）
function mod_evo_card_name(_id){
    var _d = get_plant_shape_data(_id, 0);
    if (_d != undefined && ds_map_exists(_d, "name")) return _d[? "name"];
    return _id;
}

/// @func mod_evo_route_text(target) 进化路线：「卡1 + 卡2」（单前置就是卡名）
function mod_evo_route_text(_target){
    var _cs = mod_evo_cards(_target);
    var _out = "";
    for (var _i = 0; _i < array_length(_cs); _i++){
        _out += ((_i == 0) ? "" : " + ") + mod_evo_card_name(_cs[_i].id);
    }
    return _out;
}

/// @func mod_evo_tooltip(target, desc) 进化凭证的**悬停提示**（诸神商店 / 背包共用一套字）
///   2026-10-28 用户口径：进化路线写在提示里，不画在图标上
/// @param desc 可选补充（商店传商品 description）
function mod_evo_tooltip(_target, _desc = ""){
    var _out = mod_evo_card_name(_target) + "（进化凭证）";
    var _route = mod_evo_route_text(_target);
    if (_route != "") _out += "\n进化路线：" + _route;
    if (_desc != "") _out += "\n" + _desc;
    _out += "\n在合成屋-金卡进化中使用";
    return _out;
}

/// @func mod_evo_shape_word(n) 1 → "一转" / 2 → "二转" …
function mod_evo_shape_word(_n){
    if (_n <= 0) return "";
    switch (_n){
        case 1: return "一转";
        case 2: return "二转";
        case 3: return "三转";
    }
    return string(_n) + "转";
}

/// @func mod_evo_slot_need(target, slot) 该槽要求的形态（已按卡的上限兜底；-1 = 没有这个槽）
function mod_evo_slot_need(_target, _slot){
    var _cs = mod_evo_cards(_target);
    for (var _i = 0; _i < array_length(_cs); _i++){
        if (_cs[_i].slot == _slot) return mod_evo_need_of(_cs[_i].id, _cs[_i].need);
    }
    return -1;
}

/// @func mod_evo_draw_credit(target, cx, cy, has, box, face_box) 画进化凭证图标
///   底板：等比缩放到 box 居中；卡面：按内容包围盒缩到 face_box + 内容中心对位
/// @param has       false → 整组套 sh_fusion_gray（未拥有凭证）
/// @param box       底板边长，不传按 68（进化页槽位用 68，背包格子用 74 左右）
/// @param face_box  卡面框边长，不传按 50（= 68 * 0.735，跟底板保持同一比例）
function mod_evo_draw_credit(_target, _cx, _cy, _has, _box = 68, _face_box = 50){
    // ① 金色底板（等比缩放到 box，按原点居中）
    var _bg = spr_evo_credit_bg;
    var _bw = sprite_get_width(_bg), _bh = sprite_get_height(_bg);
    var _bs = _box / max(_bw, _bh);
    if (!_has) shader_set(sh_fusion_gray);
    draw_sprite_ext(_bg, 0,
        _cx + (sprite_get_xoffset(_bg) - _bw * 0.5) * _bs,
        _cy + (sprite_get_yoffset(_bg) - _bh * 0.5) * _bs,
        _bs, _bs, 0, c_white, 1);

    // ② 金卡 0 形态立绘
    var _md = deck_get_card_data(_target, 0);
    if (_md != noone && ds_map_exists(_md, "sprite")) {
        var _face = _md[? "sprite"];
        var _fsc = 0.5236, _fox = 0, _foy = 0;       // 表里没有 → 老画法兜底
        // 卡面**只查静态表**（2026-10-27 晚：运行时 sprite_get_bbox_* 在开了 autocrop 的
        //   纹理组上不可信 —— 量出来的宽高远大于画面，会缩成指甲盖 / 直接飞出框外。
        //   表值是按「游戏真正画的那个精灵」的 PNG 第 0 帧量的，见 mod_evo_credit_face()）
        var _tbl = mod_evo_credit_face();
        if (variable_struct_exists(_tbl, _target)) {
            var _f = _tbl[$ _target];                // [左, 上, 宽, 高]
            _fsc = min(_face_box / _f[2], _face_box / _f[3]);
            _fox = (_f[0] + _f[2] * 0.5 - sprite_get_xoffset(_face)) * _fsc;
            _foy = (_f[1] + _f[3] * 0.5 - sprite_get_yoffset(_face)) * _fsc;
        }
        draw_sprite_ext(_face, 0, _cx - _fox, _cy - _foy, _fsc, _fsc, 0, c_white, 1);
    }
    if (!_has) shader_reset();

}

/// @func mod_evo_pick_target(card_id) 这张卡该进哪张金卡的槽 → { target, slot }（没有可用目标返回 undefined）
///   优先选「搭档已经拥有」的那组（能一次凑齐），否则取表里第一条
function mod_evo_pick_target(_card_id){
    if (_card_id == "") return undefined;
    var _t = mod_evo_table();
    var _names = variable_struct_get_names(_t);
    var _best = "", _best_slot = -1, _best_ready = false;
    for (var _i = 0; _i < array_length(_names); _i++){
        var _k = _names[_i];
        if (is_card_unlocked(_k)) continue;          // 金卡已经有了 → 不再收前置
        var _cs = mod_evo_cards(_k);
        var _my_slot = -1;
        for (var _j = 0; _j < array_length(_cs); _j++){
            if (_cs[_j].id == _card_id) _my_slot = _cs[_j].slot;
        }
        if (_my_slot < 0) continue;
        var _ready = true;
        for (var _j = 0; _j < array_length(_cs); _j++){
            if (_cs[_j].slot == _my_slot) continue;
            if (!is_card_unlocked(_cs[_j].id)) _ready = false;
        }
        if (_best == "" || (_ready && !_best_ready)){
            _best = _k; _best_slot = _my_slot; _best_ready = _ready;
        }
        if (_ready) break;
    }
    if (_best == "") return undefined;
    return { target:_best, slot:_best_slot };
}

/// @func mod_evo_reward(target) 进化成功的落账：扣 1 张进化凭证 → 解锁金卡（星级从 0 起）
function mod_evo_reward(_target){
    var _lvl = global.save_data.unlocked_items.max_skill_level;
    if (!global.debug) add_material_amount(mod_evo_credit_id(_target), -1);
    unlock_card(_target, 0, 0, _lvl);
    // 前置卡被消耗：星级 / 转职 / 历史最高全清（debug 下不毁档）
    if (!global.debug){
        var _cs = mod_evo_cards(_target);
        for (var _i = 0; _i < array_length(_cs); _i++) reset_card_to_new(_cs[_i].id);
    }
}

// =============================================================================
// 神器 / 宝石进化（2026-11-16）
//   数据：桌面\武器进化.xlsx；与原版 res\合成屋.swf 的 compose_tab 2/3 一致
//         （解析产物 output/god_evolution.json，工具 tools/god_evolution_extract.py）
//   3 条神器链（6 步）+ 12 条宝石系（27 步）= 33 步 / 33 张凭证
//   （2026-11-17 补齐生命系第 4 支：生命之源 → 神圣之眼 → 玫瑰之绞；登记表里末格写的是
//     「狡诈伪装」，mod 里这颗宝石叫「玫瑰之绞」，同一个东西 —— 全 12 支已闭合，无留位）
//
//   凭证 id = "evo_credit_" + 目标 id —— 故意沿用金卡凭证的同一个前缀：
//   背包「进化凭证」段、抽卡 / 商店的 evo 分支靠前缀识别（transfer_credit.gml:499），
//   这里不用注册 material，也不用改那些分支。
//
//   规则（用户 2026-11-16 口径）：
//     · 宝石：消耗当前宝石 + 1 张凭证 → 产出**星级归 0**的下一阶，**不返还任何材料**
//             （原版会按原等级退强化水晶，这里刻意不退）
//     · 武器：消耗当前武器 + 1 张凭证 → 解锁下一阶；若正装备着就**就地换**成新武器，
//             不兼容的专属宝石由 weapon_gems_reconcile 卸回背包（不丢失）
// =============================================================================

/// @func mod_gear_evo_defs() 进化链（**唯一事实源**：改路线只改这里）
///   每条链 = 由低到高的 id 数组；kind 决定走武器还是宝石分支
function mod_gear_evo_defs(){
    return {
        weapon: [
            ["poseidon_dart_gun", "zeus_bolt",     "star_wand"],       // 海神镖枪 → 宙斯神弩 → 星之神杖
            ["gods_shield",       "master_shield", "rose_shield"],     // 诸神之盾 → 主宰之盾 → 荆棘玫瑰
            ["death_scythe",      "hades_scythe",  "aladdin_lamp"]     // 死神镰刀 → 冥王战镰 → 阿拉丁神灯
        ],
        gem: [
            ["poseidon_dart_gun_gem_1", "zeus_shadow_gem",  "star_wand_gem_1", "star_wand_gem_5"],
            ["poseidon_dart_gun_gem_2", "zeus_power_gem",   "star_wand_gem_2"],
            ["poseidon_dart_gun_gem_3", "zeus_anger_gem",   "star_wand_gem_3"],
            ["poseidon_dart_gun_gem_4", "zeus_ren_gem",     "star_wand_gem_4"],
            ["gods_shield_gem_1",       "divine_blessing_gem", "rose_shield_gem_1"],
            ["gods_shield_gem_2",       "divine_shenji_gem",   "rose_shield_gem_2"],
            ["gods_shield_gem_3",       "divine_protect_gem",  "rose_shield_gem_3", "rose_shield_gem_5"],
            ["gods_shield_gem_4",       "divine_holy_gem",  "rose_shield_gem_4"],
            //   ↑ 生命之源 → 神圣之眼 → 狡诈伪装
            //   **狡诈伪装 = 玫瑰之绞（rose_shield_gem_4）**（用户 2026-11-17 口径）：
            //     xlsx / SWF 登记表里那一格叫「狡诈伪装」，mod 里这颗宝石的注册名是「玫瑰之绞」，
            //     是同一颗（荆棘玫瑰专属，`allowed_weapons: ["rose_shield"]`）。
            //     所以这条链**直接用 rose_shield_gem_4 收尾**，不需要另做 divine_forbidden
            //     （那个 id 只有素材 spr_divine_forbidden_gem_icon，从没 register_gem / 建 obj）。
            ["death_scythe_gem_1",      "ghost_strike_gem", "aladdin_lamp_gem_1", "aladdin_lamp_gem_5"],
            ["death_scythe_gem_2",      "ghost_spark_gem",  "aladdin_lamp_gem_2"],
            ["death_scythe_gem_3",      "ghost_pact_gem",   "aladdin_lamp_gem_3"],
            ["death_scythe_gem_4",      "ghost_caijue_gem", "aladdin_lamp_gem_4"]
        ]
    };
}

/// @func mod_gear_evo_build() 把链展开成「步」并缓存到全局（每帧都查，别重复展开）
///   步 = { from, to, kind, credit }；同一条链的顺序即进化顺序
function mod_gear_evo_build(){
    if (variable_global_exists("mod_gear_evo_c") && is_struct(global.mod_gear_evo_c)) return global.mod_gear_evo_c;
    var _d = mod_gear_evo_defs();
    var _kinds = ["weapon", "gem"];
    var _steps = [], _by_from = {}, _by_credit = {};
    for (var _k = 0; _k < 2; _k++){
        var _kind = _kinds[_k];
        var _chains = _d[$ _kind];
        for (var _ci = 0; _ci < array_length(_chains); _ci++){
            var _ch = _chains[_ci];
            for (var _i = 0; _i < array_length(_ch) - 1; _i++){
                var _s = { from: _ch[_i], to: _ch[_i + 1], kind: _kind,
                           tier: _i,                                   // 链内第几档（0/1/2）= 凭证等级
                           credit: "evo_credit_" + string(_ch[_i + 1]) };
                array_push(_steps, _s);
                _by_from[$ _s.from]     = _s;   // 一件装备只会往下进化一级
                _by_credit[$ _s.credit] = _s;
            }
        }
    }
    global.mod_gear_evo_c = { steps: _steps, by_from: _by_from, by_credit: _by_credit };
    return global.mod_gear_evo_c;
}

/// @func mod_gear_evo_steps(kind) 某一类（"weapon" / "gem"）的全部步；kind 省略 = 全部
function mod_gear_evo_steps(_kind = ""){
    var _all = mod_gear_evo_build().steps;
    if (_kind == "") return _all;
    var _out = [];
    for (var _i = 0; _i < array_length(_all); _i++){
        if (_all[_i].kind == _kind) array_push(_out, _all[_i]);
    }
    return _out;
}

/// @func mod_gear_evo_step_from(id) 这件装备的下一步（终点 / 不在表里 → undefined）
function mod_gear_evo_step_from(_id){
    var _c = mod_gear_evo_build();
    if (variable_struct_exists(_c.by_from, _id)) return _c.by_from[$ _id];
    return undefined;
}

/// @func mod_gear_evo_step_credit(credit_id) 这张凭证对应的步（不是本系统的 → undefined）
function mod_gear_evo_step_credit(_credit){
    var _c = mod_gear_evo_build();
    if (variable_struct_exists(_c.by_credit, _credit)) return _c.by_credit[$ _credit];
    return undefined;
}

/// @func mod_gear_evo_credit_id(target_id) 凭证 id（与金卡同前缀）
function mod_gear_evo_credit_id(_to){ return "evo_credit_" + string(_to); }

/// @func mod_gear_evo_is_credit(id) 这个 id 是不是本系统的凭证
function mod_gear_evo_is_credit(_credit){
    return (string_pos("evo_credit_", string(_credit)) == 1 && !is_undefined(mod_gear_evo_step_credit(_credit)));
}

/// @func mod_gear_evo_item_info(id) 装备显示信息 { kind, name, icon, sprite }；查不到 → undefined
function mod_gear_evo_item_info(_id){
    var _w = get_weapon_info(_id);
    if (!is_undefined(_w)) return { kind:"weapon", name:string(_w.name), icon:_w.icon, sprite:_w.sprite };
    var _g = get_gem_info(_id);
    if (!is_undefined(_g)) return { kind:"gem",    name:string(_g.name), icon:_g.icon, sprite:_g.icon };
    return undefined;
}

/// @func mod_gear_evo_name(id) 名字（查不到就回 id）
function mod_gear_evo_name(_id){
    var _i = mod_gear_evo_item_info(_id);
    return is_undefined(_i) ? string(_id) : _i.name;
}

/// @func mod_gear_evo_owned(id) 是否已拥有（武器 / 宝石分开判，别混用两套存档字段）
function mod_gear_evo_owned(_id){
    var _i = mod_gear_evo_item_info(_id);
    if (is_undefined(_i)) return false;
    if (_i.kind == "weapon") return is_weapon_unlocked(_id);
    return is_gem_unlocked(_id);
}

/// @func mod_gear_evo_star(id) 星级（= 存档 max_level，与合成屋/背包画星星的口径一致）；武器恒 0
function mod_gear_evo_star(_id){
    var _i = mod_gear_evo_item_info(_id);
    if (is_undefined(_i) || _i.kind != "gem") return 0;
    return get_gem_max_level(_id);
}

/// @func mod_gear_evo_credit_count(credit_id) 持有数量
function mod_gear_evo_credit_count(_credit){
    return get_material_amount(_credit);
}

/// @func mod_gear_evo_has_credit(credit_id) 够不够用（debug 恒真，跟金卡凭证一个口径）
function mod_gear_evo_has_credit(_credit){
    if (global.debug) return true;
    return get_material_amount(_credit) > 0;
}

/// @func mod_gear_evo_check(step) 能不能进化 → { ok, reason }
function mod_gear_evo_check(_step){
    var _r = { ok:false, reason:"" };
    if (is_undefined(_step)){ _r.reason = "先放一件要进化的装备"; return _r; }
    var _to = mod_gear_evo_item_info(_step.to);
    if (is_undefined(_to)){ _r.reason = "下一形态尚未实装"; return _r; }
    if (!mod_gear_evo_owned(_step.from)){ _r.reason = "还没有" + mod_gear_evo_name(_step.from); return _r; }
    if (mod_gear_evo_owned(_step.to)){ _r.reason = "已经拥有" + _to.name; return _r; }
    if (!mod_gear_evo_has_credit(_step.credit)){ _r.reason = "缺少进化凭证"; return _r; }
    _r.ok = true;
    return _r;
}

/// @func mod_gear_evo_commit(step) 落账：扣凭证 → 消耗旧装备 → 产出新装备
///   界面在特效播完那一帧调它（与金卡进化同一套「延迟结算」），别在点击当帧直接调
function mod_gear_evo_commit(_step){
    if (is_undefined(_step)) return false;
    if (!global.debug) add_material_amount(_step.credit, -1);

    var _from = _step.from, _to = _step.to;

    if (_step.kind == "gem"){
        // 正装备着先卸下（remove_gem 内部会写一次存档）
        if (get_gem_index(_from) != -1) remove_gem(_from);
        var _ug = global.save_data.unlocked_gems;
        for (var _i = array_length(_ug) - 1; _i >= 0; _i--){
            if (_ug[_i].id == _from) array_delete(_ug, _i, 1);
        }
        // 新宝石：level 0 + max_level 0 → 星级归零；**不退强化水晶**（用户口径）
        unlock_gem(_to);
    } else {
        var _slot = get_weapon_slot(_from);          // "" = 没装备
        var _uw = global.save_data.unlocked_weapons;
        for (var _i = array_length(_uw) - 1; _i >= 0; _i--){
            var _w = _uw[_i];
            if ((is_struct(_w) ? _w.id : _w) == _from) array_delete(_uw, _i, 1);
        }
        unlock_weapon(_to);
        // 就地换装：equip_weapon 会先快照旧宝石到记忆表，再按 allowed_weapons 把不兼容的卸下
        if (_slot != "") equip_weapon(_to, _slot);
    }
    save_file(global.save_slot);
    return true;
}

/// @func mod_gear_evo_draw_credit(target_id, cx, cy, has, box) 凭证图标 = 金色底板 + 目标装备图标
///   与金卡凭证 mod_evo_draw_credit 同一套画法（同一张 spr_evo_credit_bg），只是里面换成装备图标
function mod_gear_evo_draw_credit(_to, _cx, _cy, _has, _box = 56){
    var _bg = spr_evo_credit_bg;
    var _bw = sprite_get_width(_bg), _bh = sprite_get_height(_bg);
    var _bs = _box / max(_bw, _bh);
    if (!_has) shader_set(sh_fusion_gray);
    draw_sprite_ext(_bg, 0,
        _cx + (sprite_get_xoffset(_bg) - _bw * 0.5) * _bs,
        _cy + (sprite_get_yoffset(_bg) - _bh * 0.5) * _bs,
        _bs, _bs, 0, c_white, 1);
    var _info = mod_gear_evo_item_info(_to);
    if (!is_undefined(_info)){
        var _is = _info.icon;
        var _iw = sprite_get_width(_is), _ih = sprite_get_height(_is);
        var _sc = min(_box * 0.62 / max(1, _iw), _box * 0.62 / max(1, _ih));
        draw_sprite_ext(_is, 0,
            _cx + (sprite_get_xoffset(_is) - _iw * 0.5) * _sc,
            _cy + (sprite_get_yoffset(_is) - _ih * 0.5) * _sc,
            _sc, _sc, 0, c_white, 1);
    }
    if (!_has) shader_reset();
}

/// @func mod_gear_evo_route_text(step) 进化路线文案（悬停提示 / 背包用）
function mod_gear_evo_route_text(_step){
    if (is_undefined(_step)) return "";
    return mod_gear_evo_name(_step.from) + " → " + mod_gear_evo_name(_step.to)
        + "（消耗 " + mod_gear_evo_name(_step.from) + " + 进化凭证 x1）";
}

/// @func mod_gear_evo_step_of_target(target_id) 目标装备 → 对应的步（商店只有 unlock_item_id，靠它反查）
///   查不到 → undefined（链外的 id，别硬用）
function mod_gear_evo_step_of_target(_to){
    if (_to == "") return undefined;
    return mod_gear_evo_step_credit(mod_gear_evo_credit_id(_to));
}

/// @func mod_gear_evo_credit_price(step) 凭证售价（2026-11-16 用户口径：**按进化档位**）
///   原版登记表只有三个档位的凭证，不是每张 +25：
///     新神器 / 新宝石进化凭证 → 25
///     超神器 / 超宝石进化凭证 → 50
///     补强宝石进化凭证        → 75
///   档位 = 该步在自己链里的下标（mod_gear_evo_build 里写成 step.tier），所以**最贵 75**。
///   ⚠️ 别改回「按登记顺序 ×25」——那样第 31 张会卖到 775，是错的口径（2026-11-16 用户纠正）。
function mod_gear_evo_credit_price(_step){
    if (is_undefined(_step)) return 0;
    var _tier = variable_struct_exists(_step, "tier") ? _step.tier : 0;
    return 25 * (_tier + 1);
}

/// @func mod_gear_evo_buyable_locked(target_id) 商店售罄判定（与 mod_evo_buyable_locked 同口径）
///   已有一张凭证 / 这一阶已经进化出来了 → 售罄。每张凭证一辈子只用 1 次，不必囤。
function mod_gear_evo_buyable_locked(_to){
    if (_to == "") return true;
    if (mod_gear_evo_credit_count(mod_gear_evo_credit_id(_to)) > 0) return true;
    if (mod_gear_evo_owned(_to)) return true;
    return false;
}

/// @func mod_gear_evo_shop_tip(target_id) 商店悬停提示（与背包凭证页同一套四行字）
function mod_gear_evo_shop_tip(_to){
    var _st = mod_gear_evo_step_of_target(_to);
    if (is_undefined(_st)) return "";
    return mod_gear_evo_name(_to) + "（进化凭证）"
        + "\n进化路线：" + mod_gear_evo_route_text(_st)
        + "\n在合成屋-" + ((_st.kind == "gem") ? "宝石进化" : "神器进化") + "中使用";
}

/// @func mod_gear_evo_selfcheck() 自检：链上的 id 是否都注册、有没有重复、凭证是否撞车
///   返回 { ok, errors[] }；控制台在 debug 下由 obj_craft_bg 首次打开时打一次
function mod_gear_evo_selfcheck(){
    var _err = [];
    var _c = mod_gear_evo_build();
    var _seen_to = {};
    for (var _i = 0; _i < array_length(_c.steps); _i++){
        var _s = _c.steps[_i];
        if (is_undefined(mod_gear_evo_item_info(_s.from))) array_push(_err, "未注册（from）：" + _s.from);
        if (is_undefined(mod_gear_evo_item_info(_s.to)))   array_push(_err, "未注册（to）：" + _s.to);
        if (variable_struct_exists(_seen_to, _s.to))       array_push(_err, "同一目标出现两次：" + _s.to);
        _seen_to[$ _s.to] = true;
        if (_s.credit != mod_gear_evo_credit_id(_s.to))     array_push(_err, "凭证 id 不一致：" + _s.credit);
        // 售价只看档位（25/50/75），算到 0 或越界 = 这条步的 tier 没算出来
        var _pr = mod_gear_evo_credit_price(_s);
        if (_pr < 25 || _pr > 75 || (_pr mod 25) != 0) array_push(_err, "售价算不出：" + _s.to);
    }
    return { ok: array_length(_err) == 0, errors: _err };
}
