// 水神反射（布丁类反弹口径，与直射 / 多向同类子弹一致）：同一行、每颗只反弹一次
// 牛油果飞镖用 travel_dir 定方向（不设 image_angle，精灵 6 帧自转），
// 反弹 = 以竖直面为轴镜像：0° → 180°、+35° → +145°、-35° → -145°，上下扇形分叉保持原样
// （不要用 move_speed *= -1，那是原路倒退）。bounced 与布丁共用，一颗只弹一次。
if (!bounced && row == other.grid_row)
{
	travel_dir = 180 - travel_dir;
	if (travel_dir > 180) travel_dir -= 360;
	if (travel_dir <= -180) travel_dir += 360;
	damage += other.atk;
	bounced = true;
}
