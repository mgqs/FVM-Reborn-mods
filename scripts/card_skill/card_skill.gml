// 脚本：skill_system.gml

// 初始化技能注册表
function skill_registry_init() {
    global.skill_registry = ds_map_create();
}

// 注册卡片技能
function register_card_skill(card_id, info_id, skill_data_array) {
    if (!ds_map_exists(global.skill_registry, card_id)) {
        ds_map_add(global.skill_registry, card_id, [info_id,skill_data_array]);
    }
    
    //var card_skills = global.skill_registry[? card_id];
    //var shape_str = string(shape);
    
    //if (!ds_map_exists(card_skills, shape_str)) {
    //    ds_map_add(card_skills, shape_str, ds_list_create());
    //}
    
    //var skill_list = card_skills[? shape_str];
    
    //// 添加技能数据
    //for (var i = 0; i < array_length(skill_data_array); i++) {
    //    var skill_data = ds_map_create();
    //    var skill_info = skill_data_array[i];
        
    //    // 复制所有属性
    //    var keys = array_keys(skill_info);
    //    for (var j = 0; j < array_length(keys); j++) {
    //        var key = keys[j];
    //        skill_data[? key] = skill_info[key];
    //    }
        
    //    ds_list_add(skill_list, skill_data);
    //}
    
    return true;
}

// 获取卡片技能数据
function get_card_skill_data(card_id, shape, skill_level) {
    if (!ds_map_exists(global.skill_registry, card_id)) {
        return undefined;
    }
    
    var card_skills = global.skill_registry[? card_id];
    var shape_str = string(shape);
    
    if (!ds_map_exists(card_skills, shape_str)) {
        return undefined;
    }
    
    var skill_list = card_skills[? shape_str];
    
    if (skill_level < 0 || skill_level >= ds_list_size(skill_list)) {
        return undefined;
    }
    
    return skill_list[| skill_level];
}

// 获取卡片最高技能等级
function get_max_skill_level(card_id, shape) {
    if (!ds_map_exists(global.skill_registry, card_id)) {
        return 0;
    }
    
    var card_skills = global.skill_registry[? card_id];
    var shape_str = string(shape);
    
    if (!ds_map_exists(card_skills, shape_str)) {
        return 0;
    }
    
    return ds_list_size(card_skills[? shape_str]);
}

// 获取带有技能效果的植物数据
function get_plant_data_with_skill(plant_id, shape, upgrade_level, skill_level) {
    // 获取基础升级数据
    var upgrade_data = get_plant_upgrade(plant_id, shape, upgrade_level);
    if (upgrade_data == undefined) {
        return undefined;
    }
    // 安全检查：卡片是否在技能注册表中注册
    if (!ds_map_exists(global.skill_registry, plant_id)) {
        return upgrade_data;
    }
    var _skill_entry = global.skill_registry[? plant_id];
    if (!is_array(_skill_entry) || array_length(_skill_entry) < 2) {
        return upgrade_data;
    }
    var info_id = _skill_entry[0]
    var skill_values = _skill_entry[1]
    // 技能数据通常是一维数组；需要区分形态时可传入二维数组。
    if (is_array(skill_values) && array_length(skill_values) > 0 && is_array(skill_values[0])) {
        var skill_shape = clamp(shape, 0, array_length(skill_values) - 1)
        skill_values = skill_values[skill_shape]
    }
    if (!is_array(skill_values) || skill_level < 0 || skill_level >= array_length(skill_values)) {
        return upgrade_data;
    }
	upgrade_data[? info_id] = skill_values[skill_level]
	return(upgrade_data)
    //// 复制升级数据，避免修改原始数据
    //var result_data = ds_map_create()
	//ds_map_copy(result_data,upgrade_data);
    
    //// 获取技能数据
    //var skill_data = get_card_skill_data(plant_id, shape, skill_level);
    //if (skill_data != undefined) {
    //    // 应用技能效果（覆盖特定属性）
    //    var keys = ds_map_keys(skill_data);
    //    for (var i = 0; i < ds_map_size(skill_data); i++) {
    //        var key = keys[i];
    //        // 跳过非数值属性（如名称、描述等）
    //        if (key != "name" && key != "description" && key != "shape" && key != "level") {
    //            result_data[? key] = skill_data[? key];
    //        }
    //    }
    //}
}

// 创建技能数据
function create_skill_data(skill_level, override_properties) {
    var skill_data = ds_map_create();
    skill_data[? "skill_level"] = skill_level;
    
    // 复制所有覆盖属性
    var keys = array_keys(override_properties);
    for (var i = 0; i < array_length(keys); i++) {
        var key = keys[i];
        skill_data[? key] = override_properties[key];
    }
    
    return skill_data;
}
// 在游戏中使用技能数据
function create_plant_with_skill(plant_id, shape, upgrade_level, skill_level, x, y) {
    var plant_data = get_plant_data_with_skill(plant_id, shape, upgrade_level, skill_level);
    if (plant_data == undefined) {
        // 回退到无技能数据
        plant_data = get_plant_upgrade(plant_id, shape, upgrade_level);
        if (plant_data == undefined) {
            return undefined;
        }
    }
    
    var plant = instance_create(x, y, obj_plant_base);
    plant.hp = plant_data[? "hp"];
    plant.cost = plant_data[? "cost"];
    plant.atk = plant_data[? "atk"];
    plant.range = plant_data[? "range"];
    plant.cooldown = plant_data[? "cooldown"];
    plant.cycle = plant_data[? "cycle"];
    plant.shape = shape;
    plant.level = upgrade_level;
    plant.skill_level = skill_level;
    
    // 设置自定义属性
    if (ds_map_exists(plant_data, "flame_produce")) {
        plant.flame_produce = plant_data[? "flame_produce"];
    }
    if (ds_map_exists(plant_data, "first_produce_delay")) {
        plant.first_produce_delay = plant_data[? "first_produce_delay"];
    }
    
    return plant;
}

// ══════════════════════════════════════════════════════════════════════
// 技能等级解锁来源（背包「解锁信息」页展示用）
//   1 级技能在曲奇岛首通就解锁，往后依次推进。表按关卡推进顺序硬编码，
//   与关卡 JSON 的 rewards[1].skill_level 对齐：
//     cookie_island=1 / salad_island_water=2 / champagne_island_land=3 /
//     temple=4 / cocoa_island_daytime=5 / cheese_castle=6 /
//     macchiato_port=7 / spice_airship=8
//   ⚠️ 改关卡技能奖励时同步改这张表，下标 = 技能等级 - 1。
// ══════════════════════════════════════════════════════════════════════

/// @function skill_unlock_source_list()
/// @desc 技能 1~8 级各自的解锁关卡名，返回长度 8 的数组（下标 = 等级 - 1）
function skill_unlock_source_list() {
    return ["曲奇岛", "色拉岛（水）", "香槟岛（陆）", "神殿",
            "可可岛（日）", "芝士城堡", "玛奇朵港", "香料飞船"];
}

/// @function skill_unlock_source(_level)
/// @desc 指定技能等级的解锁关卡名；越界返回 ""
function skill_unlock_source(_level) {
    var _list = skill_unlock_source_list();
    var _idx = _level - 1;
    if (_idx < 0 || _idx >= array_length(_list)) return "";
    return _list[_idx];
}

