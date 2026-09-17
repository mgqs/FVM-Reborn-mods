image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

// obj_shovel_slot CREATE 事件
is_selected = false;        // 铲子是否被选中
is_ready = true;            // 铲子总是可用
description = "铲子:移除植物";
flame_rate = 0 //回收比例
hotkey_pressed = false

// 铲子精灵
if global.save_data.unlocked_items.shovel == "normal"{
	shovel_spr = spr_shovel;
}
else if global.save_data.unlocked_items.shovel == "copper"{
	shovel_spr = spr_copper_shovel;
	flame_rate = 0.1
}
else if global.save_data.unlocked_items.shovel == "silver"{
	shovel_spr = spr_silver_shovel;
	flame_rate = 0.25
}
else if global.save_data.unlocked_items.shovel == "gold"{
	shovel_spr = spr_gold_shovel;
	flame_rate = 0.5
}
else{
	shovel_spr = spr_shovel;
}

hotkey = "`";               // 快捷键
var slot_length = deck_slot_count()
if slot_length <= 14{
	image_index = 0
}
else{
	image_index = 1
}
// 位置和大小
slot_width = 84;
slot_height = 105;
x_offset = 0;
y_offset = 0;
mx = 0
my = 0
depth = -1200
