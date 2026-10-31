/// =============================================================================
///  mod/craft · 融合表（合成屋 · 食灵融合，craft_top_tab == 1）
///  这个文件 = 融合的**全部配方 + 全部取数 API + 菜谱提示**，obj_craft_bg 只调它
///  卡怎么分类：卡注册数据里的 is_fusion（**不看诸神商店卖什么**）
///
///  一、数据（要改就改这里）
///    mod_fusion_table()
///        融合卡 → { prereq, cards:[ 初级, 深度, 灵魂 ] }
///          prereq   前置主卡：抽到任档菜谱都附赠这张；初融那一档的 main 就是它
///          cards[]  每档一条 { main:{ id, need }, sub:{ id, need } }
///                   need = 0 本体 / 1 一转 / 2 二转，**逐条显式写**
///                          （不设默认值、不另开「排除表」，例外直接改那条的 need）
///                   副卡 sub.id 写 "" = 这道菜谱没有副卡
///    mod_fusion_levels()   三档消耗（显示名 / 产物形态 / 金币 / 融合剂 + 数量）
///
///  二、取数 API（对象层用，别直接读表）
///    mod_fusion_recipe(id, shape)    某档配方 → { main, sub }（都带 need；查不到 = 空 id）
///    mod_fusion_prereq(id)           前置主卡 id（= 初融 main.id）
///    mod_fusion_card_order()         融合页「防御卡」列表的收集顺序 + 前置主卡
///    mod_fusion_need_shape(id, need) need 按这张卡自己的形态上限兜底
///
///  三、文案
///    mod_fusion_recipe_tip(id, shape)  菜谱提示三行：菜谱名 / 主卡 / 副卡
///        合成屋融合页、诸神商店、背包凭证页**都调这一处**，三边字必须一字不差
///
///  改完调 mod_fusion_selfcheck() 自检（缺档 / 空主卡 / 前置对不上 / 副卡没注册）
/// =============================================================================

