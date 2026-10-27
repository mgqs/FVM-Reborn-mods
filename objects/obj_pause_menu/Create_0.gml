// obj_pause_menu - Create Event
image_xscale = 1.5
image_yscale = 1.5
// 菜单元素位置
menu_x = room_width / 2;
menu_y = room_height / 2;

// 按钮数据 [x偏移, 文本, 宽度, 高度,y偏移]
// 第一排：设置 / 继续游戏（海克斯模式再多一格「词条」，排在第 3 个）
// 第二排：退出游戏 / 重新开始
// 索引固定：0 继续 / 1 设置 / 2 退出 / 3 重新开始 / 4 词条
buttons = [];
if (hex_active()) {
    array_push(buttons, [0, "继续游戏", 110, 40, 0]);
    array_push(buttons, [-160, "设置", 110, 40, 0]);
} else {
    // 非海克斯模式第一排只有两个，保持原来的居中间距
    array_push(buttons, [75, "继续游戏", 110, 40, 0]);
    array_push(buttons, [-75, "设置", 110, 40, 0]);
}
array_push(buttons, [-75, "退出游戏", 110, 40, -50]);
array_push(buttons, [75, "重新开始", 110, 40, -50]);

// 海克斯模式专属：对局内查看当前已持有的词条（docs 5.5.1）
// 追加到第一排最右侧（第 3 个）
if (hex_active()) {
    array_push(buttons, [160, "词条", 110, 40, 0]);
}

// 当前选中的按钮索引
selected_button = -1;
submenu_open = false; // 是否有子菜单打开

// 按钮精灵帧
button_normal = 0; // 普通状态
button_hover = 1; // 悬停状态
button_pressed = 2; // 按下状态

panel_anim_init(id, 0.18, 0.22, 0, 3);
panel_anim_kids(id, []);
