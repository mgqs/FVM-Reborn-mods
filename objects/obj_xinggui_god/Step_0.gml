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
if (instance_exists(xg_halo))
{
    xg_halo.x = x;
    xg_halo.y = y;
    xg_halo.visible = !xg_fullscreen;
}

// ── 终转全屏判定：场上 4 张星轨神起全屏 ─────────────────────────────
{
    var _n_all = 0;
    with (obj_xinggui_god)
    {
        if (hp > 0 && grid_col >= 0 && grid_col < global.grid_cols
            && grid_row >= 0 && grid_row < global.grid_rows)
            _n_all++;
    }

    var _should_full = (shape >= 3 && hp > 0 && _n_all >= xg_fullscreen_need);

    if (_should_full != xg_fullscreen
        || (_should_full && (!variable_global_exists("xg_corner_owner") || !instance_exists(global.xg_corner_owner))))
    {
        // 旧的四角装饰先清掉（形态变化 / 数量掉下 4 张都要收）
        for (var _i = 0; _i < array_length(xg_corner_effects); _i++)
        {
            if (instance_exists(xg_corner_effects[_i]))
                instance_destroy(xg_corner_effects[_i]);
        }
        xg_corner_effects = [];
        if (variable_global_exists("xg_corner_owner") && global.xg_corner_owner == id)
            global.xg_corner_owner = noone;

        xg_fullscreen = _should_full;

        if (xg_fullscreen)
        {
            global.xg_corner_owner = id;

            // spr_xinggui_god_effect_3_full 是「左上角」单角装饰，四角靠翻转铺满地图网格
            var _spr   = spr_xinggui_god_effect_3_full;
            var _scale = 2.2;
            var _hw    = (sprite_get_width(_spr) - sprite_get_xoffset(_spr)) * _scale;
            var _hh    = (sprite_get_height(_spr) - sprite_get_yoffset(_spr)) * _scale;
            var _left  = global.grid_offset_x;
            var _top   = global.grid_offset_y;
            var _right = _left + global.grid_cols * global.grid_cell_size_x;
            var _bottom= _top  + global.grid_rows * global.grid_cell_size_y;

            var _cx = [_left + _hw, _right - _hw, _left + _hw, _right - _hw];
            var _cy = [_top  + _hh, _top  + _hh,  _bottom - _hh, _bottom - _hh];
            // 左上保留、右上水平翻、左下垂直翻、右下双翻 —— 四角纹样朝外
            var _sx = [-_scale, _scale, -_scale, _scale];
            var _sy = [-_scale, -_scale, _scale, _scale];

            for (var _k = 0; _k < 4; _k++)
            {
                var _fx = instance_create_depth(_cx[_k], _cy[_k], -3100, obj_xinggui_god_effect);
                _fx.sprite_index  = _spr;
                _fx.image_index   = 0;
                _fx.image_speed   = 0.5;
                _fx.image_xscale  = _sx[_k];
                _fx.image_yscale  = _sy[_k];
                array_push(xg_corner_effects, _fx);
            }
        }

        if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
    }
}

// 每 5 帧触发一次全卡增幅重算（与音盒马 / 浮生茶同频）
if (xg_age mod 5 == 0 && variable_global_exists("buff_apply_id")) global.buff_apply_id++;
