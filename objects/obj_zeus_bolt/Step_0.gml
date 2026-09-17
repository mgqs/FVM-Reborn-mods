if (global.is_paused)
    exit;

if (timer < (flash_speed - 1))
{
    timer++;
}
else
{
    switch (state)
    {
        case 0:
            if (image_index < 7)
                image_index++;
            else
                image_index = 0;
            
            break;
        
        case 1:
            if (image_index >= 8 && image_index <= (8 + attack_anim))
                image_index++;
            else
                image_index = 8;
            
            break;
    }
    
    timer = 0;
}

depth = parent_player.depth - 2;
var has_enemy = false;

with (obj_enemy_parent)
{
    if (can_target_on("track", target_type) && hp > 0)
    {
        has_enemy = true;
        break;
    }
}

if (has_enemy)
{
    attack_timer++;
    
    if (attack_timer > (cycle - (attack_anim * flash_speed)))
    {
        state = 1;
        
        if (fire_count < bullet_amount)
        {
            if (fire_cd <= 0)
            {
                event_user(11);
                fire_count++;
                fire_cd = 4;
            }
            else
            {
                fire_cd--;
            }
        }
    }
    
    if (attack_timer > cycle)
    {
        attack_timer = 0;
        state = 0;
        fire_count = 0;
        fire_cd = 0;
    }
}
else
{
    attack_timer = 0;
    state = 0;
    fire_count = 0;
    fire_cd = 0;
}

