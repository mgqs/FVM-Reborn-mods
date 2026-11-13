if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;

has_enemy = combat_enemy_in_rows(id, grid_row - 1, grid_row + 1, grid_col, global.grid_cols + 1, target_type);

if (has_enemy)
{
    attack_timer++;
    
    if (attack_timer == (cycle - (7 * flash_speed)) && shape == 3 && super_bullet >= 4)
    {
        event_user(13);
        super_bullet = 0;
        state = 1;
    }
    
    if (attack_timer == (cycle - (5 * flash_speed)))
    {
        fire_mid = true;
        fire_up = true;
        fire_down = true;
        event_user(1);
        state = 1;
        super_bullet++;
    }
    
    if (attack_timer == (cycle - (3 * flash_speed)))
    {
        fire_mid = true;
        fire_up = true;
        fire_down = true;
        event_user(1);
    }
    
    if (attack_timer == (cycle - (1 * flash_speed)))
    {
        switch (shape)
        {
            case 0:
                fire_up = false;
                fire_mid = false;
                fire_down = false;
                break;
            
            case 1:
                fire_up = false;
                fire_mid = true;
                fire_down = false;
                break;
            
            case 2:
                fire_up = true;
                fire_mid = true;
                fire_down = true;
                break;
            
            case 3:
                fire_up = true;
                fire_mid = true;
                fire_down = true;
                break;
        }
        
        event_user(1);
    }
    
    if (attack_timer > cycle)
    {
        attack_timer = 0;
        state = 0;
    }
}
else
{
    attack_timer = 0;
    state = 0;
}

