// obj_ronghehuopen_ice_ctrl Begin Step 事件
// ① 记录本帧冰弹坐标（供 End Step 配对命中特效；命中当帧子弹就被池回收，End Step 取不到）
// ② 冰弹命中 → 减速（与冰冻小笼包一致：ice_timer = 600 = 10 秒）
//    在 Begin Step 判定：此时子弹还没动，压到老鼠的话这一帧它的 Step 就会打中，
//    提前一帧给减速玩家看不出来；放到 Step/End Step 判的话，命中当帧子弹可能已被池回收。
// ③ 记录「本帧可能被冰弹打中」的敌人快照（rec_enemy），End Step 用来判定「直接打死」→ 碎冰特效
// ④ 场上没有冰弹后计时自毁
if (global.is_paused){
	exit
}

// 冰弹标记：子弹自己的 brazier_list 里插了哨兵值 -9999（该列表每颗子弹每条命由 Create 重建，池化复用天然复位）
rec_x = [];
rec_y = [];
rec_enemy = [];
var _ice = [];
with (obj_bullet_parent){
	if (variable_instance_exists(id, "brazier_list") && ds_list_find_index(brazier_list, -9999) != -1){
		array_push(_ice, id);
		array_push(other.rec_x, x);
		array_push(other.rec_y, y);
	}
}

// 场上没有冰弹 → 直接早退，一帧也不扫敌人（旧写法是「每颗冰弹 × 每只敌人」双 bbox 全扫，卡顿主因）
if (array_length(_ice) > 0){
	idle_frames = 0;
	var _probe = kill_probe;
	var _hit = ds_list_create();
	var _near = ds_list_create();
	for (var _i = 0; _i < array_length(_ice); _i++){
		var _b = _ice[_i];
		if (!instance_exists(_b)) continue;
		var _bl = _b.bbox_left;
		var _bt = _b.bbox_top;
		var _br = _b.bbox_right;
		var _bb = _b.bbox_bottom;

		// 减速：严格相交 + 无护盾（沿用原判定）；用引擎空间索引只取附近的敌人
		ds_list_clear(_hit);
		collision_rectangle_list(_bl, _bt, _br, _bb, obj_enemy_parent, false, true, _hit, false);
		for (var _k = 0; _k < ds_list_size(_hit); _k++){
			with (ds_list_find_value(_hit, _k)){
				if (hp > 0 && (!variable_instance_exists(id, "shield_hp") || shield_hp <= 0)){
					ice_timer = max(ice_timer, 600);   // 冰冻小笼包同款减速
				}
			}
		}

		// 击杀快照：往外放宽 kill_probe（子弹这一帧才位移进老鼠，严格相交会漏「第一下就打死」）
		ds_list_clear(_near);
		collision_rectangle_list(_bl - _probe, _bt - _probe, _br + _probe, _bb + _probe, obj_enemy_parent, false, true, _near, false);
		for (var _k = 0; _k < ds_list_size(_near); _k++){
			with (ds_list_find_value(_near, _k)){
				if (hp > 0){
					// 能不能播碎冰：与「灰烬击杀」同口径（防爆鼠等免疫灰烬的不给碎冰，BOSS 跳过）
					var _can_shatter = true;
					if (variable_instance_exists(id, "immune_to_ash") && immune_to_ash) _can_shatter = false;
					if (variable_instance_exists(id, "is_boss") && is_boss) _can_shatter = false;
					array_push(other.rec_enemy, [id, x, y, depth, hp, object_index, image_xscale, image_yscale, _can_shatter]);
				}
			}
		}
	}
	ds_list_destroy(_hit);
	ds_list_destroy(_near);
}

if (array_length(_ice) == 0){
	idle_frames++;
	if (idle_frames > 300) instance_destroy();
}
else{
	idle_frames = 0;
}
