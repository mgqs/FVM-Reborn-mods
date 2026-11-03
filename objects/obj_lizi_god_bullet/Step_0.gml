if (global.is_paused)
{
    image_speed = 0;
    exit;
}
else
{
    image_speed = 1;
}

// 飞行中仅循环播放 0-7 帧
if (image_index >= 8)
    image_index = image_index - 8;

x += move_speed;
y -= cvspeed;
cvspeed -= cgravity;

if (x > 2200 || y > 1200 || x < -200 || y < -200)
    instance_destroy();

// 飞行中撞到老鼠 → 当场炸在它**当下所在格**（同糖炒栗子 / 生煎锅）：
//   提前量只是大致瞄准，老鼠中途变向 / 被击退时仍会错格；撞上就炸才跟得住。
//   命中格直接改写成落点，走下面同一段落地流程（特效位置 / grid_row·col 都不用另写）。
if (has_target && x < target_x)
{
    var _hx = undefined;
    var _hy = undefined;
    with (obj_enemy_parent)
    {
        if (hp > 0 && grid_row == other.row && can_target_on(other.target_type, target_type)
            && precise_bbox_collision(other.id, id))
        {
            _hx = x;
            _hy = y;
        }
    }
    if (!is_undefined(_hx))
    {
        var _gp = get_grid_position_from_world(_hx, _hy);
        target_x = _gp.x;
        target_y = _gp.y;
        target_col = _gp.col;
        x = _gp.x;
        y = _gp.y;
    }
}

if (has_target)
{
    // 落地判定用「越过落点」而不是 |x-target_x|<5：
    //   远距离时 move_speed 有 13px/帧，5px 阈值可能整帧跨过去 → 永远不落地、飞出地图（旧 bug）
    if (x >= target_x)
    {
        x = target_x;
        y = target_y;
        // 特效按原样 -30 摆放（2026-11-01 用户：这个位置之前是对的，别动）
        var inst = instance_create_depth(target_x, target_y - 30, 0, obj_lizi_god_bullet_effect);
        inst.damage = damage;
        inst.damage_type = damage_type;
        inst.grid_row = row;
        inst.grid_col = target_col;
        inst.shape = shape;

        if (shape == 1)
            inst.sprite_index = spr_lizi_god_bullet_1;
        else if (shape >= 2)
            inst.sprite_index = spr_lizi_god_bullet_2;
        else
            inst.sprite_index = spr_lizi_god_bullet;

        // 深度融合：把「深度爆炸伤害」交给同一条序列帧里的爆炸特效去结算
        inst.deep_boom = deep_boom;
        inst.deep_boom_damage = deep_boom_damage;

        instance_destroy();
    }
}
