if (global.is_paused) exit;
event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP) exit;

var _fs = flash_speed;
if (is_slowdown) _fs *= 2;

// 索敌：本行、卡片右侧、射程 range 格内，取最近的一只
// 🔴 2026-11-06 修：`range` 是**卡片自己的**字段，`with (obj_enemy_parent)` 里裸写 range 会被当成
//   去老鼠身上找 range（老鼠没有这个变量）→ 报「Variable obj_test_mouse.range not set」。
//   必须在进 with 之前先取到本地变量，with 内部用 _rng。
var _rng = range;
var _has = false;
var _tgt = noone;
var _min = 99999;
with (obj_enemy_parent){
    if (hp > 0 && grid_row == other.grid_row && grid_col >= other.grid_col
        && (grid_col - other.grid_col) <= _rng
        && can_target_on(other.target_type, target_type)){
        var _d = grid_col - other.grid_col;
        if (_d < _min){
            _min = _d;
            _tgt = id;
            _has = true;
        }
    }
}
target_instance = _tgt;

if (_has){
    var _was = (state == CARD_STATE.ATTACK);
    if (attack_timer <= cycle - attack_anim * _fs){
        attack_timer++;
    }
    else if (attack_timer <= cycle){
        attack_timer++;
        state = CARD_STATE.ATTACK;
    }
    else{
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }

    if (!_was && state == CARD_STATE.ATTACK){
        fired_this_attack = false;
        image_index = idle_anim + 1;
    }
    if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= fire_frame){
        fired_this_attack = true;
        event_user(1);
    }
}
else{
    attack_timer = 0;
    fired_this_attack = false;
    state = CARD_STATE.IDLE;
}
