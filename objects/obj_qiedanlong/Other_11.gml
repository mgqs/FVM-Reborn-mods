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

    for (var _k = 0; _k < _n; _k++){
        var _spread = 0;
        // 同一路两发：只做 ±16 的小错位（都在 3×3 溅射内），保证两发都砸在同一只身上
        if (_n > 1) _spread = (_k == 0) ? -16 : 16;

        // ── 落点 ──
        var _tx, _ty;
        if (instance_exists(_t)){
            // 2026-11-13：加预判 —— 蛋要飞 ~45 帧，老鼠这期间会往左走一格多。
            //   原来直接瞄「当前 x」，蛋落下来时老鼠早走了 → 看着像落在第一发的位置 / 砸不到鼠。
            var _espd    = variable_instance_exists(_t, "move_speed") ? _t.move_speed : 0;
            var _rough   = clamp((_t.x - x) / 7.0, 20, 70);
            _tx = _t.x - _espd * _rough;
            _ty = _t.y;
        } else {
            // 空行：丢到最右一格、**该行的地面**爆（格子中心会看着在“半空”）
            _tx = global.grid_offset_x + (global.grid_cols - 1) * global.grid_cell_size_x
                + global.grid_cell_size_x * 0.5;
            _ty = global.grid_offset_y + (_lane_row + 1) * _cell_h;
        }

        // ── 弹道 ──
        //   _ft 帧后正好落到 (_aim_x, _ty)：水平速度 = 距离/帧数；
        //   竖直按 g = 1200/ft² 固定，初速反推出 (600 - dy)/ft —— dy 是「落点比出膛点低多少」，
        //   之前 _dy 算了没用，蛋只是在 45 帧后回到自己的出膛高度就炸，打上下行时爆炸高度是错的。
        // 2026-11-13 修「蛋原地打圈再过去」：
        //   旧版 _aim_x = max(x, _tx - 50)：老鼠和自己同一列时 _aim_x == x → _dx = 0
        //   → move_speed = 0，蛋純直上直下、原地打个圈才落；老鼠很近（1 格）时水平速度也只有 1~2px/帧，看着像"停住"。
        //   现在落点至少往前 2 格，且水平速度按固定 ~7px/帧 反推帧数，短距离也会正常飞出去。
        var _aim_x = max(x + global.grid_cell_size_x * 2, _tx + _spread);
        var _dx = _aim_x - x;
        var _ft  = clamp(_dx / 7.0, 20, 70);
        var _dy = _ty - (y - qd_art_up);

        var _b = instance_create_depth(x - 40 + (_k * 20 - 10), y - qd_art_up, depth - 500, obj_qiedanlong_bullet);
        _b.damage         = atk;
        _b.base_atk       = atk;
        _b.shape          = shape;
        _b.row            = _lane_row;
        _b.target_type    = target_type;
        _b.hittable_types = get_hittable_enemy_types(target_type);
        _b.splash_ratio   = qd_splash_ratio;
        _b.splash_cells   = qd_splash_cells;
        _b.thrower_y      = y;
        _b.land_y         = _ty;

        _b.move_speed = _dx / _ft;
        _b.cgravity   = 1200 / (_ft * _ft);
        _b.cvspeed    = (600 - _dy) / _ft;
        _b.flight_ft  = _ft;        // 飞满这么多帧就在落点爆（不再用 bbox 判半路命中）

        // 1/2 转贴图：Create 时 shape 还没赋（=0），只能建完再换（同雪球兔写法）
        if (shape == 1)      _b.sprite_index = spr_qiedanlong_bullet_1;
        else if (shape == 2) _b.sprite_index = spr_qiedanlong_bullet_2;
    }
}

qd_fired = true;
audio_play_sound(snd_shot, 0, 0);
