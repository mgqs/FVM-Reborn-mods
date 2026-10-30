/// 转职凭证（transfer credit）数据层
/// id 规则：transfer_<card_id>_<shape>，shape 1=一转 2=二转 3=三转 4=四转 5=终转
/// 数量走 global.save_data.inventory（add_material_amount / get_material_amount），
/// **不注册进 global.material_pool** —— 否则道具页会被上百个空格子塞满。
///
/// 档位换算：普卡 shape 1/2 = 一转/二转；金卡 shape 1/2/3 = 三转/四转/终转（档位 = shape + 2）
///   → 见 transfer_credit_tier / _shape / _tier_offset（判据只看卡注册的 is_gold）
///
/// 本文件包含：
///   ① 凭证 id / 名字 / 档位名：transfer_credit_id / _parse / _name / _tier_name
///   ② 底板 + 卡面绘制：transfer_credit_draw / _draw_id（底板目前只有一/二转 5 张）
///   ③ 购买判据：_buyable / _buyable_locked / 爬塔门槛 / 商店排序键（威望商店用）
///   ④ 背包「凭证」页的分段 / 换行 / 绘制：transfer_credit_tab_*
///   ⑤ 「威望」标签：ui_prestige_tag_*
/// 详细方案：桌面\fvm的ai\转职系统方案.md

/// @function transfer_credit_tier_offset(card_id)
/// @desc 金卡的形态编号从「三转」起：金卡 shape 1/2/3 = 三转/四转/终转 → 档位 = shape + 2
///       普卡 shape 1/2 = 一转/二转 → 档位 = shape（偏移 0）
///       判据只读卡注册数据的 is_gold，不依赖抽卡 / 诸神商店；结果缓存，避免每帧扫 deck
function transfer_credit_tier_offset(_card_id) {
    if (!variable_global_exists("_tc_gold_cache")) global._tc_gold_cache = {};
    if (variable_struct_exists(global._tc_gold_cache, _card_id)) return global._tc_gold_cache[$ _card_id];
    var _d = deck_get_card_data(_card_id, 0);
    // 卡池还没建好（启动早期）先不缓存，免得把「没查到」永久记成非金卡
    if (_d == noone) return 0;
    var _off = (ds_map_exists(_d, "is_gold") && _d[? "is_gold"] == 1) ? 2 : 0;
    global._tc_gold_cache[$ _card_id] = _off;
    return _off;
}

/// @function transfer_credit_tier(card_id, shape) 卡形态 → 凭证档位（1..5）；shape <= 0 → 0
function transfer_credit_tier(_card_id, _shape) {
    if (_shape <= 0) return 0;
    return _shape + transfer_credit_tier_offset(_card_id);
}

/// @function transfer_credit_shape(card_id, tier) 凭证档位 → 卡形态（反算，最小 1）
function transfer_credit_shape(_card_id, _tier) {
    if (_tier <= 0) return 0;
    return max(1, _tier - transfer_credit_tier_offset(_card_id));
}

/// @function transfer_credit_id(card_id, shape)
/// @desc 凭证道具 id = transfer_<卡id>_<档位>（档位不是卡形态：金卡 1/2/3 形态 = 三/四/终转）
function transfer_credit_id(_card_id, _shape) {
    var _tier = transfer_credit_tier(_card_id, _shape);
    if (_tier <= 0) return "";
    return "transfer_" + string(_card_id) + "_" + string(_tier);
}

/// @function transfer_credit_parse(id)
/// @desc 解析凭证 id → { card_id, tier, shape }；不是凭证返回 undefined
///       tier = id 里的档位（1 一转 ~ 5 终转）；shape = 该卡对应形态（金卡 3/4/5 → 1/2/3）
function transfer_credit_parse(_id) {
    if (!is_string(_id)) return undefined;
    if (string_pos("transfer_", _id) != 1) return undefined;

    var _rest = string_delete(_id, 1, 9);           // 去掉 "transfer_"
    var _pos = 0;
    // 从后往前找最后一个下划线（卡 id 里本身可能有下划线）
    for (var _i = string_length(_rest); _i >= 1; _i--) {
        if (string_char_at(_rest, _i) == "_") { _pos = _i; break; }
    }
    if (_pos <= 0) return undefined;

    var _cid = string_copy(_rest, 1, _pos - 1);
    var _sh_s = string_delete(_rest, 1, _pos);
    if (_cid == "" || _sh_s == "") return undefined;
    if (!is_real(real(_sh_s))) return undefined;

    var _tier = floor(real(_sh_s));
    if (_tier < 1) return undefined;
    // tier = id 里的档位；shape = 这张卡对应的形态（金卡 3/4/5 → 1/2/3）
    return { card_id: _cid, tier: _tier, shape: transfer_credit_shape(_cid, _tier) };
}

/// @function transfer_credit_is(id)
function transfer_credit_is(_id) {
    return !is_undefined(transfer_credit_parse(_id));
}

/// @function transfer_credit_tier_name(shape)
function transfer_credit_tier_name(_shape) {
    switch (_shape) {
        case 1: return "一转凭证";
        case 2: return "二转凭证";
        case 3: return "三转凭证";
        case 4: return "四转凭证";
        case 5: return "终转凭证";
    }
    return "转职凭证";
}

/// @function transfer_credit_card_name(card_id)
/// @desc 卡的**本体名（0 转名字）**，不带档位后缀。凭证名 / 商店名 / 抽卡提示用它；
///       转职成功提示也不用这个（提示已统一为「卡片转职成功！」）。
/// ⚠️ 卡名在 global.plant_registry 里（register_plant / register_plant_lite / mod_register_plant_lite
///    都写了 "name"），而 player_deck 的形态数据（register_card）**没有** name 字段，
///    只能当第二来源兜底 —— 顺序别反，否则名字会退回成卡 id。
function transfer_credit_card_name(_card_id) {
    // ① 植物注册表（卡名正源）
    var _meta = get_plant_shape_data(_card_id, 0);
    if (_meta != undefined) {
        var _v = _meta[? "name"];
        if (!is_undefined(_v) && is_string(_v) && _v != "") return _v;
    }

    // ② 卡池形态数据（没有 name 字段，留着兜底）
    var _d = deck_get_card_data(_card_id, 0);
    if (_d != noone && ds_exists(_d, ds_type_map) && ds_map_exists(_d, "name")) {
        var _v2 = _d[? "name"];
        if (!is_undefined(_v2) && is_string(_v2) && _v2 != "") return _v2;
    }

    return string(_card_id);
}

/// @function transfer_credit_shape_name(card_id, shape)
/// @desc 某张卡某一档的名字（0 = 本体名，1 = 一转名……）；查不到退回本体名。
/// ⚠️ 当前**没有调用点**（转职提示统一是「卡片转职成功！」）。留着给以后按档位显示名字的界面用。
function transfer_credit_shape_name(_card_id, _shape) {
    var _meta = get_plant_shape_data(_card_id, _shape);
    if (_meta != undefined) {
        var _v = _meta[? "name"];
        if (!is_undefined(_v) && is_string(_v) && _v != "") return _v;
    }
    return transfer_credit_card_name(_card_id);
}

/// @function transfer_credit_name(card_id, shape)
/// @desc 凭证名 = 本体名 + 档位（「泡椒春笋（一转凭证）」「盖亚神使（三转凭证）」）
///       shape 是**卡形态**，档位由 transfer_credit_tier() 换算（金卡 1/2/3 = 三/四/终转）
function transfer_credit_name(_card_id, _shape) {
    return transfer_credit_card_name(_card_id) + "（"
        + transfer_credit_tier_name(transfer_credit_tier(_card_id, _shape)) + "）";
}

/// @function transfer_credit_name_from_id(id)
function transfer_credit_name_from_id(_id) {
    var _p = transfer_credit_parse(_id);
    if (is_undefined(_p)) return "";
    return transfer_credit_name(_p.card_id, _p.shape);
}

