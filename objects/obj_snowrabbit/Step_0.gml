/// 雪球兔 Step 事件
/// 全屏任意行有敌即推计时；到点一次性把雪球砸向最多的目标
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;

var _cfs = flash_speed;
if (is_slowdown) _cfs = flash_speed * 2;

// ── 刷新同类加成（场上数量会变） ──
sr_same_count = 0;
with (obj_snowrabbit){
    if (shape == other.shape) other.sr_same_count++;
}
sr_same_count = max(1, sr_same_count);
sr_atk_mult   = 1 + sr_same_bonus * (sr_same_count - 1);
if (sr_atk_mult > sr_cap) sr_atk_mult = sr_cap;

// ── 全屏索敌 ──
if (state == CARD_STATE.IDLE){
    var _has = false;
    with (obj_enemy_parent){
        if (!_has && hp > 0 && target_type != "obstacle"
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

var _fire_pose = cycle - (sr_lead + sr_fire_delay) * _cfs;
var _fire_now  = cycle - sr_fire_delay * _cfs;

if (attack_timer == _fire_pose) state = CARD_STATE.ATTACK;

if (attack_timer == _fire_now){
    event_user(1);
}

if (attack_timer > cycle){
    attack_timer = 0;
    state        = CARD_STATE.IDLE;
}
