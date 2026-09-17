var inst;

if (!hit_enemy)
{
    if (other.hp > 0 && row == other.grid_row && can_hit(target_type, other.target_type))
    {
        audio_play_sound(snd_egg_bullet, 0, 0);
        
        with (other)
        {
            if (other.shape <= 1 || hp > other.damage)
            {
                damage_amount = other.damage;
                damage_type = other.damage_type;
                event_user(0);
            }
            else
            {
                if (special_ash)
                {
                    inst = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    inst.special_ash = true;
                    inst.sprite_index = sprite_index;
                    inst.image_index = image_index;
                }
                else
                {
                    instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                }
                
                instance_destroy();
            }
        }
        
        inst = instance_create_depth(x, y, depth, obj_iceeggboilerpult_bullet_effect);
        
        if (shape == 3)
            inst.sprite_index = spr_ymir_bullet_effect;
        
        if (shape == 2)
            inst.sprite_index = spr_ymir_bullet_effect_1;
        
        if (shape == 1)
            inst.sprite_index = spr_ymir_bullet_effect_2;
        
        if (shape == 0)
            inst.sprite_index = spr_ymir_bullet_effect_3;
        
        hit_enemy = true;
        hitted_enemy = other.id;
        instance_destroy();
    }
}
