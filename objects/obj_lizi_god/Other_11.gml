/// @desc 栗子神 · 投掷攻击（参考祝融的抛物线投掷 + 范围爆炸灼烧）
///  shape 0-1: 单行投掷，落地后范围灼烧
///  shape 2:   灵魂融合 —— 永远三行各投一颗（不论该行有无敌人），落地后范围灼烧
///  shape >=1: 深度融合 —— 每「深度爆炸周期」轮追加一次 3×3 深度爆炸（首次攻击即爆炸）
///  落点：目标所在**格子**，**不夹地图列**（同生煎锅的射程口径：老鼠排到多外面就丢多外面）

var _max = range;
var _far_col = min(grid_col + _max, global.grid_cols);   // 只有「该行没有敌人」时才用：射程能达到的最远格

// 深度融合：按「深度爆炸周期」轮数决定本次攻击是否附带深度爆炸
var _deep_boom = false;
if (shape >= 1) {
    if (deep_boom_counter <= 0) {
        _deep_boom = true;
        deep_boom_counter = max(1, deep_boom_period) - 1;
    } else {
        deep_boom_counter--;
    }
}
var _bullet_spr = spr_lizi_god_bullet;
if (shape == 1)
    _bullet_spr = spr_lizi_god_bullet_1;
else if (shape >= 2)
    _bullet_spr = spr_lizi_god_bullet_2;

if (shape >= 2)
{
    // ===== 灵魂融合：三行同时投掷 =====
    // 每一行**单独找最近的一只**：最上/最下行被夹回本行时，补偿的那一发也按本行正常索敌，
    //   不再固定丢到射程最远格（2026-11-01 修正）
    var _last_row = global.grid_rows - 1;
    var _lane_col = [-1, -1, -1];
    var _lane_e   = [noone, noone, noone];   // 该行锁定的目标实例（提前量要读它的 move_speed）

    for (var _i = 0; _i < 3; _i++)
    {
        var _row_q = clamp(grid_row + _i - 1, 0, _last_row);
        var _best = 99999;
        var _bc = -1;
        var _be = noone;
        with (obj_enemy_parent)
        {
            if (hp > 0 && grid_row == _row_q
                && grid_col >= other.grid_col
                && can_target_on(other.target_type, target_type))
            {
                var _dd = grid_col - other.grid_col;
                if (_dd < _best)
                {
                    _best = _dd;
                    _bc = grid_col;
                    _be = id;
                }
            }
        }
        _lane_col[_i] = _bc;
        _lane_e[_i] = _be;
    }

    var _lane_h = global.grid_cell_size_y;
    var _lane_off = [-_lane_h, 0, _lane_h];    // 三行的纵向偏移（-1 / 0 / +1 行）
    var _lane_depth = [0, -45, -90];           // 三行的绘制深度偏移

    for (var _j = 0; _j < 3; _j++)
    {
        // 边路补偿：最上行时「更上路」并回本行，最下行时「更下路」并回本行
        var _row = clamp(grid_row + _j - 1, 0, _last_row);
        // 出手位置/深度按「最终落行」算：补偿后同行的两颗从同一处出手，不会看着像跨行飞
        var _lane_index = (_row - grid_row) + 1;
        var _col = (_lane_col[_j] != -1) ? _lane_col[_j] : _far_col;

        // 提前量（同糖炒栗子 / 生煎锅）：按该行目标的移动速度把落点往前推整格
        if (_lane_e[_j] != noone && instance_exists(_lane_e[_j])
            && variable_instance_exists(_lane_e[_j], "move_speed") && _lane_e[_j].move_speed > 0)
        {
            var _ft0 = clamp(30 + ((get_world_position_from_grid(_col, _row).x - (x + 20)) / 1000) * 45, 30, 75);
            _col = max(0, _col - round(_lane_e[_j].move_speed * _ft0 / global.grid_cell_size_x));
        }

        var _off = _lane_off[_lane_index];
        var inst = instance_create_depth(x + 20, y - 105 + _off, depth + _lane_depth[_lane_index], obj_lizi_god_bullet);
        inst.damage = atk;
        inst.row = _row;
        inst.thrower_y = y + _off;
        inst.shape = shape;
        inst.sprite_index = _bullet_spr;
        inst.deep_boom = _deep_boom;
        inst.deep_boom_damage = deep_boom_damage;

        var _grid_pos = get_world_position_from_grid(_col, _row);
        var _dx = _grid_pos.x - inst.x;
        var _ft = clamp(30 + ((_dx / 1000) * 45), 30, 75);
        inst.move_speed = _dx / _ft;
        inst.cgravity = (2 * 500) / (_ft * _ft);
        inst.cvspeed = 500 / _ft;
        inst.target_col = _col;
        inst.target_x = _grid_pos.x;
        inst.target_y = _grid_pos.y;
        inst.has_target = true;
        inst.hit_enemy = false;
    }
}
else
{
    // ===== shape 0-1：单行投掷（参考祝融） =====
    var inst = instance_create_depth(x + 20, y - 105, depth - 45, obj_lizi_god_bullet);
    audio_play_sound(snd_throw, 0, 0);
    inst.damage = atk;
    inst.row = grid_row;
    inst.thrower_y = y;
    inst.shape = shape;
    inst.sprite_index = _bullet_spr;
    inst.deep_boom = _deep_boom;
    inst.deep_boom_damage = deep_boom_damage;

    var final_col = _far_col;
    if (target_instance != -4 && instance_exists(target_instance))
        final_col = target_instance.grid_col;      // 不夹列：老鼠在哪一列就丢哪一列

    // 提前量（同糖炒栗子 / 生煎锅）
    if (target_instance != -4 && instance_exists(target_instance)
        && variable_instance_exists(target_instance, "move_speed") && target_instance.move_speed > 0)
    {
        var _ft0 = clamp(30 + ((get_world_position_from_grid(final_col, grid_row).x - inst.x) / 1000) * 45, 30, 75);
        final_col = max(0, final_col - round(target_instance.move_speed * _ft0 / global.grid_cell_size_x));
    }

    var grid_pos = get_world_position_from_grid(final_col, grid_row);
    var distance_x = grid_pos.x - inst.x;
    var flight_time = clamp(30 + ((distance_x / 1000) * 45), 30, 75);
    inst.move_speed = distance_x / flight_time;
    inst.cgravity = (2 * 500) / (flight_time * flight_time);
    inst.cvspeed = 500 / flight_time;
    inst.target_col = final_col;
    inst.target_x = grid_pos.x;
    inst.target_y = grid_pos.y;
    inst.has_target = true;
    inst.hit_enemy = false;
}
