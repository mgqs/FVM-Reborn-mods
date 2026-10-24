// obj_rongheshuanggu（融合双菇）· 开火
//   atk_kind 0 = 只有对陆 / 1 = 只有对空 / 2 = 两路齐射
// 每次齐射：对陆 1 发 + 对空 1 发（4 组齐射 → 4+4）
var _idx = salvo_index;
var _fire_land = (atk_kind == 0 || atk_kind == 2);
var _fire_air  = (atk_kind == 1 || atk_kind == 2);

// 对陆：平射；1 转起无限穿透（连障碍一起穿）
if (_fire_land && _idx < shots_land){
	var _b = instance_create_depth(x + 40, y - 48, depth - 500, obj_rongheshuanggu_bullet);
	_b.damage = atk;
	_b.move_speed = 8;
	_b.row = grid_row;
	_b.pierce_all = pierce_land;
	_b.bullet_shape = shape;
	if shape == 0{
		_b.sprite_index = spr_rongheshuanggu_bullet;
	}
	else if shape == 1{
		_b.sprite_index = spr_rongheshuanggu_bullet_1;
	}
	else{
		_b.sprite_index = spr_rongheshuanggu_bullet_2;
	}
}

// 对空：直接出生在空军高度；2 转起全屏追踪
if (_fire_air && _idx < shots_air){
	var _a = instance_create_depth(x + 35, y - 128, depth - 500, obj_rongheshuanggu_bullet_air);
	_a.damage = round(atk * air_atk_ratio);
	_a.move_speed = 8;
	_a.row = grid_row;
	_a.homing = homing_air;
	_a.bullet_shape = shape;
	if shape == 0{
		_a.sprite_index = spr_rongheshuanggu_bullet_air;
	}
	else if shape == 1{
		_a.sprite_index = spr_rongheshuanggu_bullet_air_1;
	}
	else{
		_a.sprite_index = spr_rongheshuanggu_bullet_air_2;
	}
}

audio_play_sound(snd_shot, 0, 0);
