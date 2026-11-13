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

// ── 同类增伤 → 直接抬初始攻击力（2026-11-13 用户口径）──
//   只在数量变了才写 base_atk，避免每帧重算把管理器的乘区冲掉；
//   这样它会跟着魔杖蛇 / 莓果点心 / 宴飨女神这些增幅一起被放大。
if (variable_instance_exists(id, "base_atk")){
    if (sr_atk_base < 0) sr_atk_base = base_atk;
    if (base_atk != sr_atk_written) sr_atk_base = base_atk;   // 升星 / 护盾改过基准 → 跟着换

    var _sr_want = round(sr_atk_base * sr_atk_mult);
    if (_sr_want != base_atk){
        var _sr_ratio = (base_atk > 0) ? (atk / base_atk) : 1;
        base_atk = _sr_want;
        atk      = base_atk * _sr_ratio;
        sr_atk_written  = base_atk;
        buff_applied_id = -1;
    }
}

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

// 2026-11-13：攻击动画整段塞在 cycle 末尾（原来只留 20 帧，法杖抬一下就没了）
var _anim_t0  = max(0, cycle - attack_anim * _cfs);
// 出弹点 = 攻击段里第 sr_fire_index 帧（index 16）：雪球在这个姿势才落下来，
//   落完动画还剩 5 帧继续收尾，不会出现「放完才出球、全程都在后摇」
var _fire_off = clamp((sr_fire_index - 1) - (idle_anim + 1), 0, max(0, attack_anim - 1)) * _cfs;
var _fire_now = min(cycle - 1, _anim_t0 + _fire_off);

if (attack_timer >= _anim_t0 && state != CARD_STATE.ATTACK){
    state       = CARD_STATE.ATTACK;
    image_index = idle_anim + 1;
}

if (attack_timer == _fire_now){
    event_user(1);
}

if (attack_timer > cycle){
    attack_timer = 0;
    state        = CARD_STATE.IDLE;
}
