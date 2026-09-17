if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == 4)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

if (cooldown > 0)
{
    cooldown--;
    state = 0;
    exit;
}

target_list = [];
var max_t = max_targets;
var best = array_create(max_t, -4);
var best_x = array_create(max_t, 999999);
var has_enemy = false;

with (obj_enemy_parent)
{
    if (can_target_on(other.target_type, target_type))
    {
        has_enemy = true;
        var ex = x;
        
        for (var i = 0; i < max_t; i++)
        {
            if (ex < best_x[i])
            {
                var j = max_t - 1;
                
                while (j > i)
                {
                    best_x[j] = best_x[j - 1];
                    best[j] = best[j - 1];
                    j--;
                }
                
                best_x[i] = ex;
                best[i] = id;
                break;
            }
        }
    }
}

for (var i = 0; i < max_t; i++)
{
    if (best[i] != -4)
        array_push(target_list, best[i]);
}

if (has_enemy)
{
    state = 1;
    attack_timer++;
    
    if (attack_timer >= (attack_anim * flash_speed))
    {
        event_user(1);
        cooldown = cycle - attack_timer;
        attack_timer = 0;
    }
}

