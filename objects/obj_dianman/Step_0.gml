if (global.is_paused) exit;
event_inherited();

live_timer++;

// ── 卡片动画：一轮 60 帧 ──
//   前 45 帧：待机 0~13 循环（3 帧/张）
//   后 15 帧：攻击段 14~28（1 帧/张），其中 index 23 = 卡片第 24 帧 = 放电那一帧
anim_t = (anim_t + 1) mod 60;
if (anim_t < anim_idle_max) image_index = ((anim_t div 3) mod (idle_anim + 1));
else                        image_index = atk_start + (anim_t - anim_idle_max);

// 到「放电那一帧」（卡片第 24 帧）才把电弧点亮，播一遍就熄 —— 放下后、两次放电之间都不显示
if (anim_t == fx_start_frame){
    for (var _k = 0; _k < array_length(fx_list); _k++){
        var _f = fx_list[_k];
        if (instance_exists(_f)){
            _f.active     = true;
            _f.anim_t     = 0;
            _f.image_index = 0;
            _f.image_alpha = 0.85;
        }
    }
    fx_last_index = -1;
}

if (!fx_spawned){
    fx_spawned = true;
    for (var _i = -range_row; _i <= range_row; _i++){
        for (var _j = -range_col; _j <= range_col; _j++){
            var _p = get_world_position_from_grid(grid_col + _j, grid_row + _i);   // 格子中心
            // 2026-11-06 用户口径：**大小保持原样**（obj_dianman_effect 自己 Create 里 image_xscale/yscale = 1.8），
            //   只把整体位置往下挪 1 格 —— 原来锚点摆在格子中心、而贴图是从底边往上劈的 311 高电弧，
            //   观感上整片电弧比卡片高出一格。
            //   要再微调就改 dianman_fx_dy 这一个数：正数=往下，1 格 = grid_cell_size_y（116）
            var dianman_fx_dy = global.grid_cell_size_y;
            var _fx = instance_create_depth(_p.x, _p.y + dianman_fx_dy, depth - 60, obj_dianman_effect);
            _fx.image_index = ((_i + range_row) * 7) mod 13;
            if (shape == 1)      _fx.sprite_index = spr_dianman_effect_1;
            else if (shape == 2) _fx.sprite_index = spr_dianman_effect_2;
            array_push(fx_list, _fx);
        }
    }
}

// 伤害跟**脚下电弧特效**走：电弧播到第 6 帧（image_index 5）时结算一次
//   电弧由本体统一创建、同帧推进，取第一个实例的 image_index 代表整片
//   fx_last_index 用来防止「第 6 帧要停 4 帧」被连续结算 4 次
var _do_hit = false;
if (array_length(fx_list) > 0 && instance_exists(fx_list[0])){
    var _fx_i = fx_list[0].image_index;
    if (_fx_i == fx_fire_frame && fx_last_index != _fx_i) _do_hit = true;
    fx_last_index = _fx_i;
}

if (_do_hit){

    with (obj_enemy_parent){
        if (hp <= 0) continue;
        if (abs(grid_col - other.grid_col) > other.range_col) continue;
        if (abs(grid_row - other.grid_row) > other.range_row) continue;
        // 可攻击：陆 / 空 / 地鼠军（2026-11-06 按卡面）；非主流(dance) 与 幽灵(invisible) 除外
        //   rotate 名单本身含 dance / invisible，所以这里按**敌人类型**再剔一次
        //   （旧写法误用了 target_type —— 那是卡片自己的 "rotate"，条件永远不成立）
        if (!can_hit(other.target_type, target_type)) continue;
        if (other.target_type == "dance" || other.target_type == "invisible") continue;

        // 伤害照常（2026-11-06 用户口径：BOSS 也要吃伤害）
        damage_amount = other.atk;
        damage_type = "true";
        event_user(0);

        // 定身对 BOSS 无效，只有非 BOSS 才定
        if (!is_boss && hp > 0 && stun_timer < other.stun_frames) stun_timer = other.stun_frames;
    }
}

// 到期淡出
if (live_timer >= life_time){
    image_alpha -= 0.06;
    if (image_alpha <= 0){
        instance_destroy();
    }
}
