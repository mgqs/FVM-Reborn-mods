flash_value = 150
// 海克斯第二批：出场无敌 / 轻装伏击（未啃咬过不可攻击）/ BOSS 石护盾。
// 返回 0 表示这一下完全无效，必须在这里就 exit，不能让它继续走到 hp -=
if (hex_enabled()) {
	damage_amount = hex_batch2_enemy_damage_take(id, damage_amount, damage_type);
	if (damage_amount <= 0) exit;
}
// 海克斯：暴击 / 对空中目标 / 对被减速目标 的额外伤害（非海克斯模式恒 1.0）
if (hex_enabled()) damage_amount = damage_amount * hex_damage_taken_mult();
// 海克斯二期：固定减伤 / ±抖动 / 首击倍率 / 对 BOSS / 对跨服鼠军 / 决斗递增 / 致死保护。
// 必须在上面两步之后、真正扣血之前，否则减伤算不进去
if (hex_enabled()) {
	damage_amount = hex_b3_enemy_damage_pre(id, damage_amount, other);
	if (damage_amount <= 0) exit;
}
// 测试关卡：累计全场所有老鼠承受的伤害（含F4原版敌人和关卡刷怪，不只测试鼠）
if (variable_global_exists("level_id") && global.level_id == "test_level") {
	if (!variable_global_exists("test_damage_total_all")) global.test_damage_total_all = 0;
	global.test_damage_total_all += damage_amount;
}
if shield_hp > 0{
	if damage_type == "normal"{
		shield_hp -= damage_amount
	}
	else if damage_type == "pierce"{
		shield_hp -= damage_amount
		hp -= damage_amount
	}
	else {
		hp -= damage_amount
	}
}
else{
	hp -= damage_amount
}

// 海克斯二期后置：受伤层数（齿轮的烟气）/ 美食吸血（血魔的渴血）/ 命中火焰（重燃的火光）
if (hex_enabled()) {
	hex_b3_enemy_damage_post(id, damage_amount, other);
	if (other != noone && instance_exists(other) && variable_instance_exists(other, "hex_src_inst")) {
		hex_b3_bullet_hit(other, id);
	}
}