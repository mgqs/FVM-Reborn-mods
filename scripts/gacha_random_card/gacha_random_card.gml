/// @function is_eternal_gacha_mode()
/// @desc 判断是否为抽卡模式难度（星际抽卡 或 欧皇抽卡）
/// @return {bool}
function is_eternal_gacha_mode() {
    return is_gacha_mode();
}

/// @function is_lucky_gacha_mode()
/// @desc 判断是否为欧皇抽卡难度
/// @return {bool}
function is_lucky_gacha_mode() {
    return global.play_mode == 2;
}

/// @function random_gift_pick_card()
/// @desc 从完整卡牌和敌人池按礼盒权重抽取结果。
function random_gift_pick_card() {
    var pools = [[], [], [], [], [], []]; // gold, zodiac, normal, normal mouse, elite mouse, boss
    var gift_card_blacklist = ["magic_chicken", "baibianshe", "brahma", "ice_cream", "lihe"];
    var gift_enemy_blacklist = ["test_mouse"];
    for (var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        var card_id = global.player_deck[| i];
        if (array_get_index(gift_card_blacklist, card_id) != -1) continue;
        var card = global.player_deck[| i + 1];
        if (!ds_exists(card, ds_type_map)) continue;
        var shapes = card[? "shapes"];
        var has_card = false;
        for (var s = 0; s < ds_list_size(shapes); s++) {
            var data = shapes[| s];
            var shape = data[? "shape"];
            if (data[? "obj"] == noone || get_plant_shape_data(card_id, shape) == undefined) continue;
            has_card = true;
        }
        if (!has_card) continue;
        var category = gacha_is_gold_card(card_id) ? 0 : (gacha_is_zodiac_card(card_id) ? 1 : 2);
        array_push(pools[category], {kind: "card", id: card_id});
    }

    if (variable_global_exists("enemy_map") && ds_exists(global.enemy_map, ds_type_map)) {
        var enemy_ids = [];
        ds_map_keys_to_array(global.enemy_map, enemy_ids);
        for (var e = 0; e < array_length(enemy_ids); e++) {
            var enemy_id = enemy_ids[e];
            if (array_get_index(gift_enemy_blacklist, enemy_id) != -1) continue;
            var enemy_data = global.enemy_map[? enemy_id];
            if (!variable_struct_exists(enemy_data, "_obj")) continue;
            var is_boss_enemy = variable_global_exists("boss_list")
                && ds_exists(global.boss_list, ds_type_map)
                && ds_map_exists(global.boss_list, enemy_id);
            if (is_boss_enemy) {
                array_push(pools[5], {kind: "enemy", id: enemy_id, data: enemy_data});
            } else if ((variable_struct_exists(enemy_data, "elite") && enemy_data.elite)
                || (variable_struct_exists(enemy_data, "ash_proof") && enemy_data.ash_proof)) {
                array_push(pools[4], {kind: "enemy", id: enemy_id, data: enemy_data});
            } else {
                array_push(pools[3], {kind: "enemy", id: enemy_id, data: enemy_data});
            }
        }
    }

    // 礼盒概率：金卡17%、生肖卡35%、普通卡40%、普通老鼠5%、精英老鼠2%、BOSS1%。
    var weights = [17, 35, 40, 5, 2, 1];
    var available = [];
    for (var c = 0; c < 6; c++) if (array_length(pools[c]) > 0) array_push(available, c);
    if (array_length(available) == 0) return undefined;
    var total = 0;
    for (var a = 0; a < array_length(available); a++) total += weights[available[a]];
    var roll = random(total);
    var category = available[array_length(available) - 1];
    var acc = 0;
    for (var a = 0; a < array_length(available); a++) {
        acc += weights[available[a]];
        if (roll < acc) { category = available[a]; break; }
    }
    var picked = pools[category][irandom(array_length(pools[category]) - 1)];
    if (picked.kind == "enemy") return picked;
    var card_id = picked.id;
    var card = noone;
    for (var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        if (global.player_deck[| i] == card_id) { card = global.player_deck[| i + 1]; break; }
    }
    if (card == noone) return undefined;
    var shape_list = [];
    var shapes = card[? "shapes"];
    for (var s = 0; s < ds_list_size(shapes); s++) {
        var data = shapes[| s];
        if (get_plant_shape_data(card_id, data[? "shape"]) != undefined) array_push(shape_list, data[? "shape"]);
    }
    if (array_length(shape_list) == 0) return undefined;
    var shape = shape_list[irandom(array_length(shape_list) - 1)];
    return {kind: "card", card_id: card_id, shape: shape, category: category, data: deck_get_card_data(card_id, shape)};
}

