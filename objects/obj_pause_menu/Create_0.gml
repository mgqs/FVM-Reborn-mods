// obj_pause_menu - Create Event
image_xscale = 1.5
image_yscale = 1.5
// 菜单元素位置
menu_x = room_width / 2;
menu_y = room_height / 2;

// 按钮数据 [x偏移, 文本, 宽度, 高度, y偏移]
// 布局：2 行 × 3 列，最右列上下两个分别是「词条」(上) 与「效果」(下)
//   上排：继续游戏 / 设置     / 词条
//   下排：退出游戏 / 重新开始 / 效果
// 注意 y 偏移：数值越大越靠下（Draw/Step 里是 menu_y + BTN_BASE_Y + btn[4]）
// 索引固定：0 继续 / 1 设置 / 2 退出 / 3 重新开始 / 4 词条 / 5 效果
var _col_gap  = 150;   // 列间距
var _row_top  = -60;   // 上排
var _row_bot  = 0;     // 下排
buttons = [];
if (hex_active()) {
    // 海克斯模式：2 行 × 3 列
    array_push(buttons, [-_col_gap, "继续游戏", 110, 40, _row_top]);  // 0
    array_push(buttons, [0,         "设置",     110, 40, _row_top]);  // 1
    array_push(buttons, [-_col_gap, "退出游戏", 110, 40, _row_bot]);  // 2
    array_push(buttons, [0,         "重新开始", 110, 40, _row_bot]);  // 3
    // 词条 = 逐条清单，效果 = 汇总后的两栏数值（docs 5.5.1）
    array_push(buttons, [_col_gap,  "词条",     110, 40, _row_top]);  // 4
    array_push(buttons, [_col_gap,  "效果",     110, 40, _row_bot]);  // 5
} else {
    // 非海克斯模式没有词条 / 效果可看，保持 2 行 × 2 列
    var _gap2 = _col_gap / 2;
    array_push(buttons, [-_gap2, "继续游戏", 110, 40, _row_top]);
    array_push(buttons, [_gap2,  "设置",     110, 40, _row_top]);
    array_push(buttons, [-_gap2, "退出游戏", 110, 40, _row_bot]);
    array_push(buttons, [_gap2,  "重新开始", 110, 40, _row_bot]);
}

// 当前选中的按钮索引
selected_button = -1;
submenu_open = false; // 是否有子菜单打开

// 按钮精灵帧
button_normal = 0; // 普通状态
button_hover = 1; // 悬停状态
button_pressed = 2; // 按下状态

// 按钮底图缩放：沿用改动前的 0.75（视觉约 58×25），尺寸与旧版完全一致
btn_draw_scale = 0.75;

panel_anim_init(id, 0.18, 0.22, 0, 3);
panel_anim_kids(id, []);
