// obj_fashishe Step 事件
// 开火条件：**整行**（含身后、含场外）有能被「普通」命中的敌人就开火，不挑目标（照 bbq 整行触发）。
// 动画：待机 1~12 / 攻击 13~28（帧由父对象按 idle_anim / attack_anim 推）。
//   写法与牛油果 / bbq 同一套（工程标准）：
//     ① 攻击段挤在 cycle 末尾开播：attack_timer >= cycle - 攻击段时长 → ATTACK
//     ② 播到贴图的关键帧（第 15 帧 = 光环转到身上那一圈）出弹，看 image_index，不另设出弹帧变量
//     ③ attack_timer > cycle → 回待机，下一轮从 0 重新攒
//   → 攻速快到 cycle 装不下整段动画时，后摇会被下一轮前摇顶掉，这是原版表现，不做特殊处理。
if (global.is_paused) exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP || hp <= 0) exit;

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

// ── 索敌：**整行**（左右都认，同 bbq 2026-11-02 口径）──
//   身后的地精鼠出土后从左边走过来咬卡，也会触发开火；但子弹轨迹固定向右（见 Create_0 / Other_11），
//   **不要**改成按方向左右发射。
//   二转（shape >= 2）覆盖 3 行 → 任一行有敌人都开火（照 bbq 的 _rows 判法）。
var _rows = [grid_row];
if (shape >= 2)
{
    _rows = [];
    if (grid_row > 0)                    array_push(_rows, grid_row - 1);
    array_push(_rows, grid_row);
    if (grid_row < global.grid_rows - 1) array_push(_rows, grid_row + 1);
}

var _has_enemy = false;
with (obj_enemy_parent)
{
    if (hp > 0
        && array_contains(_rows, grid_row)
        && can_target_on(other.target_type, target_type))
    {
        _has_enemy = true;
        break;
    }
}

if (_has_enemy)
{
    var current_flash_speed = flash_speed;
    if (is_slowdown) current_flash_speed *= 2;

    attack_timer++;

    // 攻击段窗口：cycle 末尾刚好留出整段动画时长（cycle 比动画短就压到 1，不报错也不卡出弹）
    if (attack_timer >= max(1, cycle - attack_anim * current_flash_speed)) state = CARD_STATE.ATTACK;

    // 光环转到身上那一圈（第 15 帧 = idle_anim + 3）出弹；一段只发一次
    if (state == CARD_STATE.ATTACK && !fashishe_fired && image_index >= idle_anim + 3)
    {
        fashishe_fired = true;
        event_user(1);
    }

    if (attack_timer > cycle)
    {
        attack_timer = 0;
        fashishe_fired = false;
        state = CARD_STATE.IDLE;
    }
}
else
{
    attack_timer = 0;
    fashishe_fired = false;
    state = CARD_STATE.IDLE;
}