/// @function random_gift_spawn_card(x, y, col, row, level)
/// @desc 创建礼盒抽出的卡片，并在创建前传入形态、星级和技能参数。
function random_gift_spawn_card(_x, _y, _col, _row, _level) {
    var result = random_gift_pick_card();
    if (result == undefined) return noone;
    if (result.kind == "enemy") {
        var enemy_obj = result.data._obj;
        var enemy_inst = instance_create_depth(_x + 30, _y + 38, 0, enemy_obj);
        if (instance_exists(enemy_inst)) enemy_inst.random_gift_result = true;
        return enemy_inst;
    }
    var target_level = clamp(_level, 0, 18);
    while (target_level > 0 && get_plant_upgrade(result.card_id, result.shape, target_level) == undefined) target_level--;
    if (get_plant_upgrade(result.card_id, result.shape, target_level) == undefined) return noone;
    var skill_level = 0;
    if (variable_global_exists("save_data") && variable_struct_exists(global.save_data, "unlocked_items")) {
        skill_level = global.save_data.unlocked_items.max_skill_level;
    }
    global.random_gift_spawn_context = {
        card_id: result.card_id,
        shape: result.shape,
        level: target_level,
        skill: skill_level,
        source: "random_gift",
        terrain_adapted: true
    };
    var inst = instance_create_depth(_x, _y, 0, result.data[? "obj"]);
    global.random_gift_spawn_context = undefined;
    if (!instance_exists(inst)) return noone;
    card_created(inst, _col, _row);
    inst.depth = calculate_plant_depth(_col, _row, inst.plant_type);
    inst.random_gift_result = true;
    return inst;
}

/// @function gacha_get_excluded_cards()
/// @desc 获取本体仅通过关卡奖励获得的卡片；其转职可通过抽卡获得。
/// @return {array}
function gacha_get_excluded_cards() {
    return [
        "wooden_plate",       // 木盘子
        "wooden_cork",        // 木塞子
        "cotton_candy",       // 棉花糖
        "sausage",            // 香肠
        "oil_lamp",           // 油灯
        "soda_bubble",        // 苏打气泡
        "tang_hu_lu",         // 糖葫芦炮弹
        "double_water_pipe",  // 双向水管
        "mixian",             // 米线（松露大厅首通奖励）
        "huagao",             // 灯影花糕（松露大厅（夜）首通奖励）
        "fushengcha",         // 浮生茶（松露大厅（夜）首通奖励）
        "hongliukaochuan",    // 烤串机（百味关首通奖励）
        "chunsun"             // 泡椒春笋（赤霞渡（日）首通奖励）
    ];
}

/// @function gacha_is_excluded_card(card_id)
/// @desc 判断是否为抽卡排除卡
/// @param {string} card_id
/// @return {bool}
function gacha_is_excluded_card(card_id) {
    var excluded = gacha_get_excluded_cards();
    return array_get_index(excluded, card_id) != -1;
}

/// @function gacha_is_current_level_reward_card(card_id)
/// @desc 指定八张卡片中，本次关卡会正常发放本体的卡片。
function gacha_is_current_level_reward_card(card_id) {
    if (!gacha_is_excluded_card(card_id)) return false;
    if (!variable_global_exists("level_file") || !is_struct(global.level_file)) return false;
    if (!variable_struct_exists(global.level_file, "rewards")) return false;

    var rewards = global.level_file.rewards;
    if (!is_array(rewards) || array_length(rewards) <= 1) return false;
    var first_reward = rewards[1];
    if (!is_struct(first_reward) || !variable_struct_exists(first_reward, "card_unlock")) return false;

    var card_unlock = first_reward.card_unlock;
    for (var i = 0; i < array_length(card_unlock); i++) {
        if (card_unlock[i] == card_id) return true;
    }
    return false;
}

