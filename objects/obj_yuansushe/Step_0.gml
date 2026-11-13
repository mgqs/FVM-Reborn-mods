// obj_yuansushe Step 事件
if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP)
    exit;

var current_flash_speed = flash_speed;
if (is_slowdown)
    current_flash_speed *= 2;

var has_enemy = ys_has_target();

if (has_enemy)
{
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

// 一轮打完、回到待机之后再把眼睛换成「下一发」的颜色。
//   放在待机帧而不是出弹帧：出弹时攻击段还剩几帧，中途换图会让眼睛颜色跳得太早，
//   与原版「一段一种颜色」的表现对不上。
if (state == CARD_STATE.IDLE && ys_pending_eye >= 0)
{
    ys_eye = ys_pending_eye;
    ys_pending_eye = -1;
    sprite_index = ys_color_spr[ys_eye];
}
