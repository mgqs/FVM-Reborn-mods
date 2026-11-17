/// 金刚马 Step 事件
/// 攻击段 = cycle 最后 attack_anim × flash 帧 —— 整段攻击动画都播得完，不再只播几帧就被 cycle 掐断
/// 出弹：每轮恒 1 发，绑动画第 18 帧（index 17，铃铛晃动段开头）；原版 1/2/3 发已压成 1 发
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

// ── 收尾：攻击段到点后，继续往前把 22~24 帧（铃铛放下段）播完再回待机 ──
//   2026-11-13 用户口径：22~24 本来就是"铃铛慢慢放下来"，不该倒放，也不该直接跳回第 1 帧
//   做法 = 保持 ATTACK 让父对象继续往后推帧，推到最后一帧再交回待机（下一帧父对象从末帧归 0）
if (jg_tail){
    if (image_index >= idle_anim + attack_anim){
        jg_tail      = false;
        state        = CARD_STATE.IDLE;
        attack_timer = 0;
        jg_fired     = false;
    }
    exit;
}

// ── 周期推进：前段待机，最后 attack_anim × flash 帧走攻击段 ──
var _atk_span = attack_anim * _cfs;
if (attack_timer <= cycle - _atk_span){
    attack_timer++;
} else if (attack_timer <= cycle){
    attack_timer++;
    if (state != CARD_STATE.ATTACK){
        state       = CARD_STATE.ATTACK;
        jg_tail     = false;
        jg_fired    = false;
        image_index = idle_anim + 1;   // 进攻击段先把动画归位，避免上一轮残留的高帧号当帧就出弹
    }
} else {
    attack_timer = 0;
    // 🔴 这里**不能**把 jg_fired 清零：清零后 state 还停在 ATTACK，本帧下面的出弹段会再打一发。
    //   还没播到最后一帧 → 进收尾段把铃铛放下那几帧播完；已经到末帧就直接回待机
    if (image_index < idle_anim + attack_anim){
        jg_tail  = true;
        jg_fired = true;    // 收尾段不再出弹
    } else {
        state    = CARD_STATE.IDLE;
        jg_fired = false;
    }
}

// ── 出弹：压缩后每轮恒 1 发，绑动画第 18 帧（铃铛晃动段开头） ──
//   窗口太短（攻速压太狠 / 减速）走不到第 18 帧 → 周期末尾补出来，绝不少发
if (state == CARD_STATE.ATTACK && !jg_fired){
    if (image_index >= jg_fire_frame || attack_timer >= cycle - 1){
        jg_fired = true;
        event_user(1);
    }
}
