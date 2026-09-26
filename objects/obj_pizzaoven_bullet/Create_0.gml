// 披萨炉子弹 Create 事件
damage = 0
move_speed = 8
damage_type = "pierce"
target_type = "pierce"
image_speed = 1

// 穿透相关 - 记录已击中的敌人，避免重复伤害
hitted_enemy = ds_list_create()
hittable_types = get_hittable_enemy_types(target_type)

// 三角形路径三个顶点
point0_x = 0
point0_y = 0
point1_x = 0
point1_y = 0
point2_x = 0
point2_y = 0

// 当前目标点索引（0->1->2->0，顺时针）
target_point = 1

// 已完成的循环次数，一圈后消失
laps_completed = 0

image_xscale = 1.8
image_yscale = 1.8
