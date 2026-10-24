// obj_ronghekafei_bullet（融合咖啡杯子弹）Create 事件
// 7 帧素材：0~3 出膛喷溅（在炮口原地播一遍）、4~6 飞行中的子弹（循环）
// 0转 命中即销毁并生成原版咖啡命中特效；1转 / 2转 穿透老鼠与障碍，靠 hited_enemy 记账保证同一只只结算一次
damage = 0
move_speed = 0
pierce_all = false
row = 0
damage_type = "normal"
target_type = "normal"
hittable_types = get_hittable_enemy_types(target_type)
timer = 0
hit_tick = 0
life = 400
hited_enemy = ds_list_create()

// 先出膛喷溅、后飞行
phase = 0
phase_timer = 0

image_speed = 0
image_xscale = 1.5
image_yscale = 1.5

// 🔴 对象池复用必须复位内置显示变量（踩过：被水神 / 反弹布丁弹过的子弹复用后会掉头）
image_angle = 0
image_index = 0
image_alpha = 1
image_blend = c_white
