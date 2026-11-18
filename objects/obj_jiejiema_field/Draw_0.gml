// obj_jiejiema_field Draw 事件
// 四张特效图各管一种形状：
//   grid   → 1 只时的「本格 + 前方 1 格」
//   line   → 2 只时的连线（按长度拉伸、按角度旋转，原点在左端中点）
//   inside → 多边形内部的整片雾（**只能出现在连接线围成的范围里**）
//   side   → 多边形的每条边（同 line 的拉伸 / 旋转口径）
//
// 🔴 2026-11-18 用户口径：内部雾不许糊到多边形外面。
//   原来用 draw_sprite_ext 按顶点包围盒拉伸，可贴图是方形的、四角也有 alpha，
//   于是「多边形」就变成了一个方框。现在改成「凸包三角扇 + 纹理 uv 映射」
//   （scripts/jiejiema_field 的 jiejiema_draw_fog_fan）：几何本身就是多边形，
//   超出多边形的部分不会被画出来，不需要 surface / stencil 也能裁干净。
if (!instance_exists(jj_owner))
    exit;

var _cw = global.grid_cell_size_x;
var _ch = global.grid_cell_size_y;

// 素材 20 / 20 / 20 / 10 帧，统一 3 帧换一张
var _f20 = (floor(jj_anim / 3)) mod 20;
var _f10 = (floor(jj_anim / 3)) mod 10;

var _v  = jj_verts;
var _nv = array_length(_v);
var _is_poly = (jj_mode == "poly" && _nv >= 3);

// ── 每格底光：让玩家看清哪几格在结界里 ───────────────────────────────────
//   多边形模式**不画**：整片雾已经把范围填满了，再铺一层方块就会露出格子感
//   （之前「一格一个方块」的观感就是这么来的）。
if (!_is_poly)
{
    var _grid_sx = _cw / sprite_get_width(spr_jiejiema_fx_grid);
    var _grid_sy = _ch / sprite_get_height(spr_jiejiema_fx_grid);
    for (var i = 0; i < array_length(jj_cells); i++)
    {
        var _p = get_world_position_from_grid(jj_cells[i].col, jj_cells[i].row);
        draw_sprite_ext(spr_jiejiema_fx_grid, _f20, _p.x, _p.y,
                        _grid_sx, _grid_sy, 0, c_white, 0.9);
    }
}

if (jj_mode == "line" && _nv >= 2)
{
    var _a = get_world_position_from_grid(_v[0].col, _v[0].row);
    var _b = get_world_position_from_grid(_v[1].col, _v[1].row);
    var _len = max(1, point_distance(_a.x, _a.y, _b.x, _b.y) + _cw * 0.5);
    var _ang = point_direction(_a.x, _a.y, _b.x, _b.y);
    draw_sprite_ext(spr_jiejiema_fx_line, _f20, _a.x, _a.y,
                    _len / sprite_get_width(spr_jiejiema_fx_line), 1, _ang, c_white, 1);
}
else if (_is_poly)
{
    // ── 顶点世界坐标 + 包围盒 ──────────────────────────────────────────────
    var _px = array_create(_nv);
    var _py = array_create(_nv);
    var _minx = 0, _maxx = 0, _miny = 0, _maxy = 0;
    for (var i = 0; i < _nv; i++)
    {
        var _p = get_world_position_from_grid(_v[i].col, _v[i].row);
        _px[i] = _p.x;
        _py[i] = _p.y;
        if (i == 0) { _minx = _p.x; _maxx = _p.x; _miny = _p.y; _maxy = _p.y; }
        _minx = min(_minx, _p.x);
        _maxx = max(_maxx, _p.x);
        _miny = min(_miny, _p.y);
        _maxy = max(_maxy, _p.y);
    }
    var _bw = max(1, _maxx - _minx);
    var _bh = max(1, _maxy - _miny);

    // 扇心＝顶点质心（凸包 → 一定在多边形内部）
    var _ccx = 0, _ccy = 0;
    for (var i = 0; i < _nv; i++)
    {
        _ccx += _px[i];
        _ccy += _py[i];
    }
    _ccx /= _nv;
    _ccy /= _nv;

    // ── 内部整片雾：两层叠加 ───────────────────────────────────────────────
    //   ① 外层铺满到边线（inset 只收 2%，贴图边缘本来就是渐隐的）；
    //   ② 内层把贴图中央那块亮斑放大铺一遍（inset 32%、透明度低），
    //      让整片浓度更均匀，不然靠近连线的位置会发灰。
    var _tex = sprite_get_texture(spr_jiejiema_fx_inside, _f10);
    if (_tex != -1)
    {
        var _uv = sprite_get_uvs(spr_jiejiema_fx_inside, _f10);
        jiejiema_draw_fog_fan(_px, _py, _ccx, _ccy, _tex,
                              _minx, _miny, _bw, _bh,
                              _uv[0], _uv[1], _uv[2], _uv[3], 0.02, 0.88);
        jiejiema_draw_fog_fan(_px, _py, _ccx, _ccy, _tex,
                              _minx, _miny, _bw, _bh,
                              _uv[0], _uv[1], _uv[2], _uv[3], 0.32, 0.32);
    }

    // ── 每条边单独拉伸（图里的青色连线）──────────────────────────────────
    for (var i = 0; i < array_length(jj_edges); i++)
    {
        var _e = jj_edges[i];
        var _a = get_world_position_from_grid(_v[_e.a].col, _v[_e.a].row);
        var _b = get_world_position_from_grid(_v[_e.b].col, _v[_e.b].row);
        var _len = max(1, point_distance(_a.x, _a.y, _b.x, _b.y));
        var _ang = point_direction(_a.x, _a.y, _b.x, _b.y);
        draw_sprite_ext(spr_jiejiema_fx_side, _f20, _a.x, _a.y,
                        _len / sprite_get_width(spr_jiejiema_fx_side), 1, _ang, c_white, 1);
    }
}
