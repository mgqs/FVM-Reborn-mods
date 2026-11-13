/// =============================================================================
///  百变蛇（二转）3 格排布 —— 放置预览与实放共用同一套，保证虚影 = 实放
///    baibianshe_cell_free(col,row,used)       这一格能不能再放一只百变蛇
///    baibianshe_layout_cells(col,row,used)    本格之外那 2 只该落哪（2026-11-12 用户口径）
///    baibianshe_preview_cell(col,row,max_r,used) 老的「由近到远」搜索，现在只当 3×3 全满时的兜底
///
///  用户口径（2026-11-12，按九宫格标数看，5 = 本格）：
///      1 2 3
///      4 5 6
///      7 8 9
///    ① 先占 2 / 8（两只都在 = 竖排）
///    ② 某一侧被挡 → **替补落在被挡那一侧的同一行左右**（2 被挡 → 1 / 3；8 被挡 → 7 / 9），
///       不要贴到另一只旁边去（用户 2026-11-12 纠正）
///    ③ 2 和 8 都被挡 → 横着放（4 / 6）
///    ④ 3×3 九个格都满 → 才用远距离兜底（同列 → 同行 → 斜角，由近到远）
/// =============================================================================

/// @function baibianshe_preview_cell(col, row, max_r, used)
/// @description 由近到远找最近的可放格（3×3 全满时的兜底；预览与实放共用）
///   搜索顺序：按「同列优先 → 同行 → 斜角」的曼哈顿圈由近到远；半径 0 就是起手格本身。
/// @param {real} col    起手格列
/// @param {real} row    起手格行（调用方已把行号 clamp 到网格内）
/// @param {real} max_r  最大搜索半径（undefined 或负数 = 全屏）
/// @param {struct} used 已占用/预留的格子集合（键 "col_row"），传 undefined 表示不排除
/// @returns {array} [col, row]，找不到返回空数组
function baibianshe_preview_cell(_col, _row, _max_r = undefined, _used = undefined)
{
    var _maxd = (is_undefined(_max_r) || _max_r < 0) ? max(global.grid_cols, global.grid_rows) : _max_r;

    for (var d = 0; d <= _maxd; d++)
    {
        var _cands = [];
        var dr = -d;
        while (dr <= d)
        {
            var _dca = d - abs(dr);
            if (_dca == 0)
                array_push(_cands, { c: _col, r: _row + dr, p: 0 });
            else
            {
                for (var s = -1; s <= 1; s += 2)
                {
                    var _c2 = _col + s * _dca;
                    var _r2 = _row + dr;
                    array_push(_cands, { c: _c2, r: _r2, p: (_r2 == _row) ? 1 : 2 });
                }
            }
            dr++;
        }

        array_sort(_cands, function(a, b)
        {
            if (a.p != b.p) return a.p - b.p;
            if (a.r != b.r) return a.r - b.r;
            return a.c - b.c;
        });

        for (var j = 0; j < array_length(_cands); j++)
        {
            var _cc = _cands[j].c;
            var _rr = _cands[j].r;
            if (_cc < 0 || _cc >= global.grid_cols || _rr < 0 || _rr >= global.grid_rows) continue;
            if (!is_undefined(_used) && variable_struct_exists(_used, string(_cc) + "_" + string(_rr))) continue;
            var _w = get_world_position_from_grid(_cc, _rr);
            if (can_place_at_position(_w.x, _w.y, "normal", "normal", "none", "baibianshe")) return [_cc, _rr];
        }
    }

    return [];
}

/// @function baibianshe_cell_free(col, row, used)
/// @description 这一格在网格内、没被 used 占、且百变蛇放得下
function baibianshe_cell_free(_col, _row, _used = undefined)
{
    if (_col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows) return false;
    if (!is_undefined(_used) && variable_struct_exists(_used, string(_col) + "_" + string(_row))) return false;
    var _w = get_world_position_from_grid(_col, _row);
    return can_place_at_position(_w.x, _w.y, "normal", "normal", "none", "baibianshe");
}

/// @function baibianshe_layout_cells(col, row, used)
/// @description 二转放下时，本格之外那两只该落在哪；返回 [[col,row], ...]（最多 2 个，可能更少）
function baibianshe_layout_cells(_col, _row, _used = undefined)
{
    // 自己留一份已占格集合（后面兜底还要往里加）
    var _u = {};
    if (!is_undefined(_used))
    {
        var _keys = variable_struct_get_names(_used);
        for (var i = 0; i < array_length(_keys); i++) _u[$ _keys[i]] = true;
    }

    var _up_ok = baibianshe_cell_free(_col, _row - 1, _u);
    var _dn_ok = baibianshe_cell_free(_col, _row + 1, _u);

    var _cand = [];
    if (_up_ok) array_push(_cand, [_col, _row - 1]);          // 2
    if (_dn_ok) array_push(_cand, [_col, _row + 1]);          // 8

    // 某一侧被挡 → 替补落在**被挡那一侧同一行的左右**：
    //   2 被挡 → 1 / 3（顶行两头）；8 被挡 → 7 / 9（底行两头）
    if (_up_ok && !_dn_ok) array_push(_cand, [_col - 1, _row + 1], [_col + 1, _row + 1]);   // 7 / 9
    else if (!_up_ok && _dn_ok) array_push(_cand, [_col - 1, _row - 1], [_col + 1, _row - 1]);  // 1 / 3

    // 2 和 8 都被挡 → 横着放（4 / 6）
    array_push(_cand, [_col - 1, _row], [_col + 1, _row]);

    // 3×3 剩下的四个角
    array_push(_cand, [_col - 1, _row - 1], [_col + 1, _row - 1],
                      [_col - 1, _row + 1], [_col + 1, _row + 1]);

    var _out  = [];
    var _seen = {};
    for (var j = 0; j < array_length(_cand); j++)
    {
        var _c  = _cand[j][0];
        var _r2 = _cand[j][1];
        var _k  = string(_c) + "_" + string(_r2);
        if (variable_struct_exists(_seen, _k)) continue;
        _seen[$ _k] = true;
        if (!baibianshe_cell_free(_c, _r2, _u)) continue;
        _u[$ _k] = true;
        array_push(_out, [_c, _r2]);
        if (array_length(_out) >= 2) return _out;
    }

    // 3×3 全满 → 远距离兜底（同列 → 同行 → 斜角，由近到远）
    while (array_length(_out) < 2)
    {
        var _cell = baibianshe_preview_cell(_col, _row, undefined, _u);
        if (array_length(_cell) == 0) break;
        _u[$ string(_cell[0]) + "_" + string(_cell[1])] = true;
        array_push(_out, _cell);
    }

    return _out;
}
