// 樱桃反弹布丁反射：同上（同一行、每颗只反弹一次）
if (!bounced && row == other.grid_row)
{
    move_x *= -1;
    move_y *= -1;
    damage += other.atk;
    image_angle += 180;
    bounced = true;
}
