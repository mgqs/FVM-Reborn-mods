if ((kind == "fire" || kind == "star") && !bounced)
{
    bounced = true;
    move_x *= -1;
    bullet_rebound_bonus(id, other.atk);
    image_angle += 180;
}
