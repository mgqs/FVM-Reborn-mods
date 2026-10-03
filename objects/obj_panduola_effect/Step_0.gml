if (global.is_paused)
    exit;

tick_timer++;
plague_timer++;

// 毒气：每 tick_interval 帧对本行敌人造成一跳伤害
if (tick_index < max_ticks && tick_timer >= tick_interval)
{
    tick_timer = 0;
    var _idx = tick_index;
    tick_index++;

    with (obj_enemy_parent)
    {
        if (hp > 0 && can_hit(other.target_type, target_type))
        {
            var _hit = (grid_row == other.grid_row);
            if (other.shape >= 2)
                _hit = (abs(grid_row - other.grid_row) <= 1);

            if (_hit)
            {
                damage_amount = other.tick_damages[_idx];
                damage_type = "normal";
                event_user(0);
            }
        }
    }
}

// 鼠疫（四转）：全屏，每 plague_interval 帧一跳，共 3 次
if (has_plague && plague_left > 0 && plague_timer >= plague_interval)
{
    plague_timer = 0;
    plague_left--;

    with (obj_enemy_parent)
    {
        if (hp > 0)
        {
            damage_amount = other.plague_damage;
            damage_type = "normal";
            event_user(0);
        }
    }
}

// 全部结算完毕后销毁
if (tick_index >= max_ticks && (!has_plague || plague_left <= 0))
{
    instance_destroy();
}