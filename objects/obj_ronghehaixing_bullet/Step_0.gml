if global.is_paused{
	image_speed = 0
	exit
}

// Fusion starfish projectiles use only the first sprite frame.
image_speed = 0
image_index = 0

// 错帧连发：延时期间不出现、不移动、不判定（初级融合「向后子弹+1」的第二发滞后飞出）
if (delay > 0) {
	delay--
	visible = false
	exit
}
visible = true

// 追踪模式（终转边界反弹后）
if (has_bounced_wall) {
	if (instance_exists(target_id) && target_id.hp > 0) {
		var _aim_h = 37;
		var _dx = target_id.x - x;
		var _dy = (target_id.y - _aim_h) - y;
		var _len = point_distance(0, 0, _dx, _dy);
		if (_len > 0) {
			move_speed = (_dx / _len) * bullet_speed;
			y_move_speed = (_dy / _len) * bullet_speed;
		}
		image_angle = point_direction(0, 0, move_speed, y_move_speed);
	} else {
		// 目标丢失，重新寻找最近敌人
		target_id = noone;
		var _best = 1000000000;
		for (var _t = 0; _t < array_length(hittable_types); _t++) {
			var _key = hittable_types[_t];
			if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
			var _list = global.enemy_by_type[$ _key];
			for (var _i = 0; _i < array_length(_list); _i++) {
				var _e = _list[_i];
				if (instance_exists(_e) && _e.hp > 0) {
					var _d = point_distance(x, y, _e.x, _e.y);
					if (_d < _best) {
						target_id = _e;
						_best = _d;
					}
				}
			}
		}
	}
}

x += move_speed
y += y_move_speed

// 命中判定：接全局索敌管线（obj_battle/Step_2 每帧建好 enemy_sx 扫掠索引 + enemy_col_n）
//   ★ 旧写法每帧、每颗子弹都裸扫 global.enemy_by_type 全表 —— 与 obj_youyu_god_bullet 属同一类热路径：
//     五方向齐射 + 反弹/追踪弹，同场子弹数量多，逐颗 × 逐个敌人跑 precise_bbox_collision 开销很重
//   现改为「只处理与子弹 x 轴扫掠窗口相交的少量候选 + 按 global.bullet_hit_interval 隔帧判定」；
//   bullet_sap_type_list 内部按代缓存，同一帧多颗子弹共享同一份索引
//   安全性：子弹最快 8px/帧、判定步长 global.bullet_hit_interval(2) = 16px，
//          远小于「子弹 + 鼠」的合体碰撞宽度，不会跳过命中
hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
    hit_tick = 0;

    if (variable_global_exists("enemy_by_type") && bullet_enemy_reachable(id))
    {
        for (var _t = 0; _t < array_length(hittable_types); _t++)
        {
            var _key = hittable_types[_t];
            if (!variable_struct_exists(global.enemy_by_type, _key)) continue;

            var _list = bullet_sap_type_list(id, _key);
            for (var _i = 0; _i < array_length(_list); _i++)
            {
                var _e = _list[_i];
                if (!instance_exists(_e)) continue;
                if (_e.hp <= 0) continue;
                // 直线弹只在同一行命中；一旦撞过上下边框切为追踪模式，则解除行限制
                if (!(has_bounced_wall || b_type == 0 || (b_type == 1 && row == _e.grid_row))) continue;
                if (!precise_bbox_collision(id, _e)) continue;

                // 命中格先记下来：下面可能把这只鼠打死、实例就没了
                var _hrow = _e.grid_row;
                var _hcol = _e.grid_col;
                var _hid  = _e.id;

                with (_e)
                {
                    audio_play_sound(hit_sound,0,0)
                    damage_amount = other.damage
                    damage_type = other.damage_type
                    event_user(0)
                }

                // 深度融合（1 转起）：单格溅射 —— 对命中格内其余老鼠再造成「攻击力 × 深度溅射伤害比例」
                if (splash_ratio > 0)
                {
                    with (obj_enemy_parent)
                    {
                        if (hp > 0 && id != _hid && grid_row == _hrow && grid_col == _hcol
                            && can_hit(other.target_type, target_type))
                        {
                            damage_amount = other.damage * other.splash_ratio;
                            damage_type = other.damage_type;
                            event_user(0);
                        }
                    }
                }

                // The projectile has no follow-up animation; consume it on hit.
                instance_destroy()
                exit
            }
        }
    }
}

// ===== 边界 =====
// 地图（grid_cols × grid_rows 的那张整屏战斗区）的内边缘
var _gl = global.grid_offset_x
var _gr = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x
var _gt = global.grid_offset_y
var _gb = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y

// 2 转（王冠海星刺身）：只有「前方斜向」的 2 发（右上 / 右下）碰到地图内边缘时才转追踪
if (shape >= 2 && dir_index >= 3 && !has_bounced_wall) {
	var _hit_wall = false
	if (x >= _gr)      { x = _gr - 1; move_speed = -abs(move_speed);      _hit_wall = true }
	else if (x <= _gl) { x = _gl + 1; move_speed =  abs(move_speed);      _hit_wall = true }
	if (y >= _gb)      { y = _gb - 1; y_move_speed = -abs(y_move_speed); _hit_wall = true }
	else if (y <= _gt) { y = _gt + 1; y_move_speed =  abs(y_move_speed); _hit_wall = true }

	if (_hit_wall) {
		has_bounced_wall = true
		bullet_speed = sqrt(move_speed*move_speed + y_move_speed*y_move_speed)
		if (bullet_speed == 0) bullet_speed = 8
		image_angle = point_direction(0, 0, move_speed, y_move_speed)
		// 寻找最近敌人作为追踪目标
		target_id = noone
		var _best = 1000000000
		for (var _t = 0; _t < array_length(hittable_types); _t++) {
			var _key = hittable_types[_t];
			if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
			var _list = global.enemy_by_type[$ _key];
			for (var _i = 0; _i < array_length(_list); _i++) {
				var _e = _list[_i];
				if (instance_exists(_e) && _e.hp > 0) {
					var _d = point_distance(x, y, _e.x, _e.y);
					if (_d < _best) {
						target_id = _e;
						_best = _d;
					}
				}
			}
		}
	}
}

// 飞出场外就没怪可打，直接销毁（原先要飞到 2200/1200/-200/0，白飞一两秒）
//   销毁线在地图边缘外再放一格 —— 出弹口本身就在卡外（上方向是 y−95），
//   严格贴边的话「最上行」那颗上向弹一出生就被删；放一格后能飞出去一小段
//   左边界更宽（放宽到「老鼠判输线」），因为老鼠能一路走到那儿
//   已转追踪的子弹（has_bounced_wall）不在此列，交给下面兜底
var _pad_x = global.grid_cell_size_x
var _pad_y = global.grid_cell_size_y
if (!has_bounced_wall && (x < global.grid_offset_x - 150 || x > _gr + _pad_x
    || y < _gt - _pad_y || y > _gb + _pad_y)) {
	instance_destroy()
	exit
}

// 兜底：飞出很远还没处理掉就销毁
if (x > 2200 or y > 1200 or x < 0 or y < -200) {
	instance_destroy()
}
