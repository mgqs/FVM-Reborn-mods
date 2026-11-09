// obj_plant_preview CREATE 事件
preview_sprite = spr_small_fire; // 默认精灵
parent_slot = noone; // 父卡槽对象
is_valid = false;    // 是否在可种植区域
card_id = ""
preview_shape = 0;   // 这张卡当前的转职形态（Step_2 每帧写；Draw_0 判百变蛇二转用）
logical_base_x = 0;
logical_base_y = 0;
platform_shift_x = 0;
platform_shift_y = 0;

// 设置深度
depth = -9999999; // 确保在顶层显示