// obj_yuanqiniu Step 事件
// ① 帧推进（待机呼吸 / 攻击段整段播完）② 范围内有敌才计时 → 到点开一轮
// ③ 攻击段播到结算帧就打一波（两波合计 = 一轮总伤害）
if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── ① 帧推进（口径同 obj_xuanzhuan_ronghe：攻击段优先，播完回待机）──
if (atk_t >= 0){
    var _off = floor(atk_t / atk_flash_speed);       // 当前播到攻击段第几帧（0 基）
    if (_off >= SEG_ATK_LEN){
        atk_t = -1;
        idle_t = 0;
    } else {
        image_index = SEG_ATK_FIRST + _off;
        atk_t++;
    }
}

if (atk_t < 0){
    idle_t++;
    image_index = floor(idle_t / flash_speed) mod SEG_IDLE_LEN;
}

// ── ② 同类加成：每帧按场上同形态数量抬「初始攻击力 base_atk」──
//   2026-11-13 用户口径：同类增伤要算进初始攻击力，再被增幅/技能一起放大；
//   原来发弹时临时乘一下（floor(atk*mult)）既不算初始攻击力，也不会体现在 atk 上。
//   ⚠️ 只在数量变了才写 base_atk，避免每帧重算把管理器的乘区冲掉。
yn_same_tmp = 0;
with (obj_yuanqiniu){
    if (shape == other.shape) other.yn_same_tmp++;
}
var _cnt = max(1, yn_same_tmp);
yn_same_tmp = 0;
yn_atk_mult = min(yn_cap, 1 + yn_bonus * (_cnt - 1));

if (variable_instance_exists(id, "base_atk")){
    if (yn_atk_base < 0) yn_atk_base = base_atk;            // 首帧取基准
    if (base_atk != yn_atk_written) yn_atk_base = base_atk;  // 升星 / 护盾改过基准 → 跟着换

    var _want = round(yn_atk_base * yn_atk_mult);
    if (_want != base_atk){
        var _ratio = (base_atk > 0) ? (atk / base_atk) : 1;   // 当前已有的吃拐倍率
        base_atk = _want;
        atk      = base_atk * _ratio;                         // 同帧生效，不等管理器
        yn_atk_written = base_atk;
        buff_applied_id = -1;                                 // 让管理器下帧按新基准重算
    }
}

// ── ③ 索敌：范围内有没有能打的 ──
var _has = false;
var _n   = instance_number(obj_enemy_parent);
for (var _i = 0; _i < _n; _i++){
    var _e = instance_find(obj_enemy_parent, _i);
    if (!instance_exists(_e) || _e.hp <= 0) continue;
    if (abs(_e.grid_col - grid_col) > range_cols) continue;
    if (abs(_e.grid_row - grid_row) > range_rows) continue;
    if (!can_hit(target_type, _e.target_type)) continue;
    _has = true;
    break;
}

if (!_has){
    yn_timer = 0;
    hit_idx  = 0;
    exit;
}

// ── ④ 计时 → 开一轮 ──
yn_timer++;
if (yn_timer >= cycle){
    yn_timer = 0;

    // 一轮总伤害（xlsx 攻击力列就是这个数，已含同类加成），下面两波各拿一半
    yn_dmg = floor(atk);

    atk_t    = 0;                 // 开播攻击段
    hit_idx  = 0;                 // 本轮还没结算
    idle_t   = 0;
}

// ── ⑤ 结算：攻击段播到 HIT_FRAMES 的那一帧，整体打一波 ──
var _hit_now = false;
if (atk_t >= 0 && hit_idx < array_length(HIT_FRAMES)){
    var _af = floor(atk_t / atk_flash_speed);
    if (_af >= HIT_FRAMES[hit_idx]){
        hit_idx++;
        _hit_now = true;
    }
}

if (_hit_now){
    audio_play_sound(snd_hit1, 0, 0);     // 2026-11-12 补：每波结算一次命中音
    // 每波一半：奇数攻击力时第一波 floor、第二波补差，两波合计正好 = 一轮总伤
    var _half = floor(yn_dmg / 2);
    var _val  = (hit_idx >= 2) ? (yn_dmg - _half) : _half;

    var _n2 = instance_number(obj_enemy_parent);
    for (var _j = 0; _j < _n2; _j++){
        var _t = instance_find(obj_enemy_parent, _j);
        if (!instance_exists(_t) || _t.hp <= 0) continue;
        if (abs(_t.grid_col - grid_col) > range_cols) continue;
        if (abs(_t.grid_row - grid_row) > range_rows) continue;
        if (!can_hit(target_type, _t.target_type)) continue;

        with (_t){
            damage_amount         = _val;
            damage_type           = "true";
            damage_source_object  = other.object_index;
            damage_source_card_id = "yuanqiniu";
            // 钻地中的龙渊地精：rotate 能索敌，但伤害会被整条吃掉 → 结算前放行
            if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
            event_user(0);
            damage_source_card_id = "";
        }
    }
}
