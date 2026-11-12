// obj_zhuzhuliaoliji_bullet Step 事件
if (global.is_paused){
    image_speed = 0;
    exit
}

life++;

// 🔴 2026-11-07 用户口径：**刀片动画砍掉**，整颗子弹只显示第 0 帧（静态贴图），
//   省掉每帧的推帧运算。过火后的火焰贴图仍然播（那是另一张精灵，帧数在 Create 缓存好）。
//   sprite_index 也只在过火切换时赋值一次，不每帧重设。
if (burnt > 0){
    if (sprite_index != spr_fire_bullet) sprite_index = spr_fire_bullet;
    image_index = (life div 4) mod _fire_frames;
}
else{
    if (sprite_index != spr_zhuzhuliaoliji_bullet) sprite_index = spr_zhuzhuliaoliji_bullet;
    image_index = 0;
}

// 朝向按当前速度重算：5 个方向各自贴着自己弹道，反弹（水神 / 樱桃布丁）翻向后也不会歪
image_angle = point_direction(0, 0, vx, vy);

x += vx;
y += vy;

// 🔴 2026-11-07 性能：**出图即销毁**。
//   原来只判 2200 / 1200 / -200 / -400，刀片飞出战斗区后还要横穿商店货架 / 边框飞很久
//   （右上、右下两发 `vx=5` 要飞 300+ 帧才出界），期间每 3 帧还要跑一次 SAP 候选查询、每帧还要画。
//   销毁线 = 战斗区外**放宽一格**（出图那一列刚刷出来的老鼠仍可打），左侧再放 150px（老鼠判输线）。
var _bx_l = global.grid_offset_x - 150;
var _bx_r = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x + global.grid_cell_size_x;
// 2026-11-07：右边界跟着「最右的那只老鼠」走（出怪列 = 9 + x_offset，同一行连刷会排到第 11、12 列）
if (variable_global_exists("enemy_max_right")) _bx_r = max(_bx_r, global.enemy_max_right + global.grid_cell_size_x);
var _bx_t = global.grid_offset_y - global.grid_cell_size_y;
var _bx_b = global.grid_offset_y + global.grid_rows * global.grid_cell_size_y + global.grid_cell_size_y;
if (x < _bx_l || x > _bx_r || y < _bx_t || y > _bx_b){
    instance_destroy();
    exit
}

// 🔴 2026-11-07 性能：**每 hit_interval 帧才判一次**（本卡 3 帧 = 24px，仍小于合体碰撞宽度，不会打空），
//   并且先用 bullet_enemy_reachable 早退（子弹已经飞过所有敌人就不用算了）。
hit_tick++;
if (hit_tick < hit_interval) exit;

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
        audio_play_sound(snd_hit1, 0, 0);     // 2026-11-12 补：命中音
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
