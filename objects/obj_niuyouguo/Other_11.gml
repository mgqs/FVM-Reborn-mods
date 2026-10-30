// 邪恶牛油果 · 开火（event_user(1)）
// 一次齐射 = 向 0°、±35.26° 三个方向各发射 1 发穿透飞镖（三发同源同帧）
// 二转由 Step 在同一轮攻击动画内再调一次本事件（每方向 2 发，共 6 发）
// 出弹口在卡面右侧前方；飞镖自转靠子弹精灵 6 帧循环，不设 image_angle
var _muzzle_x = x + 42;
var _muzzle_y = y - 58;
var _dirs = [0, -fan_angle, fan_angle];

for (var _i = 0; _i < array_length(_dirs); _i++)
{
	var _b = instance_create_depth(_muzzle_x, _muzzle_y, depth - 500, obj_niuyouguo_bullet);
	_b.damage = atk;
	_b.move_speed = 9;
	_b.travel_dir = _dirs[_i];
	_b.slow_timer = slow_timer;
	_b.pierce_all = true;
	_b.target_type = target_type;
	_b.hittable_types = get_hittable_enemy_types(target_type);
	_b.row = grid_row;
}

audio_play_sound(snd_shot, 0, 0);
