// obj_tangchaolizi（糖炒栗子）Step 事件
// 单行投手：只打本行（射程 range 格），落点 = 本行最前面那只老鼠所在的格子。
// 动画自己推帧（父对象那套按 idle_anim/attack_anim 顺推的规则这里覆盖掉）：
//   待机 0~11（12 帧一循环）/ 挥锅 18~26（第 21 帧脱手）
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;
if (state == CARD_STATE.SLEEP) exit;

var _step = max(1, flash_speed * (is_slowdown ? 2 : 1));
var _atk_start = 18;
var _atk_end   = 26;
var _release   = 20;             // 第 21 帧（0 基 20）：锅翻到最大、栗子飞出
var _atk_len   = _atk_end - _atk_start + 1;

// ===== 索敌：本行、卡片右侧、射程内最近的一只 =====
var _has_enemy = false;
var _tgt = noone;
var _min_d = 99999;

with (obj_enemy_parent)
{
    if (hp > 0
        && grid_row == other.grid_row
        && grid_col >= other.grid_col
        && grid_col <= other.grid_col + other.range
        && can_target_on(other.target_type, target_type))
    {
        var _d = grid_col - other.grid_col;
        if (_d < _min_d)
        {
            _min_d = _d;
            _tgt = id;
            _has_enemy = true;
        }
    }
}

// ===== 节拍 =====
if (_has_enemy)
{
    attack_timer++;

    // 进入挥锅窗口（留出整段动画的时间）
    if (state != CARD_STATE.ATTACK && attack_timer >= cycle - _atk_len * _step)
    {
        state = CARD_STATE.ATTACK;
        tc_fired = false;
        tc_anim_t = 0;
    }

    // 挥完回待机（待机计时归零，动画从第 1 帧接上）
    if (state == CARD_STATE.ATTACK && image_index >= _atk_end)
    {
        state = CARD_STATE.IDLE;
        tc_anim_t = 0;
    }

    if (attack_timer > cycle) attack_timer = 0;
}
else
{
    attack_timer = 0;
    tc_fired = false;
    if (state == CARD_STATE.ATTACK)              // 挥到一半没目标了：直接回待机
    {
        state = CARD_STATE.IDLE;
        tc_anim_t = 0;
    }
}

// ===== 推帧 =====
tc_anim_t++;
if (state == CARD_STATE.ATTACK)
{
    var _elapsed = attack_timer - (cycle - _atk_len * _step);
    image_index = _atk_start + clamp(floor(_elapsed / _step), 0, _atk_len - 1);
}
else
{
    image_index = (tc_anim_t div _step) mod 12;
}

// ===== 出弹：锅翻到最大的那一帧 =====
if (state == CARD_STATE.ATTACK && !tc_fired && image_index >= _release)
{
    tc_fired = true;
    tc_target = _tgt;
    event_user(1);
}
