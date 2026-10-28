/// =============================================================================
///  mod/craft · 金卡表（只放金卡；融合卡在 mod_craft_fusion_table）
///  这个文件 = 金卡进化相关的**全部数据 + 全部规则 + 凭证绘制**，obj_craft_bg 只调它
///  金卡 / 融合卡怎么区分：卡注册数据里的 is_gold / is_fusion（**不看诸神商店卖什么**）
///
///  一、数据（要改就改这里）
///    mod_evo_table()          金卡前置表：金卡 → cards[{ id, slot, need }]
///        slot      金卡进化页的槽位：0 = 第 1 槽（星座卡）/ 1 = 第 2 槽（普通卡）
///                  只有 1 张前置的条目，按它自己是星座还是普通来定
///        need      该前置卡要求的形态：0 本体 / 1 一转 / 2 二转
///                  ⚠️ 一律按这张卡自己的形态上限兜底（蓝莓塔只有 0 转 → need 1 实际按 0 算）
///                  ⚠️ need **只给金卡进化用**：抽卡只发凭证/本体，诸神商店也只判「有没有这张凭证」
///    mod_evo_credit_face()    进化凭证里那张立绘的可见区域（[左,上,宽,高]）
///
///  二、取数 API（对象层用）
///    mod_evo_cards / mod_evo_need_of / mod_evo_slot_need
///
///  三、规则（判定都在这里，对象只存状态）
///    mod_evo_needed_cards()   右侧列表该有哪些卡（还没拥有的金卡所缺的前置）
///    mod_evo_pick_target()    这张卡该进哪张金卡的哪个槽
///    mod_evo_resolve()        落槽后两槽应该是什么（缺的记成 miss）
///    mod_evo_check()          能不能进化（缺卡 / 形态不足 / 凭证不足）
///    mod_evo_reward()         成功落账：扣 1 张凭证 + 解锁金卡（星级从 0 起）
///
///  四、凭证绘制
///    mod_evo_credit_id / mod_evo_has_credit / mod_evo_draw_credit
///
///  改完调 mod_evo_selfcheck() 自检（未注册卡 / 同槽 / 重复 / need 越界）
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
                                        {id:"double_blade_snake", slot:1, need:2} ] },  // 俱吠罗神使 ← 星火红柳烤串机 + 游侠双刃蛇
        gongjiang_god:           { cards:[ {id:"laipishe", slot:0, need:2},
                                        {id:"pizza_oven", slot:1, need:2} ] },  // 鲁班神使 ← 大王赖皮蛇 + 拉丝披萨炉
        brahma:                  { cards:[ {id:"magic_chicken", slot:0, need:2},
                                        {id:"baibianshe", slot:1, need:2} ] },  // 梵天神使 ← 幻幻鸡（这卡只注册到本体，need 2 会被上限兜到 0）+ 双子百变蛇
        guangming_god:           { cards:[ {id:"rabbit_lantern", slot:0, need:2},
                                        {id:"dragon_fruit", slot:1, need:2} ] },  // 巴德尔神使 ← 广寒玉兔灯笼 + 九天皓日火龙果
        shennong_god:            { cards:[ {id:"yanhuangma", slot:0, need:2},
                                        {id:"huagao", slot:1, need:2} ] },  // 神农氏神使 ← 焚天炎凰马 + 梦境灯影花糕
        haiyang_god:             { cards:[ {id:"mozhang", slot:0, need:2},
                                        {id:"hspeed_juicer", slot:1, need:2} ] },  // 塔拉萨神使 ← 凤羽魔杖蛇 + 大菠萝榨汁机
        fengrao_god:             { cards:[ {id:"zhanqima", slot:0, need:2} ] },  // 弗雷神使 ← 燎原战旗马
        clotho:                  { cards:[ {id:"brahma", slot:0, need:0} ] },  // 克洛托神使 ← 梵天神使（**本体即可**，用户 2026-10-27 明确）
        chongsheng_god:          { cards:[ {id:"xingqiongma", slot:0, need:2},
                                        {id:"anranxiaohunfan", slot:1, need:2} ] },  // 奥西里斯神使 ← 浩瀚星穹马 + 天妇罗盖饭
        sun_god:                 { cards:[ {id:"shuangzi", slot:0, need:2},
                                        {id:"small_fire", slot:1, need:2} ] },  // 阿波罗神使 ← 双子座星宿 + 太阳能高效炉
        heian_god:               { cards:[ {id:"mojie", slot:0, need:2},
                                        {id:"durian", slot:1, need:2} ] },  // 黑暗神使 ← 摩羯座战将（星座槽）+ 冰河世纪榴莲
        aurora:                  { cards:[ {id:"zhuzhujiaqiang", slot:0, need:2},
                                        {id:"blueberry_tower", slot:1, need:2} ] },  // 欧若拉神使 ← 猪猪发射站 + 蓝莓信号塔塔（这卡只注册到本体，按上限兜底）
        houyi_god:               { cards:[ {id:"sheshou", slot:0, need:2},
                                        {id:"double_blade_snake", slot:1, need:2} ] },  // 后羿神使 ← 射手座星宿（星座槽）+ 游侠双刃蛇（2026-10-28：融合三线→射手座，并对调槽位）
        joker:                   { cards:[ {id:"donut", slot:0, need:2} ] },  // 埃罗斯神使 ← 女王多拿滋
        time_god:                { cards:[ {id:"magic_chicken", slot:0, need:2},
                                        {id:"ice_cream", slot:1, need:2} ] },  // 柯罗诺斯神使 ← 幻幻鸡 + 极寒冰沙（2026-10-28 对调）
        xiangshui_god:           { cards:[ {id:"berry_dessert", slot:0, need:2} ] },  // 塔利亚神使 ← 流心莓果点心
        war_god:                 { cards:[ {id:"tiancheng", slot:0, need:2},
                                        {id:"double_water_pipe", slot:1, need:2} ] },  // 阿瑞斯神使 ← 天秤座星宿 + 合金水管
        thor:                    { cards:[ {id:"shuangyu", slot:0, need:2},
                                        {id:"egg_boiler_pult", slot:1, need:2} ] },  // 索尔神使 ← 双鱼座星宿 + 强袭煮蛋器
        fire_god:                { cards:[ {id:"jinniu", slot:0, need:2},
                                        {id:"brazier", slot:1, need:2} ] },  // 洛基神使 ← 金牛座星宿 + 岩烧烤盘
        moon_god:                { cards:[ {id:"juxie", slot:0, need:2},
                                        {id:"takoyaki", slot:1, need:2} ] },  // 狄安娜神使 ← 巨蟹座星宿 + 火影章鱼烧
        power_god:               { cards:[ {id:"hotdog_cannon", slot:0, need:2},
                                        {id:"tang_hu_lu", slot:1, need:2} ] },  // 赫丘利神使 ← 热狗榴弹炮 + 七彩糖葫芦弹
        gaia:                    { cards:[ {id:"curry_lobster_cannon", slot:0, need:2},
                                        {id:"chocolate_cannon", slot:1, need:2} ] },  // 盖亚神使 ← 加农龙虾炮 + 死神大炮
        zhurong:                 { cards:[ {id:"pan_fried_bun", slot:0, need:2},
                                        {id:"stinky_tofu_pult", slot:1, need:2} ] },  // 祝融神使 ← 臭豆腐投手 + 生煎锅
        rig:                     { cards:[ {id:"starrabbit", slot:0, need:2},
                                        {id:"nut_frier", slot:1, need:2} ] },  // 里格神使 ← 宇宙星星兔 + 松塔爆破机
        ymir:                    { cards:[ {id:"grilled_lizard_pult", slot:0, need:2},
                                        {id:"spoon_rabbit", slot:1, need:2} ] },  // 尤弥尔神使 ← 花椒蜥蜴投手 + 盖世勺勺兔
        save_god:                { cards:[ {id:"baiyang", slot:0, need:2},
                                        {id:"bull_firework", slot:1, need:2} ] },  // 灵鱼摩蹉神使 ← 白羊座星宿 + 璀璨金牛烟花
        poseidon:                { cards:[ {id:"shizi", slot:0, need:2},
                                        {id:"rotating_coffee_pot", slot:1, need:2} ] },  // 波塞冬神使 ← 狮子座星宿 + 原子咖啡壶
        ghost_god:               { cards:[ {id:"coal_starfish", slot:0, need:2} ] },  // 哈迪斯神使 ← 芥末海星刺身
        odin:                    { cards:[ {id:"double_blade_snake", slot:0, need:2} ] },  // 奥丁神使 ← 游侠双刃蛇
        water_god:               { cards:[ {id:"cherry_pudding", slot:0, need:2} ] },  // 忒提丝神使 ← 节能反弹布丁
        hundun_god:              { cards:[ {id:"hamburger", slot:0, need:2} ] },  // 混沌神使 ← 牛肉双黑汉堡
        // ⚠️ 下面 4 张不在用户给的配方表里（图上没有），沿用旧前置，等补表再改
        firework_dragon_real:    { cards:[ {id:"firework_dragon", slot:0, need:2},
                                        {id:"shegengbao", slot:1, need:2} ] },  // 真·花火龙 ← 花火龙 + 蛇羹煲
        hera:                    { cards:[ {id:"chunv", slot:0, need:2},
                                        {id:"melon_shield", slot:1, need:2} ] },  // 天后 ← 处女座精灵 + 瓜皮护罩
        ice_god:                 { cards:[ {id:"cold_drew", slot:0, need:2},
                                        {id:"ice_bucket_bomb", slot:1, need:2} ] },  // 典伊神使 ← 迅捷冷萃机 + 杂果冰桶炸弹
        zeus:                    { cards:[ {id:"athena", slot:0, need:2} ] },  // 宙斯神使 ← 雅典娜守护（2026-10-28：取消第 2 槽咖喱龙虾炮，只需一张）
        love_god:                { cards:[ {id:"sheshou", slot:0, need:2},
                                        {id:"triple_wine_rack", slot:1, need:2} ] },  // 丘比特神使 ← 射手座星宿 + 终结者酒架
        panduola_god:            { cards:[ {id:"aquarius_elve", slot:0, need:2},
                                        {id:"pufferfish", slot:1, need:2} ] },  // 潘多拉 ← 水瓶座精灵（星座槽）+ 爆辣河豚（2026-10-28 改）
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
    zeus: [62, 511, 75, 69],
    love_god: [18, 0, 93, 88],
    panduola_god: [80, 73, 59, 55],
    lingrong_god: [0, 0, 92, 75]
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
}
