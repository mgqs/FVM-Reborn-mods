// obj_ronghehuopen_ice_ctrl End Step 事件
// ① 锁冰弹贴图 + 尺寸固定（子弹自己的 Step 每帧会把贴图改回火弹，必须在所有 Step 之后再锁一次）
// ② 冰弹「直接打死」→ 换成冰桶二转的碎冰死亡动画（spr_mouse_ice_death）
// ③ 把「本帧新出现、且就在冰弹附近」的命中特效就地换成冰冻命中特效（obj_icelongbao_bullet_effect）
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

// ② 冰弹「直接打死」→ 冰桶二转的碎冰死亡动画（spr_mouse_ice_death）
//    Begin Step 记了「本帧被冰弹压住」的敌人快照，这里看它在本帧是否归零：
//    hp <= 0 且比快照低 = 这一帧被冰弹打死的；有的死法直接 instance_destroy，用快照坐标兜底。
//    做法与 obj_ice_bucket_bomb/Destroy_0 一致：建 obj_mouse_ash_death 换 sprite，
//    再把原老鼠 image_alpha 置 0（否则两套死亡动画会叠在一起）。
//    ⚠️ 快照第 9 位 _can_shatter = 不免疫灰烬且不是 BOSS —— 防爆鼠这类「本来就没有灰烬死亡特效」
//       的怪**不换碎冰**，让它照常播自己的死亡动画。
//    ⚠️ 全程只碰本控制器 + 复用既有对象，没有改任何子弹 / 敌人文件。
//    （命中音暂不动：子弹自己 `burnt == 1` 播的仍是 snd_fire_hit。）
var _kill_pts = [];
for (var _e = array_length(rec_enemy) - 1; _e >= 0; _e--){
	var _rec  = rec_enemy[_e];
	var _eid  = _rec[0];
	var _ex   = _rec[1];
	var _ey   = _rec[2];
	var _ed   = _rec[3];
	var _ehp  = _rec[4];
	var _eobj = _rec[5];
	var _exs  = _rec[6];
	var _eys  = _rec[7];
	var _can_shatter = _rec[8];   // 防爆鼠 / BOSS 在 Begin Step 就判掉了

	var _dead = false;
	if (!instance_exists(_eid)){
		_dead = true;
	}
	else if (_eid.object_index != _eobj){
		// 已经不是那只老鼠了（被回收进对象池换成 obj_pool_holder / id 被别的物体复用）→ 按已消失处理。
		// 敌人池白名单（普通鼠 / 铁锅鼠 / 熊猫鼠 / 巨鼠）死亡后会被 instance_change 成 holder，
		// 只判断 object_index 相等的话这批怪永远拿不到碎冰。
		_dead = true;
	}
	else if (_eid.hp <= 0 && _eid.hp < _ehp){
		_dead = true;
	}

	if (_dead){
		// 同一只老鼠一帧内可能被多颗冰弹压住 → 只播一次；半径用小值（16px），
		// 别用大半径，否则「紧挨着一起死的两只老鼠」会被当成同一只、第二只没特效
		var _dup = false;
		for (var _q = 0; _q < array_length(_kill_pts); _q++){
			if (point_distance(_ex, _ey, _kill_pts[_q][0], _kill_pts[_q][1]) <= 16){
				_dup = true;
				break;
			}
		}
		if (!_dup && _can_shatter){
			array_push(_kill_pts, [_ex, _ey]);
			// 脚底对齐：敌人精灵的脚底在原点上方约 12 个精灵像素 → 按缩放上移，碎冰鼠才不会「沉进地里」
			var _ash_y = _ey - kill_fx_ofs_spr * abs(_eys);
			var _ash = instance_create_depth(_ex, _ash_y, _ed, obj_mouse_ash_death);
			_ash.sprite_index = spr_mouse_ice_death;
			// 🔴 名字含 "ash_death" 的对象一律走对象池（obj_pool_is_poolable），而 obj_pool_acquire
			//    对非敌人白名单**不重置内置显示变量**：上一次这个实例淡出到 alpha≈0 才被回收，
			//    复用后就是全透明 → 现象「老鼠直接没了、碎冰看不见」。这里必须逐个显式复位。
			_ash.image_alpha = 1;
			_ash.image_blend = c_white;
			_ash.image_index = 0;
			_ash.image_speed = 1;
			_ash.image_angle = 0;
			_ash.image_xscale = _exs;   // 跟随敌人的缩放与朝向（敌人翻转时一起翻）
			_ash.image_yscale = _eys;
			_ash.visible = true;
			// 这几个关系到自毁流程，Create 虽会重跑，仍显式再给一次（防止池里带进来的旧状态）
			_ash.timer = 0;
			_ash.life = 90;
			_ash.can_destroy = false;
			_ash.special_ash = false;
			// 原老鼠直接隐掉：它的 Step 会因 image_alpha <= 0 且已 DEAD 而自行销毁（Destroy 里的金币掉落照常）
			if (instance_exists(_eid)) _eid.image_alpha = 0;
		}
	}
	array_delete(rec_enemy, _e, 1);
}

// ③ 命中特效 → 冰冻特效。这些都是工程里各弹种「命中时才建」的特效对象，Create 里都有 `timer = 0`
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
