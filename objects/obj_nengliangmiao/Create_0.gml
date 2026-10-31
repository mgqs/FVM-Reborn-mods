// obj_nengliangmiao（能量喵）Create 事件：0转 能量喵 / 1转 蓝焰 / 2转 樱红
// 本体不攻击，只维护「整行投手增幅」网格；平射增幅在子弹侧碰撞里做（nengliangmiao_pass_fire）
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

// 投手增幅（thrower 档 + 整行）：同类增幅取最高、不叠乘
buffer_type = "thrower";
buff_stacking = false;
buff_max_stacks = 1;

buff_value = nengliangmiao_thrower_mult(current_level, shape);
buff_shape = "row";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;

global.buff_dirty = true;