/// @function gacha_is_gold_card(card_id)
/// @desc 是不是金卡：**只看卡注册数据里的 is_gold**（2026-10-27 用户：不要用「在不在诸神商店」判断）
///       融合卡同理看 is_fusion，两者互斥
function gacha_is_gold_card(card_id) {
    var shape_data = deck_get_card_data(card_id, 0);
    if (shape_data != noone && ds_map_exists(shape_data, "is_gold")) {
        return (shape_data[? "is_gold"] == 1);
    }
    return false;
}

/// @function gacha_is_zodiac_card(card_id)
/// @desc 判断是否为生肖卡（商店价格 >= 80000 的卡片类商品）
/// @param {string} card_id
/// @return {bool}
function gacha_is_zodiac_card(card_id) {
    // 先排除金卡
    if (gacha_is_gold_card(card_id)) return false;

    // 检查是否在商店中
    if (!ds_map_exists(global.goods_map, card_id)) return false;

    var goods_data = global.goods_map[? card_id];
    if (!variable_struct_exists(goods_data, "type")) return false;
    if (goods_data[$ "type"] != "card") return false;

    var cost = real(goods_data[$ "cost"]);
    return cost >= 80000;
}

/// @function gacha_is_mod_weapon(weapon_id)
/// @desc 判断是否为MOD武器（通过是否在mod_weapons_init中注册来判断）
/// 这里用武器是否在 weapon_pool 中且不在普通商店武器列表中来判断
/// 简化方式：检查武器是否在商店中，如果不在商店中且在weapon_pool中则为MOD武器
/// 更准确的方式：检查武器id是否为已知MOD武器
/// @param {string} weapon_id
/// @return {bool}
function gacha_is_mod_weapon(weapon_id) {
    // MOD武器列表（来自mod_weapons_init.gml）
    var mod_weapons = [
        "zeus_bolt",
        "hades_scythe",
        "gods_shield",
        "master_shield",
        "star_wand",
        "rose_shield",
        "aladdin_lamp"
    ];
    return array_get_index(mod_weapons, weapon_id) != -1;
}

/// @function gacha_is_mod_gem(gem_id)
/// @desc 判断是否为MOD宝石
/// @param {string} gem_id
/// @return {bool}
function gacha_is_mod_gem(gem_id) {
    // MOD宝石列表（来自mod_weapons_init.gml）
    // 注：master_shield_gem_1/3/4 与 divine_blessing/protect/holy_gem 同名同功能，
    // 已移除前者防止重复抽取（前者obj为noone且不在商店中）
    var mod_gems = [
        "zeus_shadow_gem",
        "zeus_power_gem",
        "zeus_anger_gem",
        "zeus_ren_gem",
        "ghost_strike_gem",
        "ghost_spark_gem",
        "ghost_pact_gem",
        "ghost_caijue_gem",
        "gods_shield_gem_1",
        "gods_shield_gem_2",
        "gods_shield_gem_3",
        "gods_shield_gem_4",
        "master_shield_gem_2",
        "divine_blessing_gem",
        "divine_protect_gem",
        "divine_holy_gem",
        "divine_shenji_gem",
        "star_wand_gem_1",
        "star_wand_gem_2",
        "star_wand_gem_3",
        "star_wand_gem_4",
        "star_wand_gem_5",
        "rose_shield_gem_1",
        "rose_shield_gem_2",
        "rose_shield_gem_3",
        "rose_shield_gem_4",
        "rose_shield_gem_5",
        "aladdin_lamp_gem_1",
        "aladdin_lamp_gem_2",
        "aladdin_lamp_gem_3",
        "aladdin_lamp_gem_4",
        "aladdin_lamp_gem_5"
    ];
    return array_get_index(mod_gems, gem_id) != -1;
}

/// @function gacha_get_weapon_icon(weapon_id)
/// @desc 获取武器图标精灵
/// @param {string} weapon_id
/// @return {sprite}
function gacha_get_weapon_icon(weapon_id) {
    if (!ds_map_exists(global.weapon_pool, weapon_id)) return -1;
    var weapon_data = global.weapon_pool[? weapon_id];
    if (variable_struct_exists(weapon_data, "icon")) return weapon_data[$ "icon"];
    return -1;
}