/// @function transfer_credit_bg_sprite(tier, slot)
/// @desc tier = 凭证档位（1 一转 ~ 5 终转）；slot: 0/A = A 底板，1/B = B 底板，2/C = C 底板
///       一转只有 A/B 两张（中槽不显示），二转起 A/B/C 三张齐全
///       底板 = spr_transfer_bg_<档位><a|b|c>，三/四/终 是 06_凭证底板 那套原图导入的
function transfer_credit_bg_sprite(_tier, _slot) {
    switch (_tier) {
        case 1: return (_slot == 1) ? spr_transfer_bg_1b : spr_transfer_bg_1a;
        case 2:
            if (_slot == 1) return spr_transfer_bg_2b;
            if (_slot == 2) return spr_transfer_bg_2c;
            return spr_transfer_bg_2a;
        case 3:
            if (_slot == 1) return spr_transfer_bg_3b;
            if (_slot == 2) return spr_transfer_bg_3c;
            return spr_transfer_bg_3a;
        case 4:
            if (_slot == 1) return spr_transfer_bg_4b;
            if (_slot == 2) return spr_transfer_bg_4c;
            return spr_transfer_bg_4a;
        case 5:
            if (_slot == 1) return spr_transfer_bg_5b;
            if (_slot == 2) return spr_transfer_bg_5c;
            return spr_transfer_bg_5a;
    }
    return spr_transfer_bg_1a;
}

/// @function transfer_credit_face_sprite(card_id, shape)
/// @desc 该卡对应形态的 sprite；拿不到退回本体；再拿不到返回 -1
function transfer_credit_face_sprite(_card_id, _shape) {
    var _sh = _shape;
    while (_sh > 0) {
        var _d = deck_get_card_data(_card_id, _sh);
        if (_d != noone && ds_exists(_d, ds_type_map)) {
            if (ds_map_exists(_d, "sprite")) {
                var _spr = _d[? "sprite"];
                if (_spr != -1) return _spr;
            }
        }
        _sh -= 1;
    }
    var _d0 = deck_get_card_data(_card_id, 0);
    if (_d0 != noone && ds_exists(_d0, ds_type_map) && ds_map_exists(_d0, "sprite")) {
        var _spr0 = _d0[? "sprite"];
        if (_spr0 != -1) return _spr0;
    }

    // ③ 命名约定兜底：只有 plant_registry 名字、没走 register_card 的卡（多数 mod 卡）
    //    顺序：spr_<id>_<shape> → spr_<id>_<shape>_icon → spr_<id> → spr_<id>_icon
    //    （2026-10-25 补后两个 `_icon` 变体：有些卡只导了 icon、没有整卡图，否则槽里只剩底板）
    if (_shape > 0) {
        var _alt = asset_get_index("spr_" + string(_card_id) + "_" + string(_shape));
        if (_alt != -1) return _alt;
        var _alti = asset_get_index("spr_" + string(_card_id) + "_" + string(_shape) + "_icon");
        if (_alti != -1) return _alti;
    }
    var _alt0 = asset_get_index("spr_" + string(_card_id));
    if (_alt0 != -1) return _alt0;
    var _alt0i = asset_get_index("spr_" + string(_card_id) + "_icon");
    if (_alt0i != -1) return _alt0i;

    return -1;
}

/// @function transfer_credit_face_box()
/// @desc 金卡凭证里那张立绘的「可见区域」：[左, 上, 宽, 高]（图像坐标，与精灵原点无关）
///       键 = "<卡id>_<形态>"，只列金卡的 shape 1~3（普卡继续走固定 0.42，显示已认可）
///       ⚠️ 这批立绘画布大小差得离谱（欧若拉终转 555x557 画布 / 内容只有 90x116），
///          按画布缩会又小又偏，所以按内容包围盒缩到内窗 + 用内容中心对位
///       ⚠️ 换立绘 / 加金卡后要重新量（脚本：tmp_credit_price/gen_gold_face.py）
///       表里没有的卡（4 张缺图/全透明）自动回落到老的固定 0.42 画法
function transfer_credit_face_box() {
    if (variable_global_exists("_tc_face_box")) return global._tc_face_box;
    var _t = {
        "gaia_1": [3, 113, 77, 80],
        "gaia_2": [10, 102, 100, 92],
        "gaia_3": [9, 100, 92, 90],
        "aurora_1": [133, 90, 74, 102],
        "aurora_2": [126, 84, 81, 107],
        "aurora_3": [245, 202, 89, 116],
        "zhurong_1": [29, 11, 70, 91],
        "zhurong_2": [30, 11, 71, 95],
        "zhurong_3": [36, 12, 90, 97],
        "rig_1": [46, 67, 92, 69],
        "rig_2": [47, 63, 92, 74],
        "rig_3": [38, 35, 104, 103],
        "brahma_1": [204, 218, 76, 70],
        "brahma_2": [201, 210, 80, 80],
        "brahma_3": [120, 129, 95, 102],
        "clotho_1": [61, 85, 67, 89],
        "clotho_2": [119, 129, 61, 93],
        "clotho_3": [178, 154, 61, 99],
        "time_god_1": [89, 112, 77, 91],
        "time_god_2": [92, 113, 83, 98],
        "time_god_3": [104, 164, 136, 104],
        "fire_god_1": [0, 2, 71, 48],
        "fire_god_2": [0, 2, 76, 51],
        "fire_god_3": [0, 7, 80, 55],
        "firework_dragon_real_1": [47, 90, 78, 76],
        "firework_dragon_real_2": [34, 66, 79, 80],
        "thor_1": [23, 39, 100, 93],
        "thor_2": [25, 43, 108, 96],
        "thor_3": [19, 33, 119, 97],
        "war_god_1": [0, 14, 93, 94],
        "war_god_2": [0, 15, 92, 95],
        "war_god_3": [0, 14, 99, 94],
        "odin_1": [23, 30, 105, 68],
        "odin_2": [26, 38, 113, 71],
        "odin_3": [45, 51, 125, 72],
        "moon_god_1": [14, 6, 87, 90],
        "moon_god_2": [15, 2, 92, 92],
        "moon_god_3": [12, 21, 91, 92],
        "ymir_1": [31, 12, 90, 89],
        "ymir_2": [31, 11, 93, 88],
        "ymir_3": [31, 11, 84, 88],
        "hera_1": [0, 2, 105, 50],
        "hera_2": [0, 2, 115, 56],
        "hera_3": [26, 5, 105, 65],
        "sun_god_1": [2, 14, 86, 108],
        "sun_god_2": [6, 14, 88, 107],
        "sun_god_3": [1, 42, 92, 78],
        "poseidon_1": [118, 144, 82, 87],
        "poseidon_2": [119, 140, 91, 91],
        "poseidon_3": [166, 138, 88, 94],
        "ice_god_1": [4, 62, 93, 94],
        "ice_god_2": [6, 58, 97, 98],
        "ice_god_3": [13, 26, 112, 113],
        "ghost_god_1": [10, 4, 73, 82],
        "ghost_god_2": [17, 4, 86, 91],
        "ghost_god_3": [30, 38, 97, 99],
        "zeus_1": [63, 504, 75, 77],
        "zeus_2": [62, 501, 77, 80],
        "zeus_3": [21, 489, 97, 94],
        "love_god_1": [17, 0, 94, 86],
        "love_god_2": [18, 0, 92, 91],
        "love_god_3": [17, 0, 106, 91],
        "water_god_1": [3, 13, 90, 88],
        "water_god_2": [3, 17, 93, 99],
        "water_god_3": [3, 11, 92, 106],
        "power_god_1": [11, 3, 81, 95],
        "power_god_2": [11, 2, 85, 93],
        "power_god_3": [9, 6, 92, 94],
        "sheng_huo_1": [14, 34, 78, 89],
        "sheng_huo_2": [25, 74, 84, 85],
        "sheng_huo_3": [25, 77, 89, 92],
        "save_god_1": [50, 72, 71, 94],
        "save_god_2": [53, 81, 77, 85],
        "save_god_3": [70, 94, 98, 98],
        "joker_1": [11, 41, 77, 83],
        "joker_2": [13, 23, 103, 106],
        "joker_3": [26, 24, 120, 108],
        "xiangshui_god_1": [20, 10, 101, 91],
        "xiangshui_god_2": [20, 10, 101, 95],
        "xiangshui_god_3": [21, 11, 115, 101],
        "fengrao_god_1": [1, 3, 99, 92],
        "fengrao_god_2": [0, 3, 101, 96],
        "fengrao_god_3": [1, 3, 127, 100],
        "panduola_god_1": [75, 77, 66, 52],
        "panduola_god_2": [74, 72, 68, 56],
        "panduola_god_3": [167, 185, 73, 60],
        "houyi_god_1": [11, 5, 105, 114],
        "houyi_god_2": [10, 8, 117, 96],
        "houyi_god_3": [25, 17, 128, 105],
        "gongjiang_god_1": [15, 3, 85, 86],
        "gongjiang_god_2": [9, 1, 95, 94],
        "gongjiang_god_3": [7, 3, 113, 101],
        "hundun_god_1": [147, 148, 90, 73],
        "hundun_god_2": [141, 159, 112, 80],
        "hundun_god_3": [142, 154, 109, 97],
        "lingrong_god_1": [0, 0, 88, 87],
        "lingrong_god_2": [0, 0, 105, 93],
        "shennong_god_1": [20, 28, 73, 109],
        "shennong_god_2": [46, 39, 79, 116],
        "chongsheng_god_1": [4, 27, 97, 84],
        "chongsheng_god_2": [5, 22, 114, 94],
        "chongsheng_god_3": [6, 22, 111, 102],
        "hufa_god_1": [4, 33, 86, 89],
        "hufa_god_2": [1, 33, 95, 91],
        "hufa_god_3": [19, 47, 103, 101],
        "haiyang_god_1": [35, 3, 60, 63],
        "haiyang_god_2": [48, 17, 59, 64],
        "haiyang_god_3": [50, 17, 61, 70],
        "guangming_god_1": [20, 41, 93, 87],
        "guangming_god_2": [22, 36, 96, 96],
        "guangming_god_3": [25, 35, 110, 106],
        "heian_god_1": [116, 154, 81, 64],
        "heian_god_2": [96, 146, 97, 75],
        "heian_god_3": [12, 28, 96, 80]
    };
    global._tc_face_box = _t;
    return _t;
}

