var _spr = (shape == 0) ? spr_ronghehaixing_bullet : ((shape == 1) ? spr_ronghehaixing_bullet_1 : spr_ronghehaixing_bullet_2)

// ===== 五方向齐射 =====
// 方向顺序：0=后(180°) / 1=下(90°) / 2=上(-90°) / 3=右上 / 4=右下
// 每方向 2 发（错帧连发，第二发滞后 3 帧飞出）
// 后路 3 发 —— 初级融合「向后的子弹数量+1」；三档（0/1/2 转）都含此能力，融合为累加关系
// 注意：只有后路是 b_type=1（同行限制）且带 row，其余四向 b_type=0（不限制行）—— 与原实现一致
var _dir_x   = [-40,   0,   0,   40,   40];
var _dir_y   = [-45, -45, -95,  -45,  -45];
var _mvx     = [ -8,   0,   0,    5,    5];
var _mvy     = [  0,   8,  -8,   -3,    3];
var _angle   = [  0,  90, -90, -145,  145];
var _btype   = [  1,   0,   0,    0,    0];
var _shots   = [  3,   2,   2,    2,    2];
// 错帧间隔：子弹 8px/帧，5 帧 = 40px；子弹可见宽约 45px（精灵 30px × image_xscale 1.5）
// 原为 3（=24px，两颗几乎叠在一起）
var _delay_step = 5;

for (var _d = 0; _d < 5; _d++)
{
	for (var _k = 0; _k < _shots[_d]; _k++)
	{
		var _b = instance_create_depth(x + _dir_x[_d], y + _dir_y[_d], depth-500, obj_ronghehaixing_bullet);
		_b.damage = atk;
		_b.move_speed = _mvx[_d];
		_b.y_move_speed = _mvy[_d];
		_b.image_angle = _angle[_d];
		_b.b_type = _btype[_d];
		_b.shape = shape;
		_b.sprite_index = _spr;
		_b.delay = _k * _delay_step;          // 0 / 3 / 6
		_b.dir_index = _d;                    // 0=后 1=下 2=上 3=右上 4=右下（子弹的边界/追踪规则用）
		_b.splash_ratio = (shape >= 1) ? splash_ratio : 0;   // 单格溅射只在 1 转（深度融合）起生效
		if (_btype[_d] == 1) _b.row = grid_row;
	}
}