/// @function gacha_get_card_display_name(card_id)
/// @desc 获取卡片显示名称，优先从商店数据获取
/// @param {string} card_id
/// @return {string}
function gacha_get_card_display_name(card_id) {
    // 先从普通商店获取
    if (ds_map_exists(global.goods_map, card_id)) {
        var goods_data = global.goods_map[? card_id];
        if (variable_struct_exists(goods_data, "display_name")) {
            return goods_data.display_name;
        }
    }
    // 再从诸神商店获取
    if (ds_map_exists(global.gods_goods_map, card_id)) {
        var gods_data = global.gods_goods_map[? card_id];
        if (variable_struct_exists(gods_data, "display_name")) {
            return gods_data.display_name;
        }
    }
    // 兜底：返回卡片ID
    return card_id;
}

/// @function gacha_get_weapon_name(weapon_id)
/// @desc 获取武器名称
/// @param {string} weapon_id
/// @return {string}
function gacha_get_weapon_name(weapon_id) {
    if (!ds_map_exists(global.weapon_pool, weapon_id)) return "未知武器";
    var weapon_data = global.weapon_pool[? weapon_id];
    if (variable_struct_exists(weapon_data, "name")) return weapon_data[$ "name"];
    return "未知武器";
}

/// @function gacha_get_gem_icon(gem_id)
/// @desc 获取宝石图标精灵
/// @param {string} gem_id
/// @return {sprite}
function gacha_get_gem_icon(gem_id) {
    if (!ds_map_exists(global.gems_pool, gem_id)) return -1;
    var gem_data = global.gems_pool[? gem_id];
    if (variable_struct_exists(gem_data, "icon")) return gem_data[$ "icon"];
    return -1;
}

/// @function gacha_get_gem_name(gem_id)
/// @desc 获取宝石名称
/// @param {string} gem_id
/// @return {string}
function gacha_get_gem_name(gem_id) {
    if (!ds_map_exists(global.gems_pool, gem_id)) return "未知宝石";
    var gem_data = global.gems_pool[? gem_id];
    if (variable_struct_exists(gem_data, "name")) return gem_data[$ "name"];
    return "未知宝石";
}

/// @function gacha_get_gem_weapons(gem_id)
/// @desc 获取宝石对应的武器列表
/// @param {string} gem_id
/// @return {array}
function gacha_get_gem_weapons(gem_id) {
    if (!ds_map_exists(global.gems_pool, gem_id)) return [];
    var gem_data = global.gems_pool[? gem_id];
    if (variable_struct_exists(gem_data, "allowed_weapons")) {
        return gem_data[$ "allowed_weapons"];
    }
    return [];
}

// 2026-10-27 用户口径：**前置体系已整体撤除** —— 现在前置只属于「金卡进化」和「食灵融合」，
//   抽卡 / 诸神商店一概不再校验前置（不需要先拥有前置卡、也不需要前置练到几转）。
//   因此 fusion_get_prerequisites() / prereq_body_only() / fusion_prereq_met() /
//   fusion_prereq_name() / fusion_prereq_any_upgradable() 已删除（要看旧实现翻 git 历史）。
//   金卡进化表：scripts/mod_craft_evo_table；融合主卡/副卡表：scripts/mod_craft_fusion_table

/// @function card_max_available_shape(card_id)
/// @desc 这张卡**注册了**的最大形态序号（0 起算）；查不到返回 -1。
///       用途：前置要求「练到二转」，但个别卡只有 0 转（2026-10-22 查出 `blueberry_tower` 蓝莓塔、
///       `magic_chicken` 幻幻鸡），够不到二转。按「练到它自己的最大形态」算满足，
///       否则诸神商店会永远提示未满足（永远买不了）、抽卡会跳过这张前置直接给目标卡本体。
function card_max_available_shape(card_id) {
    var _max = -1;
    for (var _s = 0; _s <= 3; _s++) {
        if (get_plant_shape_data(card_id, _s) != undefined) _max = _s;
    }
    return _max;
}

/// @function fusion_recipe_id(card_id, shape)
/// @desc 食谱道具在背包里的 id（诸神商店卖的就是这个；融合页也用它当「融合菜谱」）
function fusion_recipe_id(card_id, shape) {
    return "recipe_" + card_id + "_" + string(shape);
}

/// @function has_fusion_recipe(card_id, shape)
/// @desc 背包里有没有这张卡这个形态的食谱道具
function has_fusion_recipe(card_id, shape) {
    return (get_material_amount(fusion_recipe_id(card_id, shape)) > 0);
}

