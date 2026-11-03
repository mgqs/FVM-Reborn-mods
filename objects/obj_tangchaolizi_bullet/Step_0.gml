// obj_tangchaolizi_bullet（滚烫栗子）Step 事件
if (global.is_paused) exit;

t++;

// 飞行段只循环 0~7（爆开 / 火焰帧留给落地特效）
image_index = (t div 3) mod (fly_end + 1);

var _p = min(1, t / T);
x = lerp(sx, tx, _p);
y = lerp(sy, ty, _p) - arc * 4 * _p * (1 - _p);

if (t < T)
{
	// 飞行中撞到老鼠 → 当场在它**当下所在格**炸开（照生煎锅：提前量只是大致瞄准，
	//   老鼠中途变向 / 被击退 / 加速时仍会错格，撞上就炸才跟得住）。
	//   命中格直接改写成落点，走下面同一段落地流程（纵向同样上抬 36 贴图格线，同 Other_11 的 _art_up）。
	var _hx = undefined;
	var _hy = undefined;
	with (obj_enemy_parent)
	{
		if (hp > 0 && grid_row == other.row && can_target_on(other.target_type, target_type)
			&& precise_bbox_collision(other.id, id))
		{
			_hx = x;
			_hy = y;
		}
	}
	if (is_undefined(_hx)) exit;

	var _hit_cell = get_grid_position_from_world(_hx, _hy);
	tx  = _hit_cell.x;
	ty  = _hit_cell.y - 36;
	col = _hit_cell.col;
}

// ===== 落地：生成灼烧特效（同一张精灵，从爆开帧开始播）=====
x = tx;
y = ty;

// 火焰贴地：depth = -10 - row*45（比老鼠靠后一层，不会挡住老鼠 —— 同 8周年蛋糕的火格）
// 纵向位置直接落在 ty 上（ty 在 Other_11 里已经按「地图贴图格线」抬过 36，别在这里再抬）
var _e = instance_create_depth(tx, ty, -10 - row * 45, obj_tangchaolizi_bullet_effect);
_e.sprite_index = sprite_index;
_e.shape = shape;
_e.damage = damage;
_e.damage_corner = damage_corner;
_e.grid_row = row;
_e.grid_col = col;

instance_destroy();
