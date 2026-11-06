if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// 索敌：5×5 内有没有能打的
var _has = false;
for (var _i = 0; _i < instance_number(obj_enemy_parent); _i++){
    var _e = instance_find(obj_enemy_parent, _i);
    if (!instance_exists(_e) || _e.hp <= 0) continue;
    if (abs(_e.grid_col - grid_col) > range_col) continue;
    if (abs(_e.grid_row - grid_row) > range_row) continue;
    if (!can_hit(target_type, _e.target_type)) continue;
    _has = true;
    break;
}

if (_has){
    atk_timer++;
    // 攻击间隔读注册表 cycle（技能 9 档 108→78）。原来写死 atk_interval = 108，技能/星级全打不进来
    if (atk_timer >= max(30, cycle)){
        atk_timer = 0;
        atk_t = 0;
        hit_idx = 0;
    }
}
else{
    atk_timer = 0;
    hit_idx = 0;
}

// 到结算帧就整片结算一次
var _hit_now = false;
if (atk_t >= 0 && hit_idx < array_length(HIT_FRAMES)){
    var _af = floor(atk_t / atk_flash_speed);
    if (_af >= HIT_FRAMES[hit_idx]){
        hit_idx++;
        _hit_now = true;
    }
}

if (_hit_now){
    // 一轮总伤 = atk（2 转 ×1.2），按结算次数均分，最后一份补差
    var _total = round(atk * range_mult);
    var _per = floor(_total / K);
    if (hit_idx >= K) _per = _total - _per * (K - 1);
    if (_per < 1) _per = 1;

    for (var _j = 0; _j < instance_number(obj_enemy_parent); _j++){
        var _t = instance_find(obj_enemy_parent, _j);
        if (!instance_exists(_t) || _t.hp <= 0) continue;
        if (abs(_t.grid_col - grid_col) > range_col) continue;
        if (abs(_t.grid_row - grid_row) > range_row) continue;
        if (!can_hit(target_type, _t.target_type)) continue;
        with (_t){
            damage_amount = _per;
            damage_type = "true";
            event_user(0);
        }
    }
}

// 帧推进
if (atk_t >= 0){
    var _idx = SEG_ATK_FIRST + floor(atk_t / atk_flash_speed);
    if (_idx > SEG_ATK_FIRST + SEG_ATK_LEN - 1){
        atk_t = -1;
        idle_t = 0;
    }
    else{
        image_index = _idx;
        atk_t++;
    }
}

if (atk_t < 0){
    idle_t++;
    image_index = floor(idle_t / flash_speed) mod SEG_IDLE_LEN;
}
