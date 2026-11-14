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
// 空数组 = 旧行为（只命中 row 这一行，伤害 ×1）。
// 非空时命中任意 row_hits[r] > 0 的行，伤害 = damage × row_hits[r]，
// 用来实现「上中下 5 行分别受击 1/2/3/2/1 次」。
row_hits = [];
