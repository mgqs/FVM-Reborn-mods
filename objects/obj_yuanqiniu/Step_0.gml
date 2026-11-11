// obj_yuanqiniu Step 事件
// ① 帧推进（待机 / 气泡两组）② 范围内有敌才计时 → 到点开一波 → 按 yn_wave_gap 结算每一波
if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── ① 帧推进 ──
var _frames = yn_use_bub ? yn_bub_frames : yn_idle_frames;

yn_frame_t++;
if (yn_frame_t >= flash_speed){
    yn_frame_t = 0;
    yn_frame_i++;
    if (yn_frame_i >= array_length(_frames)){
        yn_frame_i = 0;
        if (yn_use_bub){
            yn_use_bub = false;      // 气泡组只播一遍，播完回待机
            _frames = yn_idle_frames;
        }
    }
}
image_index = _frames[yn_frame_i];   // 每帧都写：父对象也在推帧

// ── ② 索敌：范围内有没有能打的 ──
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
    yn_timer      = 0;
    yn_waves_left = 0;
    yn_wave_t     = 0;
    exit;
}

// ── 计时 → 开一轮 ──
yn_timer++;
if (yn_timer >= cycle){
    yn_timer = 0;

    // 同类加成：场上同形态元气牛数量（含自己），11 只到上限 2 倍
    yn_same_tmp = 0;
    with (obj_yuanqiniu){
        if (shape == other.shape) other.yn_same_tmp++;
    }
    var _cnt = max(1, yn_same_tmp);
    yn_same_tmp = 0;
    yn_atk_mult = min(yn_cap, 1 + yn_bonus * (_cnt - 1));

    // 一轮总伤害按波数平分，奇数余数补给最后一波
    yn_wave_gap   = max(6, floor(cycle / yn_waves));
    yn_dmg        = floor(atk * yn_atk_mult);
    yn_waves_left = yn_waves;
    yn_wave_t     = 0;
    yn_use_bub    = true;         // 播气泡组
    yn_frame_i    = 0;
    yn_frame_t    = 0;
}

// ── 每 yn_wave_gap 帧结算一波 ──
if (yn_waves_left > 0){
    yn_wave_t++;
    if (yn_wave_t >= yn_wave_gap || (yn_waves_left == yn_waves && yn_wave_t == 1)){
        yn_wave_t = 0;
        var _per = floor(yn_dmg / yn_waves);
        var _val = _per;
        if (yn_waves_left == 1) _val = yn_dmg - _per * (yn_waves - 1);   // 最后一波吃余数

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

        yn_waves_left--;
    }
}