/// @func mod_fusion_table() 融合配方总表：一张融合卡一个条目，主副卡写在一起
/// @return { struct } 卡 id → { prereq, cards:[初级, 深度, 灵魂] }
function mod_fusion_table(){
    return {
        // ── 融合巧克力炮 ← 死神大炮 ────────────────────────────────────────
        ronghedapao: {
            prereq: "chocolate_cannon",                       // 死神大炮
            cards: [
                { main:{ id:"chocolate_cannon",  need:2 }, sub:{ id:"chocolate_pult",     need:2 } },  // 脆心巧克力投手
                { main:{ id:"ronghedapao",       need:0 }, sub:{ id:"lightning_baguette", need:2 } },  // 雷电长棍面包（官方电鳗的顶替）
                { main:{ id:"ronghedapao",       need:1 }, sub:{ id:"flour_sack",        need:2 } }   // 乾坤分身袋
            ]
        },
        // ── 融合海星 ← 炭烧海星 ────────────────────────────────────────────
        ronghehaixing: {
            prereq: "coal_starfish",                          // 芥末海星刺身
            cards: [
                { main:{ id:"coal_starfish",     need:2 }, sub:{ id:"melon_shield",      need:2 } },  // 锋芒瓜皮护罩（官方仙人掌花刺身的顶替）
                { main:{ id:"ronghehaixing",     need:0 }, sub:{ id:"eightcake",         need:2 } },  // 8周年红丝绒
                { main:{ id:"ronghehaixing",     need:1 }, sub:{ id:"sugar_ball_pult",   need:2 } }   // 可可糖全能投手（官方王冠蜜糖陷阱的顶替）
            ]
        },
        // ── 融合鱿鱼 ← 章鱼烧 ──────────────────────────────────────────────
        youyu_god: {
            prereq: "takoyaki",                               // 火影章鱼烧
            cards: [
                { main:{ id:"takoyaki",          need:2 }, sub:{ id:"coal_starfish",     need:2 } },  // 芥末海星刺身（0 转 8 向齐射 → 取多方向卡）
                { main:{ id:"youyu_god",         need:0 }, sub:{ id:"double_water_pipe", need:2 } },  // 合金水管
                { main:{ id:"youyu_god",         need:1 }, sub:{ id:"nut_frier",         need:2 } }   // 松塔爆破机
            ]
        },
        // ── 融合栗子 ← 糖炒栗子 ────────────────────────────────────────────
        lizi_god: {
            prereq: "tangchaolizi",                           // 糖炒栗子
            cards: [
                { main:{ id:"tangchaolizi",      need:2 }, sub:{ id:"spicy_pot",         need:2 } },  // 酱香鱿鱼锅
                { main:{ id:"lizi_god",          need:0 }, sub:{ id:"coke_bomb",         need:2 } },  // 燃烧可乐弹
                { main:{ id:"lizi_god",          need:1 }, sub:{ id:"qingse_shishi",     need:2 } }   // 柿柿如意
            ]
        },
        // ── 融合煮蛋器 ← 煮蛋器投手 ────────────────────────────────────────
        ronghedan_god: {
            prereq: "egg_boiler_pult",                        // 强袭煮蛋器
            cards: [
                { main:{ id:"egg_boiler_pult",   need:2 }, sub:{ id:"ice_egg_boiler_pult", need:2 } },  // 冰河煮蛋器
                { main:{ id:"ronghedan_god",     need:0 }, sub:{ id:"stinky_tofu_pult",  need:2 } },    // 铁板臭豆腐投手
                { main:{ id:"ronghedan_god",     need:1 }, sub:{ id:"triple_wine_rack",  need:2 } }     // 终结者酒架
            ]
        },
        // ── 融合火盆 ← 岩烧烤盘 ────────────────────────────────────────────
        ronghehuopen: {
            prereq: "brazier",                                // 岩烧烤盘
            cards: [
                { main:{ id:"brazier",           need:2 }, sub:{ id:"sugar_roxburghii", need:2 } },  // 生腌酸刺梨
                { main:{ id:"ronghehuopen",      need:0 }, sub:{ id:"durian",           need:2 } },  // 冰河世纪榴莲
                { main:{ id:"ronghehuopen",      need:1 }, sub:{ id:"ice_bucket_bomb",  need:2 } }   // 杂果冰桶炸弹
            ]
        },
        // ── 融合三线 ← 终结者三线酒架 ──────────────────────────────────────
        ronghesanxian: {
            prereq: "triple_wine_rack",                       // 终结者酒架
            cards: [
                { main:{ id:"triple_wine_rack",  need:2 }, sub:{ id:"wine_bottle_bomb", need:2 } },  // 子母酒瓶弹
                { main:{ id:"ronghesanxian",     need:0 }, sub:{ id:"sheshou",          need:2 } },  // 射手座星宿（1 转三行各 3 发 → 取三行多发卡）
                { main:{ id:"ronghesanxian",     need:1 }, sub:{ id:"oden_pot",         need:2 } }   // 海鲜关东煮喷锅（2 转三行穿透 → 取三行穿透卡）
            ]
        },
        // ── 融合双菇 ← 蚝油双菇 ────────────────────────────────────────────
        rongheshuanggu: {
            prereq: "shuanggu",                               // 蚝油双菇
            cards: [
                { main:{ id:"shuanggu",          need:2 }, sub:{ id:"hotdog_cannon",    need:2 } },  // 热狗榴弹炮
                { main:{ id:"rongheshuanggu",    need:0 }, sub:{ id:"coffee_pot",       need:2 } },  // 红温咖啡喷壶
                { main:{ id:"rongheshuanggu",    need:1 }, sub:{ id:"tang_hu_lu",       need:2 } }   // 七彩糖葫芦弹
            ]
        },
        // ── 融合咖啡杯 ← 骨瓷咖啡杯 ────────────────────────────────────────
        ronghekafei: {
            prereq: "coffee_cup",                             // 骨瓷咖啡杯
            cards: [
                { main:{ id:"coffee_cup",        need:2 }, sub:{ id:"gatlin_long_bao",  need:2 } },  // 格林机枪笼包
                { main:{ id:"ronghekafei",       need:0 }, sub:{ id:"coffee_pot",       need:2 } },  // 红温咖啡喷壶
                { main:{ id:"ronghekafei",       need:1 }, sub:{ id:"coffee_cup",       need:2 } }   // 骨瓷咖啡杯
            ]
        }
    };
}

