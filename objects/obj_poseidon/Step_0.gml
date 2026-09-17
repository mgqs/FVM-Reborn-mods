if (global.is_paused)
    exit;

if (state == 0)
    flash_speed = 5;
else if (state == 1)
    flash_speed = 4;

event_inherited();

if (is_frozen || state == 4)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;
var _x = x;
var _y = y;
var _range = 2;

if (shape == 3)
    _range = 3;

with (obj_enemy_parent)
{
    if (hp > 0 && hp > 0 && hp > 0 && abs(grid_row - other.grid_row) <= 2 && abs(grid_col - other.grid_col) <= _range)
        has_enemy = true;
}

if (has_enemy)
{
    if (attack_timer <= (cycle - (attack_anim * current_flash_speed)))
    {
        attack_timer++;
    }
    else if (attack_timer < cycle)
    {
        attack_timer++;
        state = 1;
    }
    else
    {
        attack_timer = 0;
        state = 0;
    }
    
    if (attack_timer == (cycle - (2 * current_flash_speed)) && state == 1)
        event_user(1);
    
    if (attack_timer == (cycle - (4 * current_flash_speed)) && state == 1)
    {
        event_user(1);
        audio_play_sound(snd_coffee_pot_attack, 0, 0);
    }
    
    if (shape >= 2)
    {
        if (attack_timer == (cycle - (6 * current_flash_speed)) && state == 1)
            event_user(1);
    }
}
else
{
    attack_timer = 0;
    state = 0;
}

