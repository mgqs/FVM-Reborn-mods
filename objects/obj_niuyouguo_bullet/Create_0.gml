// obj_niuyouguo_bullet（牛油果飞镖）Create 事件
// 三形态共用一套逻辑，精灵由卡片的 shape 决定（Step 里按 sprite 保持不动）
// 穿透弹：命中老鼠 / 障碍都不销毁，靠 hited_enemy 记账保证同一只只结算一次
damage = 0
move_speed = 0
travel_dir = 0        // 飞行角度：0 = 正右（朝老鼠来向），±fan_angle = 扇形上下
row = 0
damage_type = "normal"
target_type = "pierce_air"   // 与卡片同口径：normal + air + obstacle（无 dance/invisible）
hittable_types = get_hittable_enemy_types(target_type)
timer = 0
life = 160
hit_tick = 0
pierce_all = true
hited_enemy = ds_list_create()
slow_timer = 0
bounced = false       // 一次飞行只反弹一次（父类 Collision_obj_rebound_source）

// 飞镖 7 帧素材里 1~6 是旋转循环（第 7 帧 = 第 1 帧），由 Step 按 timer 自己推
image_speed = 0
image_xscale = 1.4;
image_yscale = 1.4;

// 🔴 对象池复用必须复位内置显示变量（踩过：被水神 / 反弹布丁弹过的子弹复用后会掉头）
image_angle = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_rebound = { axis:"travel_dir", angle180:false };   // 牛油果飞镖：角度镜像
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
