// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "guangming_god";
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_light_god
}
else if shape == 1{
	sprite_index = spr_light_god_1
}
else if shape == 2{
	sprite_index = spr_light_god_2
}
else if shape == 3{
	sprite_index = spr_light_god_3
}
// ========== 特定属性默认值 ==========

attack_anim = 21;
idle_anim = 12
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_type = "d_fruit"
if shape >= 1{
	target_type = "all"
}
if shape == 3
{
    var eff = instance_create_depth(x-291, y-455, 0, obj_light_area_e_1);
    // 绑定当前卡片实例
    eff.parent_inst = id;
}else{
    var eff = instance_create_depth(x-291, y-338, 0, obj_light_area_e);
    // 绑定当前卡片实例
    eff.parent_inst = id;
}
anim_timer = 0
awake_anim = 0
wake_timer = 0
can_mouse_list = ["can_mouse"]
exploded = false
explode_cooldown = 0;
