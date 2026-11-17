damage = 0;
move_speed = 0;
row = 0;
damage_type = "pierce";
target_type = "all";
timer = 0;
shape = 0;
hitted_enemy = ds_list_create();
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;
ash_kill = false;
image_xscale = 1.5;
image_yscale = 1.5;

// 🔴 对象池复用必须重置朝向：子弹走对象池（`scripts/src_hook_function` 把
// instance_create_depth 接到 obj_pool_acquire，名字含 "bullet" 就池化），
// 复用走 instance_change(obj, true) 会重跑本 Create，但**不会**替我们清掉上一个宿主留下的
// image_angle。终转中路那发是从右往左飞、Create 之后由 Other_11 写成 180°，
// 若这里不归零，它被回收后同一张精灵的下一次复用会带着 180° 出生（贴图倒挂）。
// 参考同样处理过的 `objects/obj_ronghesanxian_bullet/Create_0.gml`。
image_angle = 0;
image_alpha = 1;
image_blend = c_white;

// 终转（shape 3）专用：按行记录「该行受击次数」。
// 空数组 = 不走倍率表（改看 cover 或 row）。
// 非空时命中任意 row_hits[r] > 0 的行，伤害 = damage × row_hits[r]，
// 用来实现「上中下 5 行分别受击 1/2/3/2/1 次」。
row_hits = [];

// 缝隙制（shape 0/1/2，2026-11-17 用户口径）：子弹夹在**两行之间**飞行，
//   cover_a / cover_b = 上下两个被覆盖的行号，两行的敌人都吃这一发。
//   -1 = 不启用（终转 / 天邪池按行铺的复刻弹 / 其它调用点）。
// 与炎凰马 obj_zodiac_projectile 的 cover_a/cover_b 同口径。
// 判定**只看行号 + 水平距离**，不看 bbox —— 子弹中心在两行交界，
//   几何上跟任何一行的老鼠都不相交（纯 bbox 判定会一发都打不中）。
cover_a = -1;
cover_b = -1;
