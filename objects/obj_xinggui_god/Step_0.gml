// obj_xinggui_god Step 事件
// 只做四件事：① 悬浮层深度 ② 光环跟随 ③ 终转全屏判定 / 四角装饰 ④ 周期性触发全卡增幅重算。
// 本体无索敌、无攻击，动画由父类按 idle_anim 循环。
if (global.is_paused)
    exit;

event_inherited();

// 星轨神本体压在卡片上层，避免被同格卡片挡住
depth = calculate_plant_depth(grid_col, grid_row, plant_type) - 400;

// 三转起是悬浮卡；转职后存档形态变了要跟着改（父类每帧按存档重建 plant_type，这里兜一次拦掉）
if (shape >= 1 && plant_type != "gridless")
    plant_type = "gridless";

xg_age++;

// 光环跟随卡片（被铲子/板块挪动时一起走）
// 不随全屏切换隐藏：终转全屏时四角装饰是**另加**的一层，本体光环照常亮着
//（海洋女神同理：它的本体光环和四角装饰是同时显示的）。原来这里写 visible = !xg_fullscreen，
//  一旦 4 张条件被满足/失效就会「光环消失 → 四角出现」，看起来正好像是特效闪了一下。
// 位置取**格心**而不是卡片 x/y：卡片原点在脚底 / 悬浮卡还有额外偏移，
// 用卡片坐标当圆心会让 5*5 范围框整体错位半格。
if (instance_exists(xg_halo))
{
    if (grid_col >= 0 && grid_col < global.grid_cols
        && grid_row >= 0 && grid_row < global.grid_rows)
    {
        // 手算格心，不走 get_world_position_from_grid —— 那个函数内部会 invalidate 索敌缓存，
        // 每帧给一张卡调用一次纯属多余开销。
        xg_halo.x = global.grid_offset_x + (grid_col + 0.5) * global.grid_cell_size_x;
        xg_halo.y = global.grid_offset_y + (grid_row + 0.5) * global.grid_cell_size_y;
    }
    else
    {
        xg_halo.x = x;
        xg_halo.y = y;
    }
    xg_halo.visible = true;
}

// ── 终转全屏判定：场上 4 张星轨神起全屏 ─────────────────────────────
// 四角装饰全局只允许一套：由 xg_corner_owner 这一个实例创建并维护。
// 旧写法是「谁判定成功谁就建一套」，4 张终转星轨同帧各建一套 → 角落位置叠 16 层，
// 而且任何一张数量抖动都会整批销毁重建（image_index 归零）→ 看起来就是四角装饰在闪。
{
    var _n_all = 0;
    with (obj_xinggui_god)
    {
        if (hp > 0 && grid_col >= 0 && grid_col < global.grid_cols
            && grid_row >= 0 && grid_row < global.grid_rows)
            _n_all++;
    }

    var _should_full = (shape >= 3 && hp > 0 && _n_all >= xg_fullscreen_need);
    var _owner_ok = (variable_global_exists("xg_corner_owner")
                     && instance_exists(global.xg_corner_owner)
                     && global.xg_corner_owner.object_index == obj_xinggui_god);

    if (_should_full)
    {
        // 无人维护（还没人建 / 原来的主人被铲掉）→ 当前这张接管
        if (!_owner_ok)
        {
            global.xg_corner_owner = id;
            _owner_ok = true;
        }

        if (global.xg_corner_owner == id && array_length(xg_corner_effects) == 0)
        {
            // 四角做法照 海洋女神 / 战旗马 / 时间神：**一个角的素材 + 翻转铺到另外三角**。
            // spr_xinggui_god_effect_3_full 是「左上角」单角装饰（375x375，原点居中），
            // 内容 bbox x35..311 / y49..299 → 相对原点 (-152,-138)..(+124,+112)。
            // 位置按「内容角点贴网格角点」反推，与素材留白/原点位置无关：
            //   左上 (+,+) → x = left  - bl*s, y = top    - bt*s
            //   右上 (-,+) → x = right + bl*s, y = top    - bt*s
            //   左下 (+,-) → x = left  - bl*s, y = bottom + bt*s
            //   右下 (-,-) → x = right + bl*s, y = bottom + bt*s
            // 四角再整体**往外各扩半格**（与时间神 spr_time_god_effect_3 的 half_cell 外扩同口径），
            // 这样角饰压在格子外沿而不是压在格心线上。
            var _spr   = spr_xinggui_god_effect_3_full;
            var _s     = 1.0;          // 角饰本身 277x251，1.0 已是地图宽的 29%，再大四角会互相压住
            var _bl    = 35 - 187;     // 内容左边 - xorigin
            var _bt    = 49 - 187;     // 内容上边 - yorigin
            var _hx    = global.grid_cell_size_x * 0.5;
            var _hy    = global.grid_cell_size_y * 0.5;
            var _left  = global.grid_offset_x - _hx;
            var _top   = global.grid_offset_y - _hy;
            var _right = global.grid_offset_x + global.grid_cols * global.grid_cell_size_x + _hx;
            var _bottom= global.grid_offset_y + global.grid_rows * global.grid_cell_size_y + _hy;

            var _cx = [_left  - _bl * _s, _right + _bl * _s, _left  - _bl * _s, _right + _bl * _s];
            var _cy = [_top   - _bt * _s, _top   - _bt * _s, _bottom + _bt * _s, _bottom + _bt * _s];
            // 索引顺序：0 左上 / 1 右上 / 2 左下 / 3 右下；只有左上用素材原朝向
            var _sx = [_s, -_s, _s, -_s];
            var _sy = [_s,  _s, -_s, -_s];

            for (var _k = 0; _k < 4; _k++)
            {
                // depth -2500：盖住卡片、但在 ESC 暂停菜单（-3000）之下
                var _fx = instance_create_depth(_cx[_k], _cy[_k], -2500, obj_xinggui_god_effect);
                _fx.sprite_index  = _spr;
                _fx.image_index   = 0;
                _fx.image_speed   = _fx.xg_fx_speed;
                _fx.image_xscale  = _sx[_k];
                _fx.image_yscale  = _sy[_k];
                array_push(xg_corner_effects, _fx);
            }
            if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
        }

        xg_fullscreen = true;
    }
    else if (xg_fullscreen || array_length(xg_corner_effects) > 0)
    {
        // 条件失效：收掉自己的四角装饰；如果自己就是主人，让位给别的终转星轨
        for (var _i = 0; _i < array_length(xg_corner_effects); _i++)
        {
            if (instance_exists(xg_corner_effects[_i]))
                instance_destroy(xg_corner_effects[_i]);
        }
        xg_corner_effects = [];
        if (_owner_ok && global.xg_corner_owner == id) global.xg_corner_owner = noone;

        xg_fullscreen = false;
        if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
    }
}

// 每 5 帧触发一次全卡增幅重算（与音盒马 / 浮生茶同频）
if (xg_age mod 5 == 0 && variable_global_exists("buff_apply_id")) global.buff_apply_id++;
