
// alarm[0]事件 - 实际攻击执行
// 摧毁范围内敌人
var _x = x;
var _y = y;
var _range = 120;
if shape == 1{
	_range = 200
}
else if shape == 2{
	_range = 400
}
if !global.is_paused{
	with (obj_enemy_parent) {
		if (can_hit(other.target_type,target_type) && point_distance(x, y, _x, _y) < _range && grid_row == other.grid_row) {
		    if (immune_to_ash) {
		        // 对免疫灰烬的敌人只造成伤害
		        hp -= other.atk;
				event_user(0)
		        // 受伤效果
		        //effect_create_above(effect_smoke, x, y, 1, c_gray);
		    } else {
		        // 直接摧毁非免疫敌人
		        instance_destroy();
		        // 摧毁效果
		        //effect_create_above(ef_explosion, x, y, 1, c_yellow);
		    }
		}
	}

	// 播放倭瓜攻击效果
	//effect_create_above(ef_explosion, x, y, 2, c_white);

	// 播放攻击声音
	audio_play_sound(snd_flour_sack, 0, false);
}
else{
	alarm[0] = 1
}

// 摧毁自己
alarm[1] = 41
chspeed = 0
cvspeed = 0
	
