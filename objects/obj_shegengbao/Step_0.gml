if (global.is_paused)
    exit;

event_inherited();

if (recycled)
    return;
recycled = true;

var col = grid_col;
var row = grid_row;

if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows)
{
    card_destroyed(id);
    instance_destroy();
    return;
}

var plant_list = ds_grid_get(global.grid_plants, col, row);
var targets = ds_list_create();

// 收集目标格内可回收的卡片（排除自身、玩家底座与不可回收卡片）
for (var i = 0; i < ds_list_size(plant_list); i++)
{
    var plant = ds_list_find_value(plant_list, i);
    if (plant == id) continue;
    if (!instance_exists(plant)) continue;
    if (variable_instance_exists(plant, "plant_id") && plant.plant_id == "player") continue;
    if (variable_instance_exists(plant, "can_shovel_remove") && !plant.can_shovel_remove) continue;
    ds_list_add(targets, plant);
}

// 回收目标卡片并按形态倍率返还其放置耗能
for (var i = 0; i < ds_list_size(targets); i++)
{
    var plant = ds_list_find_value(targets, i);
    if (!instance_exists(plant)) continue;
    if (!variable_instance_exists(plant, "plant_id")) continue;

    var _shape = variable_instance_exists(plant, "shape") ? plant.shape : 0;
    var _level = variable_instance_exists(plant, "current_level") ? plant.current_level : 0;
    var _skill = variable_instance_exists(plant, "skill") ? plant.skill : 0;

    var _data = get_plant_data_with_skill(plant.plant_id, _shape, _level, _skill);
    var _cost = 0;
    if (_data != undefined && ds_exists(_data, ds_type_map) && ds_map_exists(_data, "cost"))
        _cost = _data[? "cost"];

    if (_cost > 0)
    {
        var flame_inst = instance_create_depth(plant.x, plant.y - 30, -2000, obj_flame);
        flame_inst.value = round(_cost * refund_multiplier);
    }

    card_destroyed(plant);
    instance_destroy(plant);
}

ds_list_destroy(targets);

var _world = get_world_position_from_grid(col, row);
if (global.grid_terrains[row][col].type == "normal")
{
    instance_create_depth(_world.x, _world.y, -2, obj_place_effect);
    audio_play_sound(snd_place2, 1, false);
}
else if (global.grid_terrains[row][col].type == "water")
{
    var _inst = instance_create_depth(_world.x, _world.y + 20, -2500, obj_place_effect);
    _inst.sprite_index = spr_enter_water_effect;
    audio_play_sound(snd_enter_water, 0, 0);
}

card_destroyed(id);
instance_destroy();