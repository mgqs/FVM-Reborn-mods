// obj_tianxie Step 事件
// 开火条件：**整行**（含身后、含场外）有能被「穿透」命中的敌人就开火，不挑目标（照 bbq 整行触发）。
//   2026-11-09 用户口径：**取消盲区** —— 原来「自身格 + 前方 1 格打不到」，现在等于 bbq 的整行。
// 动画：待机 1~13 / 攻击 14~23（帧由父对象按 idle_anim / attack_anim 推）。
//   写法与牛油果 / bbq / 法师蛇同一套（工程标准）：
//     ① 攻击段挤在 cycle 末尾开播：attack_timer >= cycle - 攻击段时长 → ATTACK
//     ② 播到贴图的关键帧（**第 20 帧 = idle_anim + 7，刺出最远那一帧**）出弹，看 image_index
//     ③ attack_timer > cycle → 回待机，下一轮从 0 重新攒
//   → 攻速快到 cycle 装不下整段动画时，后摇会被下一轮前摇顶掉，这是原版表现，不做特殊处理。
if (global.is_paused) exit;

event_inherited();

// ── 二转多发卡的补发队列（小笼包 6 连发 / 法师蛇 3 发）──
//   放在冻结判断之前：一轮攻击已经开始了，中途被冻也要把剩下的几发打完，不然只出半轮。
if (array_length(tx_pending) > 0) tx_tick();

if (is_frozen || state == CARD_STATE.SLEEP || hp <= 0) exit;

// 🔴 少这个局部变量会直接崩（bbq 2026-10-31 踩过）：减速时攻速翻倍，与 obj_bbq / obj_eightcake 同写法
var current_flash_speed = flash_speed;
if (is_slowdown) current_flash_speed *= 2;

// ── 索敌：整行（左右都认，同 bbq 2026-11-02 口径）──
//   身后的地精鼠出土后从左边走过来咬卡，也会触发开火；
//   打击范围仍然从「最左敌人那一格」往右数 4 格（伤害在 obj_tianxie_needle 里逐针结算）
var _has_enemy = false;
with (obj_enemy_parent)
{
    if (hp > 0
        && grid_row == other.grid_row
        && can_target_on(other.target_type, target_type))
    {
        _has_enemy = true;
    }
}

if (_has_enemy)
{
    attack_timer++;

    // 攻击段窗口：cycle 末尾刚好留出整段动画时长（cycle 比动画短就压到 1，不报错也不卡出弹）
    if (attack_timer >= max(1, cycle - attack_anim * current_flash_speed)) state = CARD_STATE.ATTACK;

    // 第 20 帧（image_index 19 = idle_anim + 7）出弹；一轮只发一次
    if (state == CARD_STATE.ATTACK && !tianxie_fired && image_index >= idle_anim + 7)
    {
        tianxie_fired = true;
        event_user(1);
    }

    if (attack_timer > cycle)
    {
        attack_timer = 0;
        tianxie_fired = false;
        state = CARD_STATE.IDLE;
    }
}
else
{
    attack_timer = 0;
    tianxie_fired = false;
    state = CARD_STATE.IDLE;
}
