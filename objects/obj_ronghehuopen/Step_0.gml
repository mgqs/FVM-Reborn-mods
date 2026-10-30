// obj_ronghehuopen（融合火盆）Step 事件
// 三段机制：① 过火增幅（全形态）② 啃咬反伤（全形态，咬多少弹多少）③ 寒气（1 转起，单次结算）
if global.is_paused{
	exit
}
event_inherited();
if is_frozen{
	exit
}

// ---------- ① 过火增幅：已改到「子弹侧碰撞」（与 obj_brazier / 火神 / 金牛同款）----------
// 每个可过火子弹都有 Collision_obj_ronghehuopen，里面调 scripts/ronghehuopen_pass_fire；
// 卡片这里不再每帧 with(obj_bullet_parent) 扫描 —— 那是「多张火盆 + 一堆子弹」时卡顿的根源。
// 判定口径（普通 / 冰弹两跳 / 2 转冰化）与门禁（can_burn / kind / disabled）全部在脚本里。

// ---------- ② 啃咬反伤：掉多少血，弹给正在啃咬本卡的老鼠多少伤害 ----------
if (hp < current_hp_track){
	var _bleed = current_hp_track - hp;
	with (obj_enemy_parent){
		if (hp > 0 && state == ENEMY_STATE.ATTACK && target_plant == other.id){
			damage_amount = _bleed;
			damage_type = "normal";
			event_user(0);
		}
	}
}
current_hp_track = hp;

// ---------- ③ 寒气（深度融合起）：每[寒气间隔]释放一次，命中即单次结算，减速 4 秒 ----------
// 原设定是「1 秒 1 跳、共 8 跳」，现合并为 1 跳、伤害 ×8 等量替代
if (shape >= 1){
	cold_timer++;
	if (cold_timer >= cold_interval){
		cold_timer = 0;
		// 星级可能在实例创建后才写入，这里按当前星级取一次威力与下一轮间隔
		var _cl = clamp(current_level, 0, 16);
		cold_damage = cold_dmg_table[_cl];
		cold_interval = cold_int_table[_cl];
		// 铺 5*5 寒气柱特效
		for (var _dr = -2; _dr <= 2; _dr++){
			for (var _dc = -2; _dc <= 2; _dc++){
				var _gc = grid_col + _dc;
				var _gr = grid_row + _dr;
				if (_gc < 0 || _gc >= global.grid_cols || _gr < 0 || _gr >= global.grid_rows) continue;
				var _pos = get_world_position_from_grid(_gc, _gr);
				instance_create_depth(_pos.x, _pos.y, depth - 10, obj_ronghehuopen_cold);
			}
		}
		// 单次伤害结算
		with (obj_enemy_parent){
			// 5*5 范围；可打陆地鼠（含幽灵、非主流），不打飞行
			if (hp > 0
				&& grid_row >= other.grid_row - 2 && grid_row <= other.grid_row + 2
				&& grid_col >= other.grid_col - 2 && grid_col <= other.grid_col + 2
				&& (target_type == "normal" || target_type == "dance" || target_type == "underground" || target_type == "invisible")){
				damage_amount = other.cold_damage * 8;   // 8 跳合并为 1 跳
				damage_type = "normal";
				event_user(0);
				ice_timer = max(ice_timer, 240);         // 减速 4 秒（不变）
			}
		}
	}
}
