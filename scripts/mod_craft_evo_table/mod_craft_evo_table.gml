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
///    mod_evo_flat  扁平老形状，只被 gacha_random_card.fusion_get_prerequisites() 转发
///                  （诸神商店「金卡本体」类商品的前置门槛还读它，当前没有这类商品）
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
        sheng_huo:               { cards:[ {id:"beef_hotpot", slot:0, need:1},
                                        {id:"spicy_pot", slot:1, need:1} ] },  // 圣火 ← 肥牛火锅 + 麻辣香锅（2026-10-23 补双前置）
        hufa_god:                { cards:[ {id:"hongliukaochuan", slot:0, need:1},
                                        {id:"double_blade_snake", slot:1, need:1} ] },  // 护法 ← 烤串机 + 双刃蛇（同为穿透/斩杀，2026-10-23 补双前置）
        gongjiang_god:           { cards:[ {id:"laipishe", slot:0, need:1},
                                        {id:"pizza_oven", slot:1, need:1} ] },  // 工匠 ← 赖皮蛇 + 披萨炉
        brahma:                  { cards:[ {id:"magic_chicken", slot:0, need:1},
                                        {id:"baibianshe", slot:1, need:1} ] },  // 创造神 ← 幻幻鸡 + 百变蛇（幻幻鸡没有二转，放前面让「二转」只落在百变蛇上）
        guangming_god:           { cards:[ {id:"dragon_fruit", slot:1, need:1} ] },  // 光明神 ← 火龙果
        shennong_god:            { cards:[ {id:"yanhuangma", slot:1, need:1} ] },  // 炎帝 ← 炎凰马
        haiyang_god:             { cards:[ {id:"hspeed_juicer", slot:0, need:1},
                                        {id:"mozhang", slot:1, need:1} ] },  // 海洋 ← 榨汁机 + 魔杖蛇
        fengrao_god:             { cards:[ {id:"zhanqima", slot:1, need:1} ] },  // 丰饶神 ← 战旗马
        clotho:                  { cards:[ {id:"brahma", slot:1, need:0} ] },  // 命运 ← 创造神（硬前置：本体即可，见 prereq_body_only）
        chongsheng_god:          { cards:[ {id:"xingqiongma", slot:0, need:1},
                                        {id:"anranxiaohunfan", slot:1, need:1} ] },  // 重生神 ← 星穹马 + 天妇罗盖饭
        sun_god:                 { cards:[ {id:"small_fire", slot:1, need:1},
                                        {id:"shuangzi", slot:0, need:1} ] },  // 太阳神 ← 小火炉 + 双子座精灵
        heian_god:               { cards:[ {id:"durian", slot:1, need:1} ] },  // 黑暗神 ← 榴莲
        aurora:                  { cards:[ {id:"blueberry_tower", slot:1, need:1} ] },  // 曙光女神 ← 蓝莓信号塔塔（水果塔是未实装卡，2026-10-22 从前置里去掉）
        houyi_god:               { cards:[ {id:"ronghesanxian", slot:1, need:1} ] },  // 宗布神 ← 融合三线
        joker:                   { cards:[ {id:"donut", slot:0, need:1},
                                        {id:"cat_box", slot:1, need:1} ] },  // 恶作剧神 ← 多拿滋 + 猫猫盒（猫猫盒只有 0 转，按形态上限兜底＝拥有本体即可）
        time_god:                { cards:[ {id:"ice_cream", slot:1, need:1} ] },  // 时间神 ← 冰激凌
        xiangshui_god:           { cards:[ {id:"berry_dessert", slot:1, need:1} ] },  // 宴飨女神 ← 莓果点心
        war_god:                 { cards:[ {id:"double_water_pipe", slot:1, need:1},
                                        {id:"tiancheng", slot:0, need:1} ] },  // 战神 ← 双向水管 + 天秤座精灵
        thor:                    { cards:[ {id:"egg_boiler_pult", slot:1, need:1},
                                        {id:"shuangyu", slot:0, need:1} ] },  // 雷神 ← 煮蛋器投手 + 双鱼座精灵
        fire_god:                { cards:[ {id:"brazier", slot:1, need:1},
                                        {id:"jinniu", slot:0, need:1} ] },  // 火神 ← 火盆 + 金牛座精灵
        moon_god:                { cards:[ {id:"takoyaki", slot:1, need:1},
                                        {id:"juxie", slot:0, need:1} ] },  // 月神 ← 章鱼烧 + 巨蟹座精灵
        power_god:               { cards:[ {id:"tang_hu_lu", slot:1, need:1} ] },  // 大力神 ← 糖葫芦炮弹
        gaia:                    { cards:[ {id:"chocolate_cannon", slot:1, need:1} ] },  // 大地女神 ← 巧克力大炮
        zhurong:                 { cards:[ {id:"pan_fried_bun", slot:0, need:1},
                                        {id:"lizi_god", slot:1, need:1} ] },  // 赤帝 ← 生煎锅 + 融合栗子
        rig:                     { cards:[ {id:"starrabbit", slot:0, need:1},
                                        {id:"nut_frier", slot:1, need:1} ] },  // 守护神 ← 星星兔 + 坚果爆炒机
        ymir:                    { cards:[ {id:"grilled_lizard_pult", slot:0, need:1},
                                        {id:"spoon_rabbit", slot:1, need:1} ] },  // 巨神 ← 烤蜥蜴投手 + 勺勺兔（原灵融煮蛋，2026-10-23 换）
        save_god:                { cards:[ {id:"bull_firework", slot:1, need:1},
                                        {id:"baiyang", slot:0, need:1} ] },  // 救世神 ← 金牛烟花 + 白羊座精灵
        poseidon:                { cards:[ {id:"rotating_coffee_pot", slot:1, need:1},
                                        {id:"shizi", slot:0, need:1} ] },  // 海神 ← 旋转咖啡喷壶 + 狮子座精灵
        ghost_god:               { cards:[ {id:"coal_starfish", slot:1, need:1} ] },  // 冥神 ← 炭烧海星
        odin:                    { cards:[ {id:"tar_sprayer", slot:1, need:1} ] },  // 主神 ← 焦油喷壶
        water_god:               { cards:[ {id:"cherry_pudding", slot:1, need:1} ] },  // 水神 ← 樱桃反弹布丁
        hundun_god:              { cards:[ {id:"hamburger", slot:1, need:1} ] },  // 混沌神使 ← 汉堡包
        firework_dragon_real:    { cards:[ {id:"firework_dragon", slot:0, need:1},
                                        {id:"shegengbao", slot:1, need:1} ] },  // 真·花火龙 ← 花火龙 + 蛇羹煲
        hera:                    { cards:[ {id:"melon_shield", slot:1, need:1},
                                        {id:"chunv", slot:0, need:1} ] },  // 天后 ← 瓜皮护罩 + 处女座精灵
        ice_god:                 { cards:[ {id:"cold_drew", slot:1, need:1} ] },  // 冰神 ← 冰块冷萃机
        zeus:                    { cards:[ {id:"athena", slot:0, need:1},
                                        {id:"curry_lobster_cannon", slot:1, need:1} ] },  // 宙斯 ← 雅典娜守护 + 咖喱龙虾炮
        love_god:                { cards:[ {id:"sheshou", slot:0, need:1},
                                        {id:"triple_wine_rack", slot:1, need:1} ] },  // 爱神 ← 射手座精灵 + 三线酒架
        panduola_god:            { cards:[ {id:"coke_bomb", slot:0, need:1},
                                        {id:"pufferfish", slot:1, need:1} ] },  // 潘多拉 ← 可乐炸弹 + 爆辣河豚（玉兔灯笼，2026-10-23 换）
        lingrong_god:            { cards:[ {id:"cotton_candy", slot:1, need:1} ] }  // 魔导士软糖 ← 棉花糖
    };
}

