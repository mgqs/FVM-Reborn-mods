if (global.is_paused) exit;

t++;

var _idx = 10 + (t div 3);
if (_idx > 19)
{
    instance_destroy();
    exit;
}
image_index = _idx;

if (t == 1)
{
    if (shape == 1) sprite_index = spr_guihuajiu_1;
    else if (shape >= 2) sprite_index = spr_guihuajiu_2;
    else sprite_index = spr_guihuajiu;
}

if (!fired)
{
    fired = true;

    hit_cols = [];
    hit_rows = [];

    if (boom_cross)
    {
        array_push(hit_cols, grid_col);     array_push(hit_rows, grid_row);
        array_push(hit_cols, grid_col - 1); array_push(hit_rows, grid_row);
        array_push(hit_cols, grid_col + 1); array_push(hit_rows, grid_row);
        array_push(hit_cols, grid_col);     array_push(hit_rows, grid_row - 1);
        array_push(hit_cols, grid_col);     array_push(hit_rows, grid_row + 1);
    }
    else
    {
        array_push(hit_cols, grid_col);
        array_push(hit_rows, grid_row);
    }

    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;

        var _hit = false;
        for (var _c = 0; _c < array_length(other.hit_cols); _c++)
        {
            if (grid_col == other.hit_cols[_c] && grid_row == other.hit_rows[_c])
            {
                _hit = true;
                break;
            }
        }
        if (!_hit) continue;

        damage_amount = other.boom_damage;
        damage_type   = other.boom_type;
        event_user(0);

        if (other.drunk_time > 0 && !is_boss)
        {
            drunk_timer = other.drunk_time;
            drunk_mult  = other.drunk_mult;
            if (!variable_instance_exists(id, "drunk_fx") || !instance_exists(drunk_fx))
            {
                drunk_fx = instance_create_depth(x, y, depth - 2, obj_guihuajiu_drunk);
                drunk_fx.target = id;
            }
        }
    }

    fire_cols = [];
    fire_rows = [];

    if (burn_cross)
    {
        array_push(fire_cols, grid_col);     array_push(fire_rows, grid_row);
        array_push(fire_cols, grid_col - 1); array_push(fire_rows, grid_row);
        array_push(fire_cols, grid_col + 1); array_push(fire_rows, grid_row);
        array_push(fire_cols, grid_col);     array_push(fire_rows, grid_row - 1);
        array_push(fire_cols, grid_col);     array_push(fire_rows, grid_row + 1);
    }
    else
    {
        array_push(fire_cols, grid_col);     array_push(fire_rows, grid_row);
        array_push(fire_cols, grid_col + 1); array_push(fire_rows, grid_row);
    }

    // 🔧 火格尺寸/位置可调
    //   火苗实心内容框（spr_guihuajiu_burn index 1~13 的 alpha≥128 并集）= x 35~107 / y 38~125，中心 (71,125)
    //   按实心框缩放到整格（原来按整张画布 136x158 缩 → 火苗只占半格，看不清）
    var _fw = 72, _fh = 87, _fcx = 71, _fcy = 125;
    var _fire_dx = 0, _fire_dy = 0;   // 往右 / 往上（负 = 上）微调
    var _fire_scale = 1.0;            // 整体再放大/缩小：1.0 = 实心框正好铺满一格

    var _fsx = global.grid_cell_size_x / _fw * _fire_scale;
    var _fsy = global.grid_cell_size_y / _fh * _fire_scale;

    for (var _f = 0; _f < array_length(fire_cols); _f++)
    {
        var _fc = fire_cols[_f];
        var _fr = fire_rows[_f];
        if (_fc < 0 || _fc >= global.grid_cols || _fr < 0 || _fr >= global.grid_rows) continue;

        var _pos = get_world_position_from_grid(_fc, _fr);
        var _cell_bottom = _pos.y + global.grid_cell_size_y * 0.5;
        var _bx = (_pos.x + _fire_dx) - (_fcx - sprite_get_xoffset(spr_guihuajiu_burn)) * _fsx;
        var _by = (_cell_bottom + _fire_dy) - (_fcy - sprite_get_yoffset(spr_guihuajiu_burn)) * _fsy;

        var _b = instance_create_depth(_bx, _by, -10 - _fr * 45, obj_guihuajiu_burn_cell);
        _b.grid_col = _fc;
        _b.grid_row = _fr;
        _b.damage = burn_total / 2;
        _b.damage_type = burn_type;
        _b.drunk_time = drunk_time;
        _b.drunk_mult = drunk_mult;
        _b.image_xscale = _fsx;
        _b.image_yscale = _fsy;
    }
}
