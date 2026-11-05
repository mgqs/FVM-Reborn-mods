if (!bounced){
    vx *= -1;
    vy *= -1;
    image_angle += 180;
    damage += other.atk;
    bounced = true;
}
