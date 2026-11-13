// 终转（至尊炎帝）追加弹：7.5 / 8.5 列 0 行向下飞的竖向陨焰。
// 生成方（obj_shennong_god/Step_0.gml）会给每发弹指定 col_left 与 col_hits：
//   7.5 列的弹 → col_left = 6（0 基），与下一列各受击 1 次；
//   8.5 列的弹 → col_left = 7（0 基），与下一列各受击 1 次；
// 两发叠加后第 7/8/9 列分别受击 1/2/1 次，与数据表一致。
// 该弹纵向飞行跨行，不维护 grid_row，命中只按「敌人所在列」判定。

damage = 0;
move_speed = 0;
damage_type = "pierce";
target_type = "all";
shape = 3;
ash_kill = true;

// 同一只敌人可能被同一发弹命中多次，所以用 ds_map 记「该敌人已吃了几次」，
// 而不是 ds_list 去重。
hit_counts = ds_map_create();
hittable_types = get_hittable_enemy_types(target_type);
hit_tick = 0;

// 覆盖的起始列（0 基）与逐列受击次数上限。
col_left = 6;
col_hits = [1, 1];

// 行不作约束；row 给个合法值，兼容父对象字段。
row = 0;

image_xscale = 1.5;
image_yscale = 1.5;
image_angle = -90;   // sprite 朝右，转 -90° 变朝下
image_speed = 1;
