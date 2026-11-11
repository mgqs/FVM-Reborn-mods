/// @function baibianshe_preview_cell(col, row, max_r, used)
/// @description 百变蛇找最近的可放格（放置预览与二转放兄弟共用同一套搜索，保证虚影和实放一致）
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