/// @func mod_fusion_levels() 三档消耗
/// @return { array } [{ name 显示名, shape 产物形态, gold 金币, mat 材料 id, mat_n 数量 }, ...]
function mod_fusion_levels(){
    return [
        { name: "初级", shape: 0, gold: 150000, mat: "secret_spices", mat_n: 1000 },
        { name: "深度", shape: 1, gold: 320000, mat: "clover_4",      mat_n: 15   },
        { name: "灵魂", shape: 2, gold: 560000, mat: "royal_spices",  mat_n: 1000 }
    ];
}

/// @func mod_fusion_recipe(id, shape) 某张融合卡某档的配方
/// @param shape 0 初级 / 1 深度 / 2 灵魂（越界按最近一档算）
/// @return { struct } { main:{id, need}, sub:{id, need} }；查不到返回空 id（调用方直接判 id == ""）
function mod_fusion_recipe(_id, _shape){
    var _empty = { main:{ id:"", need:0 }, sub:{ id:"", need:0 } };
    var _t = mod_fusion_table();
    if (!variable_struct_exists(_t, _id)) return _empty;
    var _cards = _t[$ _id].cards;
    if (!is_array(_cards) || array_length(_cards) == 0) return _empty;
    var _i = clamp(_shape, 0, array_length(_cards) - 1);
    return _cards[_i];
}

/// @func mod_fusion_prereq(id) 这张融合卡的前置主卡（= 初融那一档的 main）；查不到返回 ""
function mod_fusion_prereq(_id){
    var _t = mod_fusion_table();
    if (!variable_struct_exists(_t, _id)) return "";
    return _t[$ _id].prereq;
}

/// @func mod_fusion_need_shape(id, need) 要求形态按这张卡自己的上限兜底
///   例：need 2 但卡只注册到 1 转（card_max_available_shape = 1）→ 按 1 转算，不会永远凑不齐
function mod_fusion_need_shape(_id, _need){
    var _max = card_max_available_shape(_id);
    if (_max < 0) return _need;         // 查不到这张卡：原样返回，别把要求抹成 0
    return min(_need, _max);
}

/// @func mod_fusion_card_order() 融合页「防御卡」列表的收集顺序
///   ⚠️ 这个顺序就是融合页每档列出来的先后（历史沿用），**只能往后接、不能插队**
/// @return { array } [{ id 融合卡, pre 前置主卡 }, ...]
function mod_fusion_card_order(){
    var _ids = [
        "ronghedapao",      // 0 融合巧克力炮
        "ronghehaixing",    // 1 融合海星
        "youyu_god",        // 2 融合鱿鱼
        "lizi_god",         // 3 融合栗子
        "ronghedan_god",    // 4 融合煮蛋器
        "ronghehuopen",     // 5 融合火盆
        "ronghesanxian",    // 6 融合三线
        "rongheshuanggu",   // 7 融合双菇
        "ronghekafei"       // 8 融合咖啡杯
    ];
    var _out = [];
    for (var _i = 0; _i < array_length(_ids); _i++){
        array_push(_out, { id: _ids[_i], pre: mod_fusion_prereq(_ids[_i]) });
    }
    return _out;
}

