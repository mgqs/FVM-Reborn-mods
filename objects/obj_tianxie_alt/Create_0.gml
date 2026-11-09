// obj_tianxie_alt（天蝎座二转 · 卡面飞行物）Create
//   只给「没有子弹实体」的两张卡用：桂花酒（alt_mode = "wine"）/ 逆转牛（alt_mode = "cow"）。
//   做法：把那张卡的**卡面素材**当成飞行物 —— 内容居中压在实例坐标上、顺时针转 90°（头朝右），
//         沿本行以 alt_speed 往右飞，**碰到第一只可打老鼠就结算**，然后自毁。
//
// ── 素材常量（换素材只重量这四个数）────────────────────────────────────
//   spr_guihuajiu_2   画布 354×331，原点 (178,189)；第 0 帧内容框 x141~215 / y110~190 → 中心 (178,150)
//   spr_nizhuanniu_2  画布 196×199，原点 (104,133)；第 0 帧内容框 x71~135 / y67~138  → 中心 (103,102.5)
//   两张的「内容」都只占画布中间一小块，**必须按内容中心对齐**，否则飞起来是半透明的大方块。
//   旋转 90° 后要让内容中心落在 (x, y)，绘制原点得偏移：
//       dx = + (cy - oy) * scale        dy = - (cx - ox) * scale
//   缩放：让「转 90° 后的屏上宽度」≈ 78px（一格宽 107，留点余量）
//       wine: 内容高 80 → 78/80 = 0.975        cow: 内容高 71 → 78/71 = 1.099
//
//   ⚠️ 只用**第 0 帧**（静态卡面）：这两张素材后面几帧是爆炸 / 特效帧（spr_nizhuanniu_2 第 7 帧起
//      内容框暴涨到半个画布），跟着播会在半空突然炸开，所以 image_speed 恒 0、image_index 恒 0。
sprite_index = spr_guihuajiu_2;   // 占位，第一次 Step 按 alt_mode 换
image_speed = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;

alt_mode   = "wine";     // "wine" 桂花酒 / "cow" 逆转牛（由 obj_tianxie 的 tx_alt_spawn 赋值）
alt_row    = 0;          // 本行（只跟这一行的老鼠碰）
alt_dmg    = 0;          // 结算用（wine = 火焰格每跳基准，cow 不用）
alt_speed  = 8;          // px/帧（与披萨 / 小笼包子弹同速）
alt_life   = 0;
alt_ready  = false;      // 第一次 Step 配贴图 / 缩放 / 绘制偏移
alt_dx     = 0;
alt_dy     = 0;
alt_scale  = 1;
alt_hit_range = 46;      // 与老鼠横向距离 ≤ 这个值就算碰到（卡面约一格宽）

/// 结算：cow = 5×5 送回（0 伤害），wine = 十字火焰格 + 醉酒 25 秒
alt_trigger = function(_e)
{
    if (alt_mode == "cow")
    {
        // 逆转牛口径（照 obj_nizhuanniu 的二转脉冲）：±2 行 / ±2 列，只搬 normal / 钻地，BOSS 免疫，**不造成伤害**
        var _r = _e.grid_row;
        var _c = _e.grid_col;
        var _radius = 2;
        var _ids = [];

        with (obj_enemy_parent)
        {
            if (hp <= 0) continue;
            if (is_boss) continue;
            if (target_type != "normal" && target_type != "underground") continue;
            if (abs(grid_row - _r) > _radius) continue;
            if (abs(grid_col - _c) > _radius) continue;
            array_push(_ids, id);
        }

        for (var _i = 0; _i < array_length(_ids); _i++)
        {
            var _m = _ids[_i];
            if (!instance_exists(_m)) continue;
            if (_m.hp <= 0) continue;

            var _dest = get_world_position_from_grid(global.grid_cols, _m.grid_row).x;
            if (variable_instance_exists(_m, "birth_x")) _dest = _m.birth_x;
            if (_m.x >= _dest - global.grid_cell_size_x * 0.5) continue;   // 已经在出生线附近，别来回推

            _m.x = _dest;
            _m.grid_col = global.grid_cols;
            instance_create_depth(_m.x, _m.y, _m.depth - 10, obj_nizhuanniu_effect);
        }
    }
    else
    {
        // 桂花酒口径（照 obj_guihuajiu 二转爆炸）：十字 5 格火焰 + 醉酒 25 秒
        //   boom_damage = 0 → 命中那一下不炸伤害，只留火焰格 DoT（每跳 = burn_total / 2）和醉酒
        var _cell = get_world_position_from_grid(_e.grid_col, _e.grid_row);
        var _boom = instance_create_depth(_cell.x, _cell.y, depth + 1, obj_guihuajiu_boom);
        _boom.shape       = 2;
        _boom.grid_col    = _e.grid_col;
        _boom.grid_row    = _e.grid_row;
        _boom.boom_damage = 0;
        _boom.boom_cross  = true;
        _boom.boom_type   = "ash";
        _boom.burn_total  = alt_dmg;
        _boom.burn_cross  = true;
        _boom.burn_type   = "physical";
        _boom.drunk_time  = 25 * 60;
        _boom.drunk_mult  = 1.5;
    }
};
