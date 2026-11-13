/// 弹簧虎 Step 事件
/// 本行索敌（优先空中）→ 起攻击 → 到点连射（th_burst_gap 错帧）
if (global.is_paused) exit;

event_inherited();

if (is_frozen) exit;

// ── 寻敌：先找本行空军，再找本行任何可打目标 ──
if (!th_attacking){
    th_target_t = "normal";
    var _found = false;

    with (obj_enemy_parent){
        if (!_found && hp > 0 && grid_row == other.grid_row
            && target_type == "air" && can_hit("air", target_type)){
            other.th_target_t = "air_only";
            other.th_attacking = true;
            other.attack_timer = 0;
            _found = true;
        }
    }

    if (!th_attacking){
        with (obj_enemy_parent){
            if (!_found && hp > 0 && grid_row == other.grid_row
                && can_target_on(other.target_type, target_type)){
                other.th_attacking = true;
                other.attack_timer = 0;
                _found = true;
            }
        }
    }

    if (!th_attacking) exit;
}

// ── 攻击推进 ──
var _cfs = flash_speed;
if (is_slowdown) _cfs = flash_speed * 2;

attack_timer++;

// 连发必须排在周期内：首发提前到「cycle 前 (fire_delay + 所有错帧)」，
//   攻击段长度用 cycle（原来用 attack_anim*_cfs = 50 帧，比 cycle 78 短 → 间隔错、第 2 发被截断）
// 2026-11-13 用户口径：弹簧虎第 14~26 帧是攻击段、第 17 帧出弹；
//   原来按「cycle 末尾提前几帧」算发射点，动画早跑完好几轮 → 子弹一直出但动画没跟上。
//   现在整段攻击动画塞在 cycle 末尾，出弹绑在动画第 17 帧（index 16）。
var _atk_span = attack_anim * _cfs;
var _anim_t0  = max(0, cycle - _atk_span);
var _fire_now = _anim_t0 + (16 - (idle_anim + 1)) * _cfs;

if (attack_timer >= _anim_t0 && state != CARD_STATE.ATTACK){
    state       = CARD_STATE.ATTACK;
    image_index = idle_anim + 1;
}

if (attack_timer == _fire_now){
    th_burst_left  = th_bullet_count;
    th_burst_timer = 0;
}

if (th_burst_left > 0){
    th_burst_timer++;
    if (th_burst_timer >= th_burst_gap || attack_timer == _fire_now){
        th_burst_timer = 0;
        th_burst_left--;
        event_user(1);
    }
}

if (attack_timer > cycle){
    attack_timer   = 0;
    th_attacking   = false;
    th_target_t    = "normal";
    th_burst_left  = 0;
    th_burst_timer = 0;
    state          = CARD_STATE.IDLE;
}
