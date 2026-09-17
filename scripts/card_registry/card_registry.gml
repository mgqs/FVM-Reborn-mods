// 脚本：plant_registry.gml

// 初始化植物注册表
function plant_registry_init() {
    global.plant_registry = ds_map_create();
}

// 注册新植物（支持多形态）
function register_plant(plant_id, shapes_array) {
    if (ds_map_exists(global.plant_registry, plant_id)) {
        show_debug_message("植物已注册: " + plant_id);
        return false;
    }
    
    // 创建植物类型数据结构
    var plant_data = ds_map_create();
    plant_data[? "shapes"] = ds_map_create(); // 存储所有形态的数据
    
    // 遍历形态数组，为每个形态创建基础数据和升级数据存储
    for (var i = 0; i < array_length(shapes_array); i++) {
        var shape_info = shapes_array[i];
        var shape = shape_info.shape;
        
        // 创建形态数据
        var shape_data = ds_map_create();
        shape_data[? "name"] = shape_info.name;
        shape_data[? "description"] = shape_info.description;
        shape_data[? "base_hp"] = shape_info.hp;
        shape_data[? "base_cost"] = shape_info.cost;
        shape_data[? "base_atk"] = shape_info.atk;
        shape_data[? "base_range"] = shape_info.range;
        shape_data[? "base_cooldown"] = shape_info.cooldown;
        shape_data[? "base_cycle"] = shape_info.cycle;
        
        // 创建升级数据存储
        var upgrades = ds_map_create();
        shape_data[? "upgrades"] = upgrades;
        
        // 添加基础等级数据
        var base_upgrade = ds_map_create();
        ds_map_add(base_upgrade, "level", 0);
        ds_map_add(base_upgrade, "hp", shape_info.hp);
        ds_map_add(base_upgrade, "cost", shape_info.cost);
        ds_map_add(base_upgrade, "atk", shape_info.atk);
        ds_map_add(base_upgrade, "range", shape_info.range);
        ds_map_add(base_upgrade, "cooldown", shape_info.cooldown);
        ds_map_add(base_upgrade, "cycle", shape_info.cycle);
		if struct_exists(shape_info,"flame_produce"){
			ds_map_add(base_upgrade,"flame_produce",shape_info.flame_produce)}
        
        ds_map_add(upgrades, "0", base_upgrade);
        
        // 将形态数据添加到植物数据中
        ds_map_add(plant_data[? "shapes"], string(shape), shape_data);
    }
    
    // 添加到注册表
    ds_map_add(global.plant_registry, plant_id, plant_data);
    
    return true;
}

// 添加植物升级（支持多形态）
function add_plant_upgrade(plant_id, level, shapes_upgrade_array) {
    if (!ds_map_exists(global.plant_registry, plant_id)) {
        show_debug_message("植物未注册: " + plant_id);
        return false;
    }
    
    var plant_data = global.plant_registry[? plant_id];
    var shapes_map = plant_data[? "shapes"];
    
    // 遍历升级数据数组，为每个形态添加升级数据
    for (var i = 0; i < array_length(shapes_upgrade_array); i++) {
        var upgrade_info = shapes_upgrade_array[i];
        var shape = upgrade_info.shape;
        
        if (ds_map_exists(shapes_map, string(shape))) {
            var shape_data = shapes_map[? string(shape)];
            var upgrades = shape_data[? "upgrades"];
            
            // 创建升级数据
            var upgrade_map = ds_map_create();
            ds_map_add(upgrade_map, "level", upgrade_info.level);
            ds_map_add(upgrade_map, "hp", upgrade_info.hp);
            ds_map_add(upgrade_map, "cost", upgrade_info.cost);
            ds_map_add(upgrade_map, "atk", upgrade_info.atk);
            ds_map_add(upgrade_map, "range", upgrade_info.range);
            ds_map_add(upgrade_map, "cooldown", upgrade_info.cooldown);
            ds_map_add(upgrade_map, "cycle", upgrade_info.cycle);
			if struct_exists(upgrade_info,"flame_produce"){
			ds_map_add(upgrade_map,"flame_produce",upgrade_info.flame_produce)}
            
            // 添加自定义属性
            //var keys = ds_map_keys_to_array(upgrade_info);
            //for (var j = 0; j < ds_map_size(upgrade_info); j++) {
            //    var key = keys[j];
            //    if (key != "shape" && key != "level" && key != "hp" && key != "cost" && 
            //        key != "atk" && key != "range" && key != "cooldown" && key != "cycle" &&
            //        key != "name" && key != "description") {
            //        ds_map_add(upgrade_map, key, upgrade_info[? key]);
            //    }
            //}
            
            // 添加升级数据
            ds_map_add(upgrades, string(level), upgrade_map);
        }
    }
    
    return true;
}

// 获取植物数据
function get_plant_data(plant_id) {
    if (ds_map_exists(global.plant_registry, plant_id)) {
        return global.plant_registry[? plant_id];
    }
    return undefined;
}

// 获取植物特定形态的数据
function get_plant_shape_data(plant_id, shape) {
    var plant_data = get_plant_data(plant_id);
    if (plant_data == undefined) return undefined;
    
    var shapes_map = plant_data[? "shapes"];
    if (ds_map_exists(shapes_map, string(shape))) {
        return shapes_map[? string(shape)];
    }
    
    return undefined;
}

