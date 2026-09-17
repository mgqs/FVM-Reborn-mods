if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 0.5;
x += move_speed;
y -= cvspeed;
cvspeed -= cgravity;

if (x > 2200 || y > 1200 || x < -200 || y < -200)
    instance_destroy();

if (cvspeed < 0 && y >= thrower_y)
{
    if (!hit_enemy)
    {
        var inst = instance_create_depth(x, y, depth, obj_iceeggboilerpult_bullet_effect);
        
        if (shape == 3)
            inst.sprite_index = spr_ymir_bullet_effect;
        
        if (shape == 2)
            inst.sprite_index = spr_ymir_bullet_effect_1;
        
        if (shape == 1)
            inst.sprite_index = spr_ymir_bullet_effect_2;
        
        if (shape == 0)
            inst.sprite_index = spr_ymir_bullet_effect_3;
        
        audio_play_sound(snd_egg_bullet, 0, 0);
        instance_destroy();
    }
}
