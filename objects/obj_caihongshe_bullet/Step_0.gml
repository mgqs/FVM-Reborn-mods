if (global.is_paused) exit;

// 命中特效播放中：停在命中点，不再移动、不再判定，播完销毁
if (hit_playing){
    hit_t++;
    var _fx_step = hit_t div hit_fx_speed;
    if (_fx_step > hit_fx_last - hit_fx_first){
        instance_destroy();
        exit;
    }
    image_index = hit_fx_first + _fx_step;
    exit;
}

x += move_speed;
y += vy;
life++;

if (x > 2200 || x < -200 || y > 1200 || y < -400){
    instance_destroy();
    exit
}

// 🔴 2026-11-07 性能：隔 global.bullet_hit_interval 帧判一次 + 飞出所有敌人后早退（同全工程其它子弹）
hit_tick++;
if (hit_tick < global.bullet_hit_interval) exit;

hit_tick = 0;
if (variable_global_exists("enemy_by_type") && bullet_enemy_reachable(id) && precise_bbox_prepare(id)){
    var _al = global._pbc_l;
    var _ar = global._pbc_r;
    var _at = global._pbc_t;
    var _aq = global._pbc_b;
    var _hit = noone;
    for (var _t = 0; _t < array_length(hittable_types) && _hit == noone; _t++){
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = bullet_sap_type_list(id, _key);
        for (var _i = 0; _i < array_length(_list); _i++){
            var _e = _list[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;
            if (_e.bbox_right < _al || _e.bbox_left > _ar || _e.bbox_bottom < _at || _e.bbox_top > _aq) continue;
            _hit = _e;
            break;
        }
    }
    if (_hit != noone){
        with (_hit){
            damage_amount = other.damage;
            damage_type = other.damage_type;
            event_user(0);
            // 定身对 BOSS 无效（2026-11-06 用户口径）；伤害照常结算
            if (!is_boss && irandom(99) < other.stun_chance){
                if (stun_timer < other.stun_frames) stun_timer = other.stun_frames;
            }
        }
        // 命中：不立刻消失，原地播攻击特效（步骤见文件开头），播完由上面那段销毁
        hit_playing = true;
        hit_t = 0;
        image_index = hit_fx_first;
        exit
    }
}
