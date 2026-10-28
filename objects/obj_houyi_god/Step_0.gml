if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;

with (obj_enemy_parent)
{
    if (grid_row >= (other.grid_row - 1) && grid_row <= (other.grid_row + 1) && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type, target_type))
    {
        has_enemy = true;
        break;
    }
}

// ── 攻击循环：1-12 待机 / 13-23 攻击，第 20 帧发射（上中下三发）──────────
if (state != CARD_STATE.ATTACK)
{
    if (has_enemy)
    {
        attack_timer++;

        // cycle 不足以播完整套攻击动画时按 cycle 压缩每帧时钟（总周期仍是 cycle）
        var _spd = min(current_flash_speed, max(1, floor(cycle / max(1, attack_anim))));
        var _window = attack_anim * _spd;

        if (attack_timer >= cycle - _window)
        {
            attack_timer = 0;
            state = CARD_STATE.ATTACK;
            image_index = idle_anim + 1;
            houyi_fired = false;
            flash_speed = is_slowdown ? max(1, _spd * 0.5) : _spd;
        }
    }
    else
    {
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
}
else
{
    // 攻击动画播到第 20 帧 → 三发齐射
    if (!houyi_fired && image_index >= houyi_shoot_frame)
    {
        fire_mid = true;
        fire_up = true;
        fire_down = true;
        event_user(1);
        houyi_fired = true;
    }

    if (image_index >= idle_anim + attack_anim)
    {
        state = CARD_STATE.IDLE;
        image_index = 0;
        attack_timer = 0;
        flash_speed = flash_speed_base;
    }
}
