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
        if (_n > 1) _spread = (_k == 0) ? -30 : 30;

        // ── 落点 ──
        var _tx, _ty;
        if (instance_exists(_t)){
            _tx = _t.x;
            _ty = _t.y;
        } else {
            _tx = global.grid_offset_x + (global.grid_cols - 1) * global.grid_cell_size_x
                + global.grid_cell_size_x * 0.5;
            _ty = global.grid_offset_y + _lane_row * _cell_h + _cell_h * 0.5;
        }

        // ── 弹道 ──
        //   _ft 帧后正好落到 (_aim_x, _ty)：水平速度 = 距离/帧数；
        //   竖直按 g = 1200/ft² 固定，初速反推出 (600 - dy)/ft —— dy 是「落点比出膛点低多少」，
        //   之前 _dy 算了没用，蛋只是在 45 帧后回到自己的出膛高度就炸，打上下行时爆炸高度是错的。
        var _ft  = clamp(30 + ((_tx - x) / 1000) * 45, 30, 75);
        var _aim_x = max(x, _tx - 50 + _spread);
        var _dx = _aim_x - x;
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

        // 1/2 转贴图：Create 时 shape 还没赋（=0），只能建完再换（同雪球兔写法）
        if (shape == 1)      _b.sprite_index = spr_qiedanlong_bullet_1;
        else if (shape == 2) _b.sprite_index = spr_qiedanlong_bullet_2;
    }
}

qd_fired = true;
audio_play_sound(snd_shot, 0, 0);
