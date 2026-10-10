/// @desc 融合煮蛋器 · 投掷攻击
///  shape 0-1: 单行投掷（本行两枚）
///  shape 2:   灵魂融合 —— 三行各投两枚（不论该行有无敌人），未索敌到的行投到本行末尾格
///  索敌与本体「煮蛋器投手」同款：本行 + 前方（列不设上限），灵魂融合起扩到三行（见 Step_0）

var _last_col = global.grid_cols - 1;             // 本行末尾格（子弹不会出格）
var _last_row = global.grid_rows - 1;

var _spr = spr_ronghedan_god_bullet;
if (shape == 1)
    _spr = spr_ronghedan_god_bullet_1;
else if (shape >= 2)
    _spr = spr_ronghedan_god_bullet_2;

if (shape >= 2)
{
    // ===== 灵魂融合：三行同时投掷 =====
    // 每行挑最靠前的敌人（没有则记 -4，投到本行末尾格）
    var _targets = [-4, -4, -4];
    var _mx = [99999, 99999, 99999];

    with (obj_enemy_parent)
    {
        if (hp > 0 && can_target_on(other.target_type, target_type)
            && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1))
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
    var _lane_off = [-_lane_h, 0, _lane_h];    // 三行的纵向出手偏移（-1 / 0 / +1 行）
    var _lane_depth = [0, -45, -90];           // 三行的绘制深度偏移

    for (var _i = 0; _i < 3; _i++)
    {
        // 边路补偿：最上行时「更上路」并回本行，最下行时「更下路」并回本行
        var _row = clamp(grid_row + _i - 1, 0, _last_row);
        // 出手位置/深度按「最终落行」算：补偿后同行的两颗从同一处出手，不会看着像跨行飞
        var _lane_index = (_row - grid_row) + 1;
        var _t = _targets[_i];
        // 有敌人 → 打敌人所在列；没有敌人 → 本行末尾格
        var _col = (_t != -4) ? _t.grid_col : _last_col;

        var _off = _lane_off[_lane_index];
        var _spawn_y = y - 125 + _off;
        var _spawn_depth = depth - 500 + _lane_depth[_lane_index];

        for (var _n = 0; _n < 2; _n++)
        {
            var inst = instance_create_depth(x - 40 + (_n * 20 - 10), _spawn_y, _spawn_depth, obj_ronghedan_god_bullet);

            inst.sprite_index = _spr;
            inst.image_speed = 0;
            inst.image_index = 0;

            inst.damage = atk;
            inst.original_damage = atk;
            inst.row = _row;
            inst.thrower_y = y + _off;
            inst.shape = shape;
            inst.stun_chance = stun_chance;
            inst.stun_duration = stun_duration;
            inst.poison_damage = poison_damage;
            inst.splash_ratio = splash_ratio;

            var _spread = (_n == 0) ? -30 : 30;
            var _aim_x = 0;
            var _ft = 30;

            if (_t != -4 && instance_exists(_t))
            {
                // 打敌人：按目标速度预判落点（沿用原公式）
                _ft = clamp(30 + ((_t.x - inst.x) / 1000) * 45, 30, 75);
                _aim_x = max(x, _t.x - _t.move_speed * _ft - 50 + _spread);
                inst.target_enemy = _t;
            }
            else
            {
                // 没有敌人：投到本行射程最远格
                var _gp = get_world_position_from_grid(_col, _row);
                _aim_x = _gp.x;
                _ft = clamp(30 + ((_aim_x - inst.x) / 1000) * 45, 30, 75);
                inst.target_enemy = noone;
            }

            var _dx = _aim_x - inst.x;
            inst.move_speed = _dx / _ft;
            inst.cgravity = 1200 / (_ft * _ft);
            inst.cvspeed = 600 / _ft;
            inst.has_target = true;

            inst.hit_enemy = false;
            inst.has_splashed = false;
        }
    }
}
else
{
    // ===== shape 0-1：单行投掷 =====
    var _t = (target_instance != noone && instance_exists(target_instance)) ? target_instance : -4;
    var _col = (_t != -4) ? _t.grid_col : _last_col;

    for (var _n = 0; _n < 2; _n++)
    {
        var inst = instance_create_depth(x - 40 + (_n * 20 - 10), y - 125, depth - 500, obj_ronghedan_god_bullet);

        inst.sprite_index = _spr;
        inst.image_speed = 0;
        inst.image_index = 0;

        inst.damage = atk;
        inst.original_damage = atk;
        inst.row = grid_row;
        inst.thrower_y = y;
        inst.shape = shape;
        inst.stun_chance = stun_chance;
        inst.stun_duration = stun_duration;
        inst.poison_damage = poison_damage;
        inst.splash_ratio = splash_ratio;

        var _spread = (_n == 0) ? -30 : 30;
        var _aim_x = 0;
        var _ft = 30;

        if (_t != -4 && instance_exists(_t))
        {
            _ft = clamp(30 + ((_t.x - inst.x) / 1000) * 45, 30, 75);
            _aim_x = max(x, _t.x - _t.move_speed * _ft - 50 + _spread);
            inst.target_enemy = _t;
        }
        else
        {
            var _gp = get_world_position_from_grid(_col, grid_row);
            _aim_x = _gp.x;
            _ft = clamp(30 + ((_aim_x - inst.x) / 1000) * 45, 30, 75);
            inst.target_enemy = noone;
        }

        var _dx = _aim_x - inst.x;
        inst.move_speed = _dx / _ft;
        inst.cgravity = 1200 / (_ft * _ft);
        inst.cvspeed = 600 / _ft;
        inst.has_target = true;

        inst.hit_enemy = false;
        inst.has_splashed = false;
    }
}
