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
var _shield_before_dmg = shield_hp;
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
// 护盾吃掉的部分也算「挨了一下」：带盾敌人挨打时形体没掉血，但玩家需要一个受击反馈，
// 否则石护盾/彩甲类敌人会显得完全没被命中。
var _shield_lost = max(0, _shield_before_dmg - shield_hp);
var _hit_taken = _hp_real_lost;
if (_hit_taken <= 0 && _shield_lost > 0) _hit_taken = 1;

// 受击闪光（2026-11-14 移到这里）：原来这行在事件第一行，任何一次「进入受伤事件」都会
// 重置 150，包括被海克斯无敌/石护盾完全挡掉、damage_amount 归零后 exit 的假命中；而且
// 衰减是每帧 -10，150 需要 15 帧（0.5 秒）才褪完，连续命中时会一直停在最高白度。
// 现在只在「真的掉了血」时才点亮，并按本次伤害量决定强度（上限仍是 150），
// 既保证一下重击有明确反馈，也不会让小喀嚓把大体积敌人刷成常驻白影。
if (_hit_taken > 0) {
	var _flash_gain = max(60, min(150, 60 + _hp_real_lost / max(1, maxhp) * 900));
	flash_value = max(flash_value, _flash_gain);
}

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