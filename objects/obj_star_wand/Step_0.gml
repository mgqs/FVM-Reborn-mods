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
        case CARD_STATE.IDLE:
            if (image_index < 7)
                image_index++;
            else
                image_index = 0;

            break;

        case CARD_STATE.ATTACK:
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
    if (can_hit("all", target_type) && hp > 0)
    {
        has_enemy = true;
        break;
    }
}

if (has_enemy)
{
    attack_timer++;
    
    if (attack_timer > (cycle - (attack_anim * flash_speed)))
        state = CARD_STATE.ATTACK;

    if (attack_timer > cycle)
    {
        event_user(1);
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
}
else
{
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}

if (fire_cd > 0)
{
    fire_cd--;
}
else if (array_length(fire_queue) > 0)
{
    var _e = fire_queue[0];
    array_delete(fire_queue, 0, 1);
    
    if (instance_exists(_e) && _e.hp > 0)
    {
        var _spd = _e.move_speed * _e.move_speed_modify;
        
        if (_e.is_slowdown)
            _spd *= 0.5;
        
        if (_e.is_frozen || _e.is_stun || _e.is_scare)
            _spd = 0;
        
        var _pred_x = _e.x - (_spd * explode_timer);
        var _pred_y = _e.y - 5;
        var inst = instance_create_depth_define(_pred_x, _pred_y, depth - 500, obj_star_wand_bullet);
        inst.target_enemy = _e;
        inst.sprite_index = bullet_shape;
        inst.explode_timer = explode_timer;
        var _hit = {};
        _hit.x = _pred_x;
        _hit.y = _pred_y;
        _hit.target = _e;
        _hit.frames = explode_timer;
        array_push(pending_hits, _hit);
    }
    
    fire_cd = fire_interval;
}

for (var i = 0; i < array_length(pending_hits); i++)
{
    var _h = pending_hits[i];
    _h.frames--;
    
    if (_h.frames <= 0)
    {
        cur_hit = _h;
        
        if (instance_exists(_h.target) && _h.target.hp > 0)
        {
            with (_h.target)
            {
                audio_play_sound(snd_star_wand, 0, 0);
                damage_amount = other.atk;
                damage_type = other.damage_type;
                event_user(0);
            }
            
            if (irandom_range(1, 100) <= (diz_chance * 100))
                _h.target.stun_timer = 180;
        }
        
        if (splash_ratio > 0)
        {
            with (obj_enemy_parent)
            {
                if (hp > 0 && id != other.cur_hit.target)
                {
                    var _gcell = get_grid_position_from_world(other.cur_hit.x, other.cur_hit.y);
                    
                    if (grid_row >= (_gcell.row - 1) && grid_row <= (_gcell.row + 1) && abs(other.cur_hit.x - x) <= 180)
                    {
                        audio_play_sound(snd_star_wand, 0, 0);
                        damage_amount = round(other.atk * other.splash_ratio);
                        damage_type = other.damage_type;
                        event_user(0);
                    }
                }
            }
        }
        
        array_delete(pending_hits, i, 1);
        i--;
    }
}

