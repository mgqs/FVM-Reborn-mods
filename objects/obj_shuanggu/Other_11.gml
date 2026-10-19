// obj_shuanggu（耗油双菇）· 开火：按本次攻击的动画种类决定打哪一路
//   atk_kind 0 = 只有对陆（矮菇） / 1 = 只有对空（高菇） / 2 = 两路齐射
// 每次齐射一路一发；某一组发数用完（1 转的对陆只有 2 发）就不再多打那一组。
var _idx = salvo_index;
var _fire_land = (atk_kind == 0 || atk_kind == 2);
var _fire_air  = (atk_kind == 1 || atk_kind == 2);

// 对陆：矮菇前探，平射，只打陆 / 障碍
if (_fire_land && _idx < shots_land){
	var _b = instance_create_depth(x + 40, y - 48, depth - 500, obj_shuanggu_bullet);
	_b.damage = atk;
	_b.move_speed = 8;
	_b.row = grid_row;
	_b.bullet_shape = shape;
	if shape == 0{
		_b.sprite_index = spr_shuanggu_bullet;
	}
	else if shape == 1{
		_b.sprite_index = spr_shuanggu_bullet_1;
	}
	else{
		_b.sprite_index = spr_shuanggu_bullet_2;
	}
}

// 对空：高菇抬头，直接在「抬升后的高度」平射（没有抬升动画），只打空军
if (_fire_air && _idx < shots_air){
	var _a = instance_create_depth(x + 35, y - 128, depth - 500, obj_shuanggu_bullet_air);
	_a.damage = round(atk * air_atk_ratio);
	_a.move_speed = 8;
	_a.row = grid_row;
	_a.bullet_shape = shape;
	if shape == 0{
		_a.sprite_index = spr_shuanggu_bullet_air;
	}
	else if shape == 1{
		_a.sprite_index = spr_shuanggu_bullet_air_1;
	}
	else{
		_a.sprite_index = spr_shuanggu_bullet_air_2;
	}
}

audio_play_sound(snd_shot, 0, 0);
