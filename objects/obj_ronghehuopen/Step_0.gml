// obj_ronghehuopen（融合火盆）Step 事件
// 三段机制：① 过火增幅（全形态）② 啃咬反伤（全形态，咬多少弹多少）③ 寒气（1 转起，单次结算）
if global.is_paused{
	exit
}
event_inherited();
if is_frozen{
	exit
}

// ---------- ① 过火增幅：扫描与本卡碰撞框相交的子弹 ----------
// 与普通火盆完全同口径 —— 只对「工程里可被点燃的子弹」（带 brazier_list 的 36 个对象，见各自
// Collision_obj_brazier）生效，且记账一律用子弹自己的 burnt / brazier_list：
//   普通子弹：burnt 0 → 1，本次点燃并增幅；
//   冰弹    ：burnt < 2 才吃火盆 —— 0 → 1 只是「融化」（贴图变普通子弹、不再减速、不增幅），
//             1 → 2 才真正点燃成火弹并在那一刻增幅 → 冰弹要过两座火盆才会被增幅；
//   2 转（冰属性）：冰弹经过本卡不生效。
// 🔴 绝对不能用「卡片侧记子弹 id 的列表」去重：子弹走对象池复用（obj_pool_acquire 里
//    instance_change + 原实例复用，id 不变），卡片侧记下的旧 id 会把复用后的新子弹永久挡掉
//    （现象：只有头一两发过火成功，之后全部无反应）。子弹自身的 burnt / brazier_list 在池复用
//    跑 Create 时会重置，所以只能用它们。
// 同排判定：普通子弹按行（row），竖排子弹按列（col），与各子弹自己的火盆碰撞写法一致。
// ⚠️ 必须同时判「横竖两轴都压到本卡碰撞框」—— 只判横向的话，col 默认 0 的子弹会在别的行被误点燃。
// 还要尊重子弹自己的「可点燃门禁」（与各自 Collision_obj_brazier 的第一行条件一一对应，缺一个就会
// 让原本点不燃的子弹被点燃）：
//   can_burn ：只有置 true 才可点燃 —— 融合鱿鱼开火时只给中路（0°/180°）置 true（且 1 转起），
//              这就是「斜向子弹不能过火」的工程写法；本卡若不看它，斜向鱿鱼弹也会被点燃
//   kind     ：生肖弹只有 fire / star 两种可点燃（默认 "wave" 不可）
//   disabled ：标了失效的子弹（焦油喷射弹落地后）不可点燃
with (obj_bullet_parent){
	if (variable_instance_exists(id, "brazier_list")){
		var _is_ice = (string_count("ice", object_get_name(object_index)) != 0);
		var _same_line = (variable_instance_exists(id, "row") && row == other.grid_row)
		              || (variable_instance_exists(id, "col") && col == other.grid_col);
		var _overlap = (bbox_left < other.bbox_right && bbox_right > other.bbox_left
		             && bbox_top < other.bbox_bottom && bbox_bottom > other.bbox_top);
		var _gate_ok = true;
		if (variable_instance_exists(id, "can_burn") && !can_burn) _gate_ok = false;
		if (variable_instance_exists(id, "kind") && !(kind == "fire" || kind == "star")) _gate_ok = false;
		if (variable_instance_exists(id, "disabled") && disabled) _gate_ok = false;
		if (_gate_ok
			&& _same_line
			&& _overlap
			&& ds_list_find_index(brazier_list, other.id) == -1
			&& !(other.shape >= 2 && _is_ice)){
			var _touched = false;                  // 本帧是否真的处理了这颗子弹（融化 / 点燃）
			var _ignite = false;
			if (_is_ice){
				if (burnt < 2){
					_touched = true;
					burnt += 1;
					if (burnt == 2) _ignite = true;    // 冰弹要第二座火盆才点燃
				}
			}
			else if (burnt == 0){
				_touched = true;
				burnt += 1;
				_ignite = true;
			}
			if (_touched){
				if (_ignite){
					damage = round(damage * other.atk);
					if (other.shape >= 2){
						// 灵魂融合（2 转）：过火子弹变冰弹 —— 在子弹自己的 brazier_list 里插哨兵值 -9999 作标记
						// （该列表每颗子弹每条命由 Create 重建，池化复用天然复位），贴图锁定 / 命中减速 /
						// 命中特效统一交给独立控制器 obj_ronghehuopen_ice_ctrl（卡片被铲掉也要继续生效）
						ds_list_add(brazier_list, -9999);
						sprite_index = spr_ronghehuopen_ice_bullet;
						image_xscale = 1.4;
						image_yscale = 1.4;
						if (!instance_exists(obj_ronghehuopen_ice_ctrl)){
							instance_create_depth(0, 0, -10000, obj_ronghehuopen_ice_ctrl);
						}
					}
					else{
						// 点燃表现（与原版火盆一致）：点亮后放大一圈
						image_xscale = 1.8;
						image_yscale = 1.8;
					}
				}
				ds_list_add(brazier_list, other.id);
				audio_play_sound(snd_bullet_burnt, 0, 0);
			}
		}
	}
}

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
