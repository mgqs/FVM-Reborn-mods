/// 陆地每步：未触发 → 播放 spr_ludi_idel 待机；触发 → 播 spr_ludi_xiachen，播完销毁
if (global.is_paused) exit;

if (!ludi_triggered) {
	var _flag = false;
	if (ludi_track == 1) _flag = global.longyuan_bridge_red_active;
	else if (ludi_track == 2) _flag = global.longyuan_bridge_yellow_active;
	if (_flag) {
		ludi_triggered = true;
		sprite_index = spr_ludi_xiachen;
		image_index = 0;
	}
	exit;
}

// 下沉动画播完 → 销毁（Destroy 事件负责改地形/清卡/生成 obj_lava）
if (sprite_index == spr_ludi_xiachen && image_index >= sprite_get_number(sprite_index) - 1) {
	instance_destroy();
}
