/// =====================================================================
/// jiejiema_field —— 结界马「结界」几何（2026-11-18 新卡）
///
///   卡面口径：1 只打「本格 + 前方 1 格」；2 只（非同行）连成一条线；
///   多只以最外圈为顶点围成多边形，攻击内部格。
///
///   这里的函数全部是**纯计算**（不碰实例、不碰绘制），入参出参都是
///   { col, row } 结构体数组，方便 obj_jiejiema_field 直接拿去用，
///   也方便离线验算。网格坐标一律用「格索引」，不用像素。
///
///   🔴 凸包用 Andrew 单调链；填内部用射线法 + 边界判定。
///      顶点取「格中心」，所以格子边界上的马自己也在多边形上，
///      1 只 / 2 只的退化情形要单独走 line 分支，不能交给凸包。
/// =====================================================================

/// @func jiejiema_line_cells(_c1, _r1, _c2, _r2)
/// @desc 两格之间的连线（Bresenham，含首尾两格）→ [{col,row}, ...]
function jiejiema_line_cells(_c1, _r1, _c2, _r2)
{
    var _out = [];
    var _dc = abs(_c2 - _c1);
    var _dr = abs(_r2 - _r1);
    var _sc = (_c1 < _c2) ? 1 : -1;
    var _sr = (_r1 < _r2) ? 1 : -1;
    var _err = _dc - _dr;
    var _c = _c1;
    var _r = _r1;
    while (true)
    {
        array_push(_out, { col: _c, row: _r });
        if (_c == _c2 && _r == _r2) break;
        var _e2 = _err * 2;
        if (_e2 > -_dr)
        {
            _err -= _dr;
            _c += _sc;
        }
        if (_e2 < _dc)
        {
            _err += _dc;
            _r += _sr;
        }
    }
    return _out;
}

/// @func jiejiema_hull(_cols, _rows)
/// @desc 凸包顶点（Andrew 单调链，逆时针）。共线返回 2 个点，全部同格返回 1 个。
function jiejiema_hull(_cols, _rows)
{
    var _n = array_length(_cols);
    if (_n <= 1)
    {
        var _one = [];
        if (_n == 1) array_push(_one, { col: _cols[0], row: _rows[0] });
        return _one;
    }

    // 按 (col, row) 排序（插入排序：最多几十个点，够用且不占额外内存）
    var _idx = [];
    for (var i = 0; i < _n; i++) array_push(_idx, i);
    for (var i = 1; i < _n; i++)
    {
        var _v = _idx[i];
        var _j = i - 1;
        while (_j >= 0)
        {
            var _a = _idx[_j];
            var _before = (_cols[_a] < _cols[_v]) || (_cols[_a] == _cols[_v] && _rows[_a] <= _rows[_v]);
            if (_before) break;
            _idx[_j + 1] = _a;
            _j--;
        }
        _idx[_j + 1] = _v;
    }

    // 叉积不写成闭包：GML 的匿名函数对局部变量的捕获不可靠，直接内联最稳
    var _lower = [];
    for (var i = 0; i < _n; i++)
    {
        var _p = _idx[i];
        while (array_length(_lower) >= 2)
        {
            var _o = _lower[array_length(_lower) - 2];
            var _a2 = _lower[array_length(_lower) - 1];
            var _cr = (_cols[_a2] - _cols[_o]) * (_rows[_p] - _rows[_o])
                    - (_rows[_a2] - _rows[_o]) * (_cols[_p] - _cols[_o]);
            if (_cr > 0) break;
            array_pop(_lower);
        }
        array_push(_lower, _p);
    }
    var _upper = [];
    for (var i = _n - 1; i >= 0; i--)
    {
        var _p = _idx[i];
        while (array_length(_upper) >= 2)
        {
            var _o = _upper[array_length(_upper) - 2];
            var _a2 = _upper[array_length(_upper) - 1];
            var _cr = (_cols[_a2] - _cols[_o]) * (_rows[_p] - _rows[_o])
                    - (_rows[_a2] - _rows[_o]) * (_cols[_p] - _cols[_o]);
            if (_cr > 0) break;
            array_pop(_upper);
        }
        array_push(_upper, _p);
    }
    array_pop(_lower);
    array_pop(_upper);

    var _hull = [];
    for (var i = 0; i < array_length(_lower); i++) array_push(_hull, _lower[i]);
    for (var i = 0; i < array_length(_upper); i++) array_push(_hull, _upper[i]);

    var _out = [];
    for (var i = 0; i < array_length(_hull); i++)
        array_push(_out, { col: _cols[_hull[i]], row: _rows[_hull[i]] });
    return _out;
}

