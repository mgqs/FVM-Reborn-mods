// obj_ronghehuopen_ice_ctrl End Step 事件
// ① 锁冰弹贴图 + 尺寸固定（子弹自己的 Step 每帧会把贴图改回火弹，必须在所有 Step 之后再锁一次）
// ② 把「本帧新出现、且就在冰弹附近」的命中特效就地换成冰冻命中特效（obj_icelongbao_bullet_effect）
//    子弹自己命中时播的是各弹种自己的命中特效、卡片/控制器都拿不到命中回调，
//    所以用「本帧新建 + 位置贴近」来认；位置必须用 Begin Step 记录的那一份（rec_x/rec_y）：
//    命中当帧子弹常已被对象池回收，只比「当前存活的冰弹」会漏掉大多数命中（玉米这类子弹命中即销毁）。
if (global.is_paused){
	exit
}

// ① 锁贴图 + 固定尺寸；同时收集当前存活冰弹的位置
var _live_x = [];
var _live_y = [];
with (obj_bullet_parent){
	if (variable_instance_exists(id, "brazier_list") && ds_list_find_index(brazier_list, -9999) != -1){
		sprite_index = spr_ronghehuopen_ice_bullet;
		image_xscale = 1.4;   // 尺寸固定 1.4（不跟随原弹的 1.6 / 1.8 等档位）
		image_yscale = 1.4;
		var _fn = sprite_get_number(spr_ronghehuopen_ice_bullet);
		if (image_index >= _fn) image_index = 0;
		if (_fn > 1 && image_speed <= 0) image_speed = 0.25;   // 单帧素材不需要驱动动画
		array_push(_live_x, x);
		array_push(_live_y, y);
	}
}

// ② 命中特效 → 冰冻特效。这些都是工程里各弹种「命中时才建」的特效对象，Create 里都有 `timer = 0`
//    （对象池复用会重跑 Create，所以 timer ≤ 1 就等于「本帧新建」，不会认到旧特效）
var _fx_objs = [
	obj_fire_bullet_effect,
	obj_war_god_bullet_effect,
	obj_waterpipe_bullet_effect,
	obj_coffeecup_bullet_effect,
	obj_infected_zhanshen_bullet_effect,
	obj_corn_shooter_effect
];
var _convert = [];
for (var _k = 0; _k < array_length(_fx_objs); _k++){
	with (_fx_objs[_k]){
		var _fresh = false;
		if (variable_instance_exists(id, "timer")){
			_fresh = (timer <= 1);
		}
		else{
			_fresh = (image_index <= 0);
		}
		if (_fresh){
			var _is_ours = false;
			// 先比「本帧开始时的冰弹位置」（含命中当帧已被池回收的子弹），再比当前存活的冰弹
			for (var _i = 0; _i < array_length(other.rec_x); _i++){
				if (point_distance(x, y, other.rec_x[_i], other.rec_y[_i]) <= 75){
					_is_ours = true;
					break;
				}
			}
			if (!_is_ours){
				for (var _j = 0; _j < array_length(_live_x); _j++){
					if (point_distance(x, y, _live_x[_j], _live_y[_j]) <= 75){
						_is_ours = true;
						break;
					}
				}
			}
			if (_is_ours) array_push(_convert, id);
		}
	}
}
for (var _t = 0; _t < array_length(_convert); _t++){
	var _fx = _convert[_t];
	if (!instance_exists(_fx)) continue;
	// ⚠️ instance_change() 只作用于「当前实例」，必须 with 指定目标，否则被换成特效的是控制器自己
	with (_fx) instance_change(obj_icelongbao_bullet_effect, true);
}
