if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

var current_flash_speed = flash_speed;

if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = false;

// 🔴 2026-11-16 用户报「后羿不索敌、不出弹，老鼠也不啃它」：
//   d6ae7a5b7d 把这里的直扫换成了按行桶查询 combat_enemy_in_rows(id, grid_row-1, grid_row+1, …)，
//   单行桶那条路在别的卡上没问题，但后羿是三行窗口 —— 桶是按 string(grid_row) 分键的，
//   多行窗口一旦取到空桶就整段判「没有敌人」，攻击计时器每帧被清零 → 永远不出弹。
//   这里恢复直扫（3 行 ±1 一次遍历），只保留存活判定，行为与改造前一致。
with (obj_enemy_parent)
{
    if (!combat_target_alive(id)) continue;
    if (grid_row >= (other.grid_row - 1) && grid_row <= (other.grid_row + 1)
        && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1)
        && can_target_on(other.target_type, target_type))
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
