/// 窃蛋龙 开火事件：向前方最多 3 行投掷龙蛋
/// 每行独立找该行最靠前的目标作为落点；无目标行投到最右侧
var _cell_h = global.grid_cell_size_y;

for (var _i = 0; _i < array_length(qd_lane_rows); _i++){
    var _lane_row = grid_row + qd_lane_rows[_i];
    if (_lane_row < 0 || _lane_row >= global.grid_rows) continue;

    // ── 找该行最靠前的目标 ──
    var _t = noone;
    with (obj_enemy_parent){
        if (hp > 0 && target_type != "obstacle"
            && grid_row == _lane_row
            && grid_col >= other.grid_col
            && grid_col <= global.grid_cols + 1
            && can_target_on(other.target_type, target_type)){
            if (!instance_exists(_t) || grid_col > _t.grid_col){
                _t = id;
            }
        }
    }

    var _n = qd_lane_n[_i];

    // ── 落点：同一路所有蛋**共用一个点**（2026-11-13 用户口径：两个蛋先后到同一个格就行）──
    var _aim_x, _aim_y;
    if (instance_exists(_t)){
        // 预判：蛋飞 ~45 帧，老鼠这期间会往左走一格多
        var _espd  = variable_instance_exists(_t, "move_speed") ? _t.move_speed : 0;
        var _rough = clamp((_t.x - x) / 7.0, 20, 70);
        _aim_x = _t.x - _espd * _rough;
        _aim_y = _t.y;                       // 老鼠脚底 = 砸头/砸身
    } else {
        // 空路：炸在**最右那一格的格心**
        //   2026-11-13 用户口径：以前落在「老鼠脚底线」（格心 + 38），实际是格子的下沿，
        //   看着像掉进下一行、也像炸在格子外面；现在就是格心，3×3 溅射也以这一格为中心。
        _aim_x = global.grid_offset_x + (global.grid_cols - 1) * global.grid_cell_size_x
            + global.grid_cell_size_x * 0.5;
        _aim_y = global.grid_offset_y + _lane_row * _cell_h + _cell_h * 0.5;
    }

    // 不越出最后一格（右边缘留 24px），也不要原地丢
    var _max_x = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x - 24;
    _aim_x = clamp(_aim_x, x + global.grid_cell_size_x * 2, _max_x);

    var _spawn_x = x - 40;

    for (var _k = 0; _k < _n; _k++){
        // 同路第 2 发：落点完全一样，只**晚 6 帧到**（先后砸在同一个格），不再左右错开
        var _ft  = clamp((_aim_x - _spawn_x) / 7.0, 20, 70) + _k * 6;
        var _dy  = _aim_y - (y - qd_art_up);

        var _b = instance_create_depth(_spawn_x, y - qd_art_up, depth - 500, obj_qiedanlong_bullet);
        _b.damage         = atk;
        _b.base_atk       = atk;
        _b.shape          = shape;
        _b.row            = _lane_row;
        _b.target_type    = target_type;
        _b.hittable_types = get_hittable_enemy_types(target_type);
        _b.splash_ratio   = qd_splash_ratio;
        _b.splash_cells   = qd_splash_cells;
        _b.thrower_y      = y;
        _b.land_y         = _aim_y;
        _b.land_target    = instance_exists(_t) ? _t.id : noone;   // 落点那只（爆炸跟着它走位）

        _b.move_speed = (_aim_x - _spawn_x) / _ft;
        _b.cgravity   = 1200 / (_ft * _ft);
        _b.cvspeed    = (600 - _dy) / _ft;
        _b.flight_ft  = _ft;        // 飞满这么多帧就在落点爆

        // 1/2 转贴图：Create 时 shape 还没赋（=0），只能建完再换（同雪球兔写法）
        if (shape == 1)      _b.sprite_index = spr_qiedanlong_bullet_1;
        else if (shape == 2) _b.sprite_index = spr_qiedanlong_bullet_2;
    }
}

qd_fired = true;
audio_play_sound(snd_shot, 0, 0);
