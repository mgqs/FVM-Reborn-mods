event_inherited();
plant_id = "fengrao_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_fengrao_god;
else if (shape == 1)
    sprite_index = spr_fengrao_god_1;
else if (shape == 2)
    sprite_index = spr_fengrao_god_2;
else if (shape == 3)
    sprite_index = spr_fengrao_god_3;

attack_anim = 0;
idle_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;

buffer_type = "multi_dir";

// 五向增幅只对应「多向类」（分类驱动），不再挂载 multi_dir 第二类型。
// 终转（shape 3）可叠加：多张丰饶神覆盖同一格时倍率累加，
//   上限 3 层 = 原有加成倍率的 3 倍（2026-11-13 用户口径，情报岛文案同步改为 3 倍）。
buff_stacking = (shape >= 3);
buff_max_stacks = (shape >= 3) ? 3 : 2;

buff_value = atk / 100;
buff_shape = "5x5";
buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;

global.buff_dirty = true;

var eff_spr = spr_fengrao_god_effect;
if (shape == 1)
    eff_spr = spr_fengrao_god_effect_1;
else if (shape == 2)
    eff_spr = spr_fengrao_god_effect_2;
else if (shape == 3)
    eff_spr = spr_fengrao_god_effect_3;

fengrao_effect_obj = instance_create_depth(x, y, 0, obj_fengrao_god_effect);
fengrao_effect_obj.parent_plant = id;
fengrao_effect_obj.sprite_index = eff_spr;