/// @function gacha_make_card_reward(card_id, shape)
/// @desc 「发一张卡」的唯一出口：**融合卡一律只发对应形态的融合菜谱道具**，其它卡照常发卡本体。
///       候选池 / 补前置本体 / 推前置到下一形态 三处都走它 ——
///       2026-10-24 修：宗布神(←融合三线)、赤帝(←融合栗子) 的前置本身是融合卡，
///       那两条 return 原来手写 {reward_type:"card"}，绕过了候选池里的 recipe 转换，直接把融合卡发出去了
function gacha_make_card_reward(_id, _shape) {
    if (is_fusion_card(_id)) {
        return { reward_type: "recipe", id: _id, shape: _shape,
                 recipe_id: fusion_recipe_id(_id, _shape), gift_id: gacha_gift_id("recipe", _id) };
    }
    if (gacha_is_gold_card(_id)) {
        // 金卡不作为卡直接发：改成「进化凭证」（拿凭证去合成屋-金卡进化）
        return { reward_type: "evo_credit", id: _id, shape: 0, gift_id: gacha_gift_id("evo_credit", _id) };
    }
    return { reward_type: "card", id: _id, shape: _shape };
}

/// @function gacha_gift_id(reward_type, id) 抽到这张奖励时「附赠一次本体」的卡
///   进化凭证 → 该金卡前置表 slot 0 的那张（第 1 槽）；没有 slot 0 就取第一条
///   融合菜谱 → 它的**前置主卡**（mod_fusion_main_prereq；不分初级/深度/灵魂都送这一张）
///   🔴 只送**普通卡**：目标是金卡（进化拿）或融合卡（融合页拿）时一律不送 ——
///      否则会绕过进化 / 融合系统，直接把金卡本体或融合卡本体发出去
/// @return 卡 id；不附赠返回 ""
function gacha_gift_id(_type, _id) {
    var _pick = "";
    if (_type == "evo_credit") {
        var _cs = mod_evo_cards(_id);
        for (var _i = 0; _i < array_length(_cs); _i++) {
            if (_cs[_i].slot == 0) { _pick = _cs[_i].id; break; }
        }
        if (_pick == "" && array_length(_cs) > 0) _pick = _cs[0].id;
    } else if (_type == "recipe") {
        _pick = mod_fusion_main_prereq(_id);
    }
    if (_pick == "") return "";
    if (gacha_is_gold_card(_pick) || is_fusion_card(_pick)) return "";
    return _pick;
}

/// @function gacha_gift_preview(reward) 这次奖励会附赠哪张卡（不附赠返回 ""）
///   只在「玩家还没有这张卡本体」时附赠一次；已经拥有就不给（也不会提升转职）
function gacha_gift_preview(_reward) {
    if (!is_struct(_reward)) return "";
    if (!variable_struct_exists(_reward, "gift_id")) return "";
    var _gid = _reward.gift_id;
    if (_gid == "" || _gid == _reward.id) return "";
    if (is_card_unlocked(_gid)) return "";
    return _gid;
}

/// @function gacha_gift_apply(reward) 真发放附赠：只给本体（0 形态），不提升转职
/// @return 实际发放的卡 id（没发返回 ""）
function gacha_gift_apply(_reward) {
    var _gid = gacha_gift_preview(_reward);
    if (_gid == "") return "";
    unlock_card(_gid, 0, 0, global.save_data.unlocked_items.max_skill_level);
    return _gid;
}

/// @function gacha_gift_text(reward) 附赠提示文案（用卡名，不出现 id；不附赠返回 ""）
function gacha_gift_text(_reward) {
    var _gid = gacha_gift_preview(_reward);
    if (_gid == "") return "";
    return "附赠：" + transfer_credit_card_name(_gid) + "本体";
}

// 附赠统一走 gacha_gift_id / preview / apply / text（2026-10-27 改：只附赠本体，不再提升转职）
//   旧的 gacha_recipe_gift_target / preview / text / gift 已删除

/// @function fusion_recipe_sprite(card_id, shape)
/// @desc 食谱图标 = [精灵, 帧]：形态 0 用 spr_fusion_recipe0（帧号按 fusion_demo 顺序），1/2 用诸神那套 spr_voucher_*
function fusion_recipe_sprite(card_id, shape) {
    if (shape <= 0) return [spr_fusion_recipe0, fusion_recipe0_frame(card_id)];
    var _s = asset_get_index("spr_voucher_" + card_id + "_" + string(shape));
    if (_s == -1) _s = spr_fusion_recipe0;
    return [_s, 0];
}

