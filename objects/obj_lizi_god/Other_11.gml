/// @desc 栗子神 · 投掷攻击（参考祝融的抛物线投掷 + 范围爆炸灼烧）
///  shape 0-1: 单行投掷，落地后范围灼烧
///  shape 2:   灵魂融合 —— 永远三行各投一颗（不论该行有无敌人），落地后范围灼烧
///  shape >=1: 深度融合 —— 每「深度爆炸周期」轮追加一次 3×3 深度爆炸（首次攻击即爆炸）
///  射程：落点最远 = 卡片 range（8 格），且不超出本行末尾格；索敌同范围（见 Step_0）

var _max = range;
var _last_col = global.grid_cols - 1;              // 本行末尾格（子弹不会出格）
var _far_col = min(grid_col + _max, _last_col);    // 无目标时的落点：射程能达到的最远格

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
    // 每行挑最靠前的敌人（没有则记 -4，落到射程最远格）
    var _targets = [-4, -4, -4];
    var _mx = [99999, 99999, 99999];

    with (obj_enemy_parent)
    {
        if (hp > 0 && can_target_on(other.target_type, target_type)
            && grid_col >= other.grid_col && grid_col <= (other.grid_col + _max))
        {
            var _lane = 1 + (grid_row - other.grid_row);   // -1 行→0 / 本行→1 / +1 行→2
            if (_lane >= 0 && _lane <= 2 && x < _mx[_lane])
            {
                _mx[_lane] = x;
                _targets[_lane] = id;
            }
        }
    }

    var _lane_h = global.grid_cell_size_y;
    var _lane_off = [-_lane_h, 0, _lane_h];    // 三行的纵向偏移（-1 / 0 / +1 行）
    var _lane_depth = [0, -45, -90];           // 三行的绘制深度偏移
    var _last_row = global.grid_rows - 1;

    for (var _i = 0; _i < 3; _i++)
    {
        // 边路补偿：最上行时「更上路」并回本行，最下行时「更下路」并回本行
        var _row = clamp(grid_row + _i - 1, 0, _last_row);
        // 出手位置/深度按「最终落行」算：补偿后同行的两颗从同一处出手，不会看着像跨行飞
        var _lane_index = (_row - grid_row) + 1;
        var _t = _targets[_i];
        // 有敌人 → 打敌人所在列；没有敌人 → 射程最远格；两者都不超出本行末尾格
        var _col = (_t != -4) ? min(_t.grid_col, _far_col) : _far_col;
        _col = min(_col, _last_col);

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
        final_col = min(target_instance.grid_col, _far_col);
    final_col = min(final_col, _last_col);

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
