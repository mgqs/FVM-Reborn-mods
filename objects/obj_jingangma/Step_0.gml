/// 金刚马 Step 事件
/// 攻击段 = cycle 最后 attack_anim × flash 帧 —— 整段攻击动画都播得完，不再只播几帧就被 cycle 掐断
/// 出弹：首发绑动画第 18 帧（index 17，铃铛晃动段开头），之后按 jg_burst_gap 帧一发连发（默认 10 帧 ≈ 一个弹身）
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
        jg_tail        = false;
        state          = CARD_STATE.IDLE;
        attack_timer   = 0;
        jg_fired       = 0;
        jg_burst_timer = 0;
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
        jg_fired    = 0;
        jg_burst_timer = 0;
        image_index = idle_anim + 1;   // 进攻击段先把动画归位，避免上一轮残留的高帧号当帧就出弹
    }
} else {
    attack_timer   = 0;
    jg_burst_timer = 0;
    // 🔴 2026-11-13 修「多打一发」：这里**不能**把 jg_fired 清零。
    //   清零后 state 还停在 ATTACK，本帧下面的出弹段就把自己当「首发」再打一发（实测 3 发变 4 发）。
    //   还没播到最后一帧 → 进收尾段把铃铛放下那几帧播完；已经到末帧就直接回待机
    if (image_index < idle_anim + attack_anim){
        jg_tail  = true;
        jg_fired = jg_shot_count;   // 收尾段不再出弹
    } else {
        state    = CARD_STATE.IDLE;
        jg_fired = 0;
    }
}

// ── 出弹：首发绑动画第 18 帧（铃铛晃动段），之后按 jg_burst_gap 连发 ──
//   2026-11-13 用户口径：几发不能挤在 18/19/20 三帧里（会叠成一条），要「头对尾」分开
//   → 后续几发不再看动画帧，改成计时器控制间隔；周期末尾还剩发数就逐帧补，绝不少发
if (state == CARD_STATE.ATTACK && jg_fired < jg_shot_count){
    var _fire = false;
    if (jg_fired == 0){
        if (image_index >= jg_fire_frame) _fire = true;
        // 窗口太短（攻速压太狠 / 减速）走不到第 18 帧 → 周期末尾把整串补出来
        else if (attack_timer >= cycle - (jg_shot_count - 1) * jg_burst_gap - 1) _fire = true;
    }
    else{
        jg_burst_timer++;
        if (jg_burst_timer >= jg_burst_gap) _fire = true;
        // 周期快到点、间隔来不及走完 → 逐帧补发
        if (cycle - attack_timer <= (jg_shot_count - jg_fired)) _fire = true;
    }

    if (_fire){
        jg_fired++;
        jg_burst_timer = 0;
        event_user(1);
    }
}