/// @function fusion_recipe_display_name(card_id, shape)
/// @desc 食谱道具的显示名（口径与诸神商店一致：融合菜谱 / 深度融合菜谱 / 灵魂融合菜谱（卡名））
function fusion_recipe_display_name(card_id, shape) {
    return fusion_recipe_grade_name(shape) + "（" + fusion_recipe_card_name(card_id, shape) + "）";
}

/// @function fusion_recipe_grade_name(shape)
/// @desc 食谱档位名（卡形态 → 食谱品级）：0 初级 / 1 深度融合 / 2 灵魂融合。
///       抽卡奖励弹窗把名字拆成「卡名 + 档位」两行，档位文案只在这里维护
function fusion_recipe_grade_name(shape) {
    if (shape <= 0) return "初级融合菜谱";
    if (shape == 1) return "深度融合菜谱";
    return "灵魂融合菜谱";
}

/// @function fusion_recipe_card_name(card_id, shape)
/// @desc 食谱对应的卡名 —— **按形态取**（如融合栗子：0 转酱香锅烤栗子 / 1 转可乐香烤栗子 / 2 转如意香烤栗子）。
///       该形态没注册时退回本体形态名，都查不到回退成卡 id
function fusion_recipe_card_name(card_id, shape = 0) {
    var _nm = "";
    var _sd = get_plant_shape_data(card_id, shape);
    if (_sd == undefined && shape != 0) {
        _sd = get_plant_shape_data(card_id, 0);
    }
    // ⚠️ 形态数据是 ds_map（register_plant_lite 建的），不是结构体 → 直接 [? "name"] 取；
    // 也不要用 is_real() 守卫：新版运行时 ds_map 句柄过 is_real 返回 false，名字会退回成卡 id
    if (_sd != undefined) {
        var _v = _sd[? "name"];
        if (!is_undefined(_v) && is_string(_v)) _nm = _v;
    }
    if (_nm == "") _nm = card_id;
    return _nm;
}

/// @function card_owned_shape(card_id)
/// @desc 存档里这张卡已有的最高形态（没解锁 = -1）
///       诸神商店卖「食谱道具」时要判断「这张卡已经到几转了」——融合页那份
///       fusion_owned_shape() 是 obj_craft_bg 的实例方法，别的对象里调不到，所以这里给一份全局版
function card_owned_shape(card_id) {
    var _cur = -1;
    for (var _i = 0; _i < 3; _i++) {
        if (deck_get_card_data(card_id, _i) != noone) _cur = _i;
    }
    return _cur;
}

// 前置系统已不再参与抽卡（2026-10-27 用户：抽卡不需要前置，前置只属于食灵融合 / 金卡进化）
//   旧的 gacha_resolve_prereq_reward 已删除

