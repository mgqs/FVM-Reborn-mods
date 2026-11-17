function material_sell_init(){
	global.material_sell_prices = {}
	global.material_sell_prices[$ "clover_1"] = 2000
	global.material_sell_prices[$ "clover_2"] = 3000
	global.material_sell_prices[$ "clover_3"] = 4000
	global.material_sell_prices[$ "clover_4"] = 10000
	// 金马盛典新增（2026-11-17）：香料 13~16★ / 四叶草 5→SS
	global.material_sell_prices[$ "clover_5"] = 20000
	global.material_sell_prices[$ "clover_6"] = 40000
	global.material_sell_prices[$ "clover_s"] = 80000
	global.material_sell_prices[$ "clover_ss"] = 160000
	global.material_sell_prices[$ "magic_spices"] = 120
	global.material_sell_prices[$ "elf_spices"] = 150
	global.material_sell_prices[$ "angel_spices"] = 190
	global.material_sell_prices[$ "saint_spices"] = 240
	global.material_sell_prices[$ "advanced_crystal"] = 300
	global.material_sell_prices[$ "natural_spices"] = 30
	global.material_sell_prices[$ "secret_spices"] = 60
	global.material_sell_prices[$ "royal_spices"] = 90
	global.material_sell_prices[$ "less_crystal"] = 75
	global.material_sell_prices[$ "middle_crystal"] = 150
	global.material_sell_prices[$ "cross_server_gold_medal"] = 200
	global.material_sell_prices[$ "cross_server_silver_medal"] = 100
}

function get_material_sell_price(material_id){
	if variable_global_exists("material_sell_prices") && variable_struct_exists(global.material_sell_prices, material_id){
		return global.material_sell_prices[$ material_id]
	}
	return 0
}