/// @function transfer_credit_draw(x, y, card_id, shape, size, slot, alpha)
/// @desc 画一张凭证：底板 + 卡面。x,y 是**左上角**（不是中心）
///       size = 凭证外框显示边长（像素）。44 = 原始大小；背包格子用 74/88；商店用 110
///       卡面按**固定缩放 + 精灵原点**画（跟卡列表同款），不用 sprite_get_bbox_*、不查表
/// ⚠️ 三个坑（2026-10-25 修）：
///    ① 底板 sprite 的 origin 是 (22,22)，draw_sprite_ext 以原点定位 → 必须补偿半个身位，
///       否则底板会往左上偏 22*缩放，和卡面对不上。
///    ② 卡面**不用 draw_sprite_part**：工程所有纹理组都开了 autocrop，
///       手册明确说自动裁剪后 part 的区域会取错。改成整幅图缩放平移（含透明留白，看不出来）。
///    ③ 卡面**不用 sprite_get_bbox_***：autocrop 下运行时给的值不可信（实机症状：卡面放大盖满 /
///       整体偏出槽外）。surface 实测也放弃了（GM 渲染目标是栈，set/reset 必须成对）。
///       最终就按卡列表的画法：固定缩放 + 原点，零数据、零运行时风险。
function transfer_credit_draw(_x, _y, _card_id, _shape, _size, _slot = 0, _alpha = 1) {
    if (_size <= 0) _size = 44;
    var _s = _size / 44;

    // 底板按「档位」选，卡面按「这个形态」取（金卡三转凭证 = 三转底板 + 圣神立绘）
    var _bg = transfer_credit_bg_sprite(transfer_credit_tier(_card_id, _shape), _slot);
    draw_sprite_ext(_bg, 0,
        _x + sprite_get_xoffset(_bg) * _s,
        _y + sprite_get_yoffset(_bg) * _s,
        _s, _s, 0, c_white, _alpha);

    var _spr = transfer_credit_face_sprite(_card_id, _shape);
    if (_spr == -1) return;

    var _cx = _x + 22 * _s;                      // 底板中心
    var _cy = _y + 22 * _s;

    // 卡面：**跟卡列表 / 融合页同一套画法** —— 固定缩放、按精灵原点落笔，不做任何包围盒归一
    //   （用户 2026-10-26 定：宁可顶到框上，也不为几十张异常图维护数据表）
    //   两个常数从 551 张卡面实测统计出来：内容中位数 75×77、内容中心在原点上方约 37px
    //   → k  = 卡面缩放（44 空间）：0.42 时中位内容约 31.5×32.3，基本填满 34 内窗
    //        0.46 起会盖到内框边；0.50 ≈ 正好撑满（再大就压框了）
    //     下移 = 让「内容中心」落在窗口中心，跟着 k 走：offset ≈ 37 × k（0.42 → 15.5，取 15）
    //   个别大画布 / 宽图的卡会偏小或压框，先这样，真碍眼再单独调
    // 金卡（三/四/终转）：按内容包围盒缩到内窗，用内容中心对位
    //   普卡仍走下面那套固定 0.42 —— 现在的显示已经认可，别动
    //   🔴 2026-10-27 晚：**不要用 sprite_get_bbox_* 做运行时归一**。工程纹理组开了 autocrop，
    //      运行时 bbox 拿到的是「裁切后纹理」的尺寸，量出来远大于画面 → 整排凭证缩成指甲盖、
    //      或直接飞出底板。表值 = 按「游戏真正画的那个精灵」静态 PNG 第 0 帧量的 alpha 包围盒。
    var _key = string(_card_id) + "_" + string(_shape);
    var _box = transfer_credit_face_box();
    if (transfer_credit_tier_offset(_card_id) == 2 && variable_struct_exists(_box, _key)) {
        var _b  = _box[$ _key];                                  // [左, 上, 宽, 高]
        var _bk = min(32 / _b[2], 32 / _b[3]) * _s;
        var _bx = (_b[0] + _b[2] * 0.5 - sprite_get_xoffset(_spr)) * _bk;
        var _by = (_b[1] + _b[3] * 0.5 - sprite_get_yoffset(_spr)) * _bk;
        draw_sprite_ext(_spr, 0, _cx - _bx, _cy - _by, _bk, _bk, 0, c_white, _alpha);
        return;
    }

    var _k = 0.42 * _s;
    draw_sprite_ext(_spr, 0, _cx, _cy + 15 * _s, _k, _k, 0, c_white, _alpha);
}

/// @function transfer_credit_draw_id(x, y, id, size, slot, alpha)
function transfer_credit_draw_id(_x, _y, _id, _size, _slot = 0, _alpha = 1) {
    var _p = transfer_credit_parse(_id);
    if (is_undefined(_p)) return;
    transfer_credit_draw(_x, _y, _p.card_id, _p.shape, _size, _slot, _alpha);
}

/// @func transfer_credit_draw_count(x, y, amount, outline) 凭证格子**右下角的数量数字**
///   口径照背包道具页那套：`font_number` 白字、右对齐 + 底对齐，落点 (x,y) 是数字的右下角
///   1 万以上缩成「Nw」；amount <= 0 不画（灰槽 / 没持有）
///   outline = true 时给白字加 1px 黑描边（合成屋的凭证槽底板是金色描边，纯白字看不清）
///   背包凭证页与合成屋-卡片转职的三个凭证槽共用这一处（2026-10-27 凭证不限量后要有这个）
function transfer_credit_draw_count(_x, _y, _amount, _outline = false) {
    if (_amount <= 0) return;
    draw_set_halign(fa_right);
    draw_set_valign(fa_bottom);
    draw_set_font(font_number);
    var _txt = (_amount < 10000) ? string(_amount) : (string(floor(_amount / 10000)) + "w");

    if (_outline) {
        draw_set_colour(c_black);
        for (var _oy = -1; _oy <= 1; _oy++) {
            for (var _ox = -1; _ox <= 1; _ox++) {
                if (_ox == 0 && _oy == 0) continue;
                draw_text(_x + _ox, _y + _oy, _txt);
            }
        }
    }
    draw_set_colour(c_white);
    draw_text(_x, _y, _txt);
}

