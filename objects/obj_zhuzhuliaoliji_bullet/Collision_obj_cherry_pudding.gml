if (!bounced && row == other.grid_row){
    vx *= -1;
    vy *= -1;
    image_angle += 180;
    bullet_rebound_bonus(id, other.atk);
    bounced = true;
}
