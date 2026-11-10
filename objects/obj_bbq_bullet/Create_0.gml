// obj_bbq_bullet（街头烤肉大师的串串子弹）Create 事件
// 直线向右、全程穿透（同一条老鼠只吃一次），可吃火盆 / 融合火盆 / 火神 / 金牛的过火增幅。
// 池复用：显示变量一律在 Create 清零（父对象 Draw 会按 visual_scale 画，别留上一条子弹的缩放）。
event_inherited();
can_dandantu_store = true;

sprite_index = spr_bbq_bullet;
image_speed = 0;
image_index = 0;
image_angle = 0;
image_alpha = 1;
image_blend = c_white;
image_xscale = 1.6;
image_yscale = 1.6;

damage = 0;
// 速度：3 格/秒 = 107*3/60 ≈ 5.35 px/帧；过火后 4.5 格/秒 ≈ 8.02（2026-10-31 固定攻击改版）
move_speed = 5.35;
burnt_speed = 8.02;
move_dir = 1;            // 1 = 向右飞；被布丁 / 水神反弹后变 -1
start_x = 0;             // 出膛点（由 obj_bbq 传：猫左侧 x-40）
end_x = 2200;            // 向右飞的销毁点：第 11 格右沿（出图 2 格，由 obj_bbq 传）
end_x_left = -200;       // 只给**被反弹**的串串用：第 1 格左沿外 1 格（由 obj_bbq 传）
bounced = false;
row = 0;
burn_shot = false;
damage_type = "pierce";     // 穿透（2026-11-10 用户口径：改回 pierce —— 全程穿透的串串必须能穿地形障碍，
                            //   障碍物 Step 的放行条件只认 damage_type=="pierce" / pierce_all / pierce_obstacle。
                            //   ⚠️ 连带效果（已知并接受）：打带护盾的老鼠会「破盾 + 直接掉血」；
                            //   蛋蛋兔不再储存这颗子弹的伤害。target_type 仍是 normal，可攻击类型不变。）
target_type = "normal";

// 过火相关状态（父类统一事件 bullet_hazard_fire 按这几个字段判定）
kind = "fire";
burnt = 0;
can_burn = true;
brazier_list = ds_list_create();

hitted = ds_list_create();
hittable_types = get_hittable_enemy_types(target_type);
max_life = 300;
life = 0;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = { scale:0 };   // 爆辣烤串：尺寸自己 Step 里处理；按角度反射
hazard_rebound = { axis:"move_dir", judge:"none" };   // 爆辣烤串：尺寸自己 Step 里处理；按角度反射
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