// 获取植物升级数据
function get_plant_upgrade(plant_id, shape, level) {
    var shape_data = get_plant_shape_data(plant_id, shape);
    if (shape_data == undefined) return undefined;
    
    var upgrades = shape_data[? "upgrades"];
    if (ds_map_exists(upgrades, string(level))) {
        return upgrades[? string(level)];
    }
    
    return undefined;
}

// 创建升级数据结构（支持多形态）
function create_upgrade_data(shapes_upgrade_array) {
    return shapes_upgrade_array; // 直接返回数组，由add_plant_upgrade处理
}

// 注册新植物（轻量版）
function register_plant_lite(plant_id, shapes_array) {
    if (ds_map_exists(global.plant_registry, plant_id)) {
        show_debug_message("植物已注册: " + plant_id);
        return false;
    }
    
    // 创建植物类型数据结构
    var plant_data = ds_map_create();
    plant_data[? "shapes"] = ds_map_create(); // 存储所有形态的数据
    
    // 遍历形态数组，为每个形态创建基础数据和升级数据存储
    for (var i = 0; i < array_length(shapes_array); i++) {
        var shape_info = shapes_array[i];
        var shape = shape_info.shape;
        
        // 创建形态数据
        var shape_data = ds_map_create();
        shape_data[? "name"] = shape_info.name;
        shape_data[? "description"] = shape_info.description;
        shape_data[? "base_hp"] = shape_info.hp[0];
        shape_data[? "base_cost"] = shape_info.cost[0];
        shape_data[? "base_atk"] = shape_info.atk[0];
        shape_data[? "base_range"] = shape_info.range[0];
        shape_data[? "base_cooldown"] = shape_info.cooldown[0];
        shape_data[? "base_cycle"] = shape_info.cycle[0];
        
        // 创建升级数据存储
        var upgrades = ds_map_create();
        shape_data[? "upgrades"] = upgrades;
        
        // 添加基础等级数据
        var base_upgrade = ds_map_create();
        ds_map_add(base_upgrade, "level", 0);
        ds_map_add(base_upgrade, "hp", shape_info.hp[0]);
        ds_map_add(base_upgrade, "cost", shape_info.cost[0]);
        ds_map_add(base_upgrade, "atk", shape_info.atk[0]);
        ds_map_add(base_upgrade, "range", shape_info.range[0]);
        ds_map_add(base_upgrade, "cooldown", shape_info.cooldown[0]);
        ds_map_add(base_upgrade, "cycle", shape_info.cycle[0]);
		if struct_exists(shape_info,"flame_produce"){
			ds_map_add(base_upgrade,"flame_produce",shape_info.flame_produce[0])}
        
        ds_map_add(upgrades, "0", base_upgrade);
        
        // 将形态数据添加到植物数据中
        ds_map_add(plant_data[? "shapes"], string(shape), shape_data);
    }
    
    // 添加到注册表
    ds_map_add(global.plant_registry, plant_id, plant_data);
	
	//遍历添加等级信息
	for(var i = 1 ; i <= 16;i++){
		add_plant_upgrade_lite(plant_id,i,shapes_array)
	}
    
    return true;
}

// 添加植物升级（轻量版）
function add_plant_upgrade_lite(plant_id, level, shapes_upgrade_array) {
    if (!ds_map_exists(global.plant_registry, plant_id)) {
        show_debug_message("植物未注册: " + plant_id);
        return false;
    }
    
    var plant_data = global.plant_registry[? plant_id];
    var shapes_map = plant_data[? "shapes"];
    
    // 遍历升级数据数组，为每个形态添加升级数据
    for (var i = 0; i < array_length(shapes_upgrade_array); i++) {
        var upgrade_info = shapes_upgrade_array[i];
        var shape = upgrade_info.shape;
        
        if (ds_map_exists(shapes_map, string(shape))) {
            var shape_data = shapes_map[? string(shape)];
            var upgrades = shape_data[? "upgrades"];
            
            // 创建升级数据
            var upgrade_map = ds_map_create();
            ds_map_add(upgrade_map, "level", level);
            ds_map_add(upgrade_map, "hp", upgrade_info.hp[level]);
            ds_map_add(upgrade_map, "cost", upgrade_info.cost[level]);
            ds_map_add(upgrade_map, "atk", upgrade_info.atk[level]);
            ds_map_add(upgrade_map, "range", upgrade_info.range[level]);
            ds_map_add(upgrade_map, "cooldown", upgrade_info.cooldown[level]);
            ds_map_add(upgrade_map, "cycle", upgrade_info.cycle[level]);
			if struct_exists(upgrade_info,"flame_produce"){
			ds_map_add(upgrade_map,"flame_produce",upgrade_info.flame_produce[level])}
            
            // 添加自定义属性
            //var keys = ds_map_keys_to_array(upgrade_info);
            //for (var j = 0; j < ds_map_size(upgrade_info); j++) {
            //    var key = keys[j];
            //    if (key != "shape" && key != "level" && key != "hp" && key != "cost" && 
            //        key != "atk" && key != "range" && key != "cooldown" && key != "cycle" &&
            //        key != "name" && key != "description") {
            //        ds_map_add(upgrade_map, key, upgrade_info[? key]);
            //    }
            //}
            
            // 添加升级数据
            ds_map_add(upgrades, string(level), upgrade_map);
        }
    }
    
    return true;
}