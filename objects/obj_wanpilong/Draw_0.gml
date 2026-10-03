/// @description 顽皮龙 - 绘制事件
event_inherited();

// 绘制选点范围高亮
if (wanpilong_state == WANPILONG_STATE.TARGETING_DEST)
{
    draw_wanpilong_highlight();
}

// 绘制源目标选中框
if (wanpilong_state == WANPILONG_STATE.PRE_SWING ||
    wanpilong_state == WANPILONG_STATE.TARGETING_DEST ||
    wanpilong_state == WANPILONG_STATE.RESOLVING)
{
    if (instance_exists(source_entity))
    {
        draw_wanpilong_source_outline();
    }
}

// 绘制前摇进度条
if (wanpilong_state == WANPILONG_STATE.PRE_SWING)
{
    draw_wanpilong_preswing_bar();
}

// 绘制冷却指示
if (wanpilong_state == WANPILONG_STATE.COOLDOWN)
{
    draw_wanpilong_cooldown_indicator();
}

// 第一段选点时绘制合法源目标提示
if (wanpilong_state == WANPILONG_STATE.TARGETING_SOURCE)
{
    draw_wanpilong_source_hint();
}

// ============================================
// 绘制范围高亮格子
// ============================================
function draw_wanpilong_highlight()
{
    var _prev_alpha = draw_get_alpha();
    draw_set_alpha(0.3);

    for (var i = 0; i < ds_list_size(highlight_cells); i += 2)
    {
        var _col = highlight_cells[| i];
        var _row = highlight_cells[| i + 1];
        var _pos = get_world_position_from_grid(_col, _row);

        // 绘制绿色半透明方块
        draw_set_color(c_lime);
        draw_rectangle(
            _pos.x - global.grid_cell_size_x / 2,
            _pos.y - global.grid_cell_size_y / 2,
            _pos.x + global.grid_cell_size_x / 2,
            _pos.y + global.grid_cell_size_y / 2,
            false
        );
    }

    draw_set_alpha(_prev_alpha);
}

// ============================================
// 绘制源目标描边
// ============================================
function draw_wanpilong_source_outline()
{
    if (!instance_exists(source_entity))
        return;

    var _prev_alpha = draw_get_alpha();
    draw_set_alpha(0.8);
    draw_set_color(c_green);

    var _sx = source_entity.x - sprite_get_width(source_entity.sprite_index) / 2;
    var _sy = source_entity.y - sprite_get_height(source_entity.sprite_index) / 2;
    var _sw = sprite_get_width(source_entity.sprite_index);
    var _sh = sprite_get_height(source_entity.sprite_index);

    // 绿色描边
    draw_rectangle(_sx - 2, _sy - 2, _sx + _sw + 2, _sy + _sh + 2, true);

    draw_set_alpha(_prev_alpha);
}

// ============================================
// 绘制前摇进度条
// ============================================
function draw_wanpilong_preswing_bar()
{
    var _bar_w = 60;
    var _bar_h = 6;
    var _bar_x = x - _bar_w / 2;
    var _bar_y = y - 50;

    var _progress = pre_swing_timer / pre_swing_frames;

    // 背景
    draw_set_color(c_black);
    draw_set_alpha(0.5);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);

    // 进度
    draw_set_color(c_yellow);
    draw_set_alpha(0.9);
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w * _progress, _bar_y + _bar_h, false);

    // 文字
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_text(x, _bar_y - 14, "前摇: " + string(floor((pre_swing_frames - pre_swing_timer) / 60 * 10) / 10) + "秒");
    draw_set_halign(fa_left);
}

// ============================================
// 绘制冷却指示
// ============================================
function draw_wanpilong_cooldown_indicator()
{
    var _cd_remaining = cooldown_total - cooldown_timer;
    var _cd_seconds = ceil(_cd_remaining / 60);

    draw_set_color(c_white);
    draw_set_alpha(0.8);
    draw_set_halign(fa_center);
    draw_text(x, y + 30, "冷却: " + string(_cd_seconds) + "s");
    draw_set_halign(fa_left);
    draw_set_alpha(1);
}

// ============================================
// 绘制第一段选点提示
// ============================================
function draw_wanpilong_source_hint()
{
    var _mouse_grid = get_grid_position_from_world(mouse_x, mouse_y);

    // 检查鼠标下是否有合法源目标
    var _hovered_valid = false;
    if (_mouse_grid.col >= 0 && _mouse_grid.col < global.grid_cols &&
        _mouse_grid.row >= 0 && _mouse_grid.row < global.grid_rows)
    {
        var _plant_list = ds_grid_get(global.grid_plants, _mouse_grid.col, _mouse_grid.row);
        for (var i = 0; i < ds_list_size(_plant_list); i++)
        {
            var _plant = ds_list_find_value(_plant_list, i);
            if (instance_exists(_plant) && wanpilong_is_valid_source(_plant))
            {
                _hovered_valid = true;
                break;
            }
        }
    }

    // 提示文字
    draw_set_color(c_white);
    draw_set_alpha(0.9);
    draw_set_halign(fa_center);

    if (_hovered_valid)
    {
        draw_text(mouse_x, mouse_y - 30, "点击选择要移动的目标");
    }
    else
    {
        draw_set_color(c_red);
        draw_text(mouse_x, mouse_y - 30, "选择可移动的卡片" + (can_move_character ? "或角色" : ""));
    }

    draw_set_halign(fa_left);
    draw_set_alpha(1);
}