/// @function gacha_pick_random_reward()
/// @desc 按类别权重随机抽一个奖励（卡片 / 武器 / 宝石）
/// 抽取规则（2026-10-27 口径，**不校验任何前置**）：
/// 1. 普通 / 生肖卡：只发本体（shape 0）；已拥有 → 不进池
/// 2. 金卡：发 1 张进化凭证（金卡本体只能靠合成屋-金卡进化）；已有金卡或有凭证 → 不进池
/// 3. 融合卡：发菜谱（随机一个「没拥有、也没这道菜谱」的形态），附赠前置主卡本体
/// 4. 武器 / 宝石：未拥有才进池；宝石还要求先有对应武器
/// 权重见下方权重段（是权重不是百分比）
/// @return {struct} { reward_type, id, shape, [recipe_id], [gift_id] }
function gacha_pick_random_reward() {
    var fusion_candidates = [];
    var gold_candidates = [];
    var zodiac_candidates = [];
    var normal_candidates = [];
    var weapon_candidates = [];
    var gem_candidates = [];

    // === 卡片候选池 ===
    for (var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        var card_id = global.player_deck[| i];
		if (card_id == "lihe") continue;

        // 本体仅关卡奖励的特殊卡：未拥有且不是本关奖励 → 不进池（原逻辑保留）
        if (gacha_is_excluded_card(card_id) && !is_card_unlocked(card_id)
            && !gacha_is_current_level_reward_card(card_id)) continue;

        // ── 融合卡：只发菜谱（随机一个「还没拥有、也还没这道菜谱」的形态）──
        if (is_fusion_card(card_id)) {
            var _fowned = -1;
            if (is_card_unlocked(card_id)) {
                var _finfo = get_card_info_simple(card_id);
                _fowned = max(_finfo.max_shape, _finfo.shape);
            }
            var _fcands = [];
            for (var _fs = 0; _fs <= 3; _fs++) {
                if (get_plant_shape_data(card_id, _fs) == undefined) break;   // 形态到头了
                if (_fs <= _fowned) continue;                                 // 这个形态已经拥有
                if (has_fusion_recipe(card_id, _fs)) continue;                // 这个形态的菜谱已经到手
                array_push(_fcands, _fs);
            }
            if (array_length(_fcands) == 0) continue;                         // 全都有了，不进池
            array_push(fusion_candidates, gacha_make_card_reward(card_id, _fcands[irandom(array_length(_fcands) - 1)]));
            continue;
        }

        // ── 金卡：发「进化凭证」（金卡本体只能靠合成屋-金卡进化拿）
        //    已拥有这张金卡 / 背包里已经有它的进化凭证 → 不进池
        if (gacha_is_gold_card(card_id)) {
            if (is_card_unlocked(card_id)) continue;
            if (get_material_amount(mod_evo_credit_id(card_id)) > 0) continue;
            array_push(gold_candidates, gacha_make_card_reward(card_id, 0));
            continue;
        }

        // ── 普通 / 生肖：**只给本体**（2026-10-27 用户：抽卡不再给转职）
        //    已拥有就不进池（以前是「已拥有 → 给下一形态」，那个口径作废）
        if (is_card_unlocked(card_id)) continue;
        if (get_plant_shape_data(card_id, 0) == undefined) continue;

        var candidate = { reward_type: "card", id: card_id, shape: 0 };
        if (gacha_is_zodiac_card(card_id)) array_push(zodiac_candidates, candidate);
        else array_push(normal_candidates, candidate);
    }

    // === MOD武器候选池 ===
    var weapon_keys = [];
    ds_map_keys_to_array(global.weapon_pool, weapon_keys);
    for (var wi = 0; wi < array_length(weapon_keys); wi++) {
        var weapon_id = weapon_keys[wi];
        if (!gacha_is_mod_weapon(weapon_id)) continue;
        if (is_weapon_unlocked(weapon_id)) continue; // 已拥有不进池
        array_push(weapon_candidates, {
            reward_type: "weapon",
            id: weapon_id,
            shape: 0
        });
    }

    // === MOD宝石候选池 ===
    var gem_keys = [];
    ds_map_keys_to_array(global.gems_pool, gem_keys);
    for (var gi = 0; gi < array_length(gem_keys); gi++) {
        var gem_id = gem_keys[gi];
        if (!gacha_is_mod_gem(gem_id)) continue;
        if (is_gem_unlocked(gem_id)) continue; // 已拥有不进池

        // 必须拥有对应武器才能抽
        var allowed_weapons = gacha_get_gem_weapons(gem_id);
        var has_weapon = false;
        for (var awi = 0; awi < array_length(allowed_weapons); awi++) {
            if (is_weapon_unlocked(allowed_weapons[awi])) {
                has_weapon = true;
                break;
            }
        }
        if (!has_weapon) continue;

        array_push(gem_candidates, {
            reward_type: "gem",
            id: gem_id,
            shape: 0
        });
    }

    // === 按权重选择类别 ===
    // 权重值（非百分比；最终按「有候选的池」的权重之和归一化）：
    //   星际抽卡（难度6）：融合卡15 / 金卡8 / 生肖20 / 普通74 / 武器0.5 / 宝石0.5
    //   欧皇抽卡（难度7）：融合卡40 / 金卡50 / 生肖25 / 普通20 / 武器2.5 / 宝石2.5
    //   2026-10-25 用户口径：星际菜谱 20→15、金卡 5→8；欧皇菜谱 55→40（欧皇金卡保持 50）
    //   这是**权重**不是概率，别按百分比去反算
    var fusion_weight = 15;
    var gold_weight = 8;
    var zodiac_weight = 20;
    var normal_weight = 74;
    var weapon_weight = 0.5;
    var gem_weight = 0.5;

    if (is_lucky_gacha_mode()) {
        fusion_weight = 40;
        gold_weight = 50;
        zodiac_weight = 25;
        normal_weight = 20;
        weapon_weight = 2.5;
        gem_weight = 2.5;
    }

    // 如果某个类别候选为空，将其权重分配给其他类别（按比例）
    var total_weight = 0;
    var has_fusion = array_length(fusion_candidates) > 0;
    var has_gold = array_length(gold_candidates) > 0;
    var has_zodiac = array_length(zodiac_candidates) > 0;
    var has_normal = array_length(normal_candidates) > 0;
    var has_weapon = array_length(weapon_candidates) > 0;
    var has_gem = array_length(gem_candidates) > 0;

    if (has_fusion) total_weight += fusion_weight;
    if (has_gold) total_weight += gold_weight;
    if (has_zodiac) total_weight += zodiac_weight;
    if (has_normal) total_weight += normal_weight;
    if (has_weapon) total_weight += weapon_weight;
    if (has_gem) total_weight += gem_weight;

    // 全部为空时走兜底
    if (total_weight <= 0) {
        return gacha_pick_fallback_reward();
    }

    var roll = random(total_weight);
    var acc = 0;
    var selected_type = "normal";

    if (has_fusion) {
        acc += fusion_weight;
        if (roll < acc) {
            selected_type = "fusion";
        }
    }
    if (selected_type == "normal" && has_gold) {
        acc += gold_weight;
        if (roll < acc) {
            selected_type = "gold";
        }
    }
    if (selected_type == "normal" && has_zodiac) {
        acc += zodiac_weight;
        if (roll < acc) {
            selected_type = "zodiac";
        }
    }
    if (selected_type == "normal" && has_weapon) {
        acc += weapon_weight;
        if (roll < acc) {
            selected_type = "weapon";
        }
    }
    if (selected_type == "normal" && has_gem) {
        acc += gem_weight;
        if (roll < acc) {
            selected_type = "gem";
        }
    }

    // 根据选中的类型获取候选池
    var selected_pool = normal_candidates;
    if (selected_type == "fusion") selected_pool = fusion_candidates;
    else if (selected_type == "gold") selected_pool = gold_candidates;
    else if (selected_type == "zodiac") selected_pool = zodiac_candidates;
    else if (selected_type == "weapon") selected_pool = weapon_candidates;
    else if (selected_type == "gem") selected_pool = gem_candidates;

    // 从选中的池中随机抽取
    if (array_length(selected_pool) == 0) {
        return gacha_pick_fallback_reward();
    }

    return selected_pool[irandom(array_length(selected_pool) - 1)];
}

