/// 窃蛋龙 Step 事件
/// 三行索敌（本行 + 上下各 1 行），有目标才推攻击计时
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;

var _cfs = flash_speed;
if (is_slowdown) _cfs = flash_speed * 2;

// ── 索敌：本行或上下 1 行有敌即可 ──
if (state == CARD_STATE.IDLE){
    var _has = false;
    with (obj_enemy_parent){
        if (!_has && hp > 0 && target_type != "obstacle"
            && abs(grid_row - other.grid_row) <= 1
            && grid_col >= other.grid_col
            && grid_col <= global.grid_cols + 1
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

var _fire_pose = cycle - (4 + 1) * _cfs;
var _fire_now  = cycle - 1 * _cfs;

if (attack_timer == _fire_pose) state = CARD_STATE.ATTACK;

if (attack_timer == _fire_now){
    qd_fired = false;
    event_user(1);
}

if (attack_timer > cycle){
    attack_timer = 0;
    state        = CARD_STATE.IDLE;
}
