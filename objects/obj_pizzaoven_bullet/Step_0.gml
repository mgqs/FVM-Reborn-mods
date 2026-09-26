if global.is_paused{
	image_speed = 0
	exit	
}
image_speed = 1

// ===== 沿三角形路径顺时针移动 =====
var tx, ty;
if (target_point == 0) {
    tx = point0_x;
    ty = point0_y;
} else if (target_point == 1) {
    tx = point1_x;
    ty = point1_y;
} else {
    tx = point2_x;
    ty = point2_y;
}

var dx = tx - x;
var dy = ty - y;
var dist = sqrt(dx * dx + dy * dy);

if (dist <= move_speed) {
    // 到达当前目标点
    x = tx;
    y = ty;

    // 如果回到了 point0（起点），说明完成了一圈
    if (target_point == 0) {
        laps_completed++;
        if (laps_completed >= 1) {
            instance_destroy();
            exit;
        }
    }

    // 切换到下一个目标点（0->1->2->0）
    target_point++;
    if (target_point > 2) {
        target_point = 0;
    }
} else {
    // 向目标点移动
    x += (dx / dist) * move_speed;
    y += (dy / dist) * move_speed;
}

// ===== 穿透伤害检测（参考赖皮蛇实现） =====
if (variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e)) continue;
            with (_e)
            {
                if (hp > 0
                    && ds_list_find_index(other.hitted_enemy, id) == -1
                    && other.bbox_right >= bbox_left && other.bbox_left <= bbox_right
                    && other.bbox_bottom >= bbox_top && other.bbox_top <= bbox_bottom)
                {
                    ds_list_add(other.hitted_enemy, id);
                    damage_amount = other.damage;
                    damage_type = other.damage_type;
                    event_user(0);
                }
            }
        }
    }
}

// 边界检查
if (x > 2200 || y > 1200 || x < -200 || y < -200) {
    instance_destroy();
}
