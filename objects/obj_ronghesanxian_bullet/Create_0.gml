damage = 0
move_speed = 0
row = 0
damage_type = "normal"
target_type = "normal"
timer = 0
target_row = 0
start_y = 0
target_y_calculated = false
burnt = 0
bounced = false
brazier_list = ds_list_create()
image_speed = 0
image_xscale = 1.5;
image_yscale = 1.5;
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;
// 融合三线专属：
//   pierce_all  —— 灵魂融合（2 转）子弹可穿透全部老鼠与障碍（无数量上限）
//   hited_enemy —— 穿透时记录已结算过的敌人，避免同一只被逐帧反复结算
//                  （只在子弹自己身上记账，池化复用跑 Create 会天然复位）
//   burn_damage —— 本卡当前星级的[燃烧伤害]，命中时按 30% 概率写入燃烧控制器
pierce_all = false;
hited_enemy = ds_list_create();
burn_damage = 0;
burn_chance = 30;

// 🔴 对象池复用必须重置内置显示变量（踩过：有时一出膛就是「反向子弹」）
// 子弹走对象池：instance_create_depth 被 scripts/src_hook_function 接管 → obj_pool_acquire
// （obj_pool_is_poolable 只要对象名含 "bullet" 就为真），复用走 instance_change(obj, true)
// —— instance_change **不会**重置 image_angle / image_alpha / image_blend / image_index，
// 且 obj_pool_acquire 里的清零只对「敌人白名单」生效、不含子弹。
// 于是：被水神 / 反弹布丁反弹过的子弹（Collision_obj_water_god / _cherry_pudding 里
// image_angle += 180）一旦被回收复用，image_angle = 180 会原样带进新子弹 → 新子弹画出来是
// 掉头的。Create 在每次复用都会重跑，所以在这里清零即可。
image_angle = 0;
image_index = 0;
image_alpha = 1;
image_blend = c_white;
