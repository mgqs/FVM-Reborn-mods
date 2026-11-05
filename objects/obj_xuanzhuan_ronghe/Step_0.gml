// obj_xuanzhuan_ronghe（融合旋转咖啡喷壶）Step 事件
// ① 索敌（范围内有可打敌人才开始计时）② 到点喷发 → 结算 ③ 帧推进；死亡走父对象
if global.is_paused{
	exit
}
event_inherited();

// 2 转：不会沉睡（玛丽 / 催眠类效果对它无效）—— 被设成 SLEEP 就当场拉回 IDLE
if (shape >= 2 && state == CARD_STATE.SLEEP){
	state = CARD_STATE.IDLE;
	idle_t = 0;
}

if is_frozen{
	exit
}

// ---------- ① 索敌：范围内有没有能打的 ----------
var _has = false;
var _n = instance_number(obj_enemy_parent);
for (var _i = 0; _i < _n; _i++){
	var _e = instance_find(obj_enemy_parent, _i);
	if (!instance_exists(_e) || _e.hp <= 0) continue;
	if (abs(_e.grid_col - grid_col) > range_cols) continue;
	if (abs(_e.grid_row - grid_row) > range_rows) continue;
	if (!can_hit(target_type, _e.target_type)) continue;
	_has = true;
	break;
}

// ---------- ② 计时 + 到点喷发（转两圈，在 22 / 32 帧各结算一次，总伤 = atk）----------
if (_has){
	atk_timer++;
	if (atk_timer >= atk_interval){
		atk_timer = 0;
		atk_t = 0;                      // 开播喷发（正在喷就从头再播）
		hit_idx = 0;                    // 本轮还没结算
	}
}
else{
	atk_timer = 0;
	hit_idx = 0;
}

// 动画播到「喷满一圈」那一帧就整体结算一次（同狮子座：固定帧结算，不按扩散逐格）
var _hit_now = false;
if (atk_t >= 0 && hit_idx < array_length(HIT_FRAMES)){
	var _af = floor(atk_t / atk_flash_speed);       // 当前播到喷发段第几帧（0 基）
	if (_af >= HIT_FRAMES[hit_idx]){
		hit_idx++;
		_hit_now = true;
	}
}

if (_hit_now){
	// 每圈一半：奇数攻击力时第一圈 floor、第二圈补差，两圈合计正好 = atk
	var _half = floor(atk / 2);
	damage_value = (hit_idx >= 2) ? (atk - _half) : _half;
	var _n2 = instance_number(obj_enemy_parent);
	for (var _j = 0; _j < _n2; _j++){
		var _t = instance_find(obj_enemy_parent, _j);
		if (!instance_exists(_t) || _t.hp <= 0) continue;
		if (abs(_t.grid_col - grid_col) > range_cols) continue;
		if (abs(_t.grid_row - grid_row) > range_rows) continue;
		if (!can_hit(target_type, _t.target_type)) continue;

		with (_t){
			damage_amount = other.damage_value;
			damage_type = "true";
			damage_source_object = other.object_index;
			event_user(0);          // 走敌人自己的受伤流程（护盾 / 减伤 / 测试关统计都在这条路上）

			// 1 转起：减速 1.5 秒（命中的每只都挂，重复命中刷新时长；BOSS 也吃）
			if (other.use_ice){
				if (ice_timer < other.slow_frames) ice_timer = other.slow_frames;
			}

			// 击杀表现：**0 转什么都不加**（走敌人自己的死亡动画），1 转起才换碎冰
			if (hp <= 0 && other.use_ice){
				var _ash = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
				_ash.sprite_index = spr_mouse_ice_death;
				instance_destroy();
			}
		}
	}
}

// ---------- ③ 帧推进（喷发优先，播完回待机）----------
if (atk_t >= 0){
	var _idx = SEG_ATK_FIRST + floor(atk_t / atk_flash_speed);
	if (_idx > SEG_ATK_FIRST + SEG_ATK_LEN - 1){
		atk_t = -1;
		idle_t = 0;
	}
	else{
		image_index = _idx;
		atk_t++;
	}
}

if (atk_t < 0){
	idle_t++;
	image_index = floor(idle_t / flash_speed) mod SEG_IDLE_LEN;
}
