// 水神反射：把直射弹反弹回相反方向并附加伤害（鱿鱼是八方向弹 → 要同时反 x / y）
//   与玉米射手 / 幽灵神等 33 个子弹对象同一口径：同一行、每颗只反弹一次
if (!bounced && row == other.grid_row)
{
    move_x *= -1;
    move_y *= -1;
    damage += other.atk;
    image_angle += 180;
    bounced = true;
}