// ─────────────────────────────────────────────────────────────
// 背包「凭证」页：分段 / 顺序 / 换行（2026-10-27 收进本脚本，不再单开表脚本）
//   两种凭证 id：transfer_<卡id>_<形态 1~5> / evo_credit_<金卡id>
//   改分段顺序只动 transfer_credit_tab_groups()，背包那边只调这几个函数
// ─────────────────────────────────────────────────────────────

/// @func transfer_credit_tab_groups() 背包凭证页的分段表（**数组顺序 = 显示顺序**）
///   kind = "transfer" → 按 shape 认；kind = "evo" → 认 evo_credit_ 前缀
///   title 目前只用于注释/调试；段与段之间**强制换行**（不空行）
function transfer_credit_tab_groups(){
    return [
        { key:"t1",  title:"一转凭证", kind:"transfer", tier:1 },   // 一
        { key:"t2",  title:"二转凭证", kind:"transfer", tier:2 },   // 二
        { key:"evo", title:"进化凭证", kind:"evo"             },   // 进化
        { key:"t3",  title:"三转凭证", kind:"transfer", tier:3 },   // 三（金卡）
        { key:"t4",  title:"四转凭证", kind:"transfer", tier:4 },   // 四（金卡）
        { key:"t5",  title:"终转凭证", kind:"transfer", tier:5 }    // 终（金卡）
    ];
}

/// @func transfer_credit_tab_collect() 收集背包里持有的凭证（数量 > 0），按分段表分桶后拼起来
/// @return { struct } items[] / starts[]
///   items  每项 { id, kind, shape, card_id, group, amount }
///   starts 每段的起止小标（items 的下标）→ 绘制端用它做强制换行
///   段内顺序 = inventory 数组顺序（= 第一次获得的先后），不另外排序
function transfer_credit_tab_collect(){
    var _groups = transfer_credit_tab_groups();
    var _gn = array_length(_groups);
    var _buckets = [];
    for (var _g = 0; _g < _gn; _g++) array_push(_buckets, []);

    var _inv = global.save_data.inventory;
    var _n = array_length(_inv);
    for (var _i = 0; _i < _n; _i++){
        var _id  = _inv[_i].id;
        var _amt = _inv[_i].amount;
        if (_amt <= 0) continue;

        if (transfer_credit_is(_id)){
            var _p = transfer_credit_parse(_id);
            for (var _g = 0; _g < _gn; _g++){
                var _gr = _groups[_g];
                if (_gr.kind != "transfer" || _gr.tier != _p.tier) continue;
                array_push(_buckets[_g], { id:_id, kind:"transfer", tier:_p.tier, shape:_p.shape,
                    card_id:_p.card_id, group:_g, amount:_amt });
                break;
            }
            continue;
        }

        if (string_pos("evo_credit_", _id) == 1){
            for (var _g = 0; _g < _gn; _g++){
                if (_groups[_g].kind != "evo") continue;
                array_push(_buckets[_g], { id:_id, kind:"evo", tier:0, shape:0,
                    card_id:string_delete(_id, 1, 11), group:_g, amount:_amt });
                break;
            }
        }
    }

    var _items = [], _starts = [];
    for (var _g = 0; _g < _gn; _g++){
        if (array_length(_buckets[_g]) == 0) continue;
        array_push(_starts, array_length(_items));
        for (var _k = 0; _k < array_length(_buckets[_g]); _k++) array_push(_items, _buckets[_g][_k]);
    }
    return { items:_items, starts:_starts };
}

/// @func transfer_credit_tab_slots(items, starts, cols) 每项落在第几格（0 起算的格位下标）
///   每段的第一个必然从「新的一行第一格」开始 —— 这就是「段间强制换行、但不空行」
function transfer_credit_tab_slots(_items, _starts, _cols){
    var _slots = [];
    var _next = 0;
    var _s = 0;
    for (var _i = 0; _i < array_length(_items); _i++){
        if (_s < array_length(_starts) && _i == _starts[_s]){
            _next = ceil(_next / _cols) * _cols;
            _s++;
        }
        array_push(_slots, _next);
        _next++;
    }
    return _slots;
}

/// @func transfer_credit_tab_rows(items, starts, cols) 这套凭证要占几行（至少 1 行）
function transfer_credit_tab_rows(_items, _starts, _cols){
    var _slots = transfer_credit_tab_slots(_items, _starts, _cols);
    if (array_length(_slots) == 0) return 1;
    return max(1, ceil((_slots[array_length(_slots) - 1] + 1) / _cols));
}

/// @func transfer_credit_tab_name(item) 凭证名（背包格子悬停、商店等处共用）
function transfer_credit_tab_name(_it){
    if (_it.kind == "evo") return transfer_credit_card_name(_it.card_id) + "（进化凭证）";
    return transfer_credit_name(_it.card_id, _it.shape);
}

/// @func transfer_credit_tab_tip(item) 悬停说明：名字 / **持有数量** / 用途（转职凭证再写回收价）
///   2026-10-28 用户要求把持有数量加回来（凭证不限量后，格子里的小数字看不清时以 tip 为准）
function transfer_credit_tab_tip(_it){
    var _head = transfer_credit_tab_name(_it) + "\n持有：" + string(_it.amount);
    if (_it.kind == "evo"){
        // 进化路线写进提示（与诸神商店共用 mod_evo_route_text，2026-10-28）
        return _head + "\n进化路线：" + mod_evo_route_text(_it.card_id)
            + "\n进化凭证：在合成屋-金卡进化中使用";
    }
    return _head + "\n转职凭证：在合成屋-卡片转职中使用"
        + "\n左键点击回收（" + string(transfer_credit_recycle_price()) + "威望/个）";
}

/// @func transfer_credit_tab_draw(item, x, y, size) 画一个凭证格子
///   @param x,y  格子**左上角**；size 格子边长
function transfer_credit_tab_draw(_it, _x, _y, _size){
    if (_it.kind == "evo"){
        // 进化凭证没有单独图标：底板 + 该金卡的 0 形态立绘（跟进化页第 3 槽同一套画法）
        mod_evo_draw_credit(_it.card_id, _x + _size * 0.5, _y + _size * 0.5, true,
            _size * 0.92, _size * 0.68);
    } else {
        transfer_credit_draw_id(_x, _y, _it.id, _size);
    }
}


// ─────────────────────────────────────────────────────────────
// 购买 / 获取资格判据（2026-10-25 待办 #29）
// ⚠️ 商店置灰、确认弹窗兜底、以后转职界面都调这几个，别各自写 if
// ─────────────────────────────────────────────────────────────

/// @function transfer_credit_card_max_shape(card_id)
/// @desc 玩家把这张卡**练到过**的最高形态（读存档 max_shape）；没拥有返回 -1
function transfer_credit_card_max_shape(_card_id) {
    var _uc = global.save_data.unlocked_cards;
    var _n = array_length(_uc);
    for (var _i = 0; _i < _n; _i++) {
        if (_uc[_i].id == _card_id) {
            if (variable_struct_exists(_uc[_i], "max_shape")) return _uc[_i].max_shape;
            return 0;
        }
    }
    return -1;
}

/// @function transfer_credit_card_level(card_id)
/// @desc 这张卡的**星级**（练到过的最高星级 = 存档 unlocked_cards 的 max_level）；没拥有返回 -1
///       ⚠️ 用 max_level 不是 level：界面上的星星画的就是 max_level（合成屋/背包/转职槽都读它），
///          两张表口径必须一致，否则会出现「看着 6 星却提示星级不足」
///       转职的星级门槛（一转 7 星 / 二转 10 星，见 mod_craft_transfer_table 的 mod_tg_star_need）
///       就是拿它比 —— 别在别处另扫一遍 unlocked_cards
function transfer_credit_card_level(_card_id) {
    var _uc = global.save_data.unlocked_cards;
    var _n = array_length(_uc);
    for (var _i = 0; _i < _n; _i++) {
        if (_uc[_i].id != _card_id) continue;
        if (variable_struct_exists(_uc[_i], "max_level")) return _uc[_i].max_level;
        if (variable_struct_exists(_uc[_i], "level")) return _uc[_i].level;
        return 0;
    }
    return -1;
}

