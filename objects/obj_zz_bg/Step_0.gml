zz_msg_t = max(0, zz_msg_t - 1);

// ── 抽奖跑灯 ──
if (zz_state == 1) {
	// ── 跳过动画（与诸神宝殿同口径）：跑灯期间点一下直接出结果 ──
	//   前 6 帧不吃点击 —— 那一下还是「启动抽奖」的点击，否则点完立刻被跳过
	zz_spin_t++;
	if (zz_spin_t > 6 && mouse_check_button_pressed(mb_left)) {
		zz_state = 2;
		zz_light = -1;
		audio_play_sound(snd_win, 0, 0);
		exit;
	}
	zz_light_t++;
	if (zz_light_t >= zz_light_delay) {
		zz_light_t = 0;
		zz_light = (zz_light + 1) mod 18;
		zz_light_left--;
		if (zz_light_left <= 18) zz_light_delay = 7;   // 最后 18 格减速
		if (zz_light_left <= 0) {
			zz_state = 2;
			zz_light = -1;
			audio_play_sound(snd_win, 0, 0);
		}
	}
	exit;
}

// 兑换商店开着时把点击让给商店
if (instance_exists(obj_zz_shop_bg)) exit;
if (!mouse_check_button_pressed(mb_left)) exit;

// ── 结果弹窗 ──
if (zz_state == 2) {
	if (zz_hit(792, 126, 52, 52)) {                      // 关闭
		audio_play_sound(snd_button, 0, 0);
		zz_state = 0;
		exit;
	}
	var _bx = [305, 467, 629];
	for (var _i = 0; _i < 3; _i++) {
		if (zz_hit(_bx[_i], 516, 146, 50)) {             // 再来一次 / 十次 / 五十次
			audio_play_sound(snd_button, 0, 0);
			zz_state = 0;
			zz_start_pull(_i);
			exit;
		}
	}
	exit;
}

// ── 主界面 ──
var _px = [243, 443, 643];
for (var _t = 0; _t < 3; _t++) {
	if (zz_hit(_px[_t], 603 + zz_ui_dy, 190, 61)) {
		audio_play_sound(snd_button, 0, 0);
		zz_start_pull(_t);
		exit;
	}
}

if (zz_hit(631, 332 + zz_ui_dy, 86, 32)) {                          // 兑换商城
	audio_play_sound(snd_button, 0, 0);
	var _shop = instance_create_depth(0, 0, depth - 1, obj_zz_shop_bg);
	_shop.parent_gui = id;
	exit;
}

if (zz_hit(1000, 600 + zz_ui_dy, 55, 55)) {                         // 关闭活动
	audio_play_sound(snd_button, 0, 0);
	instance_destroy();
	exit;
}

if (zz_hit(956, 266 + zz_ui_dy, 116, 56)) {                         // 侧栏：幸运转转
	zz_msg = "当前已在幸运转转";
	zz_msg_t = 70;
	exit;
}

if (zz_hit(956, 332 + zz_ui_dy, 116, 56)) {                         // 侧栏：限时送礼
	zz_msg = "限时送礼暂未开放";
	zz_msg_t = 70;
	exit;
}
