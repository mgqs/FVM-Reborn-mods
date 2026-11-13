damage = 0;
move_speed = 0;
row = 0;
damage_type = "pierce";
target_type = "normal";
timer = 0;
target_row = -1;
start_y = 0;
target_y_calculated = false;
fire_chance = 0;
shape = 0;
hitted_enemy = ds_list_create();
brazier_list = ds_list_create();
burnt = 0;
bounced = false;
image_xscale = 1.6;
image_yscale = 1.6;
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;
ash_kill = false;
sanwei_stack = 1;
burn_bonus = false;

// ── 地火（2026-11-13）：每发子弹首次命中时，在本行命中格往右铺地面火焰 ──
//   格数：0 = 按 shape 自动（0 转 3 格 / 1·2·3 转 5 格）；>0 = 用这里手填的值
ground_fire_cells  = 0;
ground_fire_damage = 700;    // 格内每只敌人整段只吃一次
ground_fire_life   = 30;     // 0.5 秒（60 帧 = 1 秒）
ground_fire_done   = false;  // 一发只铺一次（穿透烧到后面几只时不重复铺）

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = true;      // 可被火盆 / 火神 / 金牛 / 能量喵 / 融合火盆 点燃
hazard_rebound = true;   // 可被樱桃布丁 / 布丁汪 / 水神 反弹
fire_mult = 1;           // 对象池会复用实例：不重置就会带着上一发的过火倍率出生，导致这一发点不着