/// @function transfer_credit_card_shapes_max(card_id)
/// @desc 这张卡**注册了**的最高形态序号（0 起算），查不到返回 -1。
///       ⚠️ 不能只用 card_max_available_shape()：它只读 plant_registry（get_plant_shape_data），
///          而 `yanyantu` / `12yinliao` / `blueberry_tower` / `baiyang` / `athena` / `shuangzi` / `war_god`
///          这类卡在植物注册表里只有 shape 0，转职界面就会误报「这张卡已经转满了」（2026-10-25 待办 #30 C）。
///       正源 = 卡池形态表 global.player_deck[卡id][? "shapes"]（register_card 写的那份），
///       与 plant_registry 取较大值兜住上游 native 注册风格。
function transfer_credit_card_shapes_max(_card_id) {
    var _max = card_max_available_shape(_card_id);

    if (is_undefined(global.player_deck) || !ds_exists(global.player_deck, ds_type_list)) return _max;
    var _n = ds_list_size(global.player_deck);
    for (var _i = 0; _i + 1 < _n; _i += 2) {
        if (global.player_deck[| _i] != _card_id) continue;
        var _card = global.player_deck[| _i + 1];
        var _shapes = _card[? "shapes"];
        if (is_undefined(_shapes) || !ds_exists(_shapes, ds_type_list)) break;
        var _sn = ds_list_size(_shapes);
        for (var _j = 0; _j < _sn; _j++) {
            var _sd = _shapes[| _j];
            var _v = _sd[? "shape"];
            if (!is_undefined(_v) && is_real(_v)) _max = max(_max, _v);
        }
        break;
    }
    return _max;
}

/// @function transfer_credit_has(card_id, shape)
/// @desc 背包里**还有**这一档凭证（买了没用也算持有）
function transfer_credit_has(_card_id, _shape) {
    return (get_material_amount(transfer_credit_id(_card_id, _shape)) > 0);
}

/// @function transfer_credit_progress(card_id)
/// @desc 这张卡的进度 = max(练到的形态, 背包里持有的最高档凭证)，最低 0。
///       「拿了凭证没转职也算进度」是它的本意（防止重复买同一档）。
/// ⚠️ 当前**没有调用点**：商店的跳档限制已按用户要求去掉。留着给以后的门槛 / 冷却用。
function transfer_credit_progress(_card_id) {
    var _p = max(0, transfer_credit_card_max_shape(_card_id));
    var _max = transfer_credit_card_shapes_max(_card_id);
    for (var _s = 1; _s <= _max; _s++) {
        if (transfer_credit_has(_card_id, _s)) _p = max(_p, _s);
    }
    return _p;
}

/// @function transfer_credit_tower_done_key()
/// @desc 已通关的**最高魔塔关**，编码成整数 = 层 × 100 + 小关（1-1 → 101，12-2 → 1202），0 = 一层没打。
///       魔塔关卡 id 形如 `tower_cake_<层>_<小关>`，普通与精英都算，取最大的一关。
///       用整数是为了直接比大小（"12-2" 比 "9-2" 大），显示时用 transfer_credit_tower_key_text()。
function transfer_credit_tower_done_key() {
    var _best = 0;
    var _lists = [];
    if (variable_struct_exists(global.save_data, "completed_levels")) array_push(_lists, global.save_data.completed_levels);
    if (variable_struct_exists(global.save_data, "completed_elite_levels")) array_push(_lists, global.save_data.completed_elite_levels);

    var _prefix = "tower_cake_";
    var _plen = string_length(_prefix);
    for (var _li = 0; _li < array_length(_lists); _li++) {
        var _arr = _lists[_li];
        if (!is_array(_arr)) continue;
        for (var _i = 0; _i < array_length(_arr); _i++) {
            var _id = _arr[_i];
            if (!is_string(_id)) continue;
            if (string_copy(_id, 1, _plen) != _prefix) continue;

            // 前缀后两段数字：层、小关（tower_cake_12_3 → 12 / 3）
            var _rest = string_delete(_id, 1, _plen);
            var _dash = string_pos("_", _rest);
            if (_dash <= 0) continue;
            var _f_s = string_copy(_rest, 1, _dash - 1);
            var _s_s = string_delete(_rest, 1, _dash);
            if (!is_real(real(_f_s)) || !is_real(real(_s_s))) continue;
            var _key = floor(real(_f_s)) * 100 + floor(real(_s_s));
            if (_key > _best) _best = _key;
        }
    }
    return _best;
}

/// @function transfer_credit_tower_key_text(key)
/// @desc 把「层×100+小关」还原成 `12-2` 这种文本（给提示词用）
function transfer_credit_tower_key_text(_key) {
    if (_key <= 0) return "";
    return string(_key div 100) + "-" + string(_key mod 100);
}

/// @function transfer_credit_tower_key_from(value)
/// @desc 商品字段 `tower_floor` 的两种写法统一成 key：
///       `12`      → 12-1（第 12 层第一小关）
///       `"12-2"`  → 12-2
///       0 / "" / 非法 → 0（不限制）
function transfer_credit_tower_key_from(_v) {
    if (is_string(_v)) {
        var _v2 = string_replace_all(_v, " ", "");      // 容忍 "12 - 2" 这种写法
        if (_v2 == "") return 0;
        var _dash = string_pos("-", _v2);
        if (_dash > 0) {
            var _f_s = string_copy(_v2, 1, _dash - 1);
            var _s_s = string_delete(_v2, 1, _dash);
            if (!is_real(real(_f_s)) || !is_real(real(_s_s))) return 0;
            if (real(_f_s) <= 0) return 0;              // "0-1" / "0" 都当不限制
            return floor(real(_f_s)) * 100 + floor(real(_s_s));
        }
        if (real(_v2) <= 0) return 0;                    // "0" = 不限制
        return floor(real(_v2)) * 100 + 1;
    }
    // ⚠️ 0 必须原样返回 0 —— 之前漏了这层判断，0 被算成 key=1（= 0-1），
    //    结果写了 tower_floor: 0 的商品也一直提示「魔塔通关层数不足」（2026-10-26 用户实测抓到的 bug）
    if (is_real(_v)) {
        if (_v <= 0) return 0;
        return floor(_v) * 100 + 1;
    }
    return 0;
}

/// @function credit_shop_tower_defaults() 威望商店的**默认爬塔门槛表**（🔴 要调门槛就改这里，只此一处）
///   键 = 商品的 `credit_shape`：0 = 兑换项（威望）/ 1 = 一转凭证 / 2 = 二转凭证
///   值 = 魔塔门槛：数字 = 该层第一小关（1 = 1-1），也可写 "13-2"，0 / "" = 不限制
///   单条商品想覆盖 → 在 `credit_shop_init` 的那条商品里写 `tower_floor`（写 0 = 该商品显式不限）
///   ⚠️ 2026-10-27 按用户「魔塔价格奖励建议表.xlsx」表头改：一转默认 1-1 / 二转默认 **15-1**；
///      兑换项跟着「魔塔最大层」走，表里已经有 35-3（巅峰）→ 改 35-3
function credit_shop_tower_defaults() {
    return {
        "0": "35-3",     // 兑换项（威望）：固定「通魔塔最大层」才可买
        "1": "1-1",      // 一转凭证：通关 1-1
        "2": "15-1"      // 二转凭证：通关 15-1
    };
}

/// @function credit_shop_tower_default(credit_shape) 某个 credit_shape 的默认门槛 key（0 = 不限）
function credit_shop_tower_default(_credit_shape) {
    var _t = credit_shop_tower_defaults();
    var _k = string(floor(_credit_shape));
    if (!variable_struct_exists(_t, _k)) return 0;
    return transfer_credit_tower_key_from(_t[$ _k]);
}