/// @func mod_fusion_recipe_tip(id, shape) 菜谱提示三行（菜谱名 / 主卡 / 副卡）
///   合成屋融合页、诸神商店、背包凭证页**都调这里**，三边字必须一字不差。
///   只依赖本表 + gacha_random_card 的 fusion_recipe_*，**不依赖 obj_craft_bg 里的对象内函数**
///   （诸神商店可能没进过合成屋就打开，那时对象函数还不存在）
function mod_fusion_recipe_tip(_id, _shape){
    // ① 标题：优先取诸神商店那条商品的名（跟商店一字不差），取不到才现拼
    var _title = "";
    var _gid = (_shape <= 0) ? _id : _id + "_" + string(_shape);
    if (variable_global_exists("gods_goods_map") && ds_exists(global.gods_goods_map, ds_type_map)
        && ds_map_exists(global.gods_goods_map, _gid)){
        var _g = global.gods_goods_map[? _gid];
        if (!is_undefined(_g)){
            if (variable_struct_exists(_g, "recipe_name") && is_string(_g.recipe_name) && _g.recipe_name != "") _title = _g.recipe_name;
            else if (variable_struct_exists(_g, "display_name") && is_string(_g.display_name)) _title = _g.display_name;
        }
    }
    if (_title == "") _title = fusion_recipe_display_name(_id, _shape);

    // ② 主卡 / 副卡：直接读这一档的配方，卡名按 need 兜底后的形态取（不再带「（X转）」后缀）
    var _r   = mod_fusion_recipe(_id, _shape);
    var _tip = _title;
    if (_r.main.id != ""){
        var _mn = mod_fusion_need_shape(_r.main.id, _r.main.need);
        _tip += "\n主卡：" + fusion_recipe_card_name(_r.main.id, _mn);
    }
    if (_r.sub.id != ""){
        var _sn = mod_fusion_need_shape(_r.sub.id, _r.sub.need);
        _tip += "\n副卡：" + fusion_recipe_card_name(_r.sub.id, _sn);
    }
    return _tip;
}

/// @func mod_fusion_plate(shape) 该档菜谱底板配置
///   spr           底板精灵（192x192，中心原点）：spr_recipe_plate_0/1/2
///   pad_x/pad_y   内胆相对底板的左右 / 上下留边比例（卡面就画在这块里面）
///   ⚠️ 三块底板是照各档原素材分别抠的，边框厚度不一样 → 留边比例必须分开写；
///      想调卡面大小改这里的 pad（越大卡面越小）
function mod_fusion_plate(_shape){
    if (_shape <= 0) return { spr: spr_recipe_plate_0, pad_x: 0.070, pad_y: 0.070 };   // 初融（细框）
    if (_shape == 1) return { spr: spr_recipe_plate_1, pad_x: 0.068, pad_y: 0.107 };   // 深度融合（金角蓝底）
    return                 { spr: spr_recipe_plate_2, pad_x: 0.073, pad_y: 0.152 };    // 灵魂融合（华丽框，上下更厚）
}

/// @func mod_fusion_recipe_face(card_id, shape) 卡面精灵的「可见区域」→ [左, 上, 宽, 高]
///   跟金卡凭证的 mod_evo_credit_face() 同一个思路：**只查这张静态表**，
///   不用 sprite_get_bbox_*（这批精灵在开了 autocrop 的纹理组上量出来的值不可信，会缩成指甲盖）。
///   数值是照每张卡每个形态的 PNG 第 0 帧量出来的（内容包围盒），换了卡面素材要重新量。
function mod_fusion_recipe_face(_id, _shape){
    var _t = {
        //                    形态 0（初融）      形态 1（深度融合）    形态 2（灵魂融合）
        ronghedapao:    [ [0, 21, 84, 76],   [0, 22, 100, 75],   [0, 22, 119, 82] ],
        ronghehaixing:  [ [0, 2, 80, 87],    [0, 2, 80, 89],     [0, 2, 94, 83] ],
        youyu_god:      [ [6, 5, 81, 78],    [7, 5, 93, 83],     [8, 6, 95, 82] ],
        lizi_god:       [ [6, 34, 84, 79],   [6, 27, 109, 79],   [6, 27, 111, 80] ],
        ronghedan_god:  [ [19, 56, 122, 101],[14, 57, 129, 104], [18, 50, 127, 109] ],
        ronghehuopen:   [ [2, 8, 66, 48],    [2, 8, 66, 48],     [1, 9, 72, 47] ],
        ronghesanxian:  [ [2, 1, 77, 75],    [2, 1, 77, 75],     [2, 1, 85, 76] ],
        rongheshuanggu: [ [8, 30, 78, 98],   [10, 35, 79, 107],  [10, 36, 78, 115] ],
        ronghekafei:    [ [0, 6, 65, 45],    [0, 5, 64, 48],     [0, 3, 77, 64] ]
    };
    if (!variable_struct_exists(_t, _id)) return [0, 0, 64, 64];    // 表里没这张卡（正常不会走到，自检会报）
    var _a = _t[$ _id];
    return _a[clamp(_shape, 0, array_length(_a) - 1)];
}

