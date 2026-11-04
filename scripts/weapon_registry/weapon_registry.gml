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

/// @desc 判断某颗宝石能否留在指定槽位的新武器上
/// 这是「换装保留宝石」的唯一判据，刻意与 equip_gem() 的准入判定保持一致：
/// 槽位必须相同，且宝石若有 allowed_weapons，新武器必须在其中。
/// 通用宝石（没有 allowed_weapons）只要槽位对得上就一直留着。
/// @param {string} _gem_id 宝石ID
/// @param {string} _weapon_id 换上的新武器ID
/// @param {string} _slot 武器槽位（main_weapon / secondary_weapon / super_weapon）
/// @return {bool}
function gem_fits_weapon(_gem_id, _weapon_id, _slot) {
	var _gd = get_gem_info(_gem_id)
	// ds_map 未命中会返回 undefined；历史存档里也可能有已下架的宝石ID，一律按不兼容处理
	if (!is_struct(_gd)) return false
	if (!variable_struct_exists(_gd, "slot") || _gd.slot != _slot) return false
	if (!variable_struct_exists(_gd, "allowed_weapons")) return true
	var _n = array_length(_gd.allowed_weapons)
	for (var _i = 0; _i < _n; _i++) {
		if (_gd.allowed_weapons[_i] == _weapon_id) return true
	}
	return false
}

/// @desc 换武器后重算该槽位的宝石：只保留与新武器兼容的，其余卸下（不丢宝石）
/// 原来这里是无条件 gems = []，导致换一把同类武器也会把 4 颗宝石全部卸下。
/// 注意：结构体字段必须整体赋值写回，GML 数组是写时复制，原地改局部变量不会同步。
/// @param {string} _slot 武器槽位
/// @param {string} _weapon_id 换上的新武器ID
function weapon_gems_reconcile(_slot, _weapon_id) {
	var _eq = undefined
	if (_slot == "main_weapon") _eq = global.save_data.equipped_items.main_weapon
	else if (_slot == "secondary_weapon") _eq = global.save_data.equipped_items.secondary_weapon
	else if (_slot == "super_weapon") _eq = global.save_data.equipped_items.super_weapon
	if (!is_struct(_eq)) return
	if (!variable_struct_exists(_eq, "gems") || !is_array(_eq.gems)) {
		_eq.gems = []
		return
	}
	var _old = _eq.gems
	var _keep = []
	var _n = array_length(_old)
	for (var _i = 0; _i < _n; _i++) {
		if (gem_fits_weapon(_old[_i], _weapon_id, _slot)) array_push(_keep, _old[_i])
	}
	_eq.gems = _keep
}

/// @function equip_weapon(weapon_id,slot)
/// @desc 装备武器
/// @param {string} weapon_id 武器ID
/// @param {string} slot 武器槽位
function equip_weapon(weapon_id,slot){
	// 换武器时不再整槽清空宝石：只要宝石与新武器兼容（同槽位 + allowed_weapons 命中）就保留，
	// 只有不兼容的专属宝石才卸下 —— 与重生原版行为一致。
	if slot == "main_weapon"{
		global.save_data.equipped_items.main_weapon[$ "id"] = weapon_id
		weapon_gems_reconcile("main_weapon", weapon_id)
	}
	else if slot == "secondary_weapon"{
		global.save_data.equipped_items.secondary_weapon[$ "id"] = weapon_id
		weapon_gems_reconcile("secondary_weapon", weapon_id)
	}
	else if slot == "super_weapon"{
		global.save_data.equipped_items.super_weapon[$ "id"] = weapon_id
		weapon_gems_reconcile("super_weapon", weapon_id)
	}
	global.equipped_weapon[? slot].weapon_id = weapon_id
	save_file(global.save_slot)
}

/// @function remove_weapon(slot)
/// @desc 卸下武器
/// @param {string} slot 武器槽位
function remove_weapon(slot){
	// 卸下武器：槽位空出来后宝石无处可装，这里仍然全清。
	// 与 equip_weapon 的「保留兼容宝石」策略不冲突：那条只在换上一把新武器时生效。
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