/// @function credit_shop_floor_key(goods) 一条商店商品要求的爬塔门槛 key（0 = 不限）
///   ① 商品自己写了 `tower_floor` → 以它为准（0 / "" = 显式不限制）
///   ② 没写 → 取默认表 `credit_shop_tower_defaults()` 里对应 credit_shape 的值
function credit_shop_floor_key(_g) {
    if (!is_struct(_g)) return 0;
    if (variable_struct_exists(_g, "tower_floor")) return transfer_credit_tower_key_from(_g.tower_floor);
    var _cs = variable_struct_exists(_g, "credit_shape") ? _g.credit_shape : 0;
    return credit_shop_tower_default(_cs);
}

/// @function credit_shop_floor_reason(goods) 按门槛判能不能买 → "" = 可买 / 否则返回原因文案
///   凭证与兑换项共用；余额不足另判（不在这里）
function credit_shop_floor_reason(_g) {
    var _need = credit_shop_floor_key(_g);
    if (_need > 0 && transfer_credit_tower_done_key() < _need) return "魔塔通关层数不足";
    return "";
}

/// @function transfer_credit_tower_floor_req(card_id, shape)
/// @desc 该档凭证在**商店注册表**里的爬塔门槛，返回 key（层×100+小关）；0 = 不限制。
///       懒扫 `global.goods_map` 里 `type == "credit"` 且有 `credit_shape > 0` 的商品，
///       门槛值走 `credit_shop_floor_key()`（商品写了 tower_floor 就以商品为准，否则用默认表），
///       缓存到 `global._tc_tower_req`。
function transfer_credit_tower_floor_req(_card_id, _shape) {
    if (!variable_global_exists("_tc_tower_req")) {
        var _map = {};
        if (variable_global_exists("goods_map") && ds_exists(global.goods_map, ds_type_map)) {
            var _key = ds_map_find_first(global.goods_map);
            while (!is_undefined(_key)) {
                var _g = global.goods_map[? _key];
                if (variable_struct_exists(_g, "type") && _g.type == "credit"
                    && variable_struct_exists(_g, "credit_shape") && _g.credit_shape > 0) {
                    var _tk = credit_shop_floor_key(_g);
                    if (_tk > 0) {
                        var _p = transfer_credit_parse(_g.unlock_item_id);
                        if (!is_undefined(_p)) {
                            _map[$ string(_p.card_id) + "_" + string(_p.shape)] = _tk;
                        }
                    }
                }
                _key = ds_map_find_next(global.goods_map, _key);
            }
        }
        global._tc_tower_req = _map;
    }

    var _k = string(_card_id) + "_" + string(_shape);
    var _t = global._tc_tower_req;
    if (variable_struct_exists(_t, _k)) return _t[$ _k];
    return 0;
}

/// @function transfer_credit_buyable_locked(card_id, shape)
/// @desc 是不是「**永久锁**」（置灰 + 售完罩 + 点不动）——只有这两条：
///       ① 形态不存在 ② 已经转职到该形态（或更高）。
///       🔴 2026-10-27 用户改口径：**凭证不限量**，背包里已经有一张同款凭证**照样能买**
///          （原来「已持有该档凭证 → 置灰」那条已删；重复买来堆着没意义是玩家的选择）
///       爬塔门槛、余额不足属于「临时不满足」：**不置灰、不盖售完**，点购买时才弹提示拦住
///       （用户 2026-10-26 定：这些点一下会变，不该看起来像“卖完了”）
function transfer_credit_buyable_locked(_card_id, _shape) {
    if (_shape > transfer_credit_card_shapes_max(_card_id)) return true;
    if (transfer_credit_card_max_shape(_card_id) >= _shape) return true;
    return false;
}

/// @function transfer_credit_buyable(card_id, shape)
/// @desc 商店能不能买这一档 → 返回 "" = 可买；否则返回**不可买原因**（直接拿去 show_notice）
///       2026-10-26 用户改口径：
///         ① 形态不存在 → 「该形态不存在」
///         ② 已转职到该形态 → 「不满足购买条件」（不告诉玩家是哪种）
///         ③ **「只能买下一档」已去掉** —— 任何档位都能直接买，不要求先有前一档
///         ④ 爬塔门槛 → 「魔塔通关层数不足」
///       2026-10-27 再改：**不限量** —— 「已持有该档凭证」不再拦（见 buyable_locked 注释）
function transfer_credit_buyable(_card_id, _shape) {
    // 形态是否存在：走 transfer_credit_card_shapes_max()，别用 get_plant_shape_data ——
    // 只注册 shape 0 的那批卡会被判「该形态不存在」，一转/二转凭证全部买不了（2026-10-25 待办 #30 C）
    if (_shape > transfer_credit_card_shapes_max(_card_id)) return "该形态不存在";

    if (transfer_credit_card_max_shape(_card_id) >= _shape) return "不满足购买条件";

    // 爬塔门槛（商品级 tower_floor；不写 / 0 = 不限制）
    var _need_key = transfer_credit_tower_floor_req(_card_id, _shape);
    if (_need_key > 0 && transfer_credit_tower_done_key() < _need_key) return "魔塔通关层数不足";

    return "";
}

// ─────────────────────────────────────────────────────────────
// 凭证回收（2026-10-27）：背包-凭证页点格子当场回收，**统一 500 威望/个**
//   钱和货都由 transfer_credit_recycle() 一处改，别在界面里直接 add_material_amount
// ─────────────────────────────────────────────────────────────

/// @func transfer_credit_recycle_price() 回收单价（威望/个）—— 要调价只改这里
function transfer_credit_recycle_price(){
    return 500;
}

/// @func transfer_credit_recycle(id, amount) 回收 amount 张凭证
/// @return {struct} ok / amount（实际回收数）/ gain（实际到账威望）/ reason
///   只认转职凭证（transfer_<卡>_<档位>）；进化凭证 / 别的道具一律拒绝
function transfer_credit_recycle(_id, _amount){
    var _r = { ok:false, amount:0, gain:0, reason:"" };
    if (!transfer_credit_is(_id)){ _r.reason = "这件道具不能回收"; return _r; }

    var _have = get_material_amount(_id);
    if (_have <= 0){ _r.reason = "没有可回收的凭证"; return _r; }

    var _n = clamp(floor(_amount), 1, _have);
    var _gain = _n * transfer_credit_recycle_price();
    add_material_amount(_id, -_n);
    add_material_amount("prestige", _gain);

    _r.ok = true;
    _r.amount = _n;
    _r.gain = _gain;
    return _r;
}

