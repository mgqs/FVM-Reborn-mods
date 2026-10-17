// obj_ronghehuopen_ice_ctrl Begin Step 事件
// ① 记录本帧冰弹坐标（供 End Step 配对命中特效；命中当帧子弹就被池回收，End Step 取不到）
// ② 冰弹命中 → 减速（与冰冻小笼包一致：ice_timer = 600 = 10 秒）
//    在 Begin Step 判定：此时子弹还没动，压到老鼠的话这一帧它的 Step 就会打中，
//    提前一帧给减速玩家看不出来；放到 Step/End Step 判的话，命中当帧子弹可能已被池回收。
// ③ 场上没有冰弹后计时自毁
if (global.is_paused){
	exit
}

// 冰弹标记：子弹自己的 brazier_list 里插了哨兵值 -9999（该列表每颗子弹每条命由 Create 重建，池化复用天然复位）
rec_x = [];
rec_y = [];
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
		if (hp > 0
			&& bbox_left < _br && bbox_right > _bl
			&& bbox_top < _bb && bbox_bottom > _bt
			&& (!variable_instance_exists(id, "shield_hp") || shield_hp <= 0)){
			ice_timer = max(ice_timer, 600);   // 冰冻小笼包同款减速
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
