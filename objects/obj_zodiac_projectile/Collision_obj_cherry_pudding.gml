if ((kind == "fire" || kind == "star") && !bounced)
{
    bounced = true;
    move_x *= -1;
    damage += other.atk;
    image_angle += 180;
}
