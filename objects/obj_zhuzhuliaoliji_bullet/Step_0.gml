// obj_zhuzhuliaoliji_bullet Step 事件
if (global.is_paused){
    image_speed = 0;
    exit
}

// 二转第二发：延后 delay 帧再出膛
if (delay > 0){
    delay--;
    exit
}

if (burnt > 0){
    sprite_index = spr_fire_bullet;
    image_index = (life div 4) mod sprite_get_number(spr_fire_bullet);
}

x += vx;
y += vy;
life++;

if (x > 2200 || x < -200 || y > 1200 || y < -400){
    instance_destroy();
    exit
}

if (variable_global_exists("enemy_by_type") && precise_bbox_prepare(id)){
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
            // 1 转起：命中减速 1.5 秒（BOSS 也吃）
            if (other.slow_frames > 0 && ice_timer < other.slow_frames) ice_timer = other.slow_frames;
        }
        if (burnt != 0){
            var _fx = instance_create_depth(x, y, depth, obj_fire_bullet_effect);
            _fx.sprite_index = spr_fire_bullet_effect;
        }
        instance_destroy();
        exit
    }
}
