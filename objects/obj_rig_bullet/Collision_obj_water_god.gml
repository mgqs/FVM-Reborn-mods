if (!bounced)
{
    move_speed_x *= -1;
    damage += other.atk;
    image_angle += 180;
    bounced = true;
}
