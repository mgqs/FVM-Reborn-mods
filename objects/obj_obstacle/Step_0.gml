if global.debug{
	image_alpha = 0.5
}

// 仅阻挡非穿透性直线子弹，穿透子弹和非直线子弹（追踪/抛物等）不受影响
var _half_w = global.grid_cell_size_x / 2;
var _half_h = global.grid_cell_size_y / 2;
var _bullets = ds_list_create();
var _bullet_count = collision_rectangle_list(
    x - _half_w, y - _half_h,
    x + _half_w, y + _half_h,
    obj_bullet_parent, false, true, _bullets, false
);
for (var _i = 0; _i < _bullet_count; _i++)
{
    var _bullet = _bullets[| _i];
    if (!instance_exists(_bullet))
        continue;
    var _dt = variable_instance_exists(_bullet, "damage_type") ? _bullet.damage_type : "normal";
    var _tt = variable_instance_exists(_bullet, "target_type") ? _bullet.target_type : "normal";
    // 穿透弹放行：damage_type == "pierce"，或子弹自己标了 pierce_all
    // （融合三线 2 转 / 融合双菇 1·2 转的无限穿透 —— 它们自己的 Collision_obj_obstacle 里都写了
    //  `if (pierce_all) exit;`，这里必须同口径放行，否则障碍这一侧会先把子弹销毁，表现为「穿透失效」）
    var _pierce = (_dt == "pierce")
               || (variable_instance_exists(_bullet, "pierce_all") && _bullet.pierce_all);
    if (!_pierce && _tt == "normal")
    {
        instance_destroy(_bullet);
    }
}
ds_list_destroy(_bullets);
