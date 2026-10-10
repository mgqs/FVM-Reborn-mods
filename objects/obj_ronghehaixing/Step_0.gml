if global.is_paused{
	exit
}
event_inherited();

if is_frozen || state == CARD_STATE.SLEEP{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

// ===== 索敌：三级判定（口径与 Other_11 的齐射表同源）=====
//   弹口 / 方向 = Other_11 的 _dir_x / _dir_y 表；射程 2200
//   ★ 海星本身没有「正右方」的弹道（只有 后180° / 上-90° / 下90° / 右上 / 右下），
//     旧写法「同行任意列 或 自身右侧任意行」会把打不到的敌人也算进来 → 空放；
//     但子弹可被反弹，反弹后会有往前飞的，所以索敌另加一条「前方」射线（见下）。
//   ① 类型筛：直接取「这张卡能打的敌人类型表」，不再逐敌人调 can_target_on
//   ② 粗筛（廉价且保守，绝不漏判）：射程平方 + 格子比例带
//   ③ 精确：射线 × 敌人碰撞框的 slab 相交（先做圆近似粗挡）
//   ★ 性能：方向单位向量改成预置常量；旧写法每帧要 array_create ×2 + point_distance + 除法 ×5
//   方向 0~4 = Other_11 的齐射表；第 5 条「前方」是额外加的 ——
//   海星子弹可被水神 / 樱桃布丁反弹，反弹后反向的子弹会往前飞，所以前方也要算进索敌路径
var _ox = [-40,   0,   0,  40,  40,  40];
var _oy = [-45, -45, -95, -45, -45, -45];
// 六条弹道的单位向量：后(-1,0) / 下(0,1) / 上(0,-1) / 右上(5,-3)/√34 / 右下(5,3)/√34 / 前(1,0)
var _ux = [-1, 0, 0,  0.8574929, 0.8574929, 1];
var _uy = [ 0, 1, -1, -0.5144958, 0.5144958, 0];
var _dir_n = 6;
var _ray_len = 2200;
var _reach_sq = (_ray_len + 128) * (_ray_len + 128);   // 粗筛半径（出弹点离卡最多约 103px，留足冗余）

var has_enemy = false
if (variable_global_exists("enemy_by_type"))
{
	var _types = get_hittable_enemy_types(target_type);
	var _type_n = array_length(_types);
	for (var _t = 0; _t < _type_n && !has_enemy; _t++)
	{
		var _key = _types[_t];
		if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
		var _list = global.enemy_by_type[$ _key];
		var _ln = array_length(_list);
		for (var _i = 0; _i < _ln && !has_enemy; _i++)
		{
			var _e = _list[_i];
			if (!instance_exists(_e) || _e.hp <= 0) continue;

			// ② a：射程粗筛（比平方，省一次开方）
			var _ddx = _e.x - x;
			var _ddy = _e.y - y;
			if (_ddx * _ddx + _ddy * _ddy > _reach_sq) continue;

			// ② b：格子比例带 —— 同行 / 同列一律放行；斜向要求 |列差| ÷ |行差| ∈ [0.35, 2.6]
			//      （海星斜向是 5:3 ≈ 1.67，带子留了很宽的余量）
			var _drow = _e.grid_row - grid_row;
			var _dcol = _e.grid_col - grid_col;
			if (_drow != 0 && _dcol != 0)
			{
				var _ratio = abs(_dcol) / abs(_drow);
				if (_ratio < 0.35 || _ratio > 2.6) continue;
			}

			// ③ 精确：射线 × 碰撞框
			var _bl = _e.bbox_left;
			var _br = _e.bbox_right;
			var _bt = _e.bbox_top;
			var _bb = _e.bbox_bottom;
			if (_br <= _bl || _bb <= _bt)
			{
				// 碰撞框退化时用合成框兜底
				_bl = _e.x - 30; _br = _e.x + 30; _bt = _e.y - 80; _bb = _e.y;
			}
			var _ecx = (_bl + _br) * 0.5;
			var _ecy = (_bt + _bb) * 0.5;
			// 半径取「半宽 + 半高」—— 恒 ≥ 半对角，圆一定包住碰撞框，粗挡绝不漏判
			var _rad = ((_br - _bl) + (_bb - _bt)) * 0.5;

			for (var _r = 0; _r < _dir_n; _r++)
			{
				var _mx = x + _ox[_r];
				var _my = y + _oy[_r];
				var _uxr = _ux[_r];
				var _uyr = _uy[_r];

				// 圆近似粗挡（保守放宽）
				var _vx = _ecx - _mx;
				var _vy = _ecy - _my;
				var _proj = _vx * _uxr + _vy * _uyr;
				if (_proj < -_rad || _proj > _ray_len + _rad) continue;
				if (abs(_vx * _uyr - _vy * _uxr) > _rad) continue;

				// slab 精确相交
				var _t_in = 0;
				var _t_out = _ray_len;
				var _hit = true;

				if (abs(_uxr) < 0.00001)
				{
					if (_mx < _bl || _mx > _br) _hit = false;
				}
				else
				{
					var _tx1 = (_bl - _mx) / _uxr;
					var _tx2 = (_br - _mx) / _uxr;
					_t_in = max(_t_in, min(_tx1, _tx2));
					_t_out = min(_t_out, max(_tx1, _tx2));
				}
				if (_hit)
				{
					if (abs(_uyr) < 0.00001)
					{
						if (_my < _bt || _my > _bb) _hit = false;
					}
					else
					{
						var _ty1 = (_bt - _my) / _uyr;
						var _ty2 = (_bb - _my) / _uyr;
						_t_in = max(_t_in, min(_ty1, _ty2));
						_t_out = min(_t_out, max(_ty1, _ty2));
					}
				}
				if (_hit && _t_in <= _t_out)
				{
					has_enemy = true;
					break;
				}
			}
		}
	}
}

//攻击逻辑
if (has_enemy) {
    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    } else if (attack_timer <= cycle) {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    } else {
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }

	// 每轮攻击开始时把动画拉回攻击段起点：cycle 随星级变化（48~78），
	// 单纯按 attack_anim 划段会和攻击轮次错开，导致发射帧每轮漂移
	if attack_timer == 1 {
		image_index = idle_anim + 1;
		fired_this_attack = false;
	}

	// 发射：绑在攻击动画第 24 帧（image_index 23），一次攻击只发射一次
	if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= 23) {
		fired_this_attack = true;
		event_user(1);
		audio_play_sound(snd_shot,0,0);
	}
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    fired_this_attack = false;
    state = CARD_STATE.IDLE;
}
