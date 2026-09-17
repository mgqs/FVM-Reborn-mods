// obj_quit_confirm - Create Event
bg = spr_battle_escape_menu;
width = sprite_get_width(bg);
height = sprite_get_height(bg);

// 按钮定义
buttons = [
    [-80, "确定", 110, 40],
    [80, "取消", 110, 40]
];

selected_button = -1;

// 定位到屏幕中心
x = room_width / 2;
y = room_height / 2;