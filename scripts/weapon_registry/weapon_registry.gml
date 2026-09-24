function weapon_registry_init(){
	global.weapon_pool = ds_map_create()
	global.equipped_weapon = ds_map_create()
	ds_map_add(global.equipped_weapon,"main_weapon",{"weapon_id":""})
	ds_map_add(global.equipped_weapon,"secondary_weapon",{"weapon_id":""})
	ds_map_add(global.equipped_weapon,"super_weapon",{"weapon_id":""})
}

function gem_registry_init(){
	global.gems_pool = ds_map_create()
}
/// @desc 注册宝石
function register_gem(gem_id,data){
	ds_map_add(global.gems_pool,gem_id,data)
}

/// @function register_weapon(weapon_id,data)
/// @desc 注册新的武器
/// @param {string} weapon_id 武器ID
/// @param {struct} data 武器数据
function register_weapon(weapon_id,data){
	ds_map_add(global.weapon_pool,weapon_id,data)
}

/// @function equip_weapon(weapon_id,slot)
/// @desc 装备武器
/// @param {string} weapon_id 武器ID
/// @param {string} slot 武器槽位
function equip_weapon(weapon_id,slot){
	// 更换武器时，自动把旧武器的宝石归还背包
	if slot == "main_weapon"{
		global.save_data.equipped_items.main_weapon.gems = []
		global.save_data.equipped_items.main_weapon[$ "id"] = weapon_id
	}
	else if slot == "secondary_weapon"{
		global.save_data.equipped_items.secondary_weapon.gems = []
		global.save_data.equipped_items.secondary_weapon[$ "id"] = weapon_id
	}
	else if slot == "super_weapon"{
		global.save_data.equipped_items.super_weapon.gems = []
		global.save_data.equipped_items.super_weapon[$ "id"] = weapon_id
	}
	global.equipped_weapon[? slot].weapon_id = weapon_id
	save_file(global.save_slot)
}

/// @function remove_weapon(slot)
/// @desc 卸下武器
/// @param {string} slot 武器槽位
function remove_weapon(slot){
	// 卸下武器时，自动把宝石归还背包
	if slot == "main_weapon"{
		global.save_data.equipped_items.main_weapon.gems = []
		global.save_data.equipped_items.main_weapon[$ "id"] = ""
	}
	else if slot == "secondary_weapon"{
		global.save_data.equipped_items.secondary_weapon.gems = []
		global.save_data.equipped_items.secondary_weapon[$ "id"] = ""
	}
	else if slot == "super_weapon"{
		global.save_data.equipped_items.super_weapon.gems = []
		global.save_data.equipped_items.super_weapon[$ "id"] = ""
	}
	global.equipped_weapon[? slot].weapon_id = ""
	save_file(global.save_slot)
}

/// @function equip_gem(gem_id,slot,level)
/// @desc 装备宝石
/// @param {string} gem_id 宝石ID
function equip_gem(gem_id){
	var gem_data = get_gem_info(gem_id)
	var gem_level = get_gem_level(gem_id)
	var slot = gem_data.slot
	var slot_gem = []

	// 专属宝石检查：如果宝石有 allowed_weapons，需要对应武器已装备
	if (variable_struct_exists(gem_data, "allowed_weapons")) {
		var equipped_weapon_id = ""
		if slot == "main_weapon"{
			equipped_weapon_id = global.save_data.equipped_items.main_weapon[$ "id"]
		}
		else if slot == "secondary_weapon"{
			equipped_weapon_id = global.save_data.equipped_items.secondary_weapon[$ "id"]
		}
		else if slot == "super_weapon"{
			equipped_weapon_id = global.save_data.equipped_items.super_weapon[$ "id"]
		}
		var is_allowed = false
		for (var i = 0; i < array_length(gem_data.allowed_weapons); i++) {
			if (gem_data.allowed_weapons[i] == equipped_weapon_id) {
				is_allowed = true
				break
			}
		}
		if (!is_allowed) {
			return
		}
	}

	// 互斥宝石：装备增强版宝石时自动卸下原版，反之亦然
	var _gem_conflicts = {
		aladdin_lamp_gem_1: "aladdin_lamp_gem_5",
		aladdin_lamp_gem_5: "aladdin_lamp_gem_1",
		star_wand_gem_1: "star_wand_gem_5",
		star_wand_gem_5: "star_wand_gem_1",
		rose_shield_gem_3: "rose_shield_gem_5",
		rose_shield_gem_5: "rose_shield_gem_3"
	};
	if (variable_struct_exists(_gem_conflicts, gem_id)) {
		var _conflict_id = _gem_conflicts[$ gem_id];
		if (get_gem_index(_conflict_id) != -1) {
			remove_gem(_conflict_id);
		}
	}

	if slot == "main_weapon"{
		if get_gem_index(gem_id) == -1{
			slot_gem = global.save_data.equipped_items.main_weapon.gems
			if array_length(slot_gem) < 4{
				slot_gem[array_length(slot_gem)] = gem_id
			}
		}
	}
	else if slot == "secondary_weapon"{
		if get_gem_index(gem_id) == -1{
			slot_gem = global.save_data.equipped_items.secondary_weapon.gems
			if array_length(slot_gem) < 4{
				slot_gem[array_length(slot_gem)] = gem_id
			}
		}
	}
	else if slot == "super_weapon"{
		if get_gem_index(gem_id) == -1{
			slot_gem = global.save_data.equipped_items.super_weapon.gems
			if array_length(slot_gem) < 4{
				slot_gem[array_length(slot_gem)] = gem_id
			}
		}
	}
	save_file(global.save_slot)
}

