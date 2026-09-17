if (global.is_paused)
    exit;

var pos = get_world_position_from_grid(grid_row, grid_col);
x = pos.x;
y = pos.y;

if (timer < (flash_speed - 1))
{
    timer++;
}
else
{
    switch (state)
    {
        case 0:
            if (image_index < (idle_anim - 1))
                image_index++;
            else
                image_index = 0;
            
            break;
        
        case 1:
            var attack_start = idle_anim;
            var attack_end = (idle_anim + attack_anim) - 1;
            
            if (image_index < attack_start || image_index > attack_end)
                image_index = attack_start;
            else if (image_index < attack_end)
                image_index++;
            else
                image_index = attack_start;
            
            break;
    }
    
    timer = 0;
}

depth = -500;

if (cooldown > 0)
    cooldown--;

if (!is_attacking && cooldown <= 0)
{
    var target_enemy = -4;
    
    with (obj_enemy_parent)
    {
        if (hp > 0)
        {
            target_enemy = id;
            break;
        }
    }
    
    if (target_enemy != -4)
    {
        is_attacking = true;
        attack_timer = 0;
    }
}

if (is_attacking)
{
    state = 1;
    attack_timer++;
    var t = attack_timer;
    var start_t = 32;
    var interval = 10;
    
    for (var i = 0; i < bullet_amount; i++)
    {
        if (t == (start_t + (i * interval)))
            event_user(11);
    }
    
    if (attack_timer >= (attack_anim * flash_speed))
    {
        is_attacking = false;
        attack_timer = 0;
        cooldown = cycle;
    }
}
else
{
    state = 0;
}

