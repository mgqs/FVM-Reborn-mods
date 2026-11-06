if (!bounced){
    move_speed *= -1;
    bullet_rebound_bonus(id, other.atk);
    image_angle += 180;
    bounced = true;
}
