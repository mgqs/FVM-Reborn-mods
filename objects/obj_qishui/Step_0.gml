/// 弹珠汽水 Step 事件
/// 本行有敌才推攻击计时；到点连射（qs_burst_gap 错帧）
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;

var _cfs = flash_speed;
if (is_slowdown) _cfs = flash_speed * 2;

// ── 本行索敌 ──
if (state == CARD_STATE.IDLE){
    var _has = false;
    with (obj_enemy_parent){
        if (!_has && hp > 0 && grid_row == other.grid_row
            && can_target_on(other.target_type, target_type)){
            _has = true;
        }
    }
    if (!_has){
        attack_timer = 0;
        exit;
    }
}

attack_timer++;

// 连发必须排在周期内：首发提前到「cycle 前 (fire_delay + 所有错帧)」，
//   原来首发在 cycle - fire_delay*_cfs，第 2 发要再等 burst_gap 帧 → 已过 cycle 的归零点，连发全被截断。
var _burst_span = (qs_shot_count - 1) * qs_burst_gap;
var _fire_now   = max(1, cycle - qs_fire_delay * _cfs - _burst_span);

// ── 攻击动画：按「出弹帧」反推步长，但**只占固定一小段**（qs_anim_span）──
//   2026-11-13 用户口径：子弹要第 30 帧才吐；但也不能为了等到第 30 帧让卡片几乎全程摆攻击姿势
//   （上一版按 cycle 反推，16 星时 92% 的时间都在攻击，看着像「疯狂攻击 / 帧伤」）
//   现在：攻击段固定 40 帧，17 个 index → 每 2 帧过一张，剩下的时间回待机
var _spit_steps = max(1, qs_spit_index - (idle_anim + 1));                                  // 17
var _step_max   = max(1, floor(_fire_now / _spit_steps));                                   // cycle 太短时的上限
var _anim_step  = clamp(floor(qs_anim_span / _spit_steps), 1, min(_cfs, _step_max));         // 2
var _anim_t0    = max(0, _fire_now - _spit_steps * _anim_step);

if (state != CARD_STATE.ATTACK && attack_timer >= _anim_t0){
    state     = CARD_STATE.ATTACK;
    qs_anim_t = 0;
}

// 攻击段自己算帧（父对象那套固定 flash_speed 推帧在 cycle 短的时候追不上）
if (state == CARD_STATE.ATTACK){
    qs_anim_t   = attack_timer - _anim_t0;
    image_index = min(idle_anim + attack_anim,
                      idle_anim + 1 + floor(qs_anim_t / _anim_step));
}

if (attack_timer == _fire_now){
    qs_burst_left  = qs_shot_count - 1;
    qs_burst_timer = 0;
    event_user(1);
}

if (attack_timer > _fire_now && qs_burst_left > 0){
    qs_burst_timer++;
    if (qs_burst_timer >= qs_burst_gap){
        qs_burst_timer = 0;
        qs_burst_left--;
        event_user(1);
    }
}

if (attack_timer > cycle){
    attack_timer   = 0;
    qs_burst_left  = 0;
    qs_burst_timer = 0;
    qs_anim_t      = 0;
    state          = CARD_STATE.IDLE;
}