/// @function can_equip_gem(gem_id)
/// @desc 检查宝石是否可以装备到当前武器
/// @param {string} gem_id 宝石ID
/// @return {bool} 是否可以装备
function can_equip_gem(gem_id) {
	var gem_data = get_gem_info(gem_id)
	if (!variable_struct_exists(gem_data, "allowed_weapons")) {
		return true
	}
	var slot = gem_data.slot
	var equipped_weapon_id = ""
	if slot == "main_weapon"{
		equipped_weapon_id = global.save_data.equipped_items.main_weapon[$ "id"]
	}
	else if slot == "secondary_weapon"{
		equipped_weapon_id = global.save_data.equipped_items.secondary_weapon[$ "id"]
	}
	else if slot == "super_weapon"{
		equipped_weapon_id = global.save_data.equipped_items.super_weapon[$ "id"]
	}
	for (var i = 0; i < array_length(gem_data.allowed_weapons); i++) {
		if (gem_data.allowed_weapons[i] == equipped_weapon_id) {
			return true
		}
	}
	return false
}

function get_gem_index(gem_id){
	var gem_data = get_gem_info(gem_id)
	var slot = gem_data.slot
	if slot == "main_weapon"{
		return array_get_index(global.save_data.equipped_items.main_weapon.gems,gem_id)
	}
	else if slot == "secondary_weapon"{
		return array_get_index(global.save_data.equipped_items.secondary_weapon.gems,gem_id)
	}
	else if slot == "super_weapon"{
		return array_get_index(global.save_data.equipped_items.super_weapon.gems,gem_id)
	}
}

/// @function remove_gem(slot,gem_index)
/// @desc 卸下宝石
/// @param {string} slot 武器槽位
/// @param {real} gem_index 宝石索引
function remove_gem(gem_id){
	var gem_data = get_gem_info(gem_id)
	var slot = gem_data.slot
	if slot == "main_weapon"{
		var gem_index = get_gem_index(gem_id)
		if gem_index != -1{
			array_delete(global.save_data.equipped_items.main_weapon.gems,gem_index,1)
		}
		
	}
	else if slot == "secondary_weapon"{
		var gem_index = get_gem_index(gem_id)
		if gem_index != -1{
			array_delete(global.save_data.equipped_items.secondary_weapon.gems,gem_index,1)
		}
	}
	else if slot == "super_weapon"{
		var gem_index = get_gem_index(gem_id)
		if gem_index != -1{
			array_delete(global.save_data.equipped_items.super_weapon.gems,gem_index,1)
		}
	}
	save_file(global.save_slot)
}

/// @function is_weapon_equipped(weapon_id)
/// @desc 检查武器是否已装备
/// @param {string} weapon_id 武器ID
/// @return {bool} 是否已装备
function is_weapon_equipped(weapon_id) {
    return (global.save_data.equipped_items.main_weapon[$ "id"] == weapon_id ||
            global.save_data.equipped_items.secondary_weapon[$ "id"] == weapon_id ||
            global.save_data.equipped_items.super_weapon[$ "id"] == weapon_id);
}

/// @function get_weapon_slot(weapon_id)
/// @desc 获取武器所在的槽位
/// @param {string} weapon_id 武器ID
/// @return {string} 槽位名称，如果未装备则返回空字符串
function get_weapon_slot(weapon_id) {
    if (global.save_data.equipped_items.main_weapon[$ "id"] == weapon_id) {
        return "main_weapon";
    } else if (global.save_data.equipped_items.secondary_weapon[$ "id"] == weapon_id) {
        return "secondary_weapon";
    } else if (global.save_data.equipped_items.super_weapon[$ "id"] == weapon_id) {
        return "super_weapon";
    }
    return "";
}

/// @function get_weapon_info(weapon_id)
/// @desc 获取武器信息
/// @param {string} weapon_id 武器ID
/// @return {struct} weapon_info 武器信息结构体
function get_weapon_info(weapon_id) {
    return global.weapon_pool[? weapon_id]
}

/// @desc 获取宝石信息
function get_gem_info(gem_id) {
    return global.gems_pool[? gem_id]
}