/// @function gacha_pick_fallback_reward()
/// @desc 兜底奖励：当所有卡片都达到最大形态时，随机一张卡提升等级
/// @return {struct} 包含 reward_type、id、shape 和 fallback 标记的结构体
function gacha_pick_fallback_reward() {
    var all_cards = [];
    for (var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        var card_id = global.player_deck[| i];
        if (is_card_unlocked(card_id)) {
            // 兜底是「满形态时随机一张提等级」，融合卡不参与 —— 它只能靠融合页拿，别在这里把本体发出去
            if (is_fusion_card(card_id)) continue;
            var info = get_card_info_simple(card_id);
            array_push(all_cards, {
                reward_type: "card",
                id: card_id,
                // 兜底只提升等级；展示当前使用形态，避免误显示成重复转职。
                shape: info.shape
            });
        }
    }

    if (array_length(all_cards) == 0) {
        // 极端情况：一张卡都没有，返回小火炉0形态
        return {
            reward_type: "card",
            id: "small_fire",
            shape: 0,
            fallback: true
        };
    }

    var result = all_cards[irandom(array_length(all_cards) - 1)];
    result.fallback = true;
    return result;
}

/// @function gacha_init_reward()
/// @desc 初始化抽卡奖励全局变量
function gacha_init_reward() {
    if (is_eternal_gacha_mode()) {
        global.gacha_reward = {
            reward_type: "card",
            id: "",
            shape: 0,
            received: false
        };
    }
}
