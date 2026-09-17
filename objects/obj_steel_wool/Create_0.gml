// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "steel_wool"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
sprite_index = spr_steel_wool;

// ========== 特定属性默认值 ==========

attack_anim = 6;
idle_anim = 6

invincible = true

flash_speed = 10
plant_type = "normal"
feature_type = "water"
is_slowdown = false

target_enemy = []
enemy_encounted = false
enemy_hitted = false
