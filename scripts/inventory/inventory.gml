function add_material_amount(material_id,amount){
	var length = array_length(global.save_data.inventory)
	//先检查背包中是否有材料
	if have_material(material_id){
		//如果存在，则增加数量
		for(var i = 0 ; i < length ; i++){
			if global.save_data.inventory[i].id == material_id{
				global.save_data.inventory[i].amount += amount
			}
		}
	}
	else{
		//如果不存在，则创建物品
		//array_push(global.save_data.inventory,{"id":material_id,"amount":amount})
		set_material_amount(material_id,amount)
	}
	save_file(global.save_slot)
}

function set_material_amount(material_id,amount){
	var length = array_length(global.save_data.inventory)
	//先检查背包中是否有材料
	if have_material(material_id){
		//如果存在，则设置数量
		for(var i = 0 ; i < length ; i++){
			if global.save_data.inventory[i].id == material_id{
				global.save_data.inventory[i].amount = amount
			}
		}
	}
	else{
		//如果不存在，则创建物品
		array_push(global.save_data.inventory,{"id":material_id,"amount":amount})
	}
	save_file(global.save_slot)
}

function get_material_amount(material_id){
	var length = array_length(global.save_data.inventory)
	//先检查背包中是否有材料
	if have_material(material_id){
		//如果存在，则返回数量
		for(var i = 0 ; i < length ; i++){
			if global.save_data.inventory[i].id == material_id{
				return global.save_data.inventory[i].amount	
			}
		}
	}
	else{
		//如果不存在，则返回0
		return 0
	}
}

function have_material(material_id){
	var length = array_length(global.save_data.inventory)
	for(var i = 0 ; i < length ; i++){
		if global.save_data.inventory[i].id == material_id{
			return true
		}
	}
	return false
}