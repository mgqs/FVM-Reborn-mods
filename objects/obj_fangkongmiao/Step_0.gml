// obj_fangkongmiao Step 事件
// 纯对空：场上任意位置有空军就开火，不限行列。
if (global.is_paused) exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP || hp <= 0) exit;

// 攻击段播完回待机（帧由父对象按 idle_anim / attack_anim 推）；播到 fire_frame 才出弹
if (state == CARD_STATE.ATTACK)
{
    anim_t++;
    if (!fangkongmiao_fired && image_index >= fire_frame)
    {
        fangkongmiao_fired = true;
        event_user(1);
        if (shape >= 2) pending_shot = 12;   // 二转第二发比第一发晚 12 帧
    }
    if (anim_t >= attack_anim * flash_speed)
    {
        anim_t = 0;
        state = CARD_STATE.IDLE;
        image_index = 0;
    }
}

var _has_enemy = false;
with (obj_enemy_parent)
{
    if (hp > 0 && can_target_on(other.target_type, target_type))
    {
        _has_enemy = true;
        break;
    }
}

if (_has_enemy)
{
    attack_timer++;
    if (attack_timer >= cycle)
    {
        attack_timer = 0;
        pending_shot = 0;            // 新一轮：清掉上一轮没出膛的第二发
        state = CARD_STATE.ATTACK;
        anim_t = 0;
        fangkongmiao_fired = false;
        image_index = idle_anim + 1; // 弹丸在 fire_frame（第 20 帧）才出，见上面的攻击段
    }
}
else
{
    attack_timer  = 0;
    pending_shot  = 0;
}

// 二转第二发
if (pending_shot > 0)
{
    pending_shot--;
    if (pending_shot == 0 && _has_enemy) event_user(1);
}