/// @func mod_fusion_draw_recipe(card_id, shape, cx, cy, box, alpha) 画一个菜谱图标
///   跟**进化凭证**完全同一套做法：统一底板 + 该卡该形态的**卡面精灵**（不是菜谱道具图）。
///   背包凭证页 / 诸神商店 / 抽卡奖励弹窗 / 战斗暂停 / 合成屋（槽位 + 列表）全都调这里，
///   五处口径一致，图标也不会再出现「初融比别的档大 1.5 倍」那种大小不一。
/// @param box    底板边长（卡片就是这么大，卡面按内胆自动往里收）
/// @param alpha  整体透明度（默认 1）
function mod_fusion_draw_recipe(_id, _shape, _cx, _cy, _box, _alpha = 1){
    // ① 底板（精灵原点在中心，直接画在 cx,cy）
    var _cfg = mod_fusion_plate(_shape);
    var _pw = sprite_get_width(_cfg.spr);
    var _ps = _box / _pw;
    draw_sprite_ext(_cfg.spr, 0, _cx, _cy, _ps, _ps, 0, c_white, _alpha);

    // ② 卡面：该卡该形态的卡牌精灵，按静态可见区等比缩放居中（跟 mod_evo_draw_credit 同一套换算）
    var _cd = deck_get_card_data(_id, _shape);
    if (_cd == noone) return;
    var _spr = _cd[? "sprite"];
    var _f   = mod_fusion_recipe_face(_id, _shape);
    var _iw  = _box * (1 - _cfg.pad_x * 2);
    var _ih  = _box * (1 - _cfg.pad_y * 2);
    var _sc  = min(_iw / _f[2], _ih / _f[3]) * 0.96;      // 0.96 = 卡面占内胆的比例
    var _ox  = (_f[0] + _f[2] * 0.5 - sprite_get_xoffset(_spr)) * _sc;
    var _oy  = (_f[1] + _f[3] * 0.5 - sprite_get_yoffset(_spr)) * _sc;
    draw_sprite_ext(_spr, 0, _cx - _ox, _cy - _oy, _sc, _sc, 0, c_white, _alpha);
}

/// @func mod_fusion_selfcheck() 表自检 → 问题描述数组（空数组 = 没问题）
///   查：每张卡正好三档 / 初融主卡必须等于 prereq / 主副卡 id 不能空且必须在卡池里 /
///       深度灵魂的主卡必须是这张融合卡自己 / 卡池里的融合卡和 order 列表必须一一对应
function mod_fusion_selfcheck(){
    var _bad = [];
    var _t = mod_fusion_table();
    var _names = variable_struct_get_names(_t);
    var _order = mod_fusion_card_order();
    if (array_length(_names) != array_length(_order)){
        array_push(_bad, "表里有 " + string(array_length(_names)) + " 张融合卡，order 列表是 " + string(array_length(_order)) + " 张");
    }
    for (var _i = 0; _i < array_length(_names); _i++){
        var _cid = _names[_i];
        var _e = _t[$ _cid];
        var _cards = _e.cards;
        if (!is_array(_cards) || array_length(_cards) != 3){
            array_push(_bad, _cid + "：cards 必须正好 3 档");
            continue;
        }
        if (_cards[0].main.id != _e.prereq){
            array_push(_bad, _cid + "：初融主卡(" + string(_cards[0].main.id) + ") 和 prereq(" + string(_e.prereq) + ") 对不上");
        }
        if (_cards[1].main.id != _cid || _cards[2].main.id != _cid){
            array_push(_bad, _cid + "：深度/灵魂的主卡必须是融合卡自己");
        }
        for (var _k = 0; _k < 3; _k++){
            var _pair = [_cards[_k].main, _cards[_k].sub];
            for (var _j = 0; _j < 2; _j++){
                var _c = _pair[_j];
                if (_c.id == "") continue;
                if (_c.need < 0 || _c.need > 2) array_push(_bad, _cid + " 第" + string(_k + 1) + "档：need 只能是 0/1/2");
                if (get_plant_shape_data(_c.id, 0) == undefined) array_push(_bad, _cid + " 第" + string(_k + 1) + "档：" + _c.id + " 没注册");
            }
        }
    }
    return _bad;
}
