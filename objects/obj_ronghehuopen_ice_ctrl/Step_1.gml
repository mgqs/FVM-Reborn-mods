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

for (var _i = 0; _i < array_length(_ice); _i++){
	var _b = _ice[_i];
	if (!instance_exists(_b)) continue;
	var _bl = _b.bbox_left;
	var _bt = _b.bbox_top;
	var _br = _b.bbox_right;
	var _bb = _b.bbox_bottom;
	with (obj_enemy_parent){
		if (hp > 0){
			// 减速：严格相交 + 无护盾（沿用原判定，不改手感）
			if ((!variable_instance_exists(id, "shield_hp") || shield_hp <= 0)
				&& bbox_left < _br && bbox_right > _bl
				&& bbox_top < _bb && bbox_bottom > _bt){
				ice_timer = max(ice_timer, 600);   // 冰冻小笼包同款减速
			}

			// 击杀快照：往外放宽 kill_probe（子弹这一帧才位移进老鼠，Begin Step 时可能还差几像素，
			// 用严格相交会漏掉「第一下就打死」这种最常见的情况）。
			// ⚠️ 这里**不看护盾** —— damage_type == "pierce" 时护盾和 hp 同时扣，带盾也能被一击打死，
			//    按护盾过滤会整类漏掉（如捧花僵尸）。
			// 记录本身不会造成误报 —— End Step 还要它这一帧真的掉到 hp <= 0 才算。
			if (bbox_left < _br + other.kill_probe && bbox_right > _bl - other.kill_probe
				&& bbox_top < _bb + other.kill_probe && bbox_bottom > _bt - other.kill_probe){
				// 能不能播碎冰：与工程里「灰烬击杀」同口径（`var can_ash = !immune_to_ash`）——
				// 防爆鼠等免疫灰烬的怪本来就没有灰烬死亡特效，这里也不给它碎冰；BOSS 同样跳过。
				// 必须在 Begin Step 算好一起存：End Step 时这只老鼠可能已经被销毁 / 被池回收，读不到字段。
				var _can_shatter = true;
				if (variable_instance_exists(id, "immune_to_ash") && immune_to_ash) _can_shatter = false;
				if (variable_instance_exists(id, "is_boss") && is_boss) _can_shatter = false;
				// 连 image_yscale / image_xscale 一起记：碎冰鼠要按敌人的缩放和朝向摆，否则大小/朝向对不上
				array_push(other.rec_enemy, [id, x, y, depth, hp, object_index, image_xscale, image_yscale, _can_shatter]);
			}
		}
	}
}

if (array_length(_ice) == 0){
	idle_frames++;
	if (idle_frames > 300) instance_destroy();
}
else{
	idle_frames = 0;
}
