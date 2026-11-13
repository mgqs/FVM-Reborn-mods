// obj_yuansushe_bullet（元素蛇子弹）Create 事件
// 直线穿透弹：沿本行往右飞，飞出地图右沿消散；被布丁 / 烤盘这类反弹源弹回后往左飞。
//   · 「可过障碍」= 本对象不做任何屏障碰撞，只按 global.enemy_by_type 的白名单逐只判包围盒；
//   · 「可反弹」= 声明 hazard_rebound（父对象 obj_bullet_parent 的 Collision_obj_rebound_source
//     会调 bullet_hazard_rebound，字段名必须对齐：move_speed / row / damage / hitted）；
//   · 「不受火盆类影响」= **不声明 hazard_fire**，父对象的 Collision_obj_fire_source 走进去直接
//     返回 false，火焰倍率与冰弹掉效果都不会发生（官方：冰弹不会失去减速）。
event_inherited();

image_speed = 1;

row          = 0;
ys_color     = 0;
damage       = 0;
move_speed   = 9;
ys_end_col   = global.grid_cols + 1;
ys_delay     = 0;

// 反弹：默认参数（axis = move_speed 翻转、judge = row 只认同行源卡、回程清空命中表）
//   angle180 关掉：翻转用 visual_scale_x 做左右镜像，比整体旋转 180° 好看（见 Step）
hazard_rebound = { angle180: false };

ys_pin_chance    = 0;
ys_pin_ticks     = 90;
ys_poison_chance = 0;
ys_poison_damage = 300;
ys_freeze_chance = 0;
ys_freeze_ticks  = 120;
ys_slow_ticks    = 240;
ys_crit_chance   = 0;
ys_crit_mult     = 2;

// 穿透类命中白名单（同 can_target_on 的 pierce 分支：普通 / 非主流 / 障碍 / 未显形幽灵）
ys_hittable = ["normal", "dance", "obstacle", "invisible"];

// 名字必须叫 hitted：bullet_hazard_rebound 的 reset_hits 只清这几个约定名，
// 叫别的名字 → 弹回来的子弹打不到已经打过的老鼠
hitted = ds_list_create();

// 毒气对象用工程现成的 obj_ronghedan_god_poison_effect（自带「延迟 10 帧 → 一格范围一次性伤害」
//   的结算逻辑），这里只换精灵与参数，不另建一套。
ys_poison_obj = obj_ronghedan_god_poison_effect;

// 父对象 Draw_0 按 visual_scale_* 画（image_xscale 在父 Create 里已经被置回 1），
//   所以放大要写这两个，不要只改 image_xscale。
visual_scale_x = 1.3;
visual_scale_y = 1.3;
image_xscale = 1;
image_yscale = 1;
