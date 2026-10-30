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
    // 优先对空（2026-10-30）：**必须单独扫一遍本行空军**
    //   原来「空军判定」和「打地面」写在同一个 with 循环里，实例遍历顺序不保证：
    //   先扫到地面敌人就 attacking = true + break，空军永远轮不到 → 描述里的「优先空军」实际不生效
    with (obj_enemy_parent)
    {
        if (target_type == "air" && grid_row == other.grid_row && hp > 0)
        {
            other.target_t = "air_only";
            other.attacking = true;
            break;
        }
    }

    if (!attacking)
    {
        with (obj_enemy_parent)
        {
            if (can_target_on(other.target_type, target_type) && grid_row == other.grid_row && hp > 0)
            {
                other.attacking = true;
                break;
            }
        }
    }
}

if (attacking)
{
    state = 1;
    attack_timer++;
    
    if (attack_timer == ((attack_anim * flash_speed) - 20))
        event_user(1);
    
    if (attack_timer == ((attack_anim * flash_speed) - 15))
        event_user(1);
    
    if (attack_timer == ((attack_anim * flash_speed) - 10) && shape == 2)
        event_user(1);
    
    if (attack_timer >= (attack_anim * flash_speed) || attack_timer >= cycle)
    {
        attacking = false;
        cooldown = cycle - attack_timer;
        attack_timer = 0;
        state = 0;
        target_t = "normal";
    }
}

