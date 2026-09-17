// obj_plant_preview STEP 事件
var found_plat = noone;
platform_shift_x = 0;
platform_shift_y = 0;
var logical_col = -1;
var logical_row = -1;
var grid_pos_visual = get_grid_position_from_world(mouse_x, mouse_y);
var direct_in_platform = false;

with (obj_platform) {
    var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");
    var shift_x = is_axis_x ? visual_x_shift : 0;
    var shift_y = (!is_axis_x) ? visual_y_shift : 0;
    var adj_x = mouse_x - shift_x;
    var adj_y = mouse_y - shift_y;
    var grid_pos_adj = get_grid_position_from_world(adj_x, adj_y);

    var c_off = is_axis_x ? current_offset : 0;
    var r_off = (!is_axis_x) ? current_offset : 0;
    var p_start_c = start_col + c_off;
    var p_start_r = start_row + r_off;

    if (grid_pos_adj.col >= p_start_c && grid_pos_adj.col < p_start_c + width &&
        grid_pos_adj.row >= p_start_r && grid_pos_adj.row < p_start_r + length) {
        found_plat = id;
        logical_col = grid_pos_adj.col;
        logical_row = grid_pos_adj.row;
        other.platform_shift_x = shift_x;
        other.platform_shift_y = shift_y;
        break;
    }

    // 记录鼠标视觉格子是否落在某平台逻辑范围内（用于检测移动方向外一格）
    if (!direct_in_platform &&
        grid_pos_visual.col >= p_start_c && grid_pos_visual.col < p_start_c + width &&
        grid_pos_visual.row >= p_start_r && grid_pos_visual.row < p_start_r + length) {
        direct_in_platform = true;
    }
}

if (found_plat == noone) {
    if (direct_in_platform) {
        // 鼠标视觉在平台外但格子属于平台逻辑范围（平台移动方向外一格），禁止放置
        logical_col = -1;
        logical_row = -1;
    } else {
        logical_col = grid_pos_visual.col;
        logical_row = grid_pos_visual.row;
    }
}

var logical_world = get_world_position_from_grid(logical_col, logical_row);

// 跟随鼠标移动
x = mouse_x;
y = mouse_y;
logical_base_x = logical_world.x;
logical_base_y = logical_world.y;

// 如果父卡槽被取消，销毁自己
if (parent_slot == noone || !instance_exists(parent_slot) || !parent_slot.is_selected) {
    instance_destroy();
}