if (global.is_paused)
    exit;

event_inherited();
var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;

has_enemy = combat_enemy_in_rows(id, grid_row - 1, grid_row + 1, grid_col, global.grid_cols + 1, target_type);

if (has_enemy)
{
    if (attack_timer <= (cycle - (attack_anim * current_flash_speed)))
    {
        attack_timer++;
    }
    else if (attack_timer <= cycle)
    {
        if (attack_timer == (cycle - 20))
        {
            fire_mid = true;
            fire_up = true;
            fire_down = true;
            event_user(1);
        }
        
        if (attack_timer == (cycle - 15))
        {
            fire_mid = true;
            fire_up = true;
            fire_down = true;
            event_user(1);
        }
        
        if (attack_timer == (cycle - 10))
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
        
        if (attack_timer == (cycle - 5) && shape == 3)
        {
            fire_mid = true;
            fire_up = true;
            fire_down = true;
            event_user(1);
        }
        
        attack_timer++;
        state = 1;
    }
    else
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

