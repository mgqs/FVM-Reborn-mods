bg = spr_battle_escape_menu
width = sprite_get_width(bg)
height = sprite_get_height(bg)

// 按钮定义：[x偏移, 文字, 点击宽度, 点击高度]
buttons = [
    [-110, "最大", 70, 32],
    [0, "确定", 70, 32],
    [110, "取消", 70, 32]
]

selected_button = -1
sell_material_id = ""
sell_material_name = ""
sell_material_icon = 0
sell_material_spr = spr_craft_material
max_amount = 0
unit_price = 0
input_quantity = 1
cursor_blink = 0

// 布局参数（便于统一维护）
layout_title_y = -105        // 标题 Y 偏移
layout_icon_x = -170         // 材料图标 X 偏移
layout_icon_y = -25          // 材料图标 Y 偏移
layout_icon_scale = 0.85     // 材料图标缩放
layout_text_x = -100         // 文字起始 X 偏移
layout_name_y = -45          // 材料名称 Y 偏移
layout_amount_y = -15        // 持有数量 Y 偏移
layout_price_y = 15          // 单价 Y 偏移
layout_qty_label_y = 25      // "出售数量"标签 Y 偏移
layout_input_y = 52          // 输入框 Y 偏移
layout_input_w = 160         // 输入框宽度
layout_input_h = 36          // 输入框高度
layout_total_y = 90          // 总计金额 Y 偏移
layout_btn_y = 120           // 按钮 Y 偏移

x = room_width / 2
y = room_height / 2

keyboard_string = "1"
keyboard_lastchar = ""