/// @func transfer_credit_price_scan_map(map, out, phase)
/// @desc 扫一张商品表，把「凭证 id → 价格 + 货币」写进 out（先到先得，已有键不覆盖）
///       ⚠️ 两张表都要扫：普通/跨服商品在 global.goods_map，**诸神商品在独立的 global.gods_goods_map**
///          （2026-10-28 修：只扫 goods_map 时金卡三/四/终转永远查不到价 → 补凭证提示「不在商店出售」）
///       phase 0 = 凭证类商品（威望 / 诸神）；phase 1 = 跨服商店的「一转/二转卡」
///          （跨服那批 type 是 "card"，买下去发的其实是转职凭证，见 cross_shop_buy_do）
///          分两轮扫是为了让威望/神石优先，跨服只在没有其它渠道时兜底
function transfer_credit_price_scan_map(_map, _out, _phase = 0){
    if (!ds_exists(_map, ds_type_map)) return;
    var _key = ds_map_find_first(_map);
    while (!is_undefined(_key)) {
        var _g = _map[? _key];
        if (is_struct(_g) && variable_struct_exists(_g, "unlock_item_id") && variable_struct_exists(_g, "cost")) {
            var _vid  = "";
            var _cur  = "";
            var _cur_name = "";
            var _shop = "";
            var _type = variable_struct_exists(_g, "type") ? _g.type : "";

            if (_phase == 0) {
                if (_type == "credit" && variable_struct_exists(_g, "credit_shape") && _g.credit_shape > 0) {
                    _vid  = _g.unlock_item_id;                       // 已是凭证 id
                    var _coin = variable_struct_exists(_g, "coin_type") ? _g.coin_type : "prestige";
                    _cur  = (_coin == "gold") ? "gold" : "prestige";
                    _cur_name = (_coin == "gold") ? "金币" : "威望";
                    _shop = "credit";
                }
                else if (_type == "tvoucher" && variable_struct_exists(_g, "target_shape")) {
                    _vid  = transfer_credit_id(_g.unlock_item_id, _g.target_shape);
                    _cur  = "oracle_stone";
                    _cur_name = "神石";
                    _shop = "gods";
                }
                else if (variable_struct_exists(_g, "cross_server_shop")
                    && (_type == "credit" || _type == "tvoucher")) {
                    // 跨服商店的凭证（当前只卖卡，接口先留着：以后上架凭证不用改这里）
                    _vid  = (_type == "tvoucher")
                          ? transfer_credit_id(_g.unlock_item_id, _g.target_shape)
                          : _g.unlock_item_id;
                    var _cs = _g.cross_server_shop;
                    _cur  = (_cs == "gold") ? "cross_server_gold_medal" : "cross_server_silver_medal";
                    _cur_name = (_cs == "gold") ? "跨服金勋章" : "跨服银勋章";
                    _shop = "cross";
                }
            }
            else {
                // 跨服商店的「一转 / 二转卡」：买下去发的是凭证（cross_shop_buy_do 里 add_material_amount 那张）
                if (_type == "card" && variable_struct_exists(_g, "cross_server_shop")
                    && variable_struct_exists(_g, "card_id") && variable_struct_exists(_g, "card_shape")
                    && _g.card_shape > 0) {
                    _vid  = transfer_credit_id(_g.card_id, _g.card_shape);
                    var _cs2 = _g.cross_server_shop;
                    _cur  = (_cs2 == "gold") ? "cross_server_gold_medal" : "cross_server_silver_medal";
                    _cur_name = (_cs2 == "gold") ? "金色勋章" : "白银勋章";
                    _shop = "cross";
                }
            }

            if (_vid != "" && !variable_struct_exists(_out, _vid)) {
                _out[$ _vid] = {
                    price: is_string(_g.cost) ? real(_g.cost) : _g.cost,
                    currency: _cur, name: _cur_name, shop: _shop
                };
            }
        }
        _key = ds_map_find_next(_map, _key);
    }
}

/// @func transfer_credit_price_info(card_id, shape)
/// @desc 这一档凭证**在任意一家商店**的售价与货币（转职时缺凭证要当场补，2026-10-28 用户要求）
///       两张商品表都扫：`global.goods_map`（威望商店 / 跨服）+ `global.gods_goods_map`（诸神）
/// @return { struct } price / currency（material id；金币为 "gold"）/ name（中文）/ shop；查不到 price = -1
function transfer_credit_price_info(_card_id, _shape){
    if (!variable_global_exists("_tc_price_info")) {
        var _m = {};
        // 第一轮：威望 / 诸神凭证（优先），第二轮：跨服商店的一转二转卡（兜底）
        if (variable_global_exists("goods_map"))       transfer_credit_price_scan_map(global.goods_map, _m, 0);
        if (variable_global_exists("gods_goods_map"))  transfer_credit_price_scan_map(global.gods_goods_map, _m, 0);
        if (variable_global_exists("goods_map"))       transfer_credit_price_scan_map(global.goods_map, _m, 1);
        global._tc_price_info = _m;
    }

    var _id = transfer_credit_id(_card_id, _shape);
    if (!variable_struct_exists(global._tc_price_info, _id)) {
        return { price: -1, currency: "", name: "", shop: "" };
    }
    return global._tc_price_info[$ _id];
}

// ─────────────────────────────────────────────────────────────
// 凭证交易（2026-10-27）：商店列表口径 / 搜索 / 买卖窗 / 数量窗的「数据与规则」全在这里
//   对象那边只留：画框、数字输入框、按钮命中判定（这些不好拆）
//   要改文案 / 单价 / 货币 / 上限口径 → 改这一节，别去对象里改
// ─────────────────────────────────────────────────────────────

/// @func credit_shop_goods_name(goods) 凭证页商品的显示名（商店列表、搜索、购买窗共用一处）
///   凭证 = 按卡名表实时生成（transfer_credit_name_from_id）
///   兑换项（credit_shape = 0）= 注册时写的 display_name，缺字段兜「威望」
///   🔴 兑换项必须有名字：它是唯一一条 credit_shape == 0 的商品，缺键会让整页建按钮时崩
function credit_shop_goods_name(_g){
    if (!is_struct(_g)) return "";
    if (variable_struct_exists(_g, "credit_shape") && _g.credit_shape > 0){
        return transfer_credit_name_from_id(_g.unlock_item_id);
    }
    if (variable_struct_exists(_g, "display_name")) return _g.display_name;
    return "威望";
}

/// @func credit_shop_filter_search(list, query) 凭证页搜索：就地过滤商品 id 列表
///   口径 = 商品显示名子串匹配、不区分大小写（中英文都能搜，中文靠调用方的 IME）
///   在 shop_list_recharge 里「过滤 → 排序 → 分页」的顺序不要换，页码才会跟着搜索结果走
function credit_shop_filter_search(_list, _query){
    if (!is_string(_query) || _query == "") return;
    var _q = string_lower(_query);
    var _keep = ds_list_create();
    for (var _i = 0; _i < ds_list_size(_list); _i++){
        var _gid = ds_list_find_value(_list, _i);
        if (string_pos(_q, string_lower(credit_shop_goods_name(global.goods_map[? _gid]))) > 0){
            ds_list_add(_keep, _gid);
        }
    }
    ds_list_clear(_list);
    for (var _j = 0; _j < ds_list_size(_keep); _j++) ds_list_add(_list, ds_list_find_value(_keep, _j));
    ds_list_destroy(_keep);
}

/// @func credit_shop_search_box_spawn(bg_x, bg_y, depth) 创建凭证页搜索框（obj_shop_bg 调一句）
///   用工程通用的 SearchBox（自带 IME，能打中文）；位置 = 顶部蓝带右半段（左半段是三个分类页签）
///   只在「转职凭证」页签显示 + 生效：visible 由 shop_list_recharge 管，should_correspond 在这里判
///   ⚠️ 这个函数专门服务 obj_shop_bg（回调里直接写它的变量名），别给别的界面复用
function credit_shop_search_box_spawn(_bg_x, _bg_y, _depth){
    var _sb = instance_create_depth(_bg_x + 615, _bg_y - 307, _depth, SearchBox);
    _sb.set_position(_bg_x + 440, _bg_y - 327)
        .set_size(350, 40)
        .set_placeholder("搜索凭证名")
        .set_theme({
            bg:           make_colour_rgb(3, 43, 80),
            bg_focus:     make_colour_rgb(8, 62, 112),
            border:       make_colour_rgb(120, 190, 240),
            border_focus: make_colour_rgb(200, 240, 255),
            text:         c_white,
            placeholder:  make_colour_rgb(150, 195, 230)
        })
        .set_on_change(method({ bg: id }, function(_t) {
            with (bg) {
                shop_search_text = _t;
                current_page = 1;
                shop_list_recharge();
            }
        }))
        .set_should_correspond(method({ bg: id }, function() {
            return (bg.shop_button_select == 6 && !bg.is_submenu_opened);
        }));
    return _sb;
}

/// @func credit_trade_balance(pay_kind) 该货币的余额（"gold" / "prestige" / "oracle"）
function credit_trade_balance(_pay_kind){
    if (_pay_kind == "prestige") return get_material_amount("prestige");
    if (_pay_kind == "oracle")   return get_material_amount("oracle_stone");
    return global.save_data.player.gold;
}

/// @func credit_trade_ui_words(mode, is_credit) 交易窗上的字：{ title, qty }
///   mode = "buy" 买 / "sell" 卖；is_credit = 是不是在交易凭证（决定「回收」还是「出售材料」）
function credit_trade_ui_words(_mode, _is_credit){
    if (_mode == "buy") return { title: "购买凭证", qty: "购买数量" };
    if (_is_credit)     return { title: "回收凭证", qty: "回收数量" };
    return { title: "出售材料", qty: "出售数量" };
}

/// @func credit_trade_open_buy(credit_id, price, pay_kind, suffix, depth) 开「购买凭证」数量窗
///   @return 窗实例（商店那边要拿它做 is_submenu_opened 之类的收尾，可以不接）
///   名字 / 持有 / 单价 / 货币 / 单位全在这里填好，调用方只给 id + 价 + 货币
function credit_trade_open_buy(_credit_id, _price, _pay_kind, _suffix, _depth){
    var _inst = instance_create_depth(room_width * 0.5, room_height * 0.5, _depth, obj_material_sell_confirm);
    _inst.mode            = "buy";
    _inst.trade_credit_id = _credit_id;
    _inst.sell_material_name = transfer_credit_name_from_id(_credit_id);
    _inst.held_amount     = get_material_amount(_credit_id);
    _inst.unit_price      = _price;
    _inst.pay_kind        = _pay_kind;
    _inst.unit_suffix     = _suffix;
    return _inst;
}

/// @func credit_trade_open_recycle(credit_id, amount, depth) 开「回收凭证」数量窗（单价 = 统一回收价）
function credit_trade_open_recycle(_credit_id, _amount, _depth){
    var _inst = instance_create_depth(room_width * 0.5, room_height * 0.5, _depth, obj_material_sell_confirm);
    _inst.mode            = "sell";
    _inst.trade_credit_id = _credit_id;
    _inst.sell_material_name = transfer_credit_name_from_id(_credit_id);
    _inst.max_amount      = _amount;
    _inst.unit_price      = transfer_credit_recycle_price();
    _inst.pay_kind        = "prestige";
    _inst.unit_suffix     = "威望";
    return _inst;
}

/// @func credit_trade_buy(credit_id, price, pay_kind, amount) 真买：扣货币 → 凭证入库 → 存档
///   上限 / 余额判定在调用方（数量窗按余额算 max_amount）；这里只落账
function credit_trade_buy(_credit_id, _price, _pay_kind, _amount){
    if (_credit_id == "" || _amount <= 0) return false;
    var _total = _price * _amount;
    if (_pay_kind == "prestige")      add_material_amount("prestige", -_total);
    else if (_pay_kind == "oracle")   add_material_amount("oracle_stone", -_total);
    else                              global.save_data.player.gold -= _total;
    add_material_amount(_credit_id, _amount);
    save_file(global.save_slot);
    return true;
}

// ─────────────────────────────────────────────────────────────
// 凭证价格行右边的小箭头（2026-10-27）：点它开「自定义购买数量」窗
//   素材 spr_shop_price_arrow（原版商品格里那个黄箭头，18×13，蓝底已抠成透明）
//   位置 / 大小 / 热区 / 价格文案全在这一节：Draw 与点击判定共用，别在对象里各写一份
// ─────────────────────────────────────────────────────────────

/// @func credit_price_text_scale() 价格字号（与 obj_shop_buy_btn/Draw_0 的价格行一致）
function credit_price_text_scale(){ return 1.15; }

/// @func credit_price_arrow_scale() 箭头显示倍数（18×13 → 25×18）
function credit_price_arrow_scale(){ return 1.4; }

/// @func credit_price_label(cost, coin_type) 价格行的字：「N威望」/「NG」（Draw 与点击判定共用）
function credit_price_label(_cost, _coin_type){
    return string(_cost) + ((_coin_type == "prestige") ? "威望" : "G");
}

/// @func credit_price_arrow_at(cx, cy, label) 箭头中心点 = 价格字右端再留 8px
///   内部临时把字体设成 font_yuan 量宽（Draw 里调用前本来就是它，无副作用）
function credit_price_arrow_at(_cx, _cy, _label){
    draw_set_font(font_yuan);
    var _pw = string_width(_label) * credit_price_text_scale();
    var _aw = sprite_get_width(spr_shop_price_arrow) * credit_price_arrow_scale();
    return { x: _cx + _pw * 0.5 + 8 + _aw * 0.5, y: _cy };
}

/// @func credit_price_arrow_draw_at(x, y) 画箭头（x,y = 中心）
function credit_price_arrow_draw_at(_x, _y){
    var _s = credit_price_arrow_scale();
    draw_sprite_ext(spr_shop_price_arrow, 0, _x, _y, _s, _s, 0, c_white, 1);
}

/// @func credit_price_arrow_draw(cx, cy, label) 按价格字自动定位并画箭头（Draw 里用这个，不建临时结构体）
function credit_price_arrow_draw(_cx, _cy, _label){
    draw_set_font(font_yuan);
    var _pw = string_width(_label) * credit_price_text_scale();
    var _aw = sprite_get_width(spr_shop_price_arrow) * credit_price_arrow_scale();
    credit_price_arrow_draw_at(_cx + _pw * 0.5 + 8 + _aw * 0.5, _cy);
}

/// @func credit_price_arrow_hit_at(mx, my, x, y) 点没点中箭头（热区比视觉大一圈，好点）
function credit_price_arrow_hit_at(_mx, _my, _x, _y){
    var _s  = credit_price_arrow_scale();
    var _hw = sprite_get_width(spr_shop_price_arrow)  * _s * 0.5 + 4;
    var _hh = sprite_get_height(spr_shop_price_arrow) * _s * 0.5 + 4;
    return point_in_rectangle(_mx, _my, _x - _hw, _y - _hh, _x + _hw, _y + _hh);
}

/// @func credit_price_arrow_hit(mx, my, cx, cy, label) 同上，位置按价格字自动算
function credit_price_arrow_hit(_mx, _my, _cx, _cy, _label){
    var _p = credit_price_arrow_at(_cx, _cy, _label);
    return credit_price_arrow_hit_at(_mx, _my, _p.x, _p.y);
}

// ─────────────────────────────────────────────────────────────────────────────
// 「威望」标签绘制（2026-10-26）
//   素材：原版 SWF 导出 转职系统素材\images\567.png（32x18，深蓝底已抠成透明）。
//   ⚠️ 只用于**底部余额条**（原版写法「[威望]1573」）。
//      商店凭证价格行**不用**它 —— 用户 2026-10-26 定：价格和「威望」两字自写、同色（见
//      obj_shop_buy_btn/Draw_0 的 `draw_text(x, y-62, string(cost) + "威望")`）。
// ─────────────────────────────────────────────────────────────────────────────

/// @function ui_prestige_tag_w(scale)
/// @desc 「威望」标签宽
function ui_prestige_tag_w(_scale) {
    return sprite_get_width(spr_ui_prestige_tag) * _scale;
}

/// @function ui_prestige_tag_h(scale)
/// @desc 「威望」标签高
function ui_prestige_tag_h(_scale) {
    return sprite_get_height(spr_ui_prestige_tag) * _scale;
}

/// @function ui_prestige_tag_draw(x, cy, scale)
/// @desc 画「威望」标签：x = 左端、cy = 垂直中心
function ui_prestige_tag_draw(_x, _cy, _scale) {
    draw_sprite_ext(spr_ui_prestige_tag, 0, _x, _cy - ui_prestige_tag_h(_scale) * 0.5,
        _scale, _scale, 0, c_white, 1);
}
/// @function credit_shop_sort_key(goods_id)
/// @desc 凭证页列表的排序键（2026-10-26 用户口径）：
///       ① **同一张卡的凭证必须挨在一起**；② 卡内**先一转后二转**；③ 不做全局「先所有一转再所有二转」。
///       所以键 = 「卡id|档位」，按字符串升序即可（档位是单字符，1 一定在 2 前面）。
///       兑换项（`credit_shape == 0`，如「威望 x1000」）没有卡 → 键前缀用 `~`（ASCII 126，排在所有字母后）→ 垫底。
function credit_shop_sort_key(_gid) {
    var _g = global.goods_map[? _gid];
    if (!variable_struct_exists(_g, "credit_shape") || _g.credit_shape <= 0) {
        return "~|" + string(_gid);                       // 兑换项：排最后，内部按 id
    }
    var _p = transfer_credit_parse(_g.unlock_item_id);
    var _cid = is_undefined(_p) ? string(_gid) : string(_p.card_id);
    return _cid + "|" + string(_g.credit_shape);
}
