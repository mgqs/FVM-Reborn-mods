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

// 投手增幅（thrower 档 + 整行，同类取最高）
buffer_type = "thrower";
buff_stacking = false;
buff_max_stacks = 1;

// 增幅倍率 → 注册表 custom["投掷增幅"]（2026-11-07 从 cycle 迁出，同 obj_mianbao 的 灼烧伤害）
//   🔴 原来借本卡 cycle（攻击间隔）存、运行时 ÷6000 还原：cycle 是**正式数值字段**，
//      海克斯攻速词条会乘它 → 一改就把增幅倍率改坏；面板/情报岛读出来还是「攻击间隔 130 秒」。
//      注册表里本卡 cycle 已归还成 0（本体不攻击，它什么都不该装）。
//   数值口径：0/1 转 1.3~4.1；2 转整体 ×1.15（= 1.495~4.715，对应「二转威力提高15%」）。
//   **平射增幅就是 atk 本身**（2026-11-10 起：0/1 转 2.2~4.3，2 转 2.53~4.945），
//      不再存「220 这种百分数再 /100」——父类事件统一按 other.atk * fire_mult_scale（=1）取。两套增幅互不影响。
//   custom 值按星级已经写进升级表（mod_register_plant_lite / add_plant_upgrade_lite），直接读即可。
//   关卡里星级不会再变（升星会重建卡片），所以只在 Create 取一次，Step 里直接用 throw_buff_value。
var _nl_info = get_plant_data_with_skill("nengliangmiao", shape, clamp(current_level, 0, 16),
	variable_instance_exists(id, "skill") ? skill : 0);
throw_buff_value = 1;
if (_nl_info != undefined && ds_map_exists(_nl_info, "投掷增幅")){
	throw_buff_value = _nl_info[? "投掷增幅"];
}
buff_value = throw_buff_value;
// 记一份当前状态：星级 / 技能 / 形态**可能在建实例之后才写入**（升星、转职、换技能），
//   Step 里靠这三个值判断要不要重取一次倍率（同 obj_mianbao 的写法）
_nl_lv = current_level;
_nl_sk = variable_instance_exists(id, "skill") ? skill : 0;
_nl_sh = shape;
buff_shape = "row";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;

global.buff_dirty = true;
