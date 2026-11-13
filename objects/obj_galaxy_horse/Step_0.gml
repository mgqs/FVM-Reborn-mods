// obj_galaxy_horse Step 事件
// 只做两件事：按 cycle 推进攻击节奏（有目标才开火）、到点调事件 1 出陨石。
// 伤害不在卡片侧结算 —— 陨石落点由 obj_galaxy_horse_bullet 负责（见那个对象的注释）。
if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP)
    exit;

var current_flash_speed = flash_speed;
if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = gh_has_target();

if (has_enemy)
{
    // 与双刃蛇 / 后羿同口径：前段只累积计时，进入攻击动画的那一段切 ATTACK，
    // 走完 cycle 才真正出弹，保证「抬手 → 落地」的节奏和表里的 19 秒间隔对得上。
    if (attack_timer <= cycle - attack_anim * current_flash_speed)
    {
        attack_timer++;
    }
    else if (attack_timer <= cycle)
    {
        attack_timer++;
        state = CARD_STATE.ATTACK;
    }
    else
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
