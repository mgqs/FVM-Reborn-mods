// obj_huojianzhu Step 事件
// 全屏任意位置有敌人（普通 / 地下 / 空军）就开火。
if (global.is_paused) exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP || hp <= 0) exit;

// 攻击段播完回待机（帧由父对象按 idle_anim / attack_anim 推）；播到 fire_frame 才出弹
if (state == CARD_STATE.ATTACK)
{
    anim_t++;
    if (!huojianzhu_fired && image_index >= fire_frame)
    {
        huojianzhu_fired = true;
        event_user(1);
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
        state = CARD_STATE.ATTACK;
        anim_t = 0;
        huojianzhu_fired = false;
        image_index = idle_anim + 1;   // 弹在第 26 帧才出，见上面的攻击段
    }
}
else
{
    attack_timer = 0;
}
