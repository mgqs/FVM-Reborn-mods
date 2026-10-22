// obj_ronghekafei 开火（event_user(1)）：朝本行前方射出一发咖啡弹
// 出弹口取素材里枪口的位置；精灵按 1.8 倍绘制，下面的偏移已经换算成世界坐标。
global.audio.play(snd_coffee_cup_attack,0,0)
var _ox = 59
var _oy = -25
if shape == 1{
	_ox = 61
	_oy = -31
}
else if shape == 2{
	// 三叠：三个杯子各有一个炮口（上 / 中 / 下），按本轮已发数轮着用
	var _muzzle = [[49, -70], [36, -49], [72, -23]]
	var _i = clamp(fired_shots - 1, 0, 2)
	_ox = _muzzle[_i][0]
	_oy = _muzzle[_i][1]
}
var inst = instance_create_depth(x + _ox, y + _oy, depth - 500, obj_ronghekafei_bullet)
inst.damage = atk
inst.move_speed = 8
inst.row = grid_row
inst.pierce_all = shot_pierce
