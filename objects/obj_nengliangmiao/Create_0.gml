// obj_nengliangmiao（能量喵）Create 事件：0转 能量喵 / 1转 蓝焰 / 2转 樱红
// 本体不攻击，只维护「整行投手增幅」网格；平射增幅在子弹侧碰撞里做（同火盆/金牛，5 行内联）
event_inherited();
plant_id = "nengliangmiao";
obj_type = object_index;
event_user(0);

if (shape == 0) sprite_index = spr_nengliangmiao;
else if (shape == 1) sprite_index = spr_nengliangmiao_1;
else sprite_index = spr_nengliangmiao_2;

// 11 帧全部是待机（没有攻击动作）
idle_anim = 10;
attack_anim = 0;
flash_speed = 5;
plant_type = "normal";
feature_type = "normal";
is_slowdown = false;
state = CARD_STATE.IDLE;

// 投手增幅（thrower 档 + 整行，同类取最高）：倍率借本卡 cycle 字段存（×100）—— 本体不攻击，cycle 本来空着
buffer_type = "thrower";
buff_stacking = false;
buff_max_stacks = 1;

buff_value = (variable_instance_exists(id, "base_cycle") ? base_cycle : cycle) / 60 / 100;
buff_shape = "row";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;

global.buff_dirty = true;
