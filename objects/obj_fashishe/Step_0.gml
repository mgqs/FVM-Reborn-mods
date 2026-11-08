// obj_fashishe Step 事件
// 开火条件：本行前方（含场外排队列）有能被「普通」命中的敌人就开火，不挑目标（照 bbq 整行触发）。
// 动画：待机 1~12 / 攻击 13~28，帧由父对象按 idle_anim / attack_anim 推；
//   播到 fire_frame（第 25 帧）出弹，播完 attack_anim 帧回待机。
if (global.is_paused) exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP || hp <= 0) exit;

// 攻击段：播完回待机，播到 fire_frame 出弹
if (state == CARD_STATE.ATTACK)
{
    anim_t++;
    if (!fashishe_fired && image_index >= fire_frame)
    {
        fashishe_fired = true;
        event_user(1);
    }
    if (anim_t >= attack_anim * flash_speed)
    {
        anim_t = 0;
        state = CARD_STATE.IDLE;
        image_index = 0;
    }
}

// ── 本轮剩余的发：每一发比上一发晚 fashishe_shot_delay 帧 ──
if (fashishe_burst_left > 0)
{
    if (fashishe_burst_timer <= 0)
    {
        fashishe_fire_one();
        fashishe_burst_left--;
        fashishe_burst_timer = fashishe_shot_delay;
    }
    else fashishe_burst_timer--;
}

// ── 索敌：本行前方有敌人就攒冷却 ──
var _has_enemy = false;
with (obj_enemy_parent)
{
    if (grid_row == other.grid_row
        && grid_col >= other.grid_col
        && grid_col <= global.grid_cols + 1
        && hp > 0
        && can_target_on(other.target_type, target_type))
    {
        _has_enemy = true;
        break;
    }
}

// 冷却照常攒（**攻击段也攒**，否则出弹节奏会被动画长度拖成 cycle + 动画时长）
if (_has_enemy) attack_timer = min(attack_timer + 1, max(1, cycle));
else           attack_timer = 0;

// 攒满 + 当前不在攻击段 → 起一段攻击动画（播到 fire_frame 出弹）
if (state != CARD_STATE.ATTACK && attack_timer >= cycle)
{
    attack_timer = 0;
    state = CARD_STATE.ATTACK;
    anim_t = 0;
    fashishe_fired = false;
    image_index = idle_anim + 1;
}
