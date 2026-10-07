if (global.is_paused)
{
    image_speed = 0;
    exit;
}
else
{
    image_speed = 1;
}

x += move_speed;
y -= cvspeed;
cvspeed -= cgravity;

if (x > 2200 || y > 1200 || x < -200 || y < -200)
    instance_destroy();

if (has_target)
{
    if (abs(x - target_x) < 5)
    {
        x = target_x;
        y = target_y;
        var inst = instance_create_depth(target_x, target_y - 30, 0, obj_zhurong_bullet_effect);
        inst.damage = damage;
        inst.damage_type = damage_type;
        inst.grid_row = row;
        inst.grid_col = target_col;
        inst.shape = shape;
        
        if (shape == 1)
            inst.sprite_index = spr_zhurong_bullet_effect_1;
        else if (shape == 2)
            inst.sprite_index = spr_zhurong_bullet_effect_2;
        else if (shape == 3)
            inst.sprite_index = spr_zhurong_bullet_effect_3;
        
        instance_destroy();
    }
}
