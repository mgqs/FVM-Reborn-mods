/// 金刚马 Step 事件
/// 有敌人可打才推攻击计时；周期到点摆姿态 → 出弹（连发按 jg_burst_gap 错帧）
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;

var _cfs = flash_speed;
if (is_slowdown) _cfs = flash_speed * 2;

// ── 有敌才开火 ──
if (state == CARD_STATE.IDLE){
    var _hittable = jg_hittable;
    var _has = false;
    for (var _t = 0; _t < array_length(_hittable); _t++){
        var _key = _hittable[_t];
        if (!variable_global_exists("enemy_by_type")) break;
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _arr = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_arr); _i++){
            var _e = _arr[_i];
            if (!instance_exists(_e)) continue;
            if (_e.hp <= 0) continue;
            if (_key == "underground" && !is_digging_dijing(_e)) continue;
            _has = true;
            break;
        }
        if (_has) break;
    }
    if (!_has){
        attack_timer = 0;
        state = CARD_STATE.IDLE;
        exit;
    }
}

attack_timer++;

// 连发必须排在周期内：首发提前到「cycle 前 (fire_delay + 所有错帧)」
var _burst_span = (jg_shot_count - 1) * jg_burst_gap;
var _fire_now   = cycle - jg_fire_delay * _cfs - _burst_span;
var _fire_pose  = _fire_now - jg_lead * _cfs;

if (attack_timer == _fire_pose){
    state = CARD_STATE.ATTACK;
}

if (attack_timer == _fire_now){
    // 第一发出膛，其余排队错帧
    jg_burst_left  = jg_shot_count - 1;
    jg_burst_timer = 0;
    event_user(1);
}

if (attack_timer > _fire_now && jg_burst_left > 0){
    jg_burst_timer++;
    if (jg_burst_timer >= jg_burst_gap){
        jg_burst_timer = 0;
        jg_burst_left--;
        event_user(1);
    }
}

if (attack_timer > cycle){
    attack_timer = 0;
    jg_burst_left = 0;
    jg_burst_timer = 0;
    state = CARD_STATE.IDLE;
}