/// @func jiejiema_point_in_poly(_px, _py, _verts)
/// @desc 点是否在多边形内或边上（射线法 + 边界判定）。_verts = [{col,row}, ...]
function jiejiema_point_in_poly(_px, _py, _verts)
{
    var _h = array_length(_verts);
    if (_h < 3) return false;       // 退化情形走 line 分支，不该进来

    var _inside = false;
    var _eps = 0.0001;
    for (var i = 0; i < _h; i++)
    {
        var _a = _verts[i];
        var _b = _verts[(i + 1) mod _h];
        var _x1 = _a.col;
        var _y1 = _a.row;
        var _x2 = _b.col;
        var _y2 = _b.row;

        // 边界：叉积为 0 且落在两点之间
        var _cr = (_x2 - _x1) * (_py - _y1) - (_y2 - _y1) * (_px - _x1);
        if (abs(_cr) < _eps)
        {
            if (_px >= min(_x1, _x2) - _eps && _px <= max(_x1, _x2) + _eps
                && _py >= min(_y1, _y2) - _eps && _py <= max(_y1, _y2) + _eps)
                return true;
        }

        // 射线法
        if (((_y1 > _py) != (_y2 > _py))
            && (_px < (_x2 - _x1) * (_py - _y1) / (_y2 - _y1) + _x1))
            _inside = !_inside;
    }
    return _inside;
}

/// @func jiejiema_cells_of(_cols, _rows)
/// @desc 由场上所有结界马的格子算出「吃到伤害的格集」+「画边用的顶点」。
/// @return struct { cells:[{col,row}], verts:[{col,row}], edges:[{a,b}], mode:"grid"|"line"|"poly" }
function jiejiema_cells_of(_cols, _rows)
{
    var _n = array_length(_cols);
    var _cells = [];
    var _verts = [];
    var _edges = [];
    var _mode = "grid";

    if (_n <= 0)
        return { cells: _cells, verts: _verts, edges: _edges, mode: _mode };

    if (_n == 1)
    {
        // 本格 + 前方 1 格（列号 +1；贴右边沿时不再外扩）
        var _c = _cols[0];
        var _r = _rows[0];
        array_push(_cells, { col: _c, row: _r });
        if (_c + 1 <= global.grid_cols - 1)
            array_push(_cells, { col: _c + 1, row: _r });
        array_push(_verts, { col: _c, row: _r });
        return { cells: _cells, verts: _verts, edges: _edges, mode: "grid" };
    }

    if (_n == 2)
    {
        _mode = "line";
        _cells = jiejiema_line_cells(_cols[0], _rows[0], _cols[1], _rows[1]);
        array_push(_verts, { col: _cols[0], row: _rows[0] });
        array_push(_verts, { col: _cols[1], row: _rows[1] });
        array_push(_edges, { a: 0, b: 1 });
        return { cells: _cells, verts: _verts, edges: _edges, mode: _mode };
    }

    // ≥3 只：凸包 → 多边形填内部
    var _hull = jiejiema_hull(_cols, _rows);
    if (array_length(_hull) < 3)
    {
        // 三只以上但全在一条直线上：退化成「两端连线」
        var _min_i = 0;
        var _max_i = 0;
        for (var i = 1; i < _n; i++)
        {
            if (_cols[i] * 1000 + _rows[i] < _cols[_min_i] * 1000 + _rows[_min_i]) _min_i = i;
            if (_cols[i] * 1000 + _rows[i] > _cols[_max_i] * 1000 + _rows[_max_i]) _max_i = i;
        }
        _cells = jiejiema_line_cells(_cols[_min_i], _rows[_min_i], _cols[_max_i], _rows[_max_i]);
        array_push(_verts, { col: _cols[_min_i], row: _rows[_min_i] });
        array_push(_verts, { col: _cols[_max_i], row: _rows[_max_i] });
        array_push(_edges, { a: 0, b: 1 });
        return { cells: _cells, verts: _verts, edges: _edges, mode: "line" };
    }

    _mode = "poly";
    _verts = _hull;
    var _h = array_length(_hull);
    for (var i = 0; i < _h; i++)
        array_push(_edges, { a: i, b: (i + 1) mod _h });

    // 包围盒内的格心逐格判定
    var _minc = _cols[0];
    var _maxc = _cols[0];
    var _minr = _rows[0];
    var _maxr = _rows[0];
    for (var i = 0; i < _n; i++)
    {
        _minc = min(_minc, _cols[i]);
        _maxc = max(_maxc, _cols[i]);
        _minr = min(_minr, _rows[i]);
        _maxr = max(_maxr, _rows[i]);
    }
    for (var r = _minr; r <= _maxr; r++)
    {
        for (var c = _minc; c <= _maxc; c++)
        {
            if (jiejiema_point_in_poly(c, r, _hull))
                array_push(_cells, { col: c, row: r });
        }
    }

    // 保险：马所在的格一定算（格心就是顶点，理论上已被边界判定收进来）
    for (var i = 0; i < _n; i++)
    {
        var _dup = false;
        for (var k = 0; k < array_length(_cells); k++)
        {
            if (_cells[k].col == _cols[i] && _cells[k].row == _rows[i]) { _dup = true; break; }
        }
        if (!_dup) array_push(_cells, { col: _cols[i], row: _rows[i] });
    }

    return { cells: _cells, verts: _verts, edges: _edges, mode: _mode };
}

