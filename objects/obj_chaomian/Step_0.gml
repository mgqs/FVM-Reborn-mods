if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var max_range = (shape < 2) ? 2 : 3;
var has_enemy = false;

with (obj_enemy_parent)
{
    if (grid_row == other.grid_row && grid_col > other.grid_col && grid_col <= (other.grid_col + max_range) && hp > 0 && can_hit(other.target_type, target_type))
        has_enemy = true;
}

var wait_time = cycle - (attack_anim * current_flash_speed);

if (wait_time < 0)
    wait_time = 0;

var attack_duration = attack_anim * current_flash_speed;

if (!variable_instance_exists(id, "attacked"))
    attacked = false;

if (has_enemy)
{
    if (attack_timer < wait_time)
    {
        attack_timer++;
        state = 0;
        attacked = false;
    }
    else if (attack_timer < (wait_time + attack_duration))
    {
        state = 1;
        attack_timer++;
    }
    else
    {
        if (!attacked)
        {
            var rng = (shape < 2) ? 2 : 3;
            
            with (obj_enemy_parent)
            {
                if (grid_row == other.grid_row && grid_col > other.grid_col && grid_col <= (other.grid_col + rng) && hp > 0 && can_hit(other.target_type, target_type))
                {
                    damage_amount = other.atk;
                    damage_type = 0;
                    event_user(0);
                }
            }
            
            attacked = true;
        }
        
        attack_timer = 0;
        state = 0;
        attacked = false;
    }
}
else
{
    attack_timer = 0;
    state = 0;
    attacked = false;
}

