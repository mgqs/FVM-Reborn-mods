if (global.is_paused || is_frozen)
    exit;

event_inherited();
life_timer--;

if (life_timer < 180)
{
    if ((life_timer % 10) < 5)
        image_alpha = 0.5;
    else
        image_alpha = 1;
}

if (life_timer <= 0)
{
    instance_destroy();
    exit;
}

attack_timer++;

if (attack_timer <= idle_duration)
{
    state = 0;
}
else if (attack_timer <= attack_interval)
{
    state = 1;
}
else
{
    attack_timer = 0;
    state = 0;
}

var trigger_time = idle_duration + (6 * flash_speed);
var range_cells = 1;

if (shape == 2)
    range_cells = 2;

if (attack_timer == trigger_time && state == 1)
{
    with (obj_enemy_parent)
    {
        if (hp > 0 && abs(grid_row - other.grid_row) <= range_cells && abs(grid_col - other.grid_col) <= range_cells)
        {
            hp -= other.atk;
            event_user(0);
            audio_play_sound(snd_hit1, 0, 0);
            
            if (ice_timer < 600)
                ice_timer = 600;
        }
    }
    
    var _gap1 = 105;
    var _gap2 = 115;
    var i = -range_cells;
    
    while (i <= range_cells)
    {
        var j = -range_cells;
        
        while (j <= range_cells)
        {
            var spawn_x = x + (j * _gap1);
            var spawn_y = y + (i * _gap2);
            var spike = instance_create_depth(spawn_x, spawn_y, depth - 5, obj_mojie_bullet);
            j++;
        }
        
        i++;
    }
}

