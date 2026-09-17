// 在父对象中添加升级方法
// obj_plant_parent 的自定义方法

/// @function plant_upgrade(new_level)
/// @param new_level 要升级到的等级
function card_upgrade(new_level) {
    var upgrade_data = get_plant_upgrade(plant_id, 0,new_level);
    if (upgrade_data == undefined) return false;
    
    // 应用升级属性
    hp = upgrade_data.hp;
    cost = upgrade_data.cost;
    atk = upgrade_data.atk;
    range = upgrade_data.range;
    cooldown = upgrade_data.cooldown;
    cycle = upgrade_data.cycle;
    
    current_level = new_level;
    
    // 调用升级事件
    event_user(2);  // 用户事件2用于升级处理
    return true;
}