/// @func jiejiema_cells_equal(_a, _b)
/// @desc 两套格集是否一致（判定「结界有没有重新成形」用，顺序无关会更好但这里顺序是确定的）
function jiejiema_cells_equal(_a, _b)
{
    if (array_length(_a) != array_length(_b)) return false;
    for (var i = 0; i < array_length(_a); i++)
    {
        if (_a[i].col != _b[i].col || _a[i].row != _b[i].row) return false;
    }
    return true;
}

/// @func jiejiema_draw_fog_fan(_px, _py, _cx, _cy, _tex, _bx, _by, _bw, _bh, _u0, _v0, _u1, _v1, _inset, _alpha)
/// @desc 用「凸包三角扇 + 纹理 UV」把雾贴图画进多边形里。
///   2026-11-18 用户口径：结界内部的特效**只能出现在连接线围成的范围里**。
///   以前是 draw_sprite_ext 按顶点包围盒拉伸，贴图是方形的 → 四个角会糊到多边形外。
///   改成三角扇后，几何本身就是多边形，超出多边形的部分根本不会被画出来（不需要 surface / stencil）。
/// @param {array}  _px,_py   顶点世界坐标（凸包顺序，逆/顺时针都行）
/// @param {real}   _cx,_cy   扇心（取顶点质心；凸包的质心必在内部）
/// @param {real}   _tex      sprite_get_texture() 拿到的纹理页
/// @param {real}   _bx,_by,_bw,_bh  顶点包围盒（用来把顶点位置换算成 uv）
/// @param {real}   _u0,_v0,_u1,_v1  sprite_get_uvs() 的四个分量
/// @param {real}   _inset    uv 内缩比例（贴图边缘是渐隐的，往里收一点免得边界断开）
/// @param {real}   _alpha    透明度
function jiejiema_draw_fog_fan(_px, _py, _cx, _cy, _tex,
                               _bx, _by, _bw, _bh,
                               _u0, _v0, _u1, _v1, _inset, _alpha)
{
    var _n = array_length(_px);
    if (_n < 3 || _tex == -1) return;

    var _du = (_u1 - _u0) * _inset;
    var _dv = (_v1 - _v0) * _inset;
    var _ua = _u0 + _du;
    var _ub = _u1 - _du;
    var _va = _v0 + _dv;
    var _vb = _v1 - _dv;
    var _um = (_ua + _ub) * 0.5;
    var _vm = (_va + _vb) * 0.5;

    // 扇心用中心 uv：贴图中心就是那块亮斑，正好落在多边形重心
    draw_primitive_begin_texture(pr_trianglefan, _tex);
    draw_vertex_texture_color(_cx, _cy, _um, _vm, c_white, _alpha);
    for (var i = 0; i <= _n; i++)
    {
        var _k  = i mod _n;
        var _tu = lerp(_ua, _ub, (_px[_k] - _bx) / _bw);
        var _tv = lerp(_va, _vb, (_py[_k] - _by) / _bh);
        draw_vertex_texture_color(_px[_k], _py[_k], _tu, _tv, c_white, _alpha);
    }
    draw_primitive_end();
}
