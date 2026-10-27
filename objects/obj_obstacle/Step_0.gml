if global.debug{
	image_alpha = 0.5
}

// 仅阻挡非穿透性直线子弹，穿透子弹和非直线子弹（追踪/抛物等）不受影响
// 判定框：取实例**实际遮罩**（bbox_* 已含 image_xscale/image_yscale 缩放，等于精灵图像大小），
// 再与所在格子的矩形求交 —— 既「精确到实际精灵图像」，又绝不越出单个格子。
// 格子由自身坐标反查（外部创建方只写 row/col，不保证写 grid_row/grid_col）。
var _cell = get_grid_position_from_world(x, y);
var _cell_l = _cell.x - global.grid_cell_size_x * 0.5;
var _cell_r = _cell.x + global.grid_cell_size_x * 0.5;
var _cell_t = _cell.y - global.grid_cell_size_y * 0.5;
var _cell_b = _cell.y + global.grid_cell_size_y * 0.5;

var _hit_l = max(bbox_left,   _cell_l);
var _hit_r = min(bbox_right,  _cell_r);
var _hit_t = max(bbox_top,    _cell_t);
var _hit_b = min(bbox_bottom, _cell_b);

// 遮罩为空或整块落在格外的极端情况直接跳过，避免用退化矩形做判定
if (_hit_r > _hit_l && _hit_b > _hit_t)
{
    var _bullets = ds_list_create();
    var _bullet_count = collision_rectangle_list(
        _hit_l, _hit_t,
        _hit_r, _hit_b,
        obj_bullet_parent, false, true, _bullets, false
    );
    for (var _i = 0; _i < _bullet_count; _i++)
    {
        var _bullet = _bullets[| _i];
        if (!instance_exists(_bullet))
            continue;
        var _dt = variable_instance_exists(_bullet, "damage_type") ? _bullet.damage_type : "normal";
        var _tt = variable_instance_exists(_bullet, "target_type") ? _bullet.target_type : "normal";
        // 御风马的龙卷风是风场穿透弹：不受地形障碍阻挡（百味关水中的障碍物会误销毁它）。
        if (_bullet.object_index == obj_zodiac_projectile
            && variable_instance_exists(_bullet, "kind") && _bullet.kind == "wind") continue;
        // 穿透弹放行：damage_type == "pierce"，或子弹自己标了 pierce_all
        // （融合三线 2 转 / 融合双菇 1·2 转的无限穿透 —— 它们自己的 Collision_obj_obstacle 里都写了
        //  `if (pierce_all) exit;`，这里必须同口径放行，否则障碍这一侧会先把子弹销毁，表现为「穿透失效」）
        var _pierce = (_dt == "pierce")
                   || (variable_instance_exists(_bullet, "pierce_all") && _bullet.pierce_all);
        // 行门禁：只拦「逻辑行 == 本障碍行」的子弹。炮口高（双向水管 y-75、坚果炸锅 y-95…）
        // 的子弹物理上悬到上一格下缘，若只看几何，下面那格的卡会被上面那格的障碍物白吃子弹。
        // 判定口径统一在 obstacle_should_block() 里。
        if (!_pierce && _tt == "normal" && obstacle_should_block(_bullet, id))
        {
            instance_destroy(_bullet);
        }
    }
    ds_list_destroy(_bullets);
}
