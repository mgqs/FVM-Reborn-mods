image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

state = "start"
target_col = -1
target_row = -1
b_shape = 0
target_enemy = noone

damage = 70
timer = 0

function find_priority_enemy() {
    var closest_left_enemy = noone;
    var min_x = room_width; // 初始化为房间宽度
    var max_hp = 0;
    
    // 检查右边一格内是否有敌人（假设一格为80像素）
    with (obj_enemy_parent) {
        if (hp > 0 && can_hit("track",target_type) && y > 0) { // 只考虑存活的敌人
			
            // 同时寻找最左侧且最大生命值最高的敌人
            if (maxhp > max_hp || (x < min_x && maxhp == max_hp)) {
                min_x = x;
                max_hp = maxhp;
                closest_left_enemy = id;
            }
        }
    }
    return closest_left_enemy;
}