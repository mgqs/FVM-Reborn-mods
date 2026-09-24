// 黯然销魂饭 - 复活技能
// 0形态：复活3*3范围内1个死亡的美食
// 1形态：复活3*3范围内1个死亡的美食（耗能降低）
// 2形态：复活3*3范围内2个死亡的美食

var revive_count = 1;
if (shape >= 2)
    revive_count = 2;

var _range = revive_range;
var _col = grid_col;
var _row = grid_row;

// 检查死亡卡片列表是否存在
if (!variable_global_exists("dead_cards"))
{
    global.dead_cards = ds_list_create();
    exit;
}

// 从后往前遍历死亡列表（最近死亡的优先），找到范围内可复活的卡片
var revived = 0;
for (var i = ds_list_size(global.dead_cards) - 1; i >= 0 && revived < revive_count; i--)
{
    var dead_info = global.dead_cards[| i];
    var dead_col = dead_info[? "grid_col"];
    var dead_row = dead_info[? "grid_row"];
    
    // 检查是否在3*3范围内
    if (abs(dead_col - _col) > _range || abs(dead_row - _row) > _range)
        continue;
    
    // 检查该位置是否已经有存活的卡片了
    var plant_list = ds_grid_get(global.grid_plants, dead_col, dead_row);
    var has_plant = false;
    for (var j = 0; j < ds_list_size(plant_list); j++)
    {
        var p = plant_list[| j];
        if (instance_exists(p) && p.hp > 0)
        {
            has_plant = true;
            break;
        }
    }
    
    if (has_plant)
        continue;
    
    var _plant_id = dead_info[? "plant_id"];
    var _shape = dead_info[? "shape"];
    var _level = dead_info[? "level"];
    var _skill = dead_info[? "skill"];
    
    // 获取卡片对象
    var card_data = deck_get_card_data(_plant_id, _shape);
    if (card_data == noone)
        continue;
    
    var card_obj = card_data[? "obj"];
    var grid_pos = get_world_position_from_grid(dead_col, dead_row);
    
    // 创建新的卡片实例
    var new_plant = instance_create_depth(grid_pos.x, grid_pos.y, 0, card_obj);
    
    // 设置等级、技能和形态
    new_plant.current_level = _level;
    new_plant.skill = _skill;
    new_plant.shape = _shape;
    
    // 重新调用用户事件0，确保属性和精灵正确初始化
    with (new_plant) event_user(0);
    
    // 重新计算深度并注册到网格
    var depth_value = calculate_plant_depth(dead_col, dead_row, new_plant.plant_type);
    card_created(new_plant, dead_col, dead_row);
    new_plant.depth = depth_value;
    
    // 重置攻击计时器
    new_plant.attack_timer = 0;
    new_plant.state = 0;
    
    // 复活特效
    instance_create_depth(grid_pos.x, grid_pos.y - 20, depth - 100, obj_card_heal_effect);
    
    // 从死亡列表中移除
    ds_map_destroy(dead_info);
    ds_list_delete(global.dead_cards, i);
    
    revived++;
}
