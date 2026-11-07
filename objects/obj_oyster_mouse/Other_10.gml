flash_value = 150
// 醉酒（drunk）：本对象**覆写了父类受伤事件**，父类那段 ×1.5 不会执行 → 必须在这里补一遍，
//   否则测试关（全用测试鼠）/ 木桶鼠 / 牡蛎鼠 对上桂花酒会「醉了却不加伤」。
if (variable_instance_exists(id, "drunk_timer") && drunk_timer > 0 && !is_boss)
{
    damage_amount = damage_amount * (variable_instance_exists(id, "drunk_mult") ? drunk_mult : 1.5);
}

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