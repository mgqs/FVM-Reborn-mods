// obj_joker Step 事件
// 本行索敌（空 / 陆 / 潜水 / 钻地）→ 进攻击段 → 连发 N 发（首发绑动画帧、后续按 jk_burst_gap）
// 攻击段占周期最后 attack_anim*step 帧；cycle 比 17*flash 短时按 cycle 压帧，否则播不完
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
    exit;
}

if (!attacking)
{
    with (obj_enemy_parent)
    {
        if ((target_type == "normal" || target_type == "air" || target_type == "underground" || target_type == "diver")
            && grid_row == other.grid_row && hp > 0)
        {
            other.attacking = true;
            other.attack_timer = 0;
            break;
        }
    }
}

if (attacking)
{
    attack_timer++;

    var _step = current_flash_speed;
    if (attack_anim * _step > cycle)
        _step = max(2, floor(cycle / attack_anim));

    // 攻击段只用周期的最后 attack_anim*_step 帧；之前保持待机（state 不动，父对象继续播 idle，避免定格在攻击首帧）
    var _anim_t0 = max(0, cycle - attack_anim * _step);

    if (attack_timer >= _anim_t0)
    {
        state = 1;
        var _frame  = clamp(floor((attack_timer - _anim_t0) / _step), 0, attack_anim - 1);
        image_index = idle_anim + 1 + _frame;
    }

    if (attack_timer == _anim_t0 + jk_fire_index * _step)
    {
        jk_burst_left  = jk_bullet_count;
        jk_burst_timer = 0;
    }

    if (jk_burst_left > 0)
    {
        jk_burst_timer++;
        if (jk_burst_timer >= jk_burst_gap || attack_timer == _anim_t0 + jk_fire_index * _step)
        {
            jk_burst_timer = 0;
            jk_burst_left--;
            event_user(1);
        }
    }

    if (attack_timer >= cycle)
    {
        attacking = false;
        cooldown = 0;
        attack_timer = 0;
        state = 0;
        jk_burst_left = 0;
        jk_burst_timer = 0;
    }
}
