event_inherited();
plant_id = "xiangshui_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_xiangshui_god;
else if (shape == 1)
    sprite_index = spr_xiangshui_god_1;
else if (shape == 2)
    sprite_index = spr_xiangshui_god_2;
else if (shape == 3)
    sprite_index = spr_xiangshui_god_3;

attack_anim = 0;
idle_anim = 12;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
buffer_type = "tracker";
buffer_type_2 = (shape >= 3) ? "tracker_advanced" : undefined;

// 追踪增幅统一由 tracker 分组承担（分类驱动），不再需要 xiangshui 第二类型。
buff_value = atk / 100;

if (shape < 3)
{
    buff_shape = "5x5";
}
else
{
    buff_shape = "5x7";
}

buff_stacking = (shape >= 3);
buff_max_stacks = 2;

buff_cells = build_buff_cells(grid_col, grid_row, buff_shape, buff_value);
buff_cells_refreshed = false;

ds_list_add(global.buff_sources, id);
global.buff_dirty = true;

xiangshui_effect_obj = instance_create_depth(x, y, 0, obj_xiangshui_god_effect);
xiangshui_effect_obj.parent_plant = id;
xiangshui_effect_obj.sprite_index = spr_xiangshui_god_effect_3;

// The shared range effect sprite is authored for the final 5x7 form.
// Match its display bounds to the actual buff shape for each upgrade.
var effect_width = 5;
var effect_height = (shape == 3) ? 7 : 5;
xiangshui_effect_obj.image_xscale = 1.8 * (effect_width / 5.0);
xiangshui_effect_obj.image_yscale = 1.8 * (effect_height / 7.0);
