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
var _fire_now   = cycle - qs_fire_delay * _cfs - _burst_span;
var _fire_pose  = _fire_now - qs_lead * _cfs;

if (attack_timer == _fire_pose) state = CARD_STATE.ATTACK;

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
    state          = CARD_STATE.IDLE;
}
