flash_value = 150
// 测试关卡：累计全场所有老鼠承受的伤害（本对象覆写了父类受伤事件，需在此单独累计）
if (variable_global_exists("level_id") && global.level_id == "test_level") {
	if (!variable_global_exists("test_damage_total_all")) global.test_damage_total_all = 0;
	global.test_damage_total_all += damage_amount;
}
if damage_type != "throw"{
	hp -= 0.1*damage_amount
}
else{
	hp -= damage_amount
}