/// @func mod_evo_flat() 老格式 {目标卡: [前置卡 id, …]}，只剩 fusion_get_prerequisites() 转发在用
///      ⚠️ 新代码别再用；金卡进化一律走 mod_evo_cards()
function mod_evo_flat(){
    var _t = mod_evo_table();
    var _names = variable_struct_get_names(_t);
    var _out = {};
    for (var _i = 0; _i < array_length(_names); _i++){
        var _e = _t[$ _names[_i]];
        var _ids = [];
        for (var _j = 0; _j < array_length(_e.cards); _j++) array_push(_ids, _e.cards[_j].id);
        _out[$ _names[_i]] = _ids;
    }
    return _out;
}

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
function mod_evo_credit_face(){
    // 绘制时每帧都会查 → 第一次建好就缓存到全局，后面直接读
    if (variable_global_exists("mod_evo_face_tbl")) return global.mod_evo_face_tbl;
    var _t = {

    sheng_huo:             [12, 35, 71, 88],   // spr_sh
    hufa_god:              [1, 0, 110, 107],   // spr_hufa_god
    gongjiang_god:         [13, 6, 82, 82],   // spr_gongjiang_god
    brahma:                [60, 63, 73, 66],   // spr_brahma_icon
    guangming_god:         [19, 32, 93, 85],   // spr_light_god
    shennong_god:          [26, 40, 78, 93],   // spr_shennong_god
    haiyang_god:           [11, 0, 107, 110],   // spr_haiyang_god
    fengrao_god:           [0, 3, 88, 86],   // spr_fengrao_god
    clotho:                [36, 65, 64, 83],   // spr_clotho_icon
    chongsheng_god:        [4, 29, 91, 77],   // spr_chongsheng_god
    sun_god:               [2, 13, 70, 108],   // spr_sun_god
    heian_god:             [119, 159, 77, 58],   // spr_dark_god
    aurora:                [2, 14, 54, 88],   // spr_aurora_icon
    houyi_god:             [15, 4, 100, 88],   // spr_houyi_god
    joker:                 [12, 49, 74, 89],   // spr_joker_icon
    time_god:              [28, 88, 173, 128],   // spr_time_god
    xiangshui_god:         [11, 10, 91, 79],   // spr_xiangshui_god
    war_god:               [1, 10, 84, 97],   // spr_war_god
    thor:                  [23, 37, 97, 89],   // spr_thor_icon
    fire_god:              [0, 0, 70, 50],   // spr_fire_god
    moon_god:              [15, 1, 82, 88],   // spr_moon_god
    power_god:             [12, 8, 78, 81],   // spr_power_god
    gaia:                  [4, 116, 75, 55],   // spr_gaia
    zhurong:               [22, 9, 68, 87],   // spr_zhurong
    rig:                   [39, 55, 118, 94],   // spr_rig
    ymir:                  [30, 12, 84, 82],   // spr_ymir_icon
    save_god:              [44, 63, 89, 89],   // spr_save_god_0
    poseidon:              [115, 122, 103, 105],   // spr_poseidon
    ghost_god:             [10, 4, 65, 85],   // spr_ghost_god
    odin:                  [29, 27, 92, 69],   // spr_odin
    water_god:             [1, 16, 71, 68],   // spr_water_god
    hundun_god:            [130, 83, 78, 68],   // spr_hundun_god
    firework_dragon_real:  [49, 95, 73, 72],   // spr_firework_dragon
    hera:                  [0, 2, 100, 46],   // spr_hera_icon_1
    ice_god:               [0, 65, 92, 88],   // spr_ice_god
    zeus:                  [62, 511, 75, 69],   // spr_zeus
    love_god:              [4, 0, 90, 89],   // spr_love_god
    panduola_god:          [13, 5, 200, 195],   // spr_panduola_god
    lingrong_god:          [15, 10, 63, 61]   // spr_lingrong_god
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
        if (get_card_info_simple(_c.id).max_shape < _need){
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

/// @func mod_evo_card_name(card_id) 卡的本体形态名（提示文案用；查不到就用 id）
function mod_evo_card_name(_id){
    var _d = get_plant_shape_data(_id, 0);
    if (_d != undefined && ds_map_exists(_d, "name")) return _d[? "name"];
    return _id;
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
    for (var _i = 0; i < array_length(_cs); _i++){
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
