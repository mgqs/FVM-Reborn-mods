if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;
y += move_speed;

if (y >= target_y)
{
    if (instance_exists(target_instance))
    {
        with (target_instance)
        {
            audio_play_sound(snd_ice_god, 0, 0);
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
            var inst = instance_create_depth(x, y, depth, obj_ice_god_bullet_effect);
            
            if (ice_timer <= 600)
                ice_timer = 600;
            
            hit_enemy = true;
            hitted_enemy = other.id;
            
            if (other.shape == 3)
                inst.sprite_index = spr_ice_god_bullet_effect_1;
        }
    }
    
    instance_destroy();
}
