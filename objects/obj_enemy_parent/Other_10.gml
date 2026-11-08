flash_value = 150
// 海克斯第二批：出场无敌 / 轻装伏击（未啃咬过不可攻击）/ BOSS 石护盾。
// 返回 0 表示这一下完全无效，必须在这里就 exit，不能让它继续走到 hp -=
if (hex_enabled()) {
	damage_amount = hex_batch2_enemy_damage_take(id, damage_amount, damage_type);
	if (damage_amount <= 0) exit;
}
// 海克斯：暴击 / 对空中目标 / 对被减速目标 的额外伤害（非海克斯模式恒 1.0）
if (hex_enabled()) damage_amount = damage_amount * hex_damage_taken_mult();
// 醉酒（drunk）：贝利尔/烈酒类敌人喝醉期间受击放大（pr-29 新增）
if (variable_instance_exists(id, "drunk_timer") && drunk_timer > 0 && !is_boss)
{
    damage_amount = damage_amount * (variable_instance_exists(id, "drunk_mult") ? drunk_mult : 1.5);
}
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
var _hp_before_dmg = hp;
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
var _hp_real_lost = max(0, _hp_before_dmg - hp);

// 海克斯二期后置：受伤层数（齿轮的烟气）/ 美食吸血（血魔的渴血）/ 命中火焰（重燃的火光）
if (hex_enabled()) {
	// 血魔的渴血要按「实际掉的血」结算（护盾吃掉的部分不算），
	// 传 damage_amount 会在石护盾/减伤里多给一整份治疗
	hex_b3_enemy_damage_post(id, _hp_real_lost, other);
	// 重燃的火光：来源不一定是 obj_bullet_parent 的子对象（很多卡片有自己的子弹类），
	// 缺字段就先补一份来源标记，再判一次 —— 原来只认父对象子弹，所以很多卡完全不出火。
	// 卡片本体 / 老鼠本体不算「子弹」，别给它们打标记（会污染吸血归属）
	if (other != noone && instance_exists(other)
		&& !object_is_ancestor(other.object_index, obj_card_parent)
		&& !object_is_ancestor(other.object_index, obj_enemy_parent)) {
		if (!variable_instance_exists(other, "hex_src_inst")
			&& variable_instance_exists(other, "damage")) {
			// 只给「带自己的伤害值的飞行物」补来源标记；岩浆 / 特效这类没有 damage 的
			// 不算子弹，否则会顺手吃掉「当头棒喝」的首发名额
			hex_b3_bullet_tag(other, true);
		}
		if (variable_instance_exists(other, "hex_src_inst")) hex_b3_bullet_hit(other, id);
	}
}