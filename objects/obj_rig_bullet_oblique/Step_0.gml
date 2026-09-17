if (global.is_paused)
    exit;

if (bullet_hit)
{
    hit_anim_timer++;
    image_index = 4 + floor(hit_anim_timer / 5);
    
    if (hit_anim_timer >= 15)
    {
        bullet_hit = false;
        hit_anim_timer = 0;
        anim_timer = 0;
    }
}
else
{
    if (anim_timer < 19)
        anim_timer++;
    else
        anim_timer = 0;
    
    image_index = floor(anim_timer / 5);
}

x += move_speed_x;
y += move_speed_y;

if (x > 2200 || y > 1200 || x < 0 || y < 0)
    instance_destroy();
