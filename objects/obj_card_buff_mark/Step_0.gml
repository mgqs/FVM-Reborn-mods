if (global.is_paused) exit;

// 宿主卡没了就直接收掉，避免留下一堆孤儿标记
if (!instance_exists(mark_owner)) {
	instance_destroy();
	exit;
}

var _o = mark_owner;

// 效果是否还在：以卡片身上的计时字段为唯一依据，计时归零立刻消失
var _alive = false;
if (mark_kind == 0) {
	if (variable_instance_exists(_o, "awake_buff_timer") && _o.awake_buff_timer > 0) _alive = true;
} else {
	if (variable_instance_exists(_o, "zodiac_guard_time") && _o.zodiac_guard_time > 0) _alive = true;
}
if (!_alive) {
	instance_destroy();
	exit;
}

// 跟随宿主（位置与深度都压在卡片上方）
x = _o.x + mark_off_x;
y = _o.y + mark_off_y;
depth = _o.depth - 40;

mark_timer++;
var _n = sprite_get_number(sprite_index);
if (_n <= 0) _n = 1;
image_index = (mark_timer div max(1, mark_rate)) mod _n;

// 轻微呼吸感，避免常驻特效看着像贴图死板
if (mark_pulse > 0) {
	image_alpha = mark_base_alpha + mark_pulse * sin(mark_timer * 0.12);
}
else {
	image_alpha = mark_base_alpha;
}
