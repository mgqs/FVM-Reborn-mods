// 樱桃反弹布丁反射（与直射 / 多向同类子弹同口径：同一行、每颗只反弹一次）
// 牛油果飞镖用 travel_dir 定方向（不设 image_angle，靠精灵 6 帧自转），
// 所以「弹回去」= 以竖直面为轴镜像：0° → 180°、+35° → +145°、-35° → -145°，
// 上下的扇形分叉保持原样（不要用 move_speed *= -1，那是原路倒退）。
if (!bounced && row == other.grid_row)
{
	travel_dir = 180 - travel_dir;
	if (travel_dir > 180) travel_dir -= 360;
	if (travel_dir <= -180) travel_dir += 360;
	bullet_rebound_bonus(id, other.atk);
	bounced = true;
}
