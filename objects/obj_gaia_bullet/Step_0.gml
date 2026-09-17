if (global.is_paused)
    exit;

if (state == "start")
{
    y -= 20;
    
    if (y <= -200)
    {
        x = target_x;
        y = target_y - room_height;
        state = "drop";
    }
}

if (state == "drop")
{
    if (shape_bullet == 3)
        y += 30;
    else
        y += 20;
    
    if (y >= (target_y - 10))
    {
        var effect_inst = instance_create_depth(x + 15, y - 15, depth, obj_gaia_bullet_effect);
        
        if (shape_bullet == 0)
            effect_inst.sprite_index = spr_gaia_bullet_effect;
        else if (shape_bullet == 1)
            effect_inst.sprite_index = spr_gaia_bullet_effect_1;
        else if (shape_bullet == 2)
            effect_inst.sprite_index = spr_gaia_bullet_effect_2;
        else
            effect_inst.sprite_index = spr_gaia_bullet_effect_3;
        
        instance_destroy();
    }
}
