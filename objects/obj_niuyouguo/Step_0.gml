// obj_niuyouguo（邪恶牛油果）Step 事件
if global.is_paused{
	exit
}
event_inherited();
if is_frozen{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

// 索敌：按**自己的三条弹道**判（2026-10-29 修）
//   出弹口 (x+42, y-58) 与 Other_11 完全一致，0° / ±fan_angle 三条射线，
//   任意一条真能穿到敌人身体才开火（can_hit_segment_bbox：水平外扩 12px、垂直内缩 10px）。
//   原来的写法是「前方有敌人就开火」的角度阈值（|dy| <= |dx|*0.75 + 110，锚点还用了卡片中心），
//   结果：上下相邻行远处的目标也照发（弹道早就飞过头了）、敌人已经越过卡片还朝右空放。
var has_enemy = false
var _ray_len = 1440            // 飞镖 life 160 帧 × move_speed 9 px/帧
with (obj_enemy_parent){
	if (has_enemy) break
	if (hp <= 0) continue
	if (!can_target_on(other.target_type, target_type)) continue
	// 射线起点 = 卡片出弹口（与 Other_11 的 _muzzle_x / _muzzle_y 一致）
	var _sx = other.x + 42
	var _sy = other.y - 58
	// 便宜预筛：已经越过卡片左侧、或明显超出射程的直接跳过
	var _dist_x = x - _sx
	if (_dist_x < -80 || _dist_x > _ray_len + 120) continue
	// 同一行的**地面**敌人：0° 弹道必然扫到（脚底贴本行行底、出弹口在行顶），直接算能打，
	//   避免矮一点的老鼠因为 bbox 差几像素被判成打不到而不开火。空军不套这条（会在 y 上浮动）
	if (grid_row == other.grid_row && target_type != "air"){
		has_enemy = true
		break
	}
	// 三条弹道任一条穿到身体才算能打：
	//   pad_x 12 容忍横向移动/擦边；shrink_y 10 避免水平弹道擦着上下相邻行敌人的脚底被误判
	var _ex0 = _sx + _ray_len
	var _ey0 = _sy
	var _ex1 = _sx + lengthdir_x(_ray_len, -other.fan_angle)
	var _ey1 = _sy + lengthdir_y(_ray_len, -other.fan_angle)
	var _ex2 = _sx + lengthdir_x(_ray_len,  other.fan_angle)
	var _ey2 = _sy + lengthdir_y(_ray_len,  other.fan_angle)
	if (can_hit_segment_bbox(_sx, _sy, _ex0, _ey0, id, 12, 10)
	 || can_hit_segment_bbox(_sx, _sy, _ex1, _ey1, id, 12, 10)
	 || can_hit_segment_bbox(_sx, _sy, _ex2, _ey2, id, 12, 10)){
		has_enemy = true
	}
}

if (has_enemy) {
	attack_timer++;
	// 攻击段总长 = attack_anim * flash_speed 帧
	if (attack_timer >= cycle - attack_anim * current_flash_speed){
		state = CARD_STATE.ATTACK;
	}
	// 开火绑攻击动画第 15 帧（image_index 14，果实刚离手），一次齐射 = 三方向各 1 发
	if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= 14){
		fired_this_attack = true;
		salvo_index = 1;
		salvo_timer = 0;
		event_user(1);
	}
	// 二转：同一轮动画内错 4 帧补发第二组（每方向 2 发）
	if (fired_this_attack && salvo_index < shots_per_side){
		salvo_timer++;
		if (salvo_timer >= 4){
			salvo_timer = 0;
			salvo_index++;
			event_user(1);
		}
	}
	if (attack_timer > cycle){
		attack_timer = 0;
		fired_this_attack = false;
		salvo_index = 0;
		salvo_timer = 0;
		state = CARD_STATE.IDLE;
	}
} else {
	// 没有符合条件的敌人，重置状态
	attack_timer = 0;
	fired_this_attack = false;
	salvo_index = 0;
	salvo_timer = 0;
	state = CARD_STATE.IDLE;
}
