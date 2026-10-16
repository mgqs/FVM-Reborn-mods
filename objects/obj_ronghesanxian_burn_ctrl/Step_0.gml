// obj_ronghesanxian_burn_ctrl Step：每 1 秒结算 1 次[燃烧伤害]
if global.is_paused{
	exit
}

// 清理：目标消失 / 已死 / 次数用完 → 连挂身火焰一起销毁
for (var _i = array_length(burn_list) - 1; _i >= 0; _i--){
	var _b = burn_list[_i];
	var _tg = _b.target;
	if (!instance_exists(_tg) || _tg.hp <= 0 || _b.ticks <= 0){
		if (instance_exists(_b.fx)) instance_destroy(_b.fx);
		array_delete(burn_list, _i, 1);
	}
}

// 每 1 秒（60 帧）结算 1 次：可叠加 = 多次命中把 ticks 累加上去，每 1 次扣 1 份[燃烧伤害]
tick_timer++;
if (tick_timer >= 60){
	tick_timer = 0;
	for (var _j = 0; _j < array_length(burn_list); _j++){
		var _b2 = burn_list[_j];
		var _tg2 = _b2.target;
		if (!instance_exists(_tg2) || _tg2.hp <= 0) continue;
		with (_tg2){
			damage_amount = _b2.dmg;
			damage_type = "normal";
			event_user(0);
		}
		_b2.ticks -= 1;
	}
}

// 无目标 5 秒后自毁
if (array_length(burn_list) == 0){
	idle_timer++;
	if (idle_timer >= 300) instance_destroy();
}
else{
	idle_timer = 0;
}
