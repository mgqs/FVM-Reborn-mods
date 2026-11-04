// obj_mianbao（融合菠萝面包）Step 事件
// ① 被咬产火 ② 1 转 5*5 灼烧 ③ 2 转 4 连发 ④ 受损分档 + 待机/产火帧推进；死亡爆炸在 Destroy_0
if global.is_paused{
	exit
}
event_inherited();
if is_frozen{
	exit
}

// 星级可能在建实例之后才写入，这里每帧按当前档取一次数值（口径见 Create 顶部注释）
//   灼烧 → cycle（攻击间隔表）／子弹 → atk（攻击力表）
var _lv = clamp(current_level, 0, 16);
flame_value   = variable_instance_exists(id, "flame_produce") ? flame_produce : fire_table[_lv];
burn_damage   = (shape >= 1) ? (origin_cycle / 60) : 0;   // ÷60：注册表存的是「伤害 ×60」；origin_cycle 避免减速被 ×2
bullet_damage = (shape >= 2) ? atk : 0;

// 一次遍历同时算两件事：
//   _chewed     = 是否正被老鼠啃咬（产火用）
//   _row_target = 本行前方是否有可打的敌人（4 连发用，口径同直射卡：本行 + 右侧 + 最多到场外 1 列）
var _chewed = false;
var _row_target = false;
var _n = instance_number(obj_enemy_parent);
for (var _i = 0; _i < _n; _i++){
	var _e = instance_find(obj_enemy_parent, _i);
	if (!instance_exists(_e) || _e.hp <= 0) continue;
	if (_e.state == ENEMY_STATE.ATTACK && _e.target_plant == id) _chewed = true;
	if (!_row_target
		&& _e.grid_row == grid_row
		&& _e.grid_col >= grid_col
		&& _e.grid_col <= global.grid_cols + 1
		&& can_target_on(target_type, _e.target_type)) _row_target = true;
	if (_chewed && _row_target) break;
}

// ---------- ① 被咬才产火：咬住期间每满 1 秒 1 朵，打断补 1 朵后停 ----------
if (_chewed){
	chew_timer++;
	if (chew_timer >= 60){
		chew_timer -= 60;
		if (flame_value > 0){
			var _f = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
			_f.value = flame_value;
			// 每产一朵火播一次「产火」动画（正在播就让它播完，别重开 —— 否则永远到不了末尾的冒烟帧）
			//   2 转没有冒烟帧（SEG_FIRE_LEN = 0），产火不播动画，改由开火时的后坐段代替
			if (SEG_FIRE_LEN > 0 && fire_anim_t < 0) fire_anim_t = 0;
		}
	}
}
else if (was_chewed && chew_timer > 0){
	// 啃咬被打断：不足 1 秒那段也按 1 朵给
	if (flame_value > 0){
		var _f2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		_f2.value = flame_value;
		if (SEG_FIRE_LEN > 0 && fire_anim_t < 0) fire_anim_t = 0;
	}
	chew_timer = 0;
}
was_chewed = _chewed;

// ---------- ② 1 转起：每 4.5 秒一次 5*5 灼烧（贴片 2 秒、5 跳，每跳吃表值）----------
if (shape >= 1 && burn_damage > 0){
	burn_timer++;
	if (burn_timer >= burn_interval){
		burn_timer = 0;
		for (var _dr = -2; _dr <= 2; _dr++){
			for (var _dc = -2; _dc <= 2; _dc++){
				var _gc = grid_col + _dc;
				var _gr = grid_row + _dr;
				if (_gc < 0 || _gc >= global.grid_cols || _gr < 0 || _gr >= global.grid_rows) continue;
				// 每格一个 obj_mianbao_burn_fx（照火龙果 obj_burn_effect 的淡入/循环/淡出）
				//   _pos 已经是格子中心；贴图放大 1.8，相邻格互相压住，不露方块接缝
				//   图层：地面（obj_battle，depth 50）→ 火格 40 → 卡片 / 老鼠（负 depth）
				//   所以火格压在卡片下面、地面上面（原来写 depth - 10 会盖住卡片）
				var _pos = get_world_position_from_grid(_gc, _gr);
				var _fx = instance_create_depth(_pos.x, _pos.y, 40, obj_mianbao_burn_fx);
				_fx.grid_col = _gc;
				_fx.grid_row = _gr;
				_fx.damage = burn_damage;
			}
		}
	}
}

// ---------- ③ 2 转起：每 1.5 秒一轮 4 连发，**子弹跟着机枪嘴动出膛** ----------
//   开火段 11 帧（14~24）；嘴动 4 下 = 帧 17/19/21/23，每一下打 1 发
if (shape >= 2 && bullet_damage > 0 && _row_target){
	shot_timer++;
	if (shot_timer >= shot_interval){
		shot_timer = 0;
		shots_left = 4;
		shoot_beat = 0;
		shoot_anim_t = 0;          // 开火：从帧 14 起播
	}
	// 动画走到第几个嘴动帧，就打几发（一帧最多补一发，动画停了也不会漏）
	if (shots_left > 0 && shoot_anim_t >= 0){
		var _beat_frame = floor(shoot_anim_t / shoot_flash_speed);
		if (shoot_beat < array_length(SHOOT_BEATS) && _beat_frame >= SHOOT_BEATS[shoot_beat]){
			var _b = instance_create_depth(x + 40, y - 70, depth - 500, obj_mianbao_bullet);
			_b.damage = bullet_damage;
			_b.move_speed = 8;
			_b.row = grid_row;
			shots_left--;
			shoot_beat++;
		}
	}
}
else if (shape >= 2){
	shot_timer = 0;
	shots_left = 0;
	shoot_beat = 0;
	shoot_anim_t = -1;
}

// ---------- ④ 受损分档 + 帧推进（父对象那套 IDLE/ATTACK 推进不用，这里每帧覆盖 image_index）----------
var _ratio = (max_hp > 0) ? (hp / max_hp) : 1;
var _tier = (_ratio > 0.66) ? 0 : ((_ratio > 0.33) ? 1 : 2);
if (_tier != anim_tier){
	anim_tier = _tier;
	idle_t = 0;
	fire_anim_t = -1;
	shoot_anim_t = -1;
}

// 开火段（只有 2 转，优先级最高：正在打枪就播后坐，播完再回产火 / 待机）
if (shoot_anim_t >= 0){
	var _sidx = SEG_FIRE_FIRST[anim_tier] + floor(shoot_anim_t / shoot_flash_speed);
	if (_sidx > SEG_FIRE_FIRST[anim_tier] + SEG_SHOOT_LEN - 1){
		shoot_anim_t = -1;
	}
	else{
		image_index = _sidx;
		shoot_anim_t++;
	}
}

if (shoot_anim_t < 0 && fire_anim_t >= 0){
	// 产火段：从该档产火首帧顺序播到末帧，播完回待机（fire_anim_t = -1）
	var _idx      = SEG_FIRE_FIRST[anim_tier] + floor(fire_anim_t / fire_flash_speed[shape]);
	var _idx_last = SEG_FIRE_FIRST[anim_tier] + SEG_FIRE_LEN - 1;
	if (_idx > _idx_last){
		fire_anim_t = -1;
		idle_t = 0;
	}
	else{
		image_index = _idx;
		fire_anim_t++;
	}
}

if (shoot_anim_t < 0 && fire_anim_t < 0){
	// 待机段：该档 13 帧里循环 12 帧（第 13 帧与第 1 帧同图）
	idle_t++;
	image_index = SEG_IDLE_FIRST[anim_tier] + (floor(idle_t / flash_speed) mod SEG_IDLE_LEN);
}
