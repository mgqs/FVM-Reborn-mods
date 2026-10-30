// 形态1反伤：被老鼠攻击时，对附近同一行范围内的老鼠造成等量伤害
// 与瓜皮护罩的一转效果保持一致
var _x = x;
var _y = y;
var _range = 250;
with (obj_enemy_parent) {
	if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row - 1 && grid_row <= other.grid_row + 1) {
		hp -= other.bleed_damage;
		event_user(0);
	}
